/*----------------------------------------------------------------------------------------
Author:      Rey Austral
Description: Batch Class to export order to bpcs

History
08/06/2019   Raustral   Created
08/27/2019   Raustral   Added creation of csv
02/25/2021   malviz     removed createddate/lastmodified date filter to extract missed orders
5/28/2021    patricia   Added send email on finish
9/7/2021     cibarra    Include the txt file into the email
9/8/2022     fgomendoza Add sendErrorEmail
-------------------------------------------------------------------------------------------*/
global class ExportOrderSGBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public Map<Integer, String> spaceMap;
    private Id contentVersionId;
    private Id contentVersionTXTId;
    private Integer orderSize = 0;
    List<Order> orderUpdateSuccessList = new List<Order>();
    List<Order> orderUpdateFailedList = new List<Order>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Ordernumber, PreferredDeliveryDate__c, OrderedBy__r.Name,OrderNotes__c	,'
                     + 'ShippingAddress__r.Street1__c, ShippingAddress__r.Street2__c, ShippingAddress__r.PostalCode__c, ShippingAddress__r.UnitNumber__c,'
                     + 'ShippingAddress__r.StateProvince__c, ShippingAddress__r.Country__c,TotalAmountExclGst__c,'
                     + '(SELECT  OrderItemNumber, PricebookEntry.Product2.Name, PricebookEntry.ProductCode, Quantity, CurrencyIsoCode, UnitPrice, GST__c, UnitPriceExclGst__c, '
                     + 'TotalPrice, PricebookEntry.Product2.KeyBrand__c, OrderedFor__r.Name FROM OrderItems) '
                     + 'From Order '
                     + 'WHERE Account.Market__c = \'SG\' '
                     + 'AND Status = \'Submitted\' '
                     + 'AND Type != \'' + CommonConstant.ORDER_TYPE_SAMPLEREQUEST  +  '\' '
                     + 'AND  (lastmodifieddate <= YESTERDAY OR createddate <= YESTERDAY)' //createddate is used for the test class
                     //+ 'AND (lastmodifieddate > 2019-08-07T10:00:00Z) '
              		// + 'AND OrderNotes__c != null '
                     + 'Order by OrderNumber';
                    system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        spaceMap = generateSpace();
        String street2;
        String unitNumber;
        
        orderSize = scope.size();
        
        AffiliateMetadata__mdt am = [Select BPCSEntity__c, BPCSTradingPartner__c from AffiliateMetadata__mdt where MasterLabel = 'SG' Limit 1];
        String orderString = '';
        system.debug(scope.size());
        for (Order o : scope) {
            street2 = o.ShippingAddress__r.Street2__c;
            unitNumber = o.ShippingAddress__r.UnitNumber__c;
            
            orderString = orderString + 'ST' + spaceMap.get(7);
            orderString = orderString +  spaceMap.get(491) + '\r\n'; //(464)Filler ,(15)GUI Global Unique No#  System Date + System Time , (12)*System Generated
            //generate the header - HD
            orderString = orderString + 'HD' + spaceMap.get(7);
            orderString = orderString + formatValue(am.BPCSTradingPartner__c,15);
            //Entity- Translate to BPCS Customer Number + Ship To Number
            orderString = orderString + formatValue(am.BPCSEntity__c,35); //affiliate metadata 
            String orderNumber = o.OrderNumber.replace('O-', 'TELE1');
            orderString = orderString + formatValue(orderNumber,15);
            String preferredDate =  o.PreferredDeliveryDate__c == null ? '' : formatDate( o.PreferredDeliveryDate__c );
            orderString = orderString + formatValue(preferredDate, 8);
            orderString = orderString + spaceMap.get(3); //currency
            orderString = orderString + spaceMap.get(2); //Inventory Reason Code 
            orderString = orderString + spaceMap.get(6); //Salesperson Number 
            orderString = orderString + spaceMap.get(30); //Delivery Attention Name
            orderString = orderString + formatValue(o.OrderedBy__r.Name, 30);
            orderString = orderString + formatValue(o.ShippingAddress__r.Street1__c, 30); 
            //orderString = orderString + formatValue(o.ShippingAddress__r.Street2__c, 30); 
            orderString = orderString + (street2 != null && unitNumber != null ? formatValue(street2 + ' ' + unitNumber, 30) : 
            							street2 != null && unitNumber == null ? formatValue(street2, 30) : 
            							street2 == null && unitNumber != null ? formatValue(unitNumber, 30) : spaceMap.get(30));
            orderString = orderString + spaceMap.get(30); //street 3
            orderString = orderString + formatValue(o.ShippingAddress__r.PostalCode__c, 9);
            orderString = orderString + formatValue(o.ShippingAddress__r.StateProvince__c, 3);
            orderString = orderString + spaceMap.get(4); //Country
            orderString = orderString +  spaceMap.get(241); //(209)Filler,(5)EDI Group Customer number ,(15)GUI Global Unique No , (12) EDI Source Document Text file Name 
            orderString = orderString + '\r\n';

            //generate DT
            
            Integer ctr = 1;
            for(OrderItem oi : o.OrderItems) {
                orderString = orderString + 'DT' + spaceMap.get(7);
                orderString = orderString + formatValue(orderNumber,15);
                orderString = orderString + formatIntegerValue(String.valueOf(ctr),3);
                orderString = orderString + formatValue(String.valueOf(oi.PricebookEntry.ProductCode), 15);
                orderString = orderString + formatIntegerValue(String.valueOf(oi.Quantity.setscale(3)), 11);
                orderString = orderString + spaceMap.get(2); //Unit Of Measure            
                orderString = orderString + formatIntegerValue(String.valueOf(oi.UnitPriceExclGst__c.setscale(4)), 15); //change from totalprice to UnitPrice
                orderString = orderString + spaceMap.get(430); //(403)filler , (15) GUI Global Unique No#  System Date + System Time,(12) EDI Source Document Text file Name
                orderString = orderString + '\r\n';
                ctr++;
             }

            //generate note            
            String notes = String.isBlank(o.OrderNotes__c) ? 'Preferred Delivery Date: ' + preferredDate : o.OrderNotes__c.replace('\r','').replace('\n', ' ')  + ' Preferred Delivery Date: ' +  preferredDate;

            if (50 < notes.length()) {                 
                Integer counter = 1;
                while (notes.length() != 0) {
                    orderString = orderString + 'ON' + spaceMap.get(7) ;
                    orderString = orderString + formatIntegerValue(String.valueOf(counter) ,3);
                    orderString = orderString + formatValue(notes.left(50), 50);
                    orderString = orderString + spaceMap.get(438); //(411)filler , (15) GUI Global Unique No#  System Date + System Time,(12) EDI Source Document Text file Name
                    orderString = orderString + '\r\n';
                    notes = notes.removeStart(notes.left(50));
                    counter = counter+1;
                }
            } else {
                orderString = orderString + 'ON' + spaceMap.get(7) ;
                orderString = orderString + '001';
                orderString = orderString + formatValue(notes, 50);
                orderString = orderString + spaceMap.get(438); //(411)filler , (15) GUI Global Unique No#  System Date + System Time,(12) EDI Source Document Text file Name
                orderString = orderString + '\r\n';
            }
            //generate end file
            orderString = orderString + 'END' + spaceMap.get(6);
            orderString = orderString +  spaceMap.get(491) + '\r\n'; //filler

            o.Status = CommonConstant.ORDER_STATUS_TRANSFERRED;
        }

        orderString = orderString.removeEnd('\r\n');     
        contentVersionTXTId = uploadFile(orderString, 'SG' + formatDate(Date.today()).substring(2,8) , '.txt');

        updateOrder(scope);
        generateCSVfile();
    }

    global void finish(Database.BatchableContext BC) {
        if(orderSize == 0){
            sendBlankEmail();
        }
        else{
            if(contentVersionId != null){
                sendEmail(contentVersionId, contentVersionTXTId, orderUpdateSuccessList.size() );
            }
            if(!orderUpdateFailedList.isEmpty()) {
                UtilityClass.updateList(orderUpdateFailedList);
                sendErrorEmail(orderUpdateFailedList);
            }
        }
    }

    public void updateOrder(List<Order> orderList){
        List<Database.SaveResult> srList = Database.update(orderList, false);
        for (Integer i=0; i<srList.size(); i++) {
            Order orderRecord = new Order();
            if (srList.get(i).isSuccess()){
                orderRecord.Id = String.valueOf(orderList.get(i).get('Id'));
                orderUpdateSuccessList.add(orderRecord);
            }
            else if (!srList.get(i).isSuccess()){
                orderRecord.Id = String.valueOf(orderList.get(i).get('Id'));
                orderRecord.Status = 'Draft';
                orderUpdateFailedList.add(orderRecord);
                Database.Error e = srList.get(i).getErrors().get(0);
                System.debug('Update Failed: ' + e.getStatusCode() + ': ' + e.getMessage());
                System.debug('Order fields that affected this error: ' + e.getFields());           
            }
        }
    }

    public void sendErrorEmail(List<Order> orderList){
        List<String> recip = Label.OrderReportErrorEmailRecepient.split(',');
        
        if(!recip.isEmpty()){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject(String.valueOf(Date.today()) + ' ANI SG Error Order Report');
            semail.setToAddresses(recip);
            String htmlBody = 'Please find the following SG Order details below with errors for ' + String.valueOf(Date.today()) + '.' + ' Total number of error orders: ' + orderList.size() + '.<br/>';
            /*Start Table*/
            htmlBody += '<table border="1" style="border-collapse: collapse"><caption>Order Error List</caption>'
            + '<tr><th>Id</th><th>OrderNumber</th><th>OrderCode__c</th><th>CreatedBy.Name</th><th>CreatedDate</th><th>LastModifiedBy.Name</th><th>LastModifiedDate</th></tr>';
            for(Order o : [SELECT Id, OrderNumber, OrderCode__c, CreatedBy.Name, CreatedDate, LastModifiedBy.Name, LastModifiedDate FROM Order WHERE Id IN: orderList]){
                htmlBody += '<tr><td>' + o.Id + '</td><td>' + o.OrderNumber + '</td><td>' + o.OrderCode__c + '</td><td>' + o.CreatedBy.Name + '</td><td>' + o.CreatedDate + '</td><td>' + o.LastModifiedBy.Name + '</td><td>' + o.LastModifiedDate + '</td></tr>';
            }
            htmlBody += '</table>';
            /*End Table*/
            semail.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        }
    }

    public void sendBlankEmail(){
        List<String> recip = Label.OrderReportErrorEmailRecepient.split(',');
        
        if(!recip.isEmpty()){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject(String.valueOf(Date.today()) + ' ANI SG Error Order Report');
            semail.setToAddresses(recip);
            String htmlBody = 'No Order has been processed for ' + String.valueOf(Date.today()) + '.';
            semail.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        }
    }

    public Map<Integer, String> generateSpace() {
        Map<Integer, String> resultMap = new Map<Integer, String>();
        String result = '';
        resultMap.put(0, result);
        for (Integer ctr = 1; ctr < 500; ctr++) {
            result =  result + ' ';
            resultMap.put(ctr, result);
        }
        return resultMap;
    }

    public Id uploadFile(String fileContent, String fileName, String fileType) {   
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = fileName + fileType; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = blob.valueOf(fileContent); // converting your binary string to Blog
        insert conVer;

        conVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id LIMIT 1];

        String libraryName = 'Order Export Library - SG';
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

    public String formatValue(String content, Integer maxLength) {     
        content = String.isBlank(content) ? '' : content;
        if (maxLength < content.length()) {
            content = content.substring(0, maxLength);
        } else {
            content = content + spaceMap.get( maxLength - content.length() );
        }

        return content;
    }

    public String formatIntegerValue(String content, Integer maxLength) {     
        content = String.isBlank(content) ? '' : content.remove('.');
        if (maxLength < content.length()) {
            content = content.substring(0, maxLength);
        } else {
            
            String preZero = '';
            for(Integer ctr=0; ctr<maxLength - content.length(); ctr++) {
                preZero = preZero + '0';
            }

            content = preZero + content;
        }

        return content;
    }

    public String formatDate(Date value) {
        String result;
        result = String.valueOf( value.year() );
        result = String.valueOf( value.month() ).length() == 1 ? result + '0' + value.month() : result + '' + value.month();
        result = String.valueOf( value.day() ).length() == 1 ? result + '0' + value.day() : result + '' + value.day();
        return result;
    }   

    public void generateCSVfile() {
        List<OrderItem> itemList  = [Select Order.OrderedBy__r.Name, Order.OrderedBy__r.ContactRefNo__c, Order.OrderedBy__r.HomePhone,Order.OrderedBy__r.Phone, Order.OrderedBy__r.OtherPhone, Order.Type , 
                                        Order.RelatedCampaign__r.Name,Order.EffectiveDate, Order.Status, Order.PaymentMethod__c, Promotion__r.Name, Order.FileExportDate__c,
                                        Order.Case__r.CaseNumber, Order.CurrencyIsoCode, Order.TotalAmount, Order.TotalQuantitySummary__c, Order.OrderNotes__c, Order.ShippingAddress__r.PostalCode__c,
                                        Order.ShippingAddress__r.UnitNumber__c, Order.ShippingAddress__r.Name, Order.ShippingAddress__r.Country__c, Order.ShippingAddress__r.City2__r.Name, Order.ShippingAddress__r.Ward2__r.Name,
                                        Order.ShippingAddress__r.District__r.Name, Order.ShippingAddress__r.Region__r.Name, Order.ShippingAddress__r.Street1__c, Order.ShippingAddress__r.Street2__c,
                                        Order.ShippingAddress__r.SubDistrict__r.Name, Order.ShippingAddress__r.Building__c, Order.ShippingAddress__r.VillageNo__c, Order.ShippingAddress__r.VillageName__c, Order.ShippingAddress__r.Road__c,
                                        OrderItemNumber, PricebookEntry.Product2.Name, PricebookEntry.ProductCode, Quantity, CurrencyIsoCode, UnitPrice, TotalPrice, PricebookEntry.Product2.KeyBrand__c, Order.OrderNumber,
                                        Order.CreatedBy.Name, Order.PreferredDeliveryDate__c, toLabel(Order.PreferredDeliveryTime__c), OrderedFor__r.Name, Order.ShippingAddress__r.FullAddress__c, Order.ShippingAddress__r.AddressValidationStatus__c,
                                        Order.EndDate, Order.OrderCacellationReason__r.Name, OrderId, GST__c, Order.TotalAmountExclGst__c, UnitPriceExclGst__c,TotalPriceExclGst__c,Status__c 
                                    From OrderItem 
                                    WHERE Order.Id IN: orderUpdateSuccessList
                                    Order by Order.OrderNumber];
        if(!itemList.isEmpty()){
            String generatedCSVFile = OrderReportCSVGenerator.generateCSV(itemList);
            Datetime now = Datetime.now(); 
            Integer offset = UserInfo.getTimezone().getOffset(now); 
            Datetime local = now.addSeconds(offset/1000);
            
            contentVersionId = uploadFile(generatedCSVFile, 'ExtractedOrderReport_SG_' + local , '.csv');
        }
    }
    
    private static void sendEmail (Id contentVersionId, Id contentVersionTXTId, Integer orderSize) {
        
        List<String> recip = Label.OrderReportEmailRecepient.split(',');
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        
        ContentVersion doc;
        
        doc = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
        
        attachment.setBody(doc.VersionData);
        attachment.setFileName(doc.Title + '.csv');
        fileAttachments.add(attachment);
        
        
        ContentVersion doc2;
        Messaging.EmailFileAttachment attachment2 = new Messaging.EmailFileAttachment();
        
        doc2 = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionTXTId LIMIT 1];
        
        attachment2.setBody(doc2.VersionData);
        attachment2.setFileName(doc2.Title + '.txt');
        fileAttachments.add(attachment2);

        
        String body;
        body = 'Please find the successfully processed SG Order details for ' + String.valueOf(Date.today()) + '.';
        body += 'Total number of orders: ' + String.valueof(orderSize) + '.';
        
        if(!recip.isEmpty()){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject(String.valueOf(Date.today()) + ' ANI SG Order Report');
            semail.setToAddresses(recip);
            semail.setPlainTextBody('Please find the successfully processed SG Order details for ' + String.valueOf(Date.today()) + '.' + ' Total number of orders: ' + String.valueof(orderSize) + '.');
            if(!fileAttachments.isEmpty()) semail.setFileAttachments(fileAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
        }
    }
}