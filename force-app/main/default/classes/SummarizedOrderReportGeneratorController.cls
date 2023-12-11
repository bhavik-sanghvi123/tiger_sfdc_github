/**
* @author        Viana Mirandilla
* @date          4.26.2019
* @description   Controller of SummarizedOrderReportGenerator (Lightning Component)
* @testClass     SummarizedOrderReportGeneratorTest 
* @revision(s)
*/
public with sharing class SummarizedOrderReportGeneratorController {
    public List<CommonObjectWrapper.cls_SummarizedOrder> combinedOrderList { get; set; }

    public SummarizedOrderReportGeneratorController () {
        //will be called when the excel is being loaded from Order Export (Combined Line Items) button
        combinedOrderList = queryOrderReport();
    }

    @AuraEnabled
    public static List<CommonObjectWrapper.cls_SummarizedOrder> queryOrderReport() {
        List<CommonObjectWrapper.cls_SummarizedOrder> combinedOrderList = new List<CommonObjectWrapper.cls_SummarizedOrder>() ;

        List<Order> orderList = [SELECT OrderedBy__r.Name, OrderedBy__r.ContactRefNo__c, OrderedBy__r.HomePhone, OrderedBy__r.Phone, OrderedBy__r.OtherPhone, Type,
                       RelatedCampaign__r.Name, EffectiveDate, Status, PaymentMethod__c, FileExportDate__c, Case__r.CaseNumber, CurrencyIsoCode, TotalAmount, 
                       TotalQuantitySummary__c, OrderNotes__c, ShippingAddress__r.Name, ShippingAddress__r.Country__c, ShippingAddress__r.City2__r.Name, 
                       ShippingAddress__r.Ward2__r.Name, ShippingAddress__r.District__r.Name, ShippingAddress__r.Region__r.Name, ShippingAddress__r.Street1__c, 
                       ShippingAddress__r.Street2__c, OrderNumber, CreatedBy.Name, 
                       (SELECT Promotion__r.Name, OrderItemNumber, PricebookEntry.Product2.Name, PricebookEntry.ProductCode, Quantity, CurrencyIsoCode, UnitPrice, 
                       TotalPrice, PricebookEntry.Product2.KeyBrand__c, OrderedFor__r.Name, Category__c FROM OrderItems) 
                FROM Order WHERE Status =: CommonConstant.ORDER_STATUS_SUBMITTED ORDER BY OrderNumber LIMIT 500]; 

        for (Order orderRec: orderList) {
            Integer ctr = 0;
            Integer oiSize = (orderRec.OrderItems).size();
            CommonObjectWrapper.cls_SummarizedOrder sOrderWrapper = new CommonObjectWrapper.cls_SummarizedOrder();
            sOrderWrapper.sOrderNumber = orderRec.OrderNumber;
            sOrderWrapper.sOrderContactRefNo = orderRec.OrderedBy__r.ContactRefNo__c;
            sOrderWrapper.sOrderName = orderRec.OrderedBy__r.Name;
            sOrderWrapper.sOrderStreet1 = orderRec.ShippingAddress__r.Street1__c;
            sOrderWrapper.sOrderStreet2 = orderRec.ShippingAddress__r.Street2__c;
            sOrderWrapper.sOrderWard = orderRec.ShippingAddress__r.Ward2__r.Name;
            sOrderWrapper.sOrderDistrict = orderRec.ShippingAddress__r.District__r.Name;
            sOrderWrapper.sOrderCity = orderRec.ShippingAddress__r.City2__r.Name;
            sOrderWrapper.sOrderHomePhone = orderRec.OrderedBy__r.HomePhone;
            sOrderWrapper.sOrderMobile = orderRec.OrderedBy__r.Phone;
            sOrderWrapper.sOrderOtherPhone = orderRec.OrderedBy__r.OtherPhone;
            sOrderWrapper.sOrderRelatedCampaign = orderRec.RelatedCampaign__r.Name;
            sOrderWrapper.sOrderAmount = orderRec.TotalAmount;
            sOrderWrapper.sOrderStartDate = orderRec.EffectiveDate;
            sOrderWrapper.sOrderExportDate = orderRec.FileExportDate__c;
            sOrderWrapper.sOrderCreatedBy = orderRec.CreatedBy.Name;
            sOrderWrapper.sOrderNotes = orderRec.OrderNotes__c;
            sOrderWrapper.sOrderRegion = orderRec.ShippingAddress__r.Region__r.Name;
            sOrderWrapper.sOrderType = orderRec.Type;
            sOrderWrapper.sOrderStatus = orderRec.Status;
            sOrderWrapper.sOrderPaymentMethod = orderRec.PaymentMethod__c;
            sOrderWrapper.sOrderCaseNumber = orderRec.Case__r.CaseNumber;

            //Initialize value to not null
            sOrderWrapper.sOrderTotalQuantity = 0;
            sOrderWrapper.sOrderPromotion = '';
            sOrderWrapper.sOrderKeyBrand = '';
            sOrderWrapper.sOrderOrderedFor = '';
            sOrderWrapper.sOrderCategory = '';
            sOrderWrapper.sOrderProductNumber = '';
            sOrderWrapper.sOrderProductCode = '';
            sOrderWrapper.sOrderProductName = '';
            sOrderWrapper.sOrderUnitPrice = '';

            
            for(OrderItem oi : orderRec.OrderItems) {
                ctr++;
                String strDelimiter = '; ';
                
                /**
                if(orderRec.OrderItems.size() == 1) {
                    sOrderWrapper.sOrderProductNumber = oi.OrderItemNumber;
                    sOrderWrapper.sOrderProductCode = oi.PricebookEntry.ProductCode;
                    sOrderWrapper.sOrderTotalQuantity = oi.Quantity;
                    sOrderWrapper.sOrderProductName = Integer.valueOf(oi.Quantity) + ' ' + oi.PricebookEntry.Product2.Name;
                    sOrderWrapper.sOrderPromotion = oi.Promotion__r.Name;
                    sOrderWrapper.sOrderUnitPrice = String.valueOf(oi.UnitPrice);
                    sOrderWrapper.sOrderKeyBrand = oi.PricebookEntry.Product2.KeyBrand__c;
                    sOrderWrapper.sOrderOrderedFor = oi.OrderedFor__r.Name;
                    sOrderWrapper.sOrderCategory = oi.Category__c;
                }
                **/

                if(ctr == oiSize){
                    sOrderWrapper.sOrderPromotion = sOrderWrapper.sOrderPromotion + (oi.Promotion__r.Name == null ? '' : oi.Promotion__r.Name);
                    sOrderWrapper.sOrderKeyBrand = sOrderWrapper.sOrderKeyBrand + oi.PricebookEntry.Product2.KeyBrand__c;
                    sOrderWrapper.sOrderOrderedFor = sOrderWrapper.sOrderOrderedFor + (oi.OrderedFor__r.Name == null ? '' : oi.OrderedFor__r.Name);
                    sOrderWrapper.sOrderCategory = sOrderWrapper.sOrderCategory + (oi.Category__c == null ? '' : oi.Category__c);
                    sOrderWrapper.sOrderProductNumber = sOrderWrapper.sOrderProductNumber + oi.OrderItemNumber;
                    sOrderWrapper.sOrderProductCode = sOrderWrapper.sOrderProductCode + oi.PricebookEntry.ProductCode;
                    sOrderWrapper.sOrderTotalQuantity = sOrderWrapper.sOrderTotalQuantity + oi.Quantity;
                    sOrderWrapper.sOrderProductName = sOrderWrapper.sOrderProductName + Integer.valueOf(oi.Quantity) + ' ' + oi.PricebookEntry.Product2.Name;
                    sOrderWrapper.sOrderUnitPrice = sOrderWrapper.sOrderUnitPrice + oi.UnitPrice;
                }

                else if(ctr < oiSize) {
                    sOrderWrapper.sOrderPromotion = sOrderWrapper.sOrderPromotion + (oi.Promotion__r.Name == null ? '' : oi.Promotion__r.Name + strDelimiter);
                    sOrderWrapper.sOrderKeyBrand = sOrderWrapper.sOrderKeyBrand + oi.PricebookEntry.Product2.KeyBrand__c + strDelimiter;
                    sOrderWrapper.sOrderOrderedFor = sOrderWrapper.sOrderOrderedFor + (oi.OrderedFor__r.Name == null ? '' : oi.OrderedFor__r.Name + strDelimiter);
                    sOrderWrapper.sOrderCategory = sOrderWrapper.sOrderCategory + (oi.Category__c == null ? '' : oi.Category__c + strDelimiter);
                    sOrderWrapper.sOrderProductNumber = sOrderWrapper.sOrderProductNumber + oi.OrderItemNumber + strDelimiter;
                    sOrderWrapper.sOrderProductCode = sOrderWrapper.sOrderProductCode + oi.PricebookEntry.ProductCode + strDelimiter;
                    sOrderWrapper.sOrderTotalQuantity = sOrderWrapper.sOrderTotalQuantity + oi.Quantity;
                    sOrderWrapper.sOrderProductName = sOrderWrapper.sOrderProductName + Integer.valueOf(oi.Quantity) + ' ' + oi.PricebookEntry.Product2.Name + strDelimiter;
                    sOrderWrapper.sOrderUnitPrice = sOrderWrapper.sOrderUnitPrice + oi.UnitPrice + strDelimiter;
                }
            }

            combinedOrderList.add(sOrderWrapper);
        }
        return combinedOrderList;
    }

    @AuraEnabled 
    public static OrderReportWrapper getExcelFileAsBase64String() {
        PageReference excelPage = Page.SummarizedOrderExportReport;
        //excelPage.getParameters().put('cid',contactId);
        Blob excelBlob;
        if(System.Test.isRunningTest()) { 
          excelBlob = blob.valueOf('Unit.Test');
        } else {
          excelBlob = excelPage.getContent();
        }
        String base64Excel = EncodingUtil.base64Encode(excelBlob);
        User usr = [Select Id, Market__c from User where Id=: UserInfo.getUserId()];

        Datetime now = Datetime.now(); Integer offset = UserInfo.getTimezone().getOffset(now); 
        Datetime local = now.addSeconds(offset/1000);
        createFile('ExtractedOrderReport_' + usr.Market__c + '_' + local + '.xls', excelBlob, usr.Market__c);

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
            
            updateOrderStatus();
        } catch(QueryException qex) {
            throw new AuraHandledException('You have no access to the "' + libraryName + '" folder');      
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

    public static void updateOrderStatus() {
        List<Order> orderList = [Select Id, Status from Order where Status =: CommonConstant.ORDER_STATUS_SUBMITTED ORDER BY OrderNumber LIMIT 500];
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