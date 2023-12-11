/*
* @author        Rey Austral
* @date          6.24.2019
* @description   
* @revision(s) 
*/
public with sharing class MailSampleLabelController {
    public List<OrderItem> orderItemList { get; set; }

    public MailSampleLabelController() {
        String tempStartDate1 = ApexPages.currentPage().getParameters().get('startdate');
        String tempEndDate1 = ApexPages.currentPage().getParameters().get('enddate');
        String tempStartDate;
        String tempEndDate;
        if(tempStartDate1 != null){
            tempStartDate = tempStartDate1.escapeHTML4();
        }
        if(tempEndDate1 != null){
            tempEndDate = tempEndDate1.escapeHTML4();
        }
        Date startDate = String.isNotEmpty(tempStartDate) ? Date.valueOf(tempStartDate) : null;
        Date endDate = String.isNotEmpty(tempEndDate) ? Date.valueOf(tempEndDate) : null;

        orderItemList = querySampleItemReport(startDate, endDate);
    }

    @AuraEnabled
    public static List<OrderItem> querySampleItemReport(Date startDate, Date endDate) {
        List<Order> orderList =  [Select Id, (Select Order.OrderedBy__r.Name, Order.Type , 
                       Order.RelatedCampaign__r.Name,Promotion__r.Name, Order.FileExportDate__c,                       
                       Order.ShippingAddress__r.Name, Order.ShippingAddress__r.Country__c, Order.ShippingAddress__r.City2__r.Name, Order.ShippingAddress__r.PostalCode__c,
                       Order.ShippingAddress__r.Street1__c, Order.ShippingAddress__r.Street2__c, Order.ShippingAddress__r.UnitNumber__c,
                       OrderItemNumber, PricebookEntry.Product2.Name, PricebookEntry.ProductCode, Quantity, UnitPrice, TotalPrice, Order.OrderNumber,
                       Order.CreatedBy.Name, OrderedFor__r.Name, Order.CreatedDate, Order.LastModifiedDate From OrderItems where OrderedFor__c != NULL)
                From Order 
                Where Status =: CommonConstant.ORDER_STATUS_TRANSFERRED 
                AND Type =: CommonConstant.ORDER_TYPE_SAMPLEREQUEST 
                AND FileExportDate__c >=: startDate AND FileExportDate__c <=: endDate 
                AND FileExportDate__c != NULL
                AND ExtractedforLabeling__c = false
                Order by OrderNumber LIMIT 500];
        List<OrderItem> resultList = new List<OrderItem>();
        for (Order orders : orderList) {
            resultList.addAll(orders.OrderItems);           
        }
        return  resultList;
    }

    @AuraEnabled 
    public static OrderReportWrapper getExcelFileAsBase64String(Date startDate, Date endDate) {
        PageReference excelPage = Page.MailSampleLabelExportPage;
        excelPage.getParameters().put('startdate',String.valueOf(startDate));
        excelPage.getParameters().put('enddate',String.valueOf(endDate));

        Blob excelBlob;
        if(System.Test.isRunningTest()) { 
          excelBlob = blob.valueOf('Unit.Test');
        } else {
          excelBlob = excelPage.getContent();
        }
        String base64Excel = EncodingUtil.base64Encode(excelBlob);
        User usr = [Select Id, Market__c from User where Id=: UserInfo.getUserId()];

        createFile('ExtractedMailSampleReport_' + usr.Market__c + '_' + Datetime.now() + '.xls', excelBlob, usr.Market__c);
        updateOrderStatus(startDate, endDate);
        
        OrderReportWrapper result = new OrderReportWrapper();
        result.userMarket =  usr.Market__c;
        result.fileContent = base64Excel;
        return result;
    }  

    public static void createFile (String filename, Blob content, String market) {
        String libraryName = 'Mail Sample Export Library - ' + market;
        
        try { 
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = content;
            cv.Title = filename;
            cv.PathOnClient = filename;     
            insert cv;

            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            if(System.Test.isRunningTest()) { 
                libraryName = 'Asset Library';
            }
            System.debug(libraryName);
            ContentWorkspace ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name =: libraryName LIMIT 1];

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId  = ws.Id;
            insert cdl;
           
            List<ContentFolderMember> memberFolder = new List<ContentFolderMember>();
            for (ContentFolderMember cfm : [SELECT Id, ChildRecordId, ParentContentFolderId
                                      FROM ContentFolderMember
                                      WHERE ChildRecordId = :cv.ContentDocumentId
                                      LIMIT 1]) {
                ContentFolderMember updatedCfm = new ContentFolderMember(Id = cfm.Id,
                                                                     ChildRecordId = cdl.ContentDocumentId,
                                                                     ParentContentFolderId = ws.RootContentFolderId);
                memberFolder.add(updatedCfm);

            }                          
            if (!memberFolder.isEmpty()) {
                update memberFolder;    
            }            
           
        } catch(QueryException qex) {
            throw new AuraHandledException('You have no access to the "' + libraryName + '" folder');      
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }        
    }

    public static void updateOrderStatus(Date startDate, Date endDate) {
        List<Order> orderList = [Select Id, ExtractedforLabeling__c from Order 
                                    Where Status =: CommonConstant.ORDER_STATUS_TRANSFERRED 
                                    AND Type =:CommonConstant.ORDER_TYPE_SAMPLEREQUEST          
                                    AND ExtractedforLabeling__c = false   
                                    AND FileExportDate__c != NULL                       
                                    AND FileExportDate__c >=: startDate AND FileExportDate__c <=: endDate 
                                    Order by OrderNumber LIMIT 500];
       
        for(Order order : orderList) {
            order.ExtractedforLabeling__c = true;           
        }

        update orderList;
    }
   
    public class OrderReportWrapper {
        @AuraEnabled
        public string userMarket { get; set; }
        @AuraEnabled
        public string fileContent { get; set; }
    }
}