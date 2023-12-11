/**
* @author        Rey Austral
* @date          3.1.2019
* @description   Controller of OrderReportGenerator (Lightning Component)
* @testClass     OrderReportGeneratorControllerTest
* @revision(s)
*/
public with sharing class OrderReportGeneratorController {
    public transient List<OrderItem> orderItemList { get; set; }
    public String market { get; set; }

    public OrderReportGeneratorController() {
        //will be called when the excel is being loaded from Order Export button      
        market = ApexPages.currentPage().getParameters().get('usrmarket');
        orderItemList = queryOrderItemReport();
    }

    @AuraEnabled
    public static List<OrderItem> queryOrderItemReport() {
        String query= '', filter='';
        User currentUser = [SELECT Id, Market__c FROM User WHERE Id =: userInfo.getUserId()];
        String limitRecord =  ' Order by OrderNumber LIMIT 300';
        if (currentUser.Market__c == 'SG') {
            filter = ' AND Type = \'' + CommonConstant.ORDER_TYPE_SAMPLEREQUEST  +  '\' ';
            limitRecord = ' Order by OrderNumber LIMIT 1000';
        }        
       
        query =  'Select Id, ('
                + 'Select Id, Order.OrderedBy__r.Name, Order.OrderedBy__r.ContactRefNo__c, Order.OrderedBy__r.HomePhone,Order.OrderedBy__r.Phone, Order.OrderedBy__r.OtherPhone, Order.Type , '
                + ' Order.RelatedCampaign__r.Name,Order.EffectiveDate, Order.Status, Order.PaymentMethod__c, Promotion__r.Name, Order.FileExportDate__c,'
                + ' Order.Case__r.CaseNumber, Order.CurrencyIsoCode, Order.TotalAmount, Order.TotalQuantitySummary__c, Order.OrderNotes__c, Order.ShippingAddress__r.PostalCode__c,'
                + ' Order.ShippingAddress__r.Name, Order.ShippingAddress__r.Country__c, Order.ShippingAddress__r.City2__r.Name, Order.ShippingAddress__r.Ward2__r.Name,'
                + ' Order.ShippingAddress__r.District__r.Name, Order.ShippingAddress__r.Region__r.Name, Order.ShippingAddress__r.Street1__c, Order.ShippingAddress__r.Street2__c, Order.ShippingAddress__r.UnitNumber__c,'
                + ' Order.ShippingAddress__r.SubDistrict__r.Name, Order.ShippingAddress__r.Building__c, Order.ShippingAddress__r.VillageNo__c, Order.ShippingAddress__r.VillageName__c, Order.ShippingAddress__r.Road__c,'
                + ' OrderItemNumber, PricebookEntry.Product2.Name, PricebookEntry.ProductCode, Quantity, CurrencyIsoCode, UnitPrice, TotalPrice, PricebookEntry.Product2.KeyBrand__c, Order.OrderNumber,'
                + ' Order.CreatedBy.Name, Order.PreferredDeliveryDate__c, Order.PreferredDeliveryTime__c, OrderedFor__r.Name, Order.ShippingAddress__r.FullAddress__c, Order.ShippingAddress__r.AddressValidationStatus__c,'
                + ' Order.EndDate, Order.OrderCacellationReason__r.Name, OrderId, Status__c, UnitPriceExclGst__c, TotalPriceExclGst__c, Order.TotalAmountExclGst__c'
                + ' From OrderItems) from Order where Status = \'' + CommonConstant.ORDER_STATUS_SUBMITTED  +  '\' '              
                + filter
                + limitRecord;
              
        List<OrderItem> resultList = new List<OrderItem>();
        for (Order orders : database.query(query)) {
            resultList.addAll(orders.OrderItems);           
        }
        return  resultList;
    }

    @AuraEnabled 
    public static OrderReportWrapper getExcelFileAsBase64String() {
        User usr = [Select Id, Market__c from User where Id=: UserInfo.getUserId()];      
       
        Datetime now = Datetime.now(); Integer offset = UserInfo.getTimezone().getOffset(now); 
        Datetime local = now.addSeconds(offset/1000);
        String filename = 'ExtractedSampleRequestOrderReport_' + usr.Market__c + '_' + local + '.xls';

        Blob excelBlob;
        if (usr.Market__c == 'SG') {
            List<OrderItem> orderList = queryOrderItemReport();
            if (orderList.size() != 0) {
                excelBlob = blob.valueOf(OrderReportCSVGenerator.generateCSV(orderList));
                filename = 'ExtractedOrderReport_' + usr.Market__c + '_' + local + '.csv';
            }
        } else {
            PageReference excelPage = usr.Market__c == 'TH' ? Page.OrderExportReportSGTH : Page.OrderExportReport;       
            excelPage.getParameters().put('usrmarket',usr.Market__c);          
            excelBlob = excelPage.getContent();
        } 
      
        String base64Excel = EncodingUtil.base64Encode(excelBlob);
        
        
        createFile(filename, excelBlob, usr.Market__c);

        OrderReportWrapper result = new OrderReportWrapper();
        result.userMarket =  usr.Market__c;
        result.fileContent = base64Excel;
        return result;
    }  

    public static void createFile (String filename, Blob content, String market) {
        String libraryName = 'Order Export Library - ' + market;
        
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
            
            updateOrderStatus(market);
        } catch(QueryException qex) {
            throw new AuraHandledException('You have no access to the "' + libraryName + '" folder');      
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

    public static void updateOrderStatus(String market) {
        List<Order> orderList = new List<Order>();       
        if (market == 'SG') {
            orderList = [Select Id, Status from Order where Status =: CommonConstant.ORDER_STATUS_SUBMITTED and Type =:CommonConstant.ORDER_TYPE_SAMPLEREQUEST Order by OrderNumber LIMIT 1000];
        } else {
            orderList = [Select Id, Status from Order where Status =: CommonConstant.ORDER_STATUS_SUBMITTED Order by OrderNumber LIMIT 300];
        }
        for(Order order : orderList) {
            order.Status = CommonConstant.ORDER_STATUS_TRANSFERRED;         
            order.Extracted__c = true;
            order.FileExportDate__c = Date.today();
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