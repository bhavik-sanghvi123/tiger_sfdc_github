@isTest
public class NewOrderControllerTest{
    @testsetup
    static void setupData() {
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('City').getRecordTypeId();
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
        System.runAs(sysad) {
            List<Account> accountList = TestDataFactory.createTestHousehold(1);
            List<Contact> contactList = TestDataFactory.createTestAdultContact(1, accountList.get(0).Id);
            Case caseRec = TestDataFactory.createCaseCall(accountList.get(0).Id, contactList.get(0).Id);
            //Pricebook2 pb = TestDataFactory.createPricebook(CommonConstant.MARKET_VN);
            PricebookEntry pbEntry = TestDataFactory.createPricebookEntry();
            insert pbEntry;
            
            //update Pricebook details
            Pricebook2 pb = [SELECT Id, Market__c, DefaultForTelesales__c FROM Pricebook2 LIMIT 1];
            pb.Market__c = CommonConstant.MARKET_VN;
            pb.DefaultForTelesales__c = TRUE;
            update pb;
            
            //Update Product details
            Product2 prod = [SELECT Id, Market__c, AvailableForOrder__c FROM Product2 LIMIT 1];
            prod.Market__c = CommonConstant.MARKET_VN;
            prod.AvailableForOrder__c = TRUE;
            update prod;
            
            //Create Promotion record
            TestDataFactory.createPromotion(1);
            Promotion__c promo = [SELECT Market__c, EndDate__c FROM Promotion__c LIMIT 1];
            promo.Market__c = CommonConstant.MARKET_VN;
            promo.StartDate__c = Date.today().addDays(-15);
            promo.Status__c = CommonConstant.PROMOTION_STATUS_INPROGRESS;
            update promo;
            
            //Create Promotion Item record
            TestDataFactory.createPromotionItem(1, prod.Id, promo.Id);
            
            //Create OCR (Affiliate Value) record
            TestDataFactory.createTestOCR(1);
            
            //Create Region
            List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
            //Create City
            List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
            List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, contactList.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
            
            //Create Singapore City
            Affiliate_Value__c city = new Affiliate_Value__c();          
            city.Name = 'Singapore';
            city.Market__c = 'SG';
            city.AffiliateValue__c = 'Singapore';
            city.Active__c = TRUE;
            city.RecordTypeId = idRecType;
            insert city;
            
            //Create Channel
            List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
            lChannel[0].Market__c = 'VN';
            update lChannel;
            
            //Create Campaign
            Campaign camp = TestDataFactory.createCampaign('Test Campaign 1', 'Ensure', 'VN');
            camp.Channel__c = lChannel.get(0).Id;
            insert camp;
            
            //Update Case
            caseRec.RelatedCampaign__c = camp.Id;
       		update caseRec;
        }
    }
    
    private static testMethod void createNewOrderTest() {
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {
            Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
            Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
            Id ocrId = [SELECT Id FROM Affiliate_Value__c LIMIT 1].Id;
            String conObj = CommonConstant.CONTACT_OBJECT;
            String caseObj = CommonConstant.CASE_OBJECT;
            String orderType = CommonConstant.ORDER_TYPE_TRADE;
            String paymentMethod = CommonConstant.ORDER_PAYMENT_METHOD_CREDIT_CARD;
            String notes = 'Test Notes for Order';
            String mk = NewOrderController.getMarket(conId);
            System.Test.startTest();
            String orderFromCaseId = NewOrderController.createNewOrder(caseId, null, caseObj);
            String orderFromConId = NewOrderController.createNewOrder(null, conId, conObj);
            
            System.assertNotEquals(null, orderFromCaseId, 'Order should be created and automatically linked to Case');
            System.assertNotEquals(null, orderFromConId, 'Order should be created and automatically linked to Contact');
            
            List<Order> orderList = [SELECT Type, PaymentMethod__c, OrderNotes__c FROM Order WHERE Id =: orderFromCaseId];
            String updateOrderFromCaseId = NewOrderController.saveUpdatedOrderDetails(orderFromCaseId, orderType, paymentMethod, notes);
            List<Order> updatedOrderList = [SELECT Type, PaymentMethod__c, OrderNotes__c FROM Order WHERE Id =: orderFromCaseId];
            
            System.assertNotEquals(orderList[0].Type, updatedOrderList[0].Type, 'Order Type should be updated');
            System.assertNotEquals(orderList[0].PaymentMethod__c, updatedOrderList[0].PaymentMethod__c, 'Order Payment Method should be updated');
            System.assertNotEquals(orderList[0].OrderNotes__c, updatedOrderList[0].OrderNotes__c, 'Order Notes should be updated');
            
            Order orderDetails = NewOrderController.getOrderRecord(orderList[0].Id);
            System.assertNotEquals(null, orderList[0].Type, 'Order Details must be returned.');
            
            NewOrderController.updateOrder(orderList[0].Id, ocrId);
            Order updatedOrder = [SELECT Id, OrderCacellationReason__c, Status FROM Order WHERE Id =: orderList[0].Id];
            System.assertEquals(updatedOrder.Status, CommonConstant.ORDER_STATUS_CANCELLED_ABANDONED, 'Order Status should be automatically updated');
            System.Test.stopTest();
        }
    }
    
    private static testMethod void fetchUserTest() {
        Id vnRoleId = [SELECT Id FROM UserRole WHERE Name = 'ANI - Vietnam'].Id;
        User testUser = [Select Id, Market__c, UserRoleId From User where LastName = 'tstSysAd'];
        testUser.UserRoleId = vnRoleId;
        update testUser;
        
        String userMarket;
        User userDetail = new User();
        
        System.runAs(testUser) {
            System.Test.startTest();
            userMarket = NewOrderController.fetchUser();
            userDetail = NewOrderController.getLoginUserDetails();
            System.Test.stopTest();
        }
        System.assertEquals(userMarket, testUser.Market__c, 'Market should be derived from User\'s Market Value.');
        System.assertEquals(userDetail.Market__c, testUser.Market__c, 'Market should be derived from User\'s Market Value.');
        
    }
    
    private static testMethod void lookupRecordTest() {
        String pricebookObj = CommonConstant.PRICEBOOK_OBJECT;
        
        Id vnRoleId = [SELECT Id FROM UserRole WHERE Name = 'ANI - Vietnam'].Id;
        User testUser = [Select Id From User where LastName = 'tstSysAd'];
        
        testUser.UserRoleId = vnRoleId;
        update testUser;
        
        System.Test.startTest();
        System.runAs(testUser) {
            List<sObject> optionsList = NewOrderController.lookupRecord(null, pricebookObj);
            System.assert(optionsList.size() > 0, 'Options should be returned to the user.');
        }
        System.Test.stopTest();
    }
    
    private static testMethod void getDefaultPricebookTest() {
        String pricebookObj = CommonConstant.PRICEBOOK_OBJECT;
        
        Id vnRoleId = [SELECT Id FROM UserRole WHERE Name = 'ANI - Vietnam'].Id;
        User testUser = [Select Id From User where LastName = 'tstSysAd'];
        testUser.UserRoleId = vnRoleId;
        update testUser;
        
        System.Test.startTest();
        System.runAs(testUser) {
            sObject defaultPricebook = NewOrderController.getDefaultPricebook(pricebookObj, FALSE, null);
            System.assertNotEquals(null, defaultPricebook, 'Default Pricebook2 should be set based on User\'s Market.');
        }
        System.Test.stopTest();
    }
    
    private static testMethod void fetchLookupValuesTest() {
        String productObj = CommonConstant.PRODUCT_OBJECT;
        String conObj = CommonConstant.CONTACT_OBJECT;
        String addressObj = CommonConstant.ADRESS_OBJECT;
        
        Id pricebookId = [SELECT Id FROM Pricebook2 LIMIT 1].Id;
        Id prodId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Id householdId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Product2 prodRec = new Product2();
        prodRec.Id = prodId;
        prodRec.Min_Birth_Month__c = -5;
        prodRec.Max_Birth_Month__c = 12;
        update prodRec;

        System.Test.startTest();
        List<Product2> prodList = NewOrderController.fetchLookupValues(pricebookId, null, productObj, null, null, null);
        System.assertNotEquals(0, prodList.size(), 'A list of Product related to the Pricebook must be returned.');
        
        List<Contact> conList = NewOrderController.fetchLookupValues(null, householdId, conObj, null, null, null);
        System.assertNotEquals(0, conList.size(), 'A list of Contact related to the Household must be returned.');
        
        List<Product2> prodList1 = NewOrderController.fetchLookupValues(pricebookId, null, productObj, null, 'Test', null);
        System.assertNotEquals(0, prodList1.size(), 'A list of Product related to the Pricebook must be returned.');
        
        List<Contact> conList1 = NewOrderController.fetchLookupValues(null, householdId, conObj, null, 'Lastname', prodRec.Id);
        System.assertNotEquals(0, conList1.size(), 'A list of Contact related to the Household must be returned.');
        
        System.Test.stopTest();
    }
    
    private static testMethod void getPricebookEntryDetailsTest() {
        Id pricebookId = [SELECT Id FROM Pricebook2 LIMIT 1].Id;
        Id productId = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id =: pricebookId LIMIT 1].Product2Id;
        
        System.Test.startTest();
        PricebookEntry pbe = NewOrderController.getPricebookEntryDetails(pricebookId, productId);
        System.assertNotEquals(null, pbe.Name, 'Pricebook Entry details must be returned.');
        System.Test.stopTest();
    }
    
    private static testMethod void getRelatedPromotion() {
        Id vnRoleId = [SELECT Id FROM UserRole WHERE Name = 'ANI - Vietnam'].Id;
        User testUser = [Select Id From User where LastName = 'tstSysAd'];
        testUser.UserRoleId = vnRoleId;
        update testUser;
        
        System.Test.startTest();
        System.runAs(testUser) {
            List<Promotion__c> promotionList = NewOrderController.getRelatedPromotion(null);
            System.assertNotEquals(0, promotionList.size(), 'A list of Promotion based on User\'s Market must be returned.');
        }
        System.Test.stopTest();
    }
    
    private static testMethod void getRelatedPromotionItemsTest() {
        Id promoId = [SELECT Id FROM Promotion__c LIMIT 1].Id;
        
        System.Test.startTest();
        List<PromotionItem__c> promotionList = NewOrderController.getRelatedPromotionItems(promoId);
        System.assertNotEquals(0, promotionList.size(), 'A list of Promotion Item from Promotion must be returned.');
        System.Test.stopTest();
    }
    
    private static testMethod void submitOrderTest() {
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {
            NewOrderController.SumarryWrapper param = new NewOrderController.SumarryWrapper();
            Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
            Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
            Id ocrId = [SELECT Id FROM Affiliate_Value__c LIMIT 1].Id;
            Id addId = [Select Id from Address__c Limit 1].Id;
            String conObj = CommonConstant.CONTACT_OBJECT;
            String caseObj = CommonConstant.CASE_OBJECT;
            String orderType = CommonConstant.ORDER_TYPE_TRADE;
            String paymentMethod = CommonConstant.ORDER_PAYMENT_METHOD_CREDIT_CARD;
            String notes = 'Test Notes for Order';
            String orderFromCaseId = NewOrderController.createNewOrder(caseId, null, caseObj);
            string prodId = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1].Product2Id;
            System.Test.startTest();
            param.orderId = orderFromCaseId;
            param.paymentMethod = CommonConstant.ORDER_PAYMENT_METHOD_CASH;
            param.deliveryAddress = addId;
            //param.campaign = 
            param.notes = 'test';
            param.pricebook = System.Test.getStandardPricebookId();
            param.updateAddress = true;
            Address__c addRec = new Address__c();
            addRec.Id = addId;
            addRec.Street1__c = 'test';
            param.addressRec = addRec;
            
            List<OrderItem> orderItemList = new List<OrderItem>();
            orderItemList.add( new OrderItem( OrderId = orderFromCaseId,
                                             Product2Id = prodId,
                                             Quantity = 1,
                                             UnitPrice = 10) );
            String paramString = JSON.serialize(param);
            NewOrderController.submitOrder(paramString, orderItemList);
            System.Test.stopTest();
            List<OrderItem> updatedOrderItemlist = [Select Id from OrderItem];
            System.assertEquals(1, updatedOrderItemlist.size());
            Order updatedOrder = [Select Id,PaymentMethod__c,Status from Order where Id=: orderFromCaseId];
            System.assertEquals(updatedOrder.PaymentMethod__c, CommonConstant.ORDER_PAYMENT_METHOD_CASH);
            System.assertEquals(updatedOrder.Status, CommonConstant.ORDER_STATUS_SUBMITTED);
        }
    }
    
    private static testMethod void submitInvalidOrderTest() {
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {
            NewOrderController.SumarryWrapper param = new NewOrderController.SumarryWrapper();
            Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
            Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
            Id ocrId = [SELECT Id FROM Affiliate_Value__c LIMIT 1].Id;
            Id addId = [Select Id from Address__c Limit 1].Id;
            String conObj = CommonConstant.CONTACT_OBJECT;
            String caseObj = CommonConstant.CASE_OBJECT;
            String orderType = CommonConstant.ORDER_TYPE_TRADE;
            String paymentMethod = CommonConstant.ORDER_PAYMENT_METHOD_CREDIT_CARD;
            String notes = 'Test Notes for Order';
            String orderFromCaseId = NewOrderController.createNewOrder(caseId, null, caseObj);
            string prodId = [SELECT Id FROM Product2 LIMIT 1].Id; 
            System.Test.startTest();
            param.orderId = orderFromCaseId;
            param.paymentMethod = CommonConstant.ORDER_PAYMENT_METHOD_CASH;
            param.deliveryAddress = addId;
            //param.campaign = 
            param.notes = 'test';
            //param.pricebook = System.Test.getStandardPricebookId();
            param.updateAddress = true;
            Address__c addRec = new Address__c();
            addRec.Id = addId;
            addRec.Street1__c = 'test';
            param.addressRec = addRec;
            
            List<OrderItem> orderItemList = new List<OrderItem>();
            orderItemList.add( new OrderItem( OrderId = orderFromCaseId,
                                             Product2Id = prodId,
                                             Quantity = 1,
                                             UnitPrice = 10) );
            String paramString = JSON.serialize(param);
            Boolean hasError = false;
            try {
                NewOrderController.submitOrder(paramString, orderItemList);
            } catch(Exception ex) {
                hasError = true;
            }
            System.Test.stopTest();
            //system should throw an error because there is no pricebook
            System.assertEquals(true, hasError);
        }
    }
    
    private static testMethod void getAddressAndPickListTest() {
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {
            System.Test.startTest();
            List<Address__c> defaultAddList = NewOrderController.getDefaultAddress([SELECT Id FROM Contact LIMIT 1].Id);
            NewOrderController.getHouseholdAddress([SELECT Id FROM Account LIMIT 1].Id);
            List<String> pickList = NewOrderController.getPickListValuesIntoList();
            System.Test.stopTest();
            System.assertNotEquals(0, defaultAddList.size());
            System.assertNotEquals(0, pickList.size());
        }
    }
    
    private static testMethod void getPrefDeliveryTimePicklistTest() {
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {
            System.Test.startTest();
            Map<String,String> pickListValuesMapOther = NewOrderController.getPickListValuesPreferredDeliveryTime('VN');
            Map<String,String> pickListValuesMapSG = NewOrderController.getPickListValuesPreferredDeliveryTime('SG');
            System.Test.stopTest();
            System.assertEquals(5, pickListValuesMapOther.keySet().size());
            System.assertEquals(5, pickListValuesMapSG.keySet().size());
            for(String p : pickListValuesMapOther.keySet()){
                System.assert(!p.startsWith('SG_'));
            }
            for(String p : pickListValuesMapSG.keySet()){
                System.assert(p.startsWith('SG_'));
            }
        }
    }
    
    private static testMethod void sampleOrderTest() {
        String conId = [SELECT Id, Market__c FROM Contact LIMIT 1].Id;
        Pricebook2 pbRet = new Pricebook2();
        
        Pricebook2 pb1 = new Pricebook2();
        pb1.Name = 'Sample Pricebook PH';
        pb1.IsActive = true;
        pb1.Market__c = 'PH';
        insert pb1;
        
        System.Test.startTest();
        SObject sobjRec = NewOrderController.getDefaultPricebook('', true, conId);
        System.Test.stopTest();
        
        pbRet = (Pricebook2)sobjRec;
        
        System.assertEquals('Sample Pricebook PH', pbRet.Name);
    }

    private static testMethod void getCaseDetails() {
        Id caseRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Feedback').getRecordTypeId();

        Case caseRec = [SELECT Id, RecordTypeId, RecordType.Name FROM Case LIMIT 1];
        caseRec.RecordTypeId = caseRId;       
        update caseRec;

        System.Test.startTest();
        String caseRecTypeName = NewOrderController.getCaseRecordTypeName(caseRec.Id);
        String isProcess = NewOrderController.checkContactAndHousehold(caseRec.Id);
        System.assertEquals(caseRec.RecordType.Name, caseRecTypeName, 'Case Record Type should be retrieved.');
        System.assertEquals('false', isProcess, 'Add Main Contact creation is not allowed.');
        System.Test.stopTest();
    }

    private static testMethod void getPackageItemsTest() {
        Id pckRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(CommonConstant.PRODUCT_PACKAGE_RECORDTYPE).getRecordTypeId();
        Id prdRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(CommonConstant.PRODUCT_PRODUCT_RECORDTYPE).getRecordTypeId();
        List<PackageItem__c> packageItemList = new List<PackageItem__c>();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
        lProduct[0].RecordTypeId = pckRecType;
        update lProduct;

        Product2 prodRec = [SELECT Id, RecordTypeId, AvailableForSample__c FROM Product2 LIMIT 1];
        prodRec.RecordTypeId = prdRecType;
        prodRec.AvailableForSample__c = true;
        update prodRec;

        List<PackageItem__c> lPckgItem = TestDataFactory.createTestPackageItem(lProduct[0].Id, prodRec.Id, 1);

        System.Test.startTest();
        packageItemList = NewOrderController.getPackageItems(lProduct[0].Id);
        System.assert(packageItemList.size() > 0, 'List of Package Items should be returned.');
        System.Test.stopTest();
    }
    
    private static testMethod void getExperianTokenTest() {
        System.Test.startTest();
        String token = NewOrderController.getExperianToken();
        System.Test.stopTest();
        
        System.assertNotEquals(null, token, 'Experian token should be returned');
    }
    
    private static testMethod void getAffiliateSingaporeCityTest() {
        User testUser = [Select Id, Market__c, UserRoleId From User where LastName = 'tstSysAd'];
        String sgId;
        
        System.runAs(testUser) {
            System.Test.startTest();
            sgId = NewOrderController.getAffiliateSingaporeCity();
            System.Test.stopTest();
        }
        
        System.assertNotEquals(null, sgId, 'Singapore Affiliate City Id should be returned');
    }
    
    private static testMethod void getChannelRecordTest() {
        Id campId = [SELECT Id FROM Campaign LIMIT 1].Id;
        Id channelId;
        
        System.Test.startTest();
        channelId = NewOrderController.getChannelRecord(campId);
        System.Test.stopTest();
        
        System.assertNotEquals(null, channelId, 'Channel Id shoule be returned');
    }
    
    private static testMethod void getCaseDetailsTest() {
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        
        System.Test.startTest();
        Case caseRec = NewOrderController.getCaseDetails(caseId);
        System.Test.stopTest();
        
        System.assertNotEquals(null, caseRec.RelatedCampaign__c, 'Case Details should be returned.');
    }
}