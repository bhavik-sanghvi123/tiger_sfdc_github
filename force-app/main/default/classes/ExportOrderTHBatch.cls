/*----------------------------------------------------------------------------------------
Author:      Rey Austral
Description: Batch Class to export order for TH

History
09/30/2019   Raustral   Created
04/28/2020   Jericson   updated to make it dynamic based on Market
-------------------------------------------------------------------------------------------*/
global class ExportOrderTHBatch implements Database.Batchable<sObject> {
    
    String Market;
    public ExportOrderTHBatch(String m){
        Market = m;
    }
    public Map<Integer, String> spaceMap;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id '
                     + 'From Order '
                     + 'WHERE Account.Market__c =: Market '
                     + 'AND Status = \'Submitted\' '               
                     + 'Order by OrderNumber';
                    system.debug(query);
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<Order> scope) {
       Map<Id,Order> toUpdateMap  = new Map<Id,Order>();
       String query = 'Select Order.OrderedBy__r.Name, Order.OrderedBy__r.ContactRefNo__c, Order.OrderedBy__r.HomePhone,Order.OrderedBy__r.Phone, Order.OrderedBy__r.OtherPhone, Order.Type , '
                + ' Order.RelatedCampaign__r.Name,Order.EffectiveDate, Order.Status, Order.PaymentMethod__c, Promotion__r.Name, Order.FileExportDate__c,'
                + ' Order.Case__r.CaseNumber, Order.CurrencyIsoCode, Order.TotalAmount, Order.TotalQuantitySummary__c, Order.OrderNotes__c, Order.ShippingAddress__r.PostalCode__c,'
                + ' Order.ShippingAddress__r.Name, Order.ShippingAddress__r.Country__c, Order.ShippingAddress__r.City2__r.Name, Order.ShippingAddress__r.Ward2__r.Name,'
                + ' Order.ShippingAddress__r.District__r.Name, Order.ShippingAddress__r.Region__r.Name, Order.ShippingAddress__r.Street1__c, Order.ShippingAddress__r.Street2__c,'
                + ' Order.ShippingAddress__r.SubDistrict__r.Name, Order.ShippingAddress__r.Building__c, Order.ShippingAddress__r.VillageNo__c, Order.ShippingAddress__r.VillageName__c, Order.ShippingAddress__r.Road__c,'
                + ' OrderItemNumber, PricebookEntry.Product2.Name, PricebookEntry.ProductCode, Quantity, CurrencyIsoCode, UnitPrice, TotalPrice, PricebookEntry.Product2.KeyBrand__c, Order.OrderNumber,'
                + ' Order.CreatedBy.Name, Order.PreferredDeliveryDate__c, Order.PreferredDeliveryTime__c, OrderedFor__r.Name, Order.ShippingAddress__r.FullAddress__c, Order.ShippingAddress__r.AddressValidationStatus__c,'
                + ' Order.EndDate, Order.OrderCacellationReason__r.Name, OrderId, Status__c, Id '
                + ' From OrderItem '
                + ' WHERE Order.Id IN: scope '              
                + ' Order by Order.OrderNumber';
        String generatedCSVFile ='';
        generatedCSVFile = genereateHeader().removeEnd(',') + '\n';
        String fileRow = '';
        for (OrderItem orderItem : Database.query(query)) {
            fileRow = '';
            fileRow = orderItem.Order.OrderNumber;
            fileRow = fileRow +','+ orderItem.Order.OrderedBy__r.ContactRefNo__c;
            fileRow = fileRow +','+ orderItem.Order.OrderedBy__r.Name;
            fileRow = fileRow +','+ orderItem.OrderedFor__r.Name;
            fileRow = fileRow +','+ forceString( orderItem.Order.ShippingAddress__r.Street1__c);
            fileRow = fileRow +','+ forceString( orderItem.Order.ShippingAddress__r.Street2__c );
            fileRow = fileRow +','+ orderItem.Order.ShippingAddress__r.City2__r.Name;
            fileRow = fileRow +','+ forceString( orderItem.Order.ShippingAddress__r.Building__c );
            fileRow = fileRow +','+ formatString( orderItem.Order.ShippingAddress__r.District__r.Name);
            fileRow = fileRow +','+ formatString( orderItem.Order.ShippingAddress__r.SubDistrict__r.Name );
            fileRow = fileRow +','+ forceString( orderItem.Order.ShippingAddress__r.VillageNo__c );
            fileRow = fileRow +','+ formatString( orderItem.Order.ShippingAddress__r.VillageName__c );
            fileRow = fileRow +','+ formatString( orderItem.Order.ShippingAddress__r.Ward2__r.Name );
            fileRow = fileRow +','+ formatString( orderItem.Order.ShippingAddress__r.Road__c );
            fileRow = fileRow +','+ formatString( orderItem.Order.ShippingAddress__r.PostalCode__c );
            fileRow = fileRow +','+ forceString( orderItem.Order.OrderedBy__r.HomePhone );
            fileRow = fileRow +','+ forceString( orderItem.Order.OrderedBy__r.Phone );
            fileRow = fileRow +','+ forceString( orderItem.Order.OrderedBy__r.OtherPhone );
            fileRow = fileRow +','+ orderItem.Order.RelatedCampaign__r.Name;
            fileRow = fileRow +','+ forceString( orderItem.OrderItemNumber );
            fileRow = fileRow +','+ orderItem.PricebookEntry.ProductCode;
            fileRow = fileRow +','+ orderItem.Quantity;
            fileRow = fileRow +','+ orderItem.PricebookEntry.Product2.Name;
            fileRow = fileRow +','+ orderItem.Promotion__r.Name;
            fileRow = fileRow +','+ orderItem.UnitPrice;
            fileRow = fileRow +','+ orderItem.TotalPrice;
            fileRow = fileRow +','+ (orderItem.Order.PreferredDeliveryDate__c == null ? '' : formatCSVDate( orderItem.Order.PreferredDeliveryDate__c) );
            fileRow = fileRow +','+ orderItem.Order.PreferredDeliveryTime__c;
            fileRow = fileRow +','+ (orderItem.Order.EffectiveDate == null ? '' : formatCSVDate( orderItem.Order.EffectiveDate));            
            fileRow = fileRow +','+ formatCSVDate(Date.today());
            fileRow = fileRow +','+ orderItem.Order.CreatedBy.Name;
            fileRow = fileRow +','+ orderItem.PricebookEntry.Product2.KeyBrand__c;
            fileRow = fileRow +','+ (String.isEmpty(orderItem.Order.OrderNotes__c) ? '' : orderItem.Order.OrderNotes__c.replace('\r','').replace('\n', ' ').escapeCsv());
            fileRow = fileRow +','+ orderItem.Order.ShippingAddress__r.Region__r.Name;
            fileRow = fileRow +','+ orderItem.Order.Type;
            fileRow = fileRow +','+ orderItem.Status__c;
            fileRow = fileRow +','+ orderItem.Id;
            fileRow = fileRow +','+ orderItem.Order.Status;
            fileRow = fileRow +','+ orderItem.Order.OrderCacellationReason__r.Name;
            fileRow = fileRow +',';
            fileRow = fileRow +','+ orderItem.Order.PaymentMethod__c;
            fileRow = fileRow +','+ orderItem.Order.Case__r.CaseNumber;
            fileRow = fileRow +','+ orderItem.OrderId;

            generatedCSVFile = generatedCSVFile + fileRow.replace('null', '') + '\n';

            if (!toUpdateMap.containsKey(orderItem.OrderId)) {
                Order o =  new Order();
                o.Id = orderItem.OrderId;
                o.Status = CommonConstant.ORDER_STATUS_TRANSFERRED;
                toUpdateMap.put(orderItem.OrderId, o);
            }
        }
        generatedCSVFile = '\uFEFF' + generatedCSVFile.removeEnd('\n');

        Datetime now = Datetime.now(); Integer offset = UserInfo.getTimezone().getOffset(now); 
        Datetime local = now.addSeconds(offset/1000);

        uploadFile(generatedCSVFile, 'ExtractedOrderReport_' + MARKET + '_' + local , '.csv');
        
        update toUpdateMap.values();
    }
    
    global void finish(Database.BatchableContext BC) {
    } 

    public void uploadFile(String fileContent, String fileName, String fileType) {   
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = fileName + fileType; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = blob.valueOf(fileContent); // converting your binary string to Blog
        insert conVer;

        conVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id LIMIT 1];

        String libraryName = 'Order Export Library - ' + MARKET;
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
    }

    public String formatCSVDate(date value) {
        String result;
        result = String.valueOf( value.day() ).length() == 1 ? '0' + value.day() :  String.valueOf( value.day() );
        result = String.valueOf( value.month() ).length() == 1 ? result + '/0' + value.month() : result + '/' + value.month();
        result = result + '/' + String.valueOf( value.year() );
        return result;
    }

    public String formatString(String value) {
        return String.isEmpty(value) ? '' : value.escapeCsv();
    }

    public String forceString(String value) {
        return String.isEmpty(value) ? '' : ('\'' + value).escapeCsv();
    }

    public String genereateHeader() {
        List<String> headerArray = new List<String>();
        headerArray.add('Order Number');
        headerArray.add('Contact Ref No');
        headerArray.add('Name');
        headerArray.add('Related Contact/Child');
        headerArray.add('House No');
        headerArray.add('Lane');
        headerArray.add('City');
        headerArray.add('Building');
        headerArray.add('District');
        headerArray.add('Sub-District');
        headerArray.add('Village No');
        headerArray.add('Village Name');
        headerArray.add('Ward');
        headerArray.add('Road');
        headerArray.add('Postal Code');
        headerArray.add('Home Phone');
        headerArray.add('Mobile');
        headerArray.add('Other Phone');
        headerArray.add('Related Campaign');
        headerArray.add('Order Product Number');
        headerArray.add('Product Code');
        headerArray.add('Quantity');
        headerArray.add('Product Name');
        headerArray.add('Promotion');
        headerArray.add('Unit Price');
        headerArray.add('Order Amount');
        headerArray.add('Preferred Delivery Date');
        headerArray.add('Preferred Delivery Time');
        headerArray.add('Order Start Date');
        headerArray.add('File Export Date');
        headerArray.add('Created By');
        headerArray.add('Key Brand');
        headerArray.add('Order Notes');
        headerArray.add('Region');
        headerArray.add('Order Type');
        headerArray.add('Order Product Status');
        headerArray.add('Order Product Id');
        headerArray.add('Status');
        headerArray.add('Cancellation Reason');
        headerArray.add('Order End Date');
        headerArray.add('Payment Method');
        headerArray.add('Case Number');
        headerArray.add('Salesforce Id');

        return string.join(headerArray, ',');
    }
}