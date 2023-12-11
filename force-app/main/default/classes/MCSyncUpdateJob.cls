/* Updates Contact MC Sync Field per country
operation - TRUE or FALSE 
TRUE - query all records with Sync = False then update to TRUE
FALSE - query all records with Sync = TRUE then update to FALSE
recordType - Adult or Child */
global class MCSyncUpdateJob implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    String country;
    String recordType;
    Boolean operation; 
    Integer limitValue;
    String countrySyncField;
    Set<Id> updatedIdSet = new Set<Id>();
    Map<String, String> countrySyncFieldMap = new Map<String, String>{
        'ANZ' => 'MC_Sync_Eligibility_ANZ__c',
            'ID' => 'MC_Sync_Eligibility_ID__c',
            'IN' => 'MC_Sync_Eligibility_IN__c',
            'MY' => 'MC_Sync_Eligibility_MY__c',
            'PH' => 'MC_Sync_Eligibility_PH__c',
            'SG' => 'MC_Sync_Eligibility_SG__c',
            'TH' => 'MC_Sync_Eligibility_TH__c',
            'VN' => 'MC_Sync_Eligibility_VN__c'
            };
    
    global MCSyncUpdateJob (String countryInput, String recordTypeInput, Boolean operationInput, Integer limitValueInput){
        country = countryInput;
        recordType = recordTypeInput;
        operation = operationInput;
        limitValue = limitValueInput;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String contactRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        String whereString = '';
        String query = 'SELECT Id, ' +countrySyncFieldMap.get(country)
            + ' FROM Contact ';
        if(String.isNotBlank(country)){
            countrySyncField = countrySyncFieldMap.get(country);
            whereString += ' Market__c = \'' +country+ '\'';
            whereString += ' AND ';
            whereString += countrySyncFieldMap.get(country) + ' = ' + !operation;
        }
        if(String.isNotBlank(recordType)){
            whereString += String.isNotBlank(whereString) ? ' AND' : '';
            whereString += ' RecordtypeId = \'' +contactRectypeId+ '\'';
        }
        if(String.isNotBlank(whereString)){
            query += ' WHERE ' +whereString;
        }
        query += ' ORDER BY CreatedDate ';
        if(limitValue != null && limitValue > 0){
            query += ' LIMIT ' + limitValue;
        }
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> conUpdateList = new List<Contact>();
        if(!scope.isEmpty()){
            for(Contact c : scope){
                c.put(countrySyncField, operation);
                conUpdateList.add(c);
                updatedIdSet.add(c.Id);
            }
        }
        update conUpdateList;
    }
    
    global void finish(Database.BatchableContext BC) {
        Id cvId = generateCSVfile(updatedIdSet);
        if(cvId != null){
            sendEmail(cvId, updatedIdSet.size());
        }
    }
    
    global void execute(SchedulableContext sc) {
        MCSyncUpdateJob batch = new MCSyncUpdateJob(country, recordType, operation, limitValue); 
        Database.executebatch(batch, 200);
    }
    
    public Id generateCSVfile(Set<Id> recSet) {
        Id contentVersionId;
        if(!recSet.isEmpty()){
            String generatedCSVFile ='';
            generatedCSVFile = genereateHeader().removeEnd(',') + '\n';
            String fileRow = '';
            for(Id recId : recSet){
                fileRow = '';
                fileRow = recId;
                generatedCSVFile = generatedCSVFile + fileRow.replace('null', '') + '\n';
            }
            generatedCSVFile = '\uFEFF' + generatedCSVFile.removeEnd('\n');
            Datetime now = Datetime.now(); 
            Integer offset = UserInfo.getTimezone().getOffset(now); 
            Datetime local = now.addSeconds(offset/1000);
            
            contentVersionId = uploadFile(generatedCSVFile, 'MCSyncUpdateJob_'+ local , '.csv');
        }
        return contentVersionId;
    }
    
    public String genereateHeader() {
        List<String> headerArray = new List<String>();
        headerArray.add('Id');
        return string.join(headerArray, ',');
    }
    
    public Id uploadFile(String fileContent, String fileName, String fileType) {   
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = fileName + fileType; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = blob.valueOf(fileContent); // converting your binary string to Blog
        insert conVer;
        
        conVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id LIMIT 1];
        
        String libraryName = 'MCSyncUpdateJob';
        if(System.Test.isRunningTest()) { 
            libraryName = 'sfdc_asset_company_assets';
        }
        ContentWorkspace ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE DeveloperName =: libraryName LIMIT 1];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conVer.ContentDocumentId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        cdl.LinkedEntityId  = ws.Id;
        insert cdl;
        
        return conVer.Id;
    }
    
    public void sendEmail (Id cvId, Integer recSize) {
        
        List<String> recip = Label.MCSyncJobEmailRecipient.split(',');
        if(!recip.contains(UserInfo.getUserEmail()) ){
            recip.add(UserInfo.getUserEmail());
        }
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
        for(ContentVersion cv : [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE Id =: cvId]){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(cv.VersionData);
            attachment.setFileName(cv.Title + '.csv');
            fileAttachments.add(attachment);
        }
        
        String body;
        body = 'Please find the summary of updated Contacts for MC Sync Update Job on '+ String.valueOf(Datetime.now()) + '.\n';
        body += 'Total number of successfully updated records: ' + recSize + '.\n';
        
        if(!recip.isEmpty()){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject(String.valueOf(Date.today()) + ' Updated Contacts for MC Sync Report');
            semail.setToAddresses(recip);
            semail.setPlainTextBody(body);
            if(!fileAttachments.isEmpty()) semail.setFileAttachments(fileAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        }
    }
}