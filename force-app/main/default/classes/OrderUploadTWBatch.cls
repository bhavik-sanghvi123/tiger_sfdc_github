/*
Author: Frank Gomendoza
Description: Batch job that creates records on Order and OrderItem object via consuming records from staging object TW_Order_Manual__c
*/
global class OrderUploadTWBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    Set<String> affiliateValueInsertKeys = new Set<String>();
    Set<String> addressInsertKeys = new Set<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, CreatedDate, Status__c, Phone__c, Birthdate__c, Product_1__c, Quantity_1__c, Product_2__c, Quantity_2__c, Product_3__c, Quantity_3__c, Product_4__c, Quantity_4__c, '
            + 'Payment_Type__c, VAT__c, Preferred_Delivery_Time__c, Preferred_Delivery_Date__c, Description__c, Customer__c, Receiver_Name__c, Type__c, Sales_Person__c, Pricebook_Name__c, Promoter_Code__c, '
            + 'City__c, District__c, Street__c, Tax_ID__c, Tax_Name__c '
            + 'FROM TW_Order_Manual__c '
            + 'WHERE Status__c = \'Pending\' '
            + 'Order By Name, Phone__c ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<TW_Order_Manual__c> scope) {
        for(TW_Order_Manual__c s : scope){
            System.debug(s);
        }
        System.debug('scope size---'+scope.size());
        
        if(!scope.isEmpty()) {
            Id recTypeSuccess = Schema.sObjectType.TW_Order_Manual__c.getRecordTypeInfosByName().get('Success').getRecordTypeId();
            Set<Date> childBirthDateSet = new Set<Date>();
            Set<String> parentPhoneStringSet = new Set<String>();
            Set<String> productStringSet = new Set<String>();
            Set<String> abbottPartnerStringSet = new Set<String>();
            Set<String> affiliateValueStringSet = new Set<String>();
            Set<String> pricebookNameStringSet = new Set<String>();
            Set<Id> orderManualUpdateKeys = new Set<Id>();
            Map<String, TW_Order_Manual__c> twOrderManualMap = new Map<String, TW_Order_Manual__c>();
            Map<String, Contact> parentPhoneMap = new Map<String, Contact>();
            Map<String, Map<String, Address__c>> parentAddressMap = new Map<String, Map<String, Address__c>>();
            Map<String, Affiliate_Value__c> affiliateValueMap = new Map<String, Affiliate_Value__c>();
            Map<String, Contact> childParentMap = new Map<String, Contact>();
            Map<String, Decimal> childToOrderItemCountMap = new Map<String, Decimal>();
            Map<String, Product2> productMap = new Map<String, Product2>();
            Map<String, Id> pricebookMap = new Map<String, Id>();
            Map<String, Map<String, PricebookEntry>> pricebookToPBEntryMap = new Map<String, Map<String, PricebookEntry>>();
            Map<String, AbbottPartner__c> abbottPartnerMap = new Map<String, AbbottPartner__c>();
            Map<Id, TW_Order_Manual__c> orderManualUpdateMap = new Map<Id, TW_Order_Manual__c>();
            List<Affiliate_Value__c> affiliateValueCityInsertList = new List<Affiliate_Value__c>();
            List<Affiliate_Value__c> affiliateValueDistrictInsertList = new List<Affiliate_Value__c>();
            List<Address__c> addressInsertList = new List<Address__c>();
            List<Order> orderInsertList = new List<Order>();
            List<OrderItem> orderItemInsertList = new List<OrderItem>();
            
            for(TW_Order_Manual__c o : scope){
                twOrderManualMap.put(o.Id, o);
                if(String.isNotBlank(o.Birthdate__c) ) childBirthDateSet.add( Date.parse(o.Birthdate__c) );
                if(String.isNotBlank(o.Phone__c) ) parentPhoneStringSet.add(o.Phone__c);
                if(String.isNotBlank(o.Product_1__c) ) productStringSet.add(o.Product_1__c);
                if(String.isNotBlank(o.Product_2__c) ) productStringSet.add(o.Product_2__c);
                if(String.isNotBlank(o.Product_3__c) ) productStringSet.add(o.Product_3__c);
                if(String.isNotBlank(o.Product_4__c) ) productStringSet.add(o.Product_4__c);
                if(String.isNotBlank(o.City__c) ) affiliateValueStringSet.add(o.City__c);
                if(String.isNotBlank(o.District__c) ) affiliateValueStringSet.add(o.District__c);
                if(String.isNotBlank(o.Promoter_Code__c) ) abbottPartnerStringSet.add(o.Promoter_Code__c);
                if(String.isNotBlank(o.Sales_Person__c) ) abbottPartnerStringSet.add(o.Sales_Person__c);
                if(String.isNotBlank(o.Pricebook_Name__c) ) pricebookNameStringSet.add(o.Pricebook_Name__c); 
            }
            for(Contact m : [SELECT Id, Phone, Default_Address__c, AccountId,
                             (SELECT Id, ParentContact__c, City2__c, Country__c, DefaultAddress__c, District__c, External_Reference_Number__c, Street1__c FROM Addresses__r)
                             FROM Contact WHERE PrimaryContact__c = true AND Phone IN: parentPhoneStringSet AND Market__c = 'TW'])
            {
                parentPhoneMap.put(m.Phone, m);
                for(Address__c a : m.Addresses__r){
                    List<String> addressHashList = new List<String>();
                    if(a.City2__c != null) addressHashList.add(a.City2__c);
                    if(a.District__c != null) addressHashList.add(a.District__c);
                    if(a.Street1__c != null) addressHashList.add(a.Street1__c);
                    String addressHashKey = String.join(addressHashList, '-');
                    if(parentAddressMap.containsKey(m.Id)){
                        parentAddressMap.get(m.Id).put(addressHashKey, a);
                    }
                    else{
                        parentAddressMap.put(m.Id, new Map<String, Address__c>{addressHashKey => a} );
                    }
                }
            }
            for(Affiliate_Value__c av : [SELECT Id, Name, AffiliateValue__c FROM Affiliate_Value__c WHERE Name IN: affiliateValueStringSet OR AffiliateValue__c IN: affiliateValueStringSet]){
                if(String.IsNotBlank(av.Name) ) affiliateValueMap.put(av.Name, av);
                if(String.IsNotBlank(av.AffiliateValue__c) ) affiliateValueMap.put(av.AffiliateValue__c, av);
            }
            for(Contact c : [SELECT Id, Birthdate, AgeinMonths__c, Parent__c, Parent__r.Phone,
                             (SELECT Id, Product2Id, Product_Code__c, OrderedFor__c, Quantity FROM Order_Products__r) 
                             FROM Contact WHERE PrimaryContact__c = false AND Birthdate IN: childBirthDateSet AND Parent__r.Phone IN: parentPhoneStringSet])
            {
                Datetime bday = c.Birthdate;
                String bdayStringFormat = bday.format('MM/dd/yyyy');
                childParentMap.put(bdayStringFormat + '-' + c.Parent__r.Phone, c);
                for(OrderItem oi: c.Order_Products__r){
                    String childProductHashkey = c.Id + '-' + oi.Product_Code__c;
                    if(childToOrderItemCountMap.containsKey(childProductHashkey)){
                        childToOrderItemCountMap.put(childProductHashkey, childToOrderItemCountMap.get(childProductHashkey) + oi.Quantity);
                    }
                    else{
                        childToOrderItemCountMap.put(childProductHashkey, oi.Quantity);
                    }
                }
            } 
            for(Product2 p : [SELECT Id, Available_For_Promo__c, Max_eligible_for_Promo__c, ProductCode, Min_Birth_Month__c, Max_Birth_Month__c FROM Product2 WHERE ProductCode IN: productStringSet]){
                productMap.put(p.ProductCode, p);
            } 
            for(PricebookEntry pbe : [SELECT Id, UnitPrice, ProductCode, Pricebook2Id, Pricebook2.Name FROM PricebookEntry WHERE Pricebook2.Name IN: pricebookNameStringSet AND Pricebook2.Market__c = 'TW' AND Pricebook2.IsActive = true AND ProductCode IN: productStringSet AND IsActive = true]){
                pricebookMap.put(pbe.Pricebook2.Name, pbe.Pricebook2Id);
                if(pricebookToPBEntryMap.containsKey(pbe.Pricebook2.Name) ){
                    if(pricebookToPBEntryMap.get(pbe.Pricebook2.Name).containsKey(pbe.ProductCode)){
                        System.debug('Duplicate order item found in pricebook : ' +pbe.Pricebook2Id+ ' with product code : ' +pbe.ProductCode);
                    }
                    else{
                        pricebookToPBEntryMap.get(pbe.Pricebook2.Name).put(pbe.ProductCode, pbe);
                    }
                }
                else{
                    pricebookToPBEntryMap.put(pbe.Pricebook2.Name, new Map<String, PricebookEntry>{pbe.ProductCode => pbe} );
                }
            }
            for(AbbottPartner__c ap : [SELECT Id, External_Id__c FROM AbbottPartner__c WHERE External_Id__c IN: abbottPartnerStringSet]){
                abbottPartnerMap.put(ap.External_Id__c, ap);
            }
            
            System.debug('**********Local Map**********');
            System.debug('parentPhoneMap keys: ' +parentPhoneMap.keySet());
            System.debug('parentAddressMap keys: ' +parentAddressMap);
            System.debug('affiliateValueMap keys: ' +affiliateValueMap.keySet());
            System.debug('childParentMap keys: ' +childParentMap.keySet());
            System.debug('childToOrderItemCountMap keys: ' +childToOrderItemCountMap.keySet());
            System.debug('productMap keys: ' +productMap.keySet());
            System.debug('pricebookMap keys: ' +pricebookMap.keySet());
            System.debug('pricebookToPBEntryMap keys: ' +pricebookToPBEntryMap);
            System.debug('abbottPartnerMap keys: ' +abbottPartnerMap.keySet());
			System.debug('**********Stateful Map**********');
            System.debug('affiliateValueInsertKeys keys: ' +affiliateValueInsertKeys);
            System.debug('addressInsertKeys keys: ' +addressInsertKeys);

            for(TW_Order_Manual__c o : scope){
                System.debug('---------------------------------');
                System.debug('TW_Order_Manual__c record :' +o.Id);
                Boolean nextRecord = false;
                //csv required fields check
                if(String.isBlank(o.Birthdate__c) || String.isBlank(o.Phone__c) ){
                    o.Status__c = 'Error';
                    o.Error_Reason__c = 'Phone and Birthdate must be populated';
                    orderManualUpdateMap.put(o.Id, o);
                    continue;
                }
                if(String.isBlank(o.Preferred_Delivery_Date__c )){
                    o.Status__c = 'Error';
                    o.Error_Reason__c = 'Preferred Delivery Date must be populated';
                    orderManualUpdateMap.put(o.Id, o);
                    continue;
                }
                if(String.isBlank(o.VAT__c )){
                    o.Status__c = 'Error';
                    o.Error_Reason__c = 'VAT must be populated';
                    orderManualUpdateMap.put(o.Id, o);
                    continue;
                }
                //validation for Tax Id numeric values only
                if(String.isNotBlank(o.Tax_ID__c) && !o.Tax_ID__c.isNumeric()){
                    o.Status__c = 'Error';
                    o.Error_Reason__c = 'Tax Id must be numeric';
                    orderManualUpdateMap.put(o.Id, o);
                    continue;
                }
                String childParentHashkey = o.Birthdate__c + '-' + o.Phone__c;
                System.debug('childParentHashkey :' +childParentHashkey);
                //Mother-child combination check
                if(childParentMap.containsKey(childParentHashkey)){
                    Contact child = childParentMap.get(childParentHashkey);
                    Contact parent = parentPhoneMap.get(o.Phone__c);
                    
                    //Order and OrderItem required fields check
                    if(String.isBlank(o.Product_1__c) && String.isBlank(o.Product_2__c) && String.isBlank(o.Product_3__c) && String.isBlank(o.Product_4__c) ){
                        o.Status__c = 'Error';
                        o.Error_Reason__c = 'No products inserted';
                        orderManualUpdateMap.put(o.Id, o);
                        continue;
                    }
                    if( (String.isNotBlank(o.Product_1__c) && String.isBlank(o.Quantity_1__c) ) || (String.isNotBlank(o.Product_2__c) && String.isBlank(o.Quantity_2__c) ) ||
                      (String.isNotBlank(o.Product_3__c) && String.isBlank(o.Quantity_3__c) ) || (String.isNotBlank(o.Product_4__c) && String.isBlank(o.Quantity_4__c) ) ){
                        o.Status__c = 'Error';
                        o.Error_Reason__c = 'Quantity is required';
                        orderManualUpdateMap.put(o.Id, o);
                        continue;
                    }
                    if(String.isBlank(o.Pricebook_Name__c)){
                        o.Status__c = 'Error';
                        o.Error_Reason__c = 'Pricebook Name is required';
                        orderManualUpdateMap.put(o.Id, o);
                        continue;
                    }
                    Map<String, Decimal> productQuantityMap = new Map<String, Decimal>();
                    if(String.isNotBlank(o.Product_1__c) && String.isNotBlank(o.Quantity_1__c) ) populateProductQuantityMap(o.Product_1__c, Decimal.valueOf(o.Quantity_1__c), productQuantityMap);
                    if(String.isNotBlank(o.Product_2__c) && String.isNotBlank(o.Quantity_2__c) ) populateProductQuantityMap(o.Product_2__c, Decimal.valueOf(o.Quantity_2__c), productQuantityMap);
                    if(String.isNotBlank(o.Product_3__c) && String.isNotBlank(o.Quantity_3__c) ) populateProductQuantityMap(o.Product_3__c, Decimal.valueOf(o.Quantity_3__c), productQuantityMap);
                    if(String.isNotBlank(o.Product_4__c) && String.isNotBlank(o.Quantity_4__c) ) populateProductQuantityMap(o.Product_4__c, Decimal.valueOf(o.Quantity_4__c), productQuantityMap);
                    
                    for(String productString : productQuantityMap.keySet()){
                        //Product Check
                        if(productMap.containsKey(productString)){
                            Product2 product = productMap.get(productString);
                            Decimal productPurchaseQuantity = productQuantityMap.get(productString);
                            if(!validProductPromoAssignment(child, product, productPurchaseQuantity, childToOrderItemCountMap) ){
                                o.Error_Reason__c = 'Child has exceeded purchase limit for product code: ' +productString;
                                nextRecord = true;
                                break;
                            }
                            if(!validProductBirthRange(child, product) ){
                                o.Error_Reason__c = 'Child age does not fit product birth range for product code: ' +productString;
                                nextRecord = true;
                                break;
                            }
                        }
                        else{
                            o.Error_Reason__c = 'Cannot find existing product with product code: ' +productString;
                            nextRecord = true;
                            break;
                        }
                        
                        //PricebookEntry check
                        if(pricebookToPBEntryMap.containsKey(o.Pricebook_Name__c)){
                            Map<String, PricebookEntry> pricebookEntryMap = pricebookToPBEntryMap.get(o.Pricebook_Name__c);
                            if(!pricebookEntryMap.containsKey(productString)){
                                o.Error_Reason__c = 'Cannot find existing active Pricebook Entry for Pricebook: ' +o.Pricebook_Name__c+ ' with product code: ' +productString;
                                nextRecord = true;
                                break;
                            }
                        }
                        else{
                            o.Error_Reason__c = 'Cannot find existing active Pricebook with name: ' +o.Pricebook_Name__c;
                            nextRecord = true;
                            break;
                        }
                        
                    }
                    
                    if(nextRecord) {
                        o.Status__c = 'Error';
                        orderManualUpdateMap.put(o.Id, o);
                        continue;
                    }
                    
                    //Address check - If Default Address is blank, look for existing address then assign to main contact (not assigned as default address)
                    //If not existing, create new address then assign address to main contact (not assigned as default address)
                    Address__c address = new Address__c();
                    if( String.isNotBlank(o.City__c) || String.isNotBlank(o.District__c) || String.isNotBlank(o.Street__c) ){
                        List<String> addressHashList = new List<String>();
                        if(String.isNotBlank(o.City__c) && affiliateValueMap.containsKey(o.City__c) ){
                            addressHashList.add(affiliateValueMap.get(o.City__c).Id);
                        }
                        if(String.isNotBlank(o.District__c) && affiliateValueMap.containsKey(o.District__c) ){
                            addressHashList.add(affiliateValueMap.get(o.District__c).Id);
                        }
                        if(String.isNotBlank(o.Street__c) ){
                            addressHashList.add(o.Street__c);
                        }
                        String addressHashKey = String.join(addressHashList, '-');
                        
                        if(parentAddressMap.containsKey(parent.Id) ){
                            Map<String, Address__c> addressMap = parentAddressMap.get(parent.Id);
                            if(addressMap.containsKey(addressHashKey)){
                                address = addressMap.get(addressHashKey);
                                System.debug('Address found in related contact address list for main contact: ' + parent.Id);
                            }
                            else{
                                //create address
                                if(!addressInsertKeys.contains(addressHashKey)){
                                    address = createNewAddress(parent, o, affiliateValueMap, affiliateValueCityInsertList, affiliateValueDistrictInsertList);
                                    addressInsertList.add(address);
                                    addressInsertKeys.add(addressHashKey);
                                }
                            }
                        }
                        else{
                            //no existing address in related address list
                            //create address
                            if(!addressInsertKeys.contains(addressHashKey)){
                                address = createNewAddress(parent, o, affiliateValueMap, affiliateValueCityInsertList, affiliateValueDistrictInsertList);
                                addressInsertList.add(address);
                                addressInsertKeys.add(addressHashKey);
                            }
                            
                        }
                    }
                    
                    //Create new Order and OrderItem record
                    processOrder(o, parent, child, address, productMap, pricebookMap, pricebookToPBEntryMap, abbottPartnerMap, orderInsertList, orderItemInsertList);
                }
                else{
                    if(parentPhoneMap.containsKey(o.Phone__c)){
                        o.Status__c = 'Error';
                        o.Error_Reason__c = 'Mother contact found but child is missing.';
                        orderManualUpdateMap.put(o.Id, o);
                        continue;
                    }
                    else{
                        o.Status__c = 'Error';
                        o.Error_Reason__c = 'Mother contact cannot be found.';
                        orderManualUpdateMap.put(o.Id, o);
                        continue;
                    }
                }
            }
            
            //Debug lists
            System.debug('---------------------------------');
            System.debug('affiliateValueCityInsertList size ' +affiliateValueCityInsertList.size());
            if(!affiliateValueCityInsertList.isEmpty()){
                for(Affiliate_Value__c a : affiliateValueCityInsertList){
                    System.debug(a);
                }
            }
            System.debug('affiliateValueDistrictInsertList size ' +affiliateValueDistrictInsertList.size());
            if(!affiliateValueDistrictInsertList.isEmpty()){
                for(Affiliate_Value__c a : affiliateValueDistrictInsertList){
                    System.debug(a);
                }
            }
            System.debug('addressInsertList size ' +addressInsertList.size());
            if(!addressInsertList.isEmpty()){
                for(Address__c a : addressInsertList){
                    System.debug(a);
                }
            }
            System.debug('orderInsertList size ' +orderInsertList.size());
            if(!orderInsertList.isEmpty()){
                for(Order a : orderInsertList){
                    System.debug(a);
                }
            }
            System.debug('orderItemInsertList size ' +orderItemInsertList.size());
            if(!orderItemInsertList.isEmpty()){
                for(OrderItem a : orderItemInsertList){
                    System.debug(a);
                }
            }
            System.debug('orderManualUpdateList size ' +orderManualUpdateMap.keySet().size());
            if(!orderManualUpdateMap.keySet().isEmpty()){
                for(TW_Order_Manual__c a : orderManualUpdateMap.values() ){
                    System.debug(a);
                    System.debug(a.Status__c);
                    System.debug(a.Error_Reason__c);
                }
            }
            
            //DML Operations
            Savepoint sp = Database.setSavepoint();
            Boolean isRollback = false;
            try{
                Map<String, List<Affiliate_Value__c>> twOrderManualToAVCityInsertListMap = new Map<String, List<Affiliate_Value__c>>();
                Map<String, List<Affiliate_Value__c>> twOrderManualToAVDistrictInsertListMap = new Map<String, List<Affiliate_Value__c>>();
                Map<String, List<Address__c>> twOrderManualToAddressInsertListMap = new Map<String, List<Address__c>>();
                Map<String, List<Order>> twOrderManualToOrderInsertListMap = new Map<String, List<Order>>();
                Map<String, List<OrderItem>> twOrderManualToOrderItemInsertListMap = new Map<String, List<OrderItem>>();
                List<Affiliate_Value__c> deleteAVList = new List<Affiliate_Value__c>();
                List<Address__c> deleteAddressList = new List<Address__c>();
                List<Order> deleteOrderList = new List<Order>();
                List<OrderItem> deleteOrderItemList = new List<OrderItem>();
                Set<Id> orderManualIdDeleteList = new Set<Id>();
                
                //insert city affiliate value
                if(!affiliateValueCityInsertList.isEmpty()){
                    twOrderManualToAVCityInsertListMap = insertRecords('Affiliate_Value__c', affiliateValueCityInsertList, twOrderManualMap, orderManualUpdateMap, orderManualIdDeleteList);
                }
                if(!orderManualIdDeleteList.isEmpty() && !affiliateValueDistrictInsertList.isEmpty()){
                    removeErrorsFromList(orderManualIdDeleteList, affiliateValueDistrictInsertList);
                }
                //insert district affiliate value
                if(!affiliateValueDistrictInsertList.isEmpty()){
                    twOrderManualToAVDistrictInsertListMap = insertRecords('Affiliate_Value__c', affiliateValueDistrictInsertList, twOrderManualMap, orderManualUpdateMap, orderManualIdDeleteList);
                }
                if(!orderManualIdDeleteList.isEmpty() && !addressInsertList.isEmpty()){
                    removeErrorsFromList(orderManualIdDeleteList, addressInsertList);
                }
                //insert address
                if(!addressInsertList.isEmpty()){
                	twOrderManualToAddressInsertListMap = insertRecords('Address__c', addressInsertList, twOrderManualMap, orderManualUpdateMap, orderManualIdDeleteList);
                }
                if(!orderManualIdDeleteList.isEmpty() && !orderInsertList.isEmpty()){
                    removeErrorsFromList(orderManualIdDeleteList, orderInsertList);
                }
                //insert order
                if(!orderInsertList.isEmpty()){
                	twOrderManualToOrderInsertListMap = insertRecords('Order', orderInsertList, twOrderManualMap, orderManualUpdateMap, orderManualIdDeleteList);
                }
                if(!orderManualIdDeleteList.isEmpty() && !orderItemInsertList.isEmpty()){
                    removeErrorsFromList(orderManualIdDeleteList, orderItemInsertList);
                }
                //insert order item
                if(!orderItemInsertList.isEmpty()){
                	twOrderManualToOrderItemInsertListMap = insertRecords('OrderItem', orderItemInsertList, twOrderManualMap, orderManualUpdateMap, orderManualIdDeleteList);
                }
                
                //delete inserted records associated with error TW_Order_Manual record
                for(String twOrderId : orderManualIdDeleteList){
                    if(twOrderManualToAVCityInsertListMap.containsKey(twOrderId)){
                        deleteAVList.addAll(twOrderManualToAVCityInsertListMap.get(twOrderId));
                        for(Affiliate_Value__c av : deleteAVList){
                            if(affiliateValueInsertKeys.contains(av.Name)){
                                affiliateValueInsertKeys.remove(av.Name);
                            }
                        }
                    }
                    if(twOrderManualToAVDistrictInsertListMap.containsKey(twOrderId)){
                        deleteAVList.addAll(twOrderManualToAVDistrictInsertListMap.get(twOrderId));
                        for(Affiliate_Value__c av : deleteAVList){
                            if(affiliateValueInsertKeys.contains(av.Name)){
                                affiliateValueInsertKeys.remove(av.Name);
                            }
                        }
                    }
                    if(twOrderManualToAddressInsertListMap.containsKey(twOrderId)){
                        deleteAddressList.addAll(twOrderManualToAddressInsertListMap.get(twOrderId));
                        for(Address__c addr : deleteAddressList){
                            List<String> addressHashList = new List<String>();
                            if(String.IsNotBlank(addr.City2__c) ) addressHashList.add((String)addr.City2__c);
                            if(String.IsNotBlank(addr.District__c) ) addressHashList.add((String)addr.District__c);
                            if(String.IsNotBlank(addr.Street1__c) ) addressHashList.add((String)addr.Street1__c);
                            String addressHashKey = String.join(addressHashList, '-');
                            if(addressInsertKeys.contains(addressHashKey)){
                                addressInsertKeys.remove(addressHashKey);
                            }
                        }
                    }
                    if(twOrderManualToOrderInsertListMap.containsKey(twOrderId)){
                        deleteOrderList.addAll(twOrderManualToOrderInsertListMap.get(twOrderId));
                    }
                    if(twOrderManualToOrderItemInsertListMap.containsKey(twOrderId)){
                        deleteOrderItemList.addAll(twOrderManualToOrderItemInsertListMap.get(twOrderId));
                    }
                }
                
                if(!deleteAddressList.isEmpty()) delete deleteAddressList;
                if(!deleteAVList.isEmpty()) delete deleteAVList;
                if(!deleteOrderItemList.isEmpty()) delete deleteOrderItemList;
                if(!deleteOrderList.isEmpty()) delete deleteOrderList;
                
                //update Order to Submitted
                List<Order> ordersForProcessing = new List<Order>();
                for(String twId : twOrderManualToOrderInsertListMap.keySet()) {
                    for(Order newOrder : twOrderManualToOrderInsertListMap.get(twId)){
                        newOrder.Status = 'Submitted';
                        ordersForProcessing.add(newOrder);
                    }
                }
                if(!ordersForProcessing.isEmpty()){
                    List<Database.SaveResult> srListOrderUpdate =  Database.update(ordersForProcessing, false);
                    for (Integer i=0; i<srListOrderUpdate.size(); i++){
                        if (srListOrderUpdate.get(i).isSuccess()){
                            System.debug('Successfully updated order with Id : ' + srListOrderUpdate.get(i).getId() );
                        } 
                        else if (!srListOrderUpdate.get(i).isSuccess()){
                            Database.Error e = srListOrderUpdate.get(i).getErrors().get(0);
                            System.debug('Update Failed: ' + e.getStatusCode() + ': ' + e.getMessage());
                            System.debug('Order fields that affected this error: ' + e.getFields());
                        }  
                    }
                }
            }
            catch(Exception e){
                System.debug(e.getMessage());
                System.debug('Rollback all data for this transaction');
                isRollback = true;
                Database.rollback(sp);
            }
            
            if(!isRollback){
                for(TW_Order_Manual__c twOrder : scope){
                    if(!orderManualUpdateMap.containsKey(twOrder.Id)){
                        twOrder.RecordTypeId = recTypeSuccess;
                        twOrder.Status__c = 'Success';
                        twOrder.Error_Reason__c = '';
                        orderManualUpdateMap.put(twOrder.Id, twOrder);
                    }
                }
                //update TW_Order_Manual
                for (Database.SaveResult sr : Database.update(orderManualUpdateMap.values(), false)){
                    if(sr.isSuccess()){
                        System.debug('Successfully updated TW_Order_Manual__c with Id : ' + sr.getId());
                    }
                    else{
                        for (Database.Error e : sr.getErrors()){ 
                            System.debug('Update error for TW_Order_Manual__c with Id : '+ sr.getId());
                            System.debug(e.getStatusCode() + ': ' + e.getMessage());
                            System.debug('TW_Order_Manual__c fields that affected this error: ' + e.getFields());
                        }
                    }                
                }
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
        //Send an email to admin - summary of processed records
    }
    
    global void execute(SchedulableContext sc) {
        OrderUploadTWBatch batch = new OrderUploadTWBatch(); 
        Database.executebatch(batch, 1);
    }
    
    global static void start(){
        Database.executebatch(new OrderUploadTWBatch());
    }
    
    global static void start(String jobName, String cronExp){
        System.schedule(jobName, cronExp, new OrderUploadTWBatch());
    }
    
    
    /*Methods*/
    public void populateProductQuantityMap(String product, Decimal quantity, Map<String, Decimal> productQuantityMap){
        if(productQuantityMap.containsKey(product) ){
            productQuantityMap.put(product, productQuantityMap.get(product) + quantity) ;
        }
        else{
            productQuantityMap.put(product, quantity);
        }    
    }
    
    public Boolean validProductPromoAssignment(Contact c, Product2 p, Decimal quantity, Map<String, Decimal> childToOrderItemCountMap){
        Boolean valid = true;
        if(p.Available_For_Promo__c && p.Max_eligible_for_Promo__c != null){
            String childProductHashKey = c.Id + '-' + p.ProductCode;
            if(childToOrderItemCountMap.containsKey(childProductHashKey)){
                Decimal childProductCount = childToOrderItemCountMap.get(childProductHashKey) + quantity;
                if(childProductCount > p.Max_eligible_for_Promo__c){
                    valid = false;
                }
                else{
                    childToOrderItemCountMap.put(childProductHashKey, childProductCount);
                }
            }
            else{
                if(quantity > p.Max_eligible_for_Promo__c){
                    valid = false;
                }
                else{
                    childToOrderItemCountMap.put(childProductHashKey, quantity);
                }
            }
        }
        return valid;
    }
    
    public Boolean validProductBirthRange(Contact c, Product2 p){
        Boolean valid = true;
        if(c.AgeinMonths__c != null && (p.Min_Birth_Month__c != null || p.Max_Birth_Month__c != null) ){
            if(c.AgeinMonths__c < p.Min_Birth_Month__c || c.AgeinMonths__c > p.Max_Birth_Month__c){
                valid = false;
            }
        }
        return valid;
    }
    
    public Address__c createNewAddress(Contact parent, TW_Order_Manual__c o, Map<String, Affiliate_Value__c> affiliateValueMap, List<Affiliate_Value__c> affiliateValueCityInsertList, List<Affiliate_Value__c> affiliateValueDistrictInsertList){
        Affiliate_Value__c avCity = new Affiliate_Value__c();
        Affiliate_Value__c avDistrict = new Affiliate_Value__c();
        Address__c address = new Address__c();
        
        if(String.isNotBlank(o.City__c)){
            if(affiliateValueMap.containsKey(o.City__c) ){
                address.City2__c = affiliateValueMap.get(o.City__c).Id;
            }
            else{
                avCity = createNewAffiliateValue(o.City__c, 'City', o.Id, null, null);
                address.City2__r = new Affiliate_Value__c(Auto_Upload_Reference__c = avCity.Auto_Upload_Reference__c);
                if(!affiliateValueInsertKeys.contains(o.City__c) ){
                    affiliateValueCityInsertList.add(avCity);
                    affiliateValueInsertKeys.add(o.City__c);
                }
            }
        }
        if(String.isNotBlank(o.District__c)){
            if(affiliateValueMap.containsKey(o.District__c) ){
                address.District__c = affiliateValueMap.get(o.District__c).Id;
            }
            else{
                if(affiliateValueMap.containsKey(o.City__c) ){ 
                    avDistrict = createNewAffiliateValue(o.District__c, 'District', o.Id, address.City2__c, null);
                }
                else{
                    avDistrict = createNewAffiliateValue(o.District__c, 'District', o.Id, null, address.City2__r);
                }
                address.District__r = new Affiliate_Value__c(Auto_Upload_Reference__c = avDistrict.Auto_Upload_Reference__c);
                if(!affiliateValueInsertKeys.contains(o.District__c) ){
                    affiliateValueDistrictInsertList.add(avDistrict);
                    affiliateValueInsertKeys.add(o.District__c);
                }
            }
        }
        address.ParentContact__c = parent.Id;
        address.Country__c = 'Taiwan';
        address.DefaultAddress__c = false;
        //address.External_Reference_Number__c = addressHashKey; //external id
        address.ParentHousehold__c = parent.AccountId;
        address.Street1__c = String.isNotBlank(o.Street__c) ? o.Street__c : null;
        address.SourceCreatedDate__c = Datetime.now();
        address.Created_from_Auto_Upload__c = true;
        address.TW_Order_Manual_Id__c = o.Id;
        return address;
    }
    
    public Affiliate_Value__c createNewAffiliateValue(String externalKey, String avIdentifier, Id twOrderId, Id parentAVId, Affiliate_Value__c parentAV){
        Id recTypeId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get(avIdentifier).getRecordTypeId();
        Affiliate_Value__c av = new Affiliate_Value__c();
        av.RecordTypeId = recTypeId;
        av.Active__c = true;
        av.Name = externalKey;
        av.AffiliateValue__c = externalKey; //external id
        av.Market__c = 'TW';
        av.SourceCreatedDate__c = Datetime.now();
        av.Created_from_Auto_Upload__c = true;
        av.TW_Order_Manual_Id__c = twOrderId;
        av.Auto_Upload_Reference__c = String.valueOf(twOrderId).toLowerCase() + externalKey;
        if(parentAVId != null){
            av.ParentAffiliateValue__c = parentAVId;
        }
        else{
            av.ParentAffiliateValue__r = parentAV;
        }
        return av;
    }
    
    public void processOrder(TW_Order_Manual__c om, Contact parent, Contact child, Address__c addr, Map<String, Product2> productMap, Map<String, Id> pricebookMap, 
                             Map<String, Map<String, PricebookEntry>> pricebookToPBEntryMap, Map<String, AbbottPartner__c> abbottPartnerMap, List<Order> orderInsertList, List<OrderItem> orderItemInsertList)
    {
        Order o = createNewOrder(om, parent, addr, abbottPartnerMap, pricebookMap);
        orderInsertList.add(o);
        
        if(String.isNotBlank(om.Product_1__c) ){
            orderItemInsertList.add(createNewOrderItem(om.Product_1__c, om.Quantity_1__c, om, o, child, productMap, pricebookToPBEntryMap) );
        }
        if(String.isNotBlank(om.Product_2__c) ){
            orderItemInsertList.add(createNewOrderItem(om.Product_2__c, om.Quantity_2__c, om, o, child, productMap, pricebookToPBEntryMap) );
        }
        if(String.isNotBlank(om.Product_3__c) ){
            orderItemInsertList.add(createNewOrderItem(om.Product_3__c, om.Quantity_3__c, om, o, child, productMap, pricebookToPBEntryMap) );
        }
        if(String.isNotBlank(om.Product_4__c) ){
            orderItemInsertList.add(createNewOrderItem(om.Product_4__c, om.Quantity_4__c, om, o, child, productMap, pricebookToPBEntryMap) );
        }
    }
    
    public Order createNewOrder(TW_Order_Manual__c om, Contact parent, Address__c addr, Map<String, AbbottPartner__c> abbottPartnerMap, Map<String, Id> pricebookMap){
        Order o = new Order();
        o.PaymentMethod__c = String.isNotBlank(om.Payment_Type__c) ? om.Payment_Type__c : null;
        o.VAT__c = String.isNotBlank(om.VAT__c) ? om.VAT__c : null;
        o.TaxId__c = String.isNotBlank(om.Tax_ID__c) ? om.Tax_ID__c : null;
        o.TaxName__c = String.isNotBlank(om.Tax_Name__c) ? om.Tax_Name__c : null;
        o.Abbott_Partner_Code__c = String.isNotBlank(om.Promoter_Code__c) && abbottPartnerMap.containsKey(om.Promoter_Code__c) ? abbottPartnerMap.get(om.Promoter_Code__c).Id : null;
        o.Abbott_Sales_Person__c = String.isNotBlank(om.Sales_Person__c) && abbottPartnerMap.containsKey(om.Sales_Person__c) ? abbottPartnerMap.get(om.Sales_Person__c).Id : null; 
        o.AlternateReceiverName__c = String.isNotBlank(om.Receiver_Name__c) ? om.Receiver_Name__c : null;
        o.PreferredDeliveryDate__c = String.isNotBlank(om.Preferred_Delivery_Date__c) ? Date.parse(om.Preferred_Delivery_Date__c) : null; 
        o.PreferredDeliveryTime__c = String.isNotBlank(om.Preferred_Delivery_Time__c) ? om.Preferred_Delivery_Time__c : null;
        o.Description = String.isNotBlank(om.Description__c) ? om.Description__c : null;
        o.Type = String.isNotBlank(om.Type__c) ? om.Type__c : null;
        o.OrderedBy__c = parent.Id;
        o.AccountId = parent.AccountId;
        o.EffectiveDate = Date.Today();
        o.Pricebook2Id = pricebookMap.get(om.Pricebook_Name__c);
        if(addr.Id != null){
            o.ShippingAddress__c = addr.Id;
        }
        else{
            o.ShippingAddress__r = new Address__c(TW_Order_Manual_ID__c = addr.TW_Order_Manual_ID__c);
        }
        o.Status = 'Draft';
        o.CurrencyIsoCode = 'TWD';
        o.Created_from_Auto_Upload__c = true;
        o.TW_Order_Manual_ID__c = om.Id;
        return o;
    }
    
    public OrderItem createNewOrderItem(String productCode, String quantity, TW_Order_Manual__c om, Order o, Contact child, Map<String, Product2> productMap, Map<String, Map<String, PricebookEntry>> pricebookToPBEntryMap){
        OrderItem oi = new OrderItem();
        oi.Product2Id = productMap.containsKey(productCode) ? productMap.get(productCode).Id : null;
        oi.Quantity = Decimal.valueOf(quantity);
        oi.Order = new Order(TW_Order_Manual_ID__c = o.TW_Order_Manual_ID__c);
        oi.OrderedFor__c = child.Id;
        oi.PricebookEntryId = pricebookToPBEntryMap.get(om.Pricebook_Name__c).get(productCode).Id;
        oi.UnitPrice = pricebookToPBEntryMap.get(om.Pricebook_Name__c).get(productCode).UnitPrice;
        oi.TW_Order_Manual_ID__c = om.Id;
        return oi;
    }
    
    //delete error records in list associated with tw_order id
    public void removeErrorsFromList(Set<Id> orderManualIdDeleteList, List<SObject> insertList){
        for (Integer i = (insertList.size()-1) ; i>= 0 ; i--){
            String twOrderId = String.valueOf(insertList.get(i).get('TW_Order_Manual_ID__c') );
            if(orderManualIdDeleteList.contains(twOrderId)){
                insertList.remove(i);
            }
        } 
    }
    
    //insert records
    public Map<String, List<SObject>> insertRecords(String objectName, List<SObject> insertList, Map<String, TW_Order_Manual__c> twOrderManualMap, Map<Id, TW_Order_Manual__c> orderManualUpdateMap, Set<Id> orderManualIdDeleteList){
        Map<String, List<SObject>> returnMap = new Map<String, List<SObject>>();
        
        List<Database.SaveResult> srList = Database.insert(insertList, false);
        for (Integer i=0; i<srList.size(); i++){
            TW_Order_Manual__c twOrderRecord = twOrderManualMap.get(String.valueOf(insertList.get(i).get('TW_Order_Manual_ID__c') ) );
            if (srList.get(i).isSuccess()){
                System.debug('Successfully inserted ' +objectName+ ' with Id : ' + srList.get(i).getId() );
                if(returnMap.containsKey(twOrderRecord.Id)){
                    returnMap.get(twOrderRecord.Id).add(insertList.get(i));
                }
                else{
                    returnMap.put(twOrderRecord.Id, new List<SObject>{insertList.get(i)});
                }
            } 
            else if (!srList.get(i).isSuccess()){
                Database.Error e = srList.get(i).getErrors().get(0);
                System.debug('Insert Failed: ' + e.getStatusCode() + ': ' + e.getMessage());
                System.debug(objectName+ ' fields that affected this error: ' + e.getFields());
                twOrderRecord.Status__c = 'Error';
                twOrderRecord.Error_Reason__c = 'Insert Failed: ' + e.getStatusCode() + ': ' + e.getMessage() + ', ' +objectName+ ' fields that affected this error: ' + e.getFields();
                if(!orderManualUpdateMap.containsKey(twOrderRecord.Id) ){
                    orderManualUpdateMap.put(twOrderRecord.Id, twOrderRecord);
                    orderManualIdDeleteList.add(twOrderRecord.Id);
                }
            }  
        }
        return returnMap; 
    }
}