/*
Author: Jericson Mercado
Description: Batch job that creates record on Order Export object to be extracted via dataloader
*/
global class ExportOrderBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    String Market;
    Boolean isMultiline;
    public String queryOverride;
    DateTime batchDateExecuted;
    
    global ExportOrderBatch (String m, Boolean multiLine){
        Market = m;
        isMultiline = multiLine;
        batchDateExecuted = Datetime.now();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        String status = CommonConstant.ORDER_STATUS_SUBMITTED, filter = '';
        if (Market == 'SG') {
            filter = ' AND Type = \'' + CommonConstant.ORDER_TYPE_SAMPLEREQUEST  +  '\' ';
        }
        String queryStr = 'SELECT OrderedBy__r.Name, OrderedBy__r.ContactRefNo__c, OrderedBy__r.HomePhone,'
                        + ' OrderedBy__r.Phone, OrderedBy__r.OtherPhone, Type, RelatedCampaign__r.Name,'
                        + ' EffectiveDate, Status, PaymentMethod__c, FileExportDate__c,'
                        + ' Case__r.CaseNumber, CurrencyIsoCode, TotalAmount, TotalQuantitySummary__c, OrderNotes__c,'
                        + ' ShippingAddress__r.Name, ShippingAddress__r.Country__c, ShippingAddress__r.City2__r.Name,'
                        + ' ShippingAddress__r.Ward2__r.Name, ShippingAddress__r.District__r.Name, ShippingAddress__r.Region__r.Name,'
                        + ' ShippingAddress__r.Street1__c, ShippingAddress__r.Street2__c, ShippingAddress__r.UnitNumber__c, OrderNumber, CreatedBy.LastName, CreatedBy.FirstName, Account.Market__c,'
                        + ' ShippingAddress__r.AddressValidationStatus__c,ShippingAddress__r.FullAddress__c,ShippingAddress__r.Building__c,'
                        + ' ShippingAddress__r.Road__c,ShippingAddress__r.PostalCode__c,PreferredDeliveryDate__c,PreferredDeliveryTime__c,'
                        + ' OrderCacellationReason__r.Name,EndDate,Id,'
                        + ' (SELECT Promotion__r.Name, OrderItemNumber, PricebookEntry.Product2.Name, PricebookEntry.ProductCode, Quantity, CurrencyIsoCode, UnitPrice,'
                        + ' TotalPrice, PricebookEntry.Product2.KeyBrand__c, OrderedFor__r.Name, Category__c,Status__c,Id '
                        + ' FROM OrderItems)'
                        + ' FROM Order'
                        + ' WHERE Status =: status'
                        + ' AND Account.Market__c =: Market'
                        + filter
                        + ' Order by OrderNumber';

        if(String.isNotBlank(queryOverride)){
            queryStr = queryOverride;
        }
        
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> oList){
        Map<Id, Order> orderMap = new Map<Id, Order>();
        Map<Id, List<OrderItem>> orderItemMap = new Map<Id, List<OrderItem>>();

        for(Order o: oList){
            o.Status = CommonConstant.ORDER_STATUS_TRANSFERRED;         
            o.Extracted__c = true;
            o.FileExportDate__c = Date.today();
            orderMap.put(o.Id, o);
        }

        List<OrderExport2__c> exportList = new List<OrderExport2__c>();

        for(Database.saveResult sr: Database.Update(orderMap.values(), false)){
            if(sr.isSuccess()){
                Order o = orderMap.get(sr.getId());

                if (isMultiline) {
                    OrderExport2__c oe = new OrderExport2__c();
                    processOrder(oe,o);
                    Boolean isFirst = true;
                    for(OrderItem oi: o.OrderItems){
                        processMultiLineOrderItem(oe,oi,isFirst);
                        isFirst = false;
                    }
                    exportList.add(oe);
                } else {
                    for(OrderItem oi: o.OrderItems){
                        OrderExport2__c oeRow = new OrderExport2__c();
                        processOrder(oeRow,o);
                        processOrderItem(oeRow,oi);
                        exportList.add(oeRow);
                    }
                }  
            }
        }

        if(!exportList.isEmpty()){ Database.insert(exportList); }
    }

    public OrderExport2__c processOrder(OrderExport2__c oe, Order o) {
        oe.Order__c = o.Id;
        oe.Order_Number__c = o.OrderNumber;
        oe.Contact_Ref_No__c = o.OrderedBy__r.ContactRefNo__c;
        oe.Name__c = o.OrderedBy__r.Name;
        oe.Street_1__c = o.ShippingAddress__r.Street1__c;
        oe.Street_2__c = o.ShippingAddress__r.Street2__c;
        oe.UnitNumber__c = o.ShippingAddress__r.UnitNumber__c;
        oe.Ward__c =  o.ShippingAddress__r.Ward2__r.Name;
        oe.District__c = o.ShippingAddress__r.District__r.Name;
        oe.Province__c = o.ShippingAddress__r.City2__r.Name;
        oe.Home_Phone__c = o.OrderedBy__r.HomePhone;
        oe.Mobile__c = o.OrderedBy__r.Phone;
        oe.Other_Phone__c = o.OrderedBy__r.OtherPhone;
        oe.Related_Campaign__c = o.RelatedCampaign__r.Name;

        oe.Order_Amount__c = o.TotalAmount;
        oe.Order_Start_Date__c = String.valueOf(o.EffectiveDate);
        oe.File_Export_Date__c = String.valueOf(Date.Today());
        oe.Created_By__c = o.CreatedBy.LastName + ' ' + o.CreatedBy.FirstName;
        oe.Order_Notes__c = o.OrderNotes__c;
        oe.Region__c = o.ShippingAddress__r.Region__r.Name;
        oe.Order_Type__c = o.Type;
        oe.Status__c = o.Status;
        oe.Payment_Method__c = o.PaymentMethod__c;
        oe.Case_Number__c = o.Case__r.CaseNumber;
        oe.Total_Quantity__c = 0;
        //rustral : 10.22.2019 - additional fields for SG Market 
        oe.AddressValidationStatus__c = o.ShippingAddress__r.AddressValidationStatus__c;
        oe.FullAddress__c =  String.isEmpty(o.ShippingAddress__r.FullAddress__c) ? '' : o.ShippingAddress__r.FullAddress__c.replace('\r','').replace('\n', ' ').replace('<br>', ' ');
        oe.City__c = o.ShippingAddress__r.City2__r.Name;
        oe.Building__c = o.ShippingAddress__r.Building__c;
        oe.Road__c = o.ShippingAddress__r.Road__c;
        oe.PostalCode__c = o.ShippingAddress__r.PostalCode__c;
        oe.TotalPrice__c = o.TotalAmount;
        oe.PreferredDeliveryDate__c = o.PreferredDeliveryDate__c;
        oe.PreferredDeliveryTime__c = o.PreferredDeliveryTime__c;
        oe.CancellationReason__c = o.OrderCacellationReason__r.Name;
        oe.OrderEndDate__c = o.EndDate;
        oe.SalesforceId__c = o.Id;
                
        oe.FileExportTime__c = Time.newInstance(batchDateExecuted.hour() , batchDateExecuted.minute(), 0, 0);
        return oe;
    }

    public OrderExport2__c processOrderItem(OrderExport2__c oe, OrderItem oi) {
        oe.RelatedContactChild__c = oi.OrderedFor__r.Name;
        oe.Promotion__c = oi.Promotion__r.Name == null ? '' : oi.Promotion__r.Name;
        oe.Key_Brand__c = oi.PricebookEntry.Product2.KeyBrand__c == null ? '' : oi.PricebookEntry.Product2.KeyBrand__c;                        
        oe.Ordered_For__c = oi.OrderedFor__r.Name == null ? '' : oi.OrderedFor__r.Name;                        
        oe.Category__c = oi.Category__c == null ? '' : oi.Category__c;
        oe.Order_Product_Number__c = oi.OrderItemNumber;
        oe.Product_Code__c = oi.PricebookEntry.ProductCode;
        oe.Product_Name__c = oi.PricebookEntry.Product2.Name;
        oe.Unit_Price__c = String.valueOf(oi.UnitPrice);
        oe.Quantity__c = oi.Quantity;
        oe.OrderProductStatus__c = oi.Status__c;
        oe.OrderProductId__c = oi.Id;

        return oe;
    }

    public OrderExport2__c processMultiLineOrderItem(OrderExport2__c oe, OrderItem oi, Boolean isFirst) {
        String promo = oi.Promotion__r.Name == null ? '' : oi.Promotion__r.Name;
        oe.Promotion__c = isFirst ? promo : oe.Promotion__c + '; ' + promo;

        String keyBrand = oi.PricebookEntry.Product2.KeyBrand__c == null ? '' : oi.PricebookEntry.Product2.KeyBrand__c;
        oe.Key_Brand__c = isFirst ? keyBrand : oe.Key_Brand__c + '; ' + keyBrand;
        
        String orderedFor = oi.OrderedFor__r.Name == null ? '' : oi.OrderedFor__r.Name;
        oe.Ordered_For__c = isFirst ? orderedFor : oe.Ordered_For__c + '; ' + orderedFor;
        
        String category = oi.Category__c == null ? '' : oi.Category__c;
        oe.Category__c = isFirst ? category : oe.Category__c + '; ' + category;
        oe.Order_Product_Number__c = isFirst ? oi.OrderItemNumber : oe.Order_Product_Number__c + '; ' + oi.OrderItemNumber;
        oe.Product_Code__c = isFirst ? oi.PricebookEntry.ProductCode : oe.Product_Code__c + '; ' + oi.PricebookEntry.ProductCode;
        oe.Total_Quantity__c += oi.Quantity;
        oe.Product_Name__c = isFirst ?
                            String.valueof(Integer.valueof(oi.Quantity)) + ' ' + oi.PricebookEntry.Product2.Name :
                            oe.Product_Name__c + '; ' + String.valueof(Integer.valueOf(oi.Quantity)) + ' ' +  oi.PricebookEntry.Product2.Name;

        oe.Unit_Price__c = isFirst ? String.valueOf(oi.UnitPrice) : oe.Unit_Price__c + '; ' + String.valueOf(oi.UnitPrice);

        return oe;
    }

    global void finish(Database.BatchableContext BC){}
}