/*
Author: Frank Gomendoza
Description: Batch job for SG that creates Case records for Similac Mom
*/
global class SGSimilacMomBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    Set<Id> insertSuccessSet = new Set<Id>();
    List<errorWrap> insertErrorList = new List<errorWrap>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id conChildId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Child').getRecordTypeId();
        String query = 'SELECT Id, Active__c, AgeinMonths__c, AccountId, Parent__c, Parent__r.Active__c, Parent__r.LatestChannelResponse__c, Market__c, Phone, CreatedDate FROM Contact'
            +' WHERE RecordTypeId = \'' + conChildId + '\' AND AgeinMonths__c = 8 AND Market__c = \'' + CommonConstant.MARKET_SG + '\' AND Parent__r.Active__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Case> newCaseList = new List<Case>();
        if(!scope.isEmpty()){
            Id caseCallId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
            Set<Contact> childConList = new Set<Contact>();
            Set<Id> childConWithSimMomIdSet = new Set<Id>();
            Map<Id, Set<Contact>> parentChildMap = new Map<Id, Set<Contact>>();
            Map<Id, ChannelResponse__c> childCRMap = new Map<Id, ChannelResponse__c>();
            Map<Id, ChannelResponse__c> parentCRMap = new Map<Id, ChannelResponse__c>();
            
            for(Contact con : scope){
                if(parentChildMap.containsKey(con.Parent__c) ){
                    parentChildMap.get(con.Parent__c).add(con);
                }
                else{
                    parentChildMap.put(con.Parent__c, new Set<Contact>{con});
                }
            }
            
            for(ChannelResponse__c cr : [SELECT Id, Contact__c, Contact__r.AccountId, BrandRelationship__c, BrandRelationship__r.Active__c, BrandRelationship__r.User__c, BrandRelationship__r.PrimaryContact__c, BrandRelationship__r.CreatedDate 
                                         FROM ChannelResponse__c WHERE Brand__c = 'SIMILAC MOM' AND Classification__c = 'New Registration' AND Contact__c IN: parentChildMap.keySet() AND BrandRelationship__r.Active__c = true])
            {
                if(cr.BrandRelationship__r.User__c != null){
                    if(childCRMap.containsKey(cr.BrandRelationship__r.User__c)){
                        ChannelResponse__c crPrev = childCRMap.get(cr.BrandRelationship__r.User__c);
                        if(cr.BrandRelationship__r.CreatedDate > crPrev.BrandRelationship__r.CreatedDate){
                            childCRMap.put(cr.BrandRelationship__r.User__c, cr);
                        }
                    }
                    else{
                        childCRMap.put(cr.BrandRelationship__r.User__c, cr);
                    }
                }
                else if(cr.BrandRelationship__r.PrimaryContact__c != null){
                    if(parentCRMap.containsKey(cr.BrandRelationship__r.PrimaryContact__c)){
                        ChannelResponse__c crPrev1 = parentCRMap.get(cr.BrandRelationship__r.PrimaryContact__c);
                        if(cr.BrandRelationship__r.CreatedDate > crPrev1.BrandRelationship__r.CreatedDate){
                            parentCRMap.put(cr.BrandRelationship__r.PrimaryContact__c, cr);
                        }
                    }
                    else{
                        parentCRMap.put(cr.BrandRelationship__r.PrimaryContact__c, cr);
                    }
                }
                childConList.addAll(parentChildMap.get(cr.Contact__c));
            }
            
            //Check if child has Sim Mom Case already
            for(Case c : [SELECT Id, CallRegarding__c, Campaign__c, Campaign__r.Product__r.Name FROM Case WHERE RecordTypeId =: caseCallId AND ProductCampaign__c = 'SIMILAC MOM' AND CallRegarding__c IN: childConList]){
                childConWithSimMomIdSet.add(c.CallRegarding__c); //dont include
            }
            
            //Create Case
            BusinessHours busHrsDefault = [SELECT Id FROM BusinessHours WHERE Name = 'Default' LIMIT 1][0];
            Campaign campaignSimMom = [SELECT Id FROM Campaign WHERE Name = 'SG-SimilacMum-Con&Ren-Call' LIMIT 1][0];
            for(Contact child : childConList){
                //Should not have existing Sim Mom Case
                if(!childConWithSimMomIdSet.contains(child.Id) ){
                    Case newCase = new Case();
                    newCase.RecordtypeId = caseCallId;
                    newCase.Status = 'New';
                    newCase.AccountId = child.AccountId;
                    newCase.ContactId = child.Parent__c;
                    newCase.CallRegarding__c = child.Id;
                    newCase.BusinessHoursId = busHrsDefault.Id;
                    newCase.Subject = 'SG Similac Mom Maternal Con and Ret Call';
                    newCase.Campaign__c = campaignSimMom.Id;
                    newCase.CallType__c = 'Outbound';
                    newCase.Channel__c = child.Parent__r.LatestChannelResponse__c;
                    newCase.Market__c = 'SG';
                    newCase.Survey_Link__c = 'http://cloud.sg.abbottnutrition.com/SimilacMum_EDDSurvey2?Contact_ID='+ child.Parent__c;  
                    if(childCRMap.containsKey(child.Id)){
                        newCase.RelatedChannelResponse__c = childCRMap.get(child.Id).Id;
                        newCase.RelatedBrandRelationship__c = childCRMap.get(child.Id).BrandRelationship__c;
                    }
                    else if(parentCRMap.containsKey(child.Parent__c)){
                        newCase.RelatedChannelResponse__c = parentCRMap.get(child.Parent__c).Id;
                        newCase.RelatedBrandRelationship__c = parentCRMap.get(child.Parent__c).BrandRelationship__c;
                    }
                    newCaseList.add(newCase);
                }
            }
            
            if(!newCaseList.isEmpty()) insertCase(newCaseList);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Number of Successfully Inserted Case for ' + Date.Today() + ' : ' + insertSuccessSet.size());
        System.debug('Number of Failed Case for ' + Date.Today() + ' : ' + insertErrorList.size());
        Map<Id, Case> insertSuccessMap = new Map<Id, Case>([SELECT Id, Casenumber, ContactId, Contact.Name, Contact.Phone, CallRegarding__r.Name, Channel__r.Name, RelatedCampaign__r.Name FROM Case WHERE Id IN: insertSuccessSet]);
        Id cvIdSuccess;
        Id cvIdError;
        if(!insertSuccessMap.keySet().isEmpty()){
            cvIdSuccess = generateCSVfileSuccess(insertSuccessMap);
        }
        if(!insertErrorList.isEmpty()){
            cvIdError = generateCSVfileError(insertErrorList);
        }
        if(cvIdSuccess != null || cvIdError != null){
            sendEmail(cvIdSuccess, cvIdError, insertSuccessMap.keySet().size(), insertErrorList.size());
        }
    }
    
    global void execute(SchedulableContext sc) {
        SGSimilacMomBatch batch = new SGSimilacMomBatch(); 
        Database.executebatch(batch, 20);
    }
    
    public void insertCase(List<Case> insertList){
        try{
            List<Database.SaveResult> srList = Database.insert(insertList, false);
            for (Integer i=0; i<srList.size(); i++){
                if (srList.get(i).isSuccess()){
                    insertSuccessSet.add(srList.get(i).getId());
                } 
                else if (!srList.get(i).isSuccess()){
                    Database.Error e = srList.get(i).getErrors().get(0);
                    String errorReason = 'Insert Failed: ' + e.getStatusCode() + ': ' + e.getMessage() + '. Case fields that affected this error: ' + e.getFields();
                    errorWrap errRec = new errorWrap();
                    errRec.contactId = (Id) insertList.get(i).get('ContactId');
                    errRec.callRegardingId = (Id) insertList.get(i).get('CallRegarding__c');
                    errRec.relatedCRId = (Id) insertList.get(i).get('RelatedChannelResponse__c');
                    errRec.errorMsg = errorReason;
                    insertErrorList.add(errRec);
                }  
            }
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    public Id generateCSVfileSuccess(Map<Id, Case> recSuccessMap) {
        Id contentVersionId;
        if(!recSuccessMap.keySet().isEmpty()){
            String generatedCSVFile ='';
            generatedCSVFile = genereateHeaderSuccess().removeEnd(',') + '\n';
            String fileRow = '';
            for(Id recId : recSuccessMap.keySet()){
                Case c = recSuccessMap.get(recId);
                fileRow = '';
                fileRow = c.CaseNumber;
                fileRow = fileRow +','+ c.Contact.Phone;
                fileRow = fileRow +','+ c.Contact.Name;
                fileRow = fileRow +','+ c.CallRegarding__r.Name;
                fileRow = fileRow +','+ c.Channel__r.Name;
                fileRow = fileRow +','+ c.RelatedCampaign__r.Name;
                generatedCSVFile = generatedCSVFile + fileRow.replace('null', '') + '\n';
            }
            generatedCSVFile = '\uFEFF' + generatedCSVFile.removeEnd('\n');
            Datetime now = Datetime.now(); 
            Integer offset = UserInfo.getTimezone().getOffset(now); 
            Datetime local = now.addSeconds(offset/1000);
            
            contentVersionId = uploadFile(generatedCSVFile, 'SG Successful Insert Case for Similac Mum ' + local , '.csv');
        }
        return contentVersionId;
    }
    
    public Id generateCSVfileError(List<errorWrap> recErrorList) {
        Id contentVersionId;
        if(!recErrorList.isEmpty()){
            String generatedCSVFile ='';
            generatedCSVFile = genereateHeaderError().removeEnd(',') + '\n';
            String fileRow = '';
            for(errorWrap rec : recErrorList){
                fileRow = '';
                fileRow = rec.contactId;
                fileRow = fileRow +','+ rec.callRegardingId;
                fileRow = fileRow +','+ rec.relatedCRId;
                fileRow = fileRow +','+ rec.errorMsg;
                generatedCSVFile = generatedCSVFile + fileRow.replace('null', '') + '\n';
            }
            generatedCSVFile = '\uFEFF' + generatedCSVFile.removeEnd('\n');
            Datetime now = Datetime.now(); 
            Integer offset = UserInfo.getTimezone().getOffset(now); 
            Datetime local = now.addSeconds(offset/1000);
            
            contentVersionId = uploadFile(generatedCSVFile, 'SG Failed Insert Case for Similac Mum ' + local , '.csv');
        }
        return contentVersionId;
    }
    
    public String genereateHeaderSuccess() {
        List<String> headerArray = new List<String>();
        headerArray.add('CaseNumber');
        headerArray.add('Contact Phone');
        headerArray.add('Contact Name');
        headerArray.add('Call Regarding Name');
        headerArray.add('Channel Name');
        headerArray.add('Related Campaign Name');
        return string.join(headerArray, ',');
    }
    public String genereateHeaderError() {
        List<String> headerArray = new List<String>();
        headerArray.add('Contact Id');
        headerArray.add('Call Regarding Id');
        headerArray.add('Related Channel Response Id');
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
        
        String libraryName = 'SimMum_Case_Library_SG';
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
        
        List<String> recip = Label.SimMumBatchEmailRecipient.split(',');
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
        body = 'Please find the summary of inserted Similac Mom Cases for '+ String.valueOf(Date.today()) + '.\n';
        body += 'Total number of successfully inserted records: ' + successSize + '.\n';
        body += 'Total number of failed inserted records: ' + failedSize + '.\n';
        
        if(!recip.isEmpty()){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject(String.valueOf(Date.today()) + ' Inserted Similac Mom Case Report');
            semail.setToAddresses(recip);
            semail.setPlainTextBody(body);
            if(!fileAttachments.isEmpty()) semail.setFileAttachments(fileAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        }
    }
    
    public class errorWrap {
        public Id contactId {get; set;}
        public Id callRegardingId {get; set;}
		public Id relatedCRId {get; set;}
        public String errorMsg {get; set;}
    }
    
}