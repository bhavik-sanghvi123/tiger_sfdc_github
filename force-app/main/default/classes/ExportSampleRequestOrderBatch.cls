/*----------------------------------------------------------------------------------------
Author:      Crissar Ibarra
Description: Batch Class to export Sample Request Order Report then send via email

History
08/21/2021   Crissar Ibarra Created
-------------------------------------------------------------------------------------------*/
global class ExportSampleRequestOrderBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public Map<Integer, String> spaceMap;
    private Id contentVersionId;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Name__c, Order_Number__c, Street_1__c, Street_2__c, UnitNumber__c, PostalCode__c, Mobile__c, Product_Code__c, Quantity__c, Order__c '
                     + 'From OrderExport2__c '
                     + 'WHERE CreatedDate = YESTERDAY '
                     + 'AND FileExportTime__c != null AND Market__c = \'SG\'';

        system.debug('::: query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderExport2__c> scope) {
        
        if(!scope.isEmpty()){
            generateCSVfile();
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //System.debug(contentVersionId);
        sendEmail(contentVersionId);
        
    }

    public Id uploadFile(String fileContent, String fileName, String fileType) {   
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = fileName + fileType; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = blob.valueOf(fileContent); // converting your binary string to Blog
        insert conVer;

        conVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id LIMIT 1];

        String libraryName = 'ANI - Orders & Purchases';
        if(System.Test.isRunningTest()) { 
            libraryName = 'Asset Library';
        }
        ContentWorkspace ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name =: libraryName LIMIT 1];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conVer.ContentDocumentId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        cdl.LinkedEntityId  = ws.Id;
        insert cdl;
        
        return conVer.Id;
    }   
    
    public void generateCSVfile() {
    
        List<OrderExport2__c> esroList = [SELECT ID, Name__c , Order_Number__c, Street_1__c, Street_2__c, UnitNumber__c, PostalCode__c, Mobile__c, Product_Code__c, Quantity__c 
                                          FROM OrderExport2__c
                                          WHERE CreatedDate = YESTERDAY
                                          AND FileExportTime__c != null AND Market__c = 'SG'];
        String generatedCSVFile = ExportSampleRequestOrderCSVGenerator.generateCSV(esroList);
        Datetime now = Datetime.now(); Integer offset = UserInfo.getTimezone().getOffset(now); 
        Datetime local = now.addSeconds(offset/1000);
        contentVersionId = uploadFile(generatedCSVFile, 'ExtractedExportSampleRequestOrder' + local , '.csv');

    }
    
    private static void sendEmail (Id contentVersionId) {
        List<ContentVersion> docList = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId];
        List<String> recip = Label.SampleOrderReportEmailRecepientSG.split(',');
        system.debug('::: docList ' + docList );
        if(!docList.isEmpty()){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(docList[0].VersionData);
            attachment.setFileName(docList[0].Title + '.csv');
            
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject(String.valueOf(Date.today()) + ' Export Sample Request Order Report');
            semail.setToAddresses(recip);
            semail.setPlainTextBody('Please find the Export Sample Request Order details for ' + String.valueOf(Date.today()) + '.');
            semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        }  
    }
    
}