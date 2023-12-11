global class DeleteRecordsBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    String objectAPIName; 
    Integer olderThanDays;
    String fieldName;
    String fieldValue;
    Map<String,String> fieldFilterMap = new Map<String,String>();
    Integer limitValue;
    Integer batchSize = 20;
    Set<Id> deleteSuccessSet = new Set<Id>();
    Map<Id, String> deleteErrorMap = new Map<Id, String>();
    private Id contentVersionId;
    
    global DeleteRecordsBatch(String objectAPINameInput, Integer olderThanDaysInput, Map<String,String> fieldFilterMapInput, Integer limitInput, Integer batchSizeInput){
        if(String.isNotBlank(objectAPINameInput)) objectAPIName = objectAPINameInput;
        if(olderThanDaysInput != null) olderThanDays = olderThanDaysInput;
        if(fieldFilterMapInput != null && !fieldFilterMapInput.keySet().isEmpty()) fieldFilterMap = fieldFilterMapInput; //fieldName-fieldValue map
        if(limitInput != null && limitInput > 0) limitValue = limitInput;
        if(batchSizeInput != null && batchSizeInput > 0) batchSize = batchSizeInput;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryStr;
        String queryStrWhere;
        if(String.isNotBlank(objectAPIName) && doesObjectExist(objectAPIName)){
            queryStr = 'SELECT Id'
                + ' FROM ' + objectAPIName;
            //WHERE Conditions
            if(olderThanDays != null || (String.isNotBlank(fieldName) && doesFieldExist(objectAPIName, fieldName)) ){
                queryStr += ' WHERE';
                if(olderThanDays != null) {
                    DateTime setDate = Date.today().addDays(-olderThanDays);
                    String formatSetDate = setDate.format('yyyy-MM-dd');
                    queryStrWhere = ' DAY_ONLY(CreatedDate) <= ' + formatSetDate;
                }
                if(!fieldFilterMap.keySet().isEmpty()){
                    for(String fieldName : fieldFilterMap.keySet()){
                        if(doesFieldExist(objectAPIName, fieldName) && String.isNotBlank(fieldFilterMap.get(fieldName))){
                            if(String.isNotBlank(queryStrWhere)){
                                queryStrWhere += ' AND ' + fieldName + ' = \'' + fieldFilterMap.get(fieldName) + '\'';
                            }
                            else{
                                queryStrWhere = fieldName + ' = \'' + fieldFilterMap.get(fieldName) + '\'';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(queryStrWhere)){
                queryStr += queryStrWhere;
            }
            if(limitValue != null){
                queryStr += ' LIMIT ' + limitValue;
            }
        }
        else{
            queryStr = 'SELECT Id FROM VN_contact_manual__c LIMIT 0';
        }
        System.debug(queryStr);
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> recList){
        if(!recList.isEmpty()){
            deleteRecords(recList);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Number of Successfully Deleted Records for ' + objectAPIName + ' : ' + deleteSuccessSet.size());
        System.debug('Number of Failed Deleted Records for ' + objectAPIName + ' : ' + deleteErrorMap.keySet().size());
        Id cvIdSuccess = generateCSVfileSuccess(deleteSuccessSet);
        Id cvIdError = generateCSVfileError(deleteErrorMap);
        if(cvIdSuccess != null || cvIdError != null){
            sendEmail(cvIdSuccess, cvIdError, deleteSuccessSet.size(), deleteErrorMap.keySet().size());
        }
    }
    
    global void execute(SchedulableContext sc) {
        DeleteRecordsBatch batch = new DeleteRecordsBatch(objectAPIName, olderThanDays, fieldFilterMap, limitValue, batchSize); 
        Database.executebatch(batch, batchSize);
    }
    
    public boolean doesObjectExist(String objName){
        for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
            String sobjName = String.valueOf(sObjectType);
            if (sobjName.equalsIgnoreCase(objName)) {
                return true;
            }
        }
        return false;
    }
    
    public boolean doesFieldExist(String objName, string fieldName)
    {
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) {}
        
        return false;
    }
    
    public void deleteRecords(List<SObject> deleteList){
        try{
            List<Database.DeleteResult> srList = Database.delete(deleteList, false);
            for (Integer i=0; i<srList.size(); i++){
                if (srList.get(i).isSuccess()){
                    deleteSuccessSet.add(srList.get(i).getId());
                } 
                else if (!srList.get(i).isSuccess()){
                    Database.Error e = srList.get(i).getErrors().get(0);
                    String errorReason = 'Delete Failed: ' + e.getStatusCode() + ': ' + e.getMessage() + ' ' + objectAPIName+ ' fields that affected this error: ' + e.getFields();
                    System.debug(errorReason);
                    deleteErrorMap.put(srList.get(i).getId(), errorReason);
                }  
            }
        }
        catch(Exception e){
            System.debug(e);
        }
    }

    public Id generateCSVfileSuccess(Set<Id> recSuccessSet) {
        Id contentVersionId;
        if(!recSuccessSet.isEmpty()){
            String generatedCSVFile ='';
            generatedCSVFile = genereateHeaderSuccess().removeEnd(',') + '\n';
            String fileRow = '';
            for(Id recId : recSuccessSet){
                fileRow = '';
                fileRow = recId;
                generatedCSVFile = generatedCSVFile + fileRow.replace('null', '') + '\n';
            }
            generatedCSVFile = '\uFEFF' + generatedCSVFile.removeEnd('\n');
            Datetime now = Datetime.now(); 
            Integer offset = UserInfo.getTimezone().getOffset(now); 
            Datetime local = now.addSeconds(offset/1000);
            
            contentVersionId = uploadFile(generatedCSVFile, 'DeleteRecordsBatch_' + objectAPIName + '_Success_'+ local , '.csv');
        }
        return contentVersionId;
    }
    
    public Id generateCSVfileError(Map<Id, String> recErrorMap) {
        Id contentVersionId;
        if(!recErrorMap.keySet().isEmpty()){
            String generatedCSVFile ='';
            generatedCSVFile = genereateHeaderError().removeEnd(',') + '\n';
            String fileRow = '';
            for(Id recId : recErrorMap.keySet()){
                fileRow = '';
                fileRow = recId;
                fileRow = fileRow +','+ recErrorMap.get(recId);
                generatedCSVFile = generatedCSVFile + fileRow.replace('null', '') + '\n';
            }
            generatedCSVFile = '\uFEFF' + generatedCSVFile.removeEnd('\n');
            Datetime now = Datetime.now(); 
            Integer offset = UserInfo.getTimezone().getOffset(now); 
            Datetime local = now.addSeconds(offset/1000);
            
            contentVersionId = uploadFile(generatedCSVFile, 'DeleteRecordsBatch_' + objectAPIName + '_Error_'+ local , '.csv');
        }
        return contentVersionId;
    }
    
    public String genereateHeaderSuccess() {
        List<String> headerArray = new List<String>();
        headerArray.add('Id');
        return string.join(headerArray, ',');
    }

    public String genereateHeaderError() {
        List<String> headerArray = new List<String>();
        headerArray.add('Id');
        headerArray.add('Error Message');
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
        
        String libraryName = 'Delete_Records_Batch';
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
    
    public void sendEmail (Id contentVersionSuccessId, Id contentVersionErrorId, Integer successSize, Integer failedSize) {
        
        List<String> recip = Label.DeleteRecordsBatchEmailRecipient.split(',');
        if(!recip.contains(UserInfo.getUserEmail()) ){
            recip.add(UserInfo.getUserEmail());
        }
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
        for(ContentVersion cv : [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionSuccessId OR Id =: contentVersionErrorId]){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(cv.VersionData);
            attachment.setFileName(cv.Title + '.csv');
            fileAttachments.add(attachment);
        }
        
        String body;
        body = 'Please find the summary of deleted ' + objectAPIName + ' for '+ String.valueOf(Date.today()) + '.\n';
        body += 'Total number of successfully deleted records: ' + successSize + '.\n';
        body += 'Total number of failed deleted records: ' + failedSize + '.\n';
        
        if(!recip.isEmpty()){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject(String.valueOf(Date.today()) + ' Deleted ' + objectAPIName + ' Report');
            semail.setToAddresses(recip);
            semail.setPlainTextBody(body);
            if(!fileAttachments.isEmpty()) semail.setFileAttachments(fileAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        }
    }
}