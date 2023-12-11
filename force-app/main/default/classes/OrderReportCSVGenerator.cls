public with sharing class OrderReportCSVGenerator {
    public static String generateCSV(List<OrderItem> itemList) {
        String generatedCSVFile ='';
        generatedCSVFile = genereateHeader().removeEnd(',') + '\n';
        String fileRow = '';
        for (OrderItem orderItem : itemList) {
            fileRow = '';
            fileRow = orderItem.Order.OrderNumber;
            fileRow = fileRow +','+ orderItem.Order.OrderedBy__r.ContactRefNo__c;
            fileRow = fileRow +','+ orderItem.Order.OrderedBy__r.Name;
            fileRow = fileRow +','+ orderItem.OrderedFor__r.Name;
            fileRow = fileRow +','+ orderItem.Order.ShippingAddress__r.AddressValidationStatus__c;
            fileRow = fileRow +','+ formatString(orderItem.Order.ShippingAddress__r.FullAddress__c);
            fileRow = fileRow +','+ forceString( orderItem.Order.ShippingAddress__r.Street1__c);
            fileRow = fileRow +','+ forceString( orderItem.Order.ShippingAddress__r.Street2__c );
            fileRow = fileRow +','+ forceString(orderItem.Order.ShippingAddress__r.UnitNumber__c);
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
            fileRow = fileRow +','+ formatString( orderItem.Order.RelatedCampaign__r.Name );
            fileRow = fileRow +','+ forceString( orderItem.OrderItemNumber );
            fileRow = fileRow +','+ orderItem.PricebookEntry.ProductCode;
            fileRow = fileRow +','+ orderItem.Quantity;
            fileRow = fileRow +','+ orderItem.PricebookEntry.Product2.Name;
            fileRow = fileRow +','+ orderItem.Promotion__r.Name;
            fileRow = fileRow +','+ orderItem.UnitPriceExclGst__c;
            fileRow = fileRow +','+ orderItem.TotalPriceExclGst__c;
            fileRow = fileRow +','+ orderItem.Order.TotalAmountExclGst__c;
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
        }
        return generatedCSVFile = '\uFEFF' + generatedCSVFile.removeEnd('\n');
    }

    public static String formatCSVDate(date value) {
        String result;
        result = String.valueOf( value.day() ).length() == 1 ? '0' + value.day() :  String.valueOf( value.day() );
        result = String.valueOf( value.month() ).length() == 1 ? result + '/0' + value.month() : result + '/' + value.month();
        result = result + '/' + String.valueOf( value.year() );
        return result;
    }

    public static String formatString(String value) {
        return String.isEmpty(value) ? '' : value.replace('\r','').replace('\n', ' ').replace('<br>', ' ').escapeCsv();
    }

    public static String forceString(String value) {
        String result = '';
        if (!String.isEmpty(value) && value.contains(','))   {
            result =  value.replace('\r','').replace('\n', ' ').replace('<br>', ' ').escapeCsv();
        } else if (!String.isEmpty(value)){
            result = '\'' + value.replace('\r','').replace('\n', ' ').replace('<br>', ' ').escapeCsv();
        }  
        return result;
    }

    public static String genereateHeader() {
        List<String> headerArray = new List<String>();
        headerArray.add('Order Number');
        headerArray.add('Contact Ref No');
        headerArray.add('Name');
        headerArray.add('Related Contact/Child');
        headerArray.add('Address Validation Status');
        headerArray.add('Full Address');
        headerArray.add('Street 1');
        headerArray.add('Street 2');
        headerArray.add('Unit Number');
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
        headerArray.add('Total Price');
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