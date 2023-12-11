@isTest
private class OrderTriggerHelperTest {
    @testsetup
    static void setupData() {
        Test.enableChangeDataCapture();
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {
            List<Product2> productList = new List<Product2>();

            Product2 lProductbr = TestDataFactory.createTestBrandProduct2(1)[0];
            lProductbr.Market__c = 'TW';        
            lProductbr.AvailableBrandRelationship__c = true;
            productList.add(lProductbr);
            // update lProductbr;

            Product2 lProduct = TestDataFactory.createTestBrandProduct2(1)[0];
            lProduct.Market__c = 'TW';      
            lProduct.BrandRelationshipLink__c = lProductbr.Id;
            productList.add(lProduct);
            // update lProduct;

            UtilityClass.insertList(productList);

            List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount[0].Market__c = 'TW';
            update lAccount;

            List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
            List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProductbr.Id);
            List<Channel__c> lChannel = TestDataFactory.createTestChannel2(2);
            lChannel[0].Name = 'Marketing Channel`';
            lChannel[0].Market__c = 'TW';
            lChannel[1].Name = 'Social Channel';
            lChannel[1].Market__c = 'TW';
            // update lChannel;
            UtilityClass.insertList(lChannel);
            
            List<Campaign> campaignList = new List<Campaign>();

            Campaign camp = TestDataFactory.createCampaign('Marketing Campaign', 'Similac', 'TW');
            camp.Channel__c = lChannel.get(0).Id;
            campaignList.add(camp);
            // insert camp;

            Campaign camp2 = TestDataFactory.createCampaign('Social Campaign', 'Pediasure', 'TW');
            camp2.Channel__c = lChannel.get(1).Id;
            campaignList.add(camp2);
            // insert camp2;

            UtilityClass.insertList(campaignList);

            PricebookEntry entry = TestDataFactory.createPricebookEntry2('TW', productList[0], productList[1]);
            // insert entry;

            List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
            // insert lOrder;
            UtilityClass.insertList(lOrder);
            Test.getEventBus().deliver();       
            
            List<OrderItem> oiList = new List<OrderItem>();

            OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
            item.Product2Id = lProduct.Id;
            // insert item;
            oiList.add(item);

            OrderItem item2 = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
            item2.Product2Id = lProduct.Id;
            // insert item2;
            oiList.add(item2);

            OrderItem item3 = TestDataFactory.createOrderItem(lOrder.get(1).Id, entry.Id);
            item3.Product2Id = lProduct.Id;
            // insert item3;
            oiList.add(item3);

            UtilityClass.insertList(oiList);

            // item3 = [SELECT Product2Id FROM OrderItem WHERE Id =: item3.Id];
            Product2 product = new Product2(Id = item3.Product2Id, BrandRelationshipLink__c = lProductbr.Id);
            // update new Product2(Id = item3.Product2Id, BrandRelationshipLink__c = lProductbr.Id);
            update product;

            List<Membership__c> lMembership = TestDataFactory.createMembership2(1,lContact.get(0).Id,1);
            lMembership[0].Recent_Product_Purchased__c = product.Id;
            
            UtilityClass.insertList(lMembership);
        }
    }

    @isTest
    static void test_updateBrandRelationship_Lead() {
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
        System.runAs(sysad) {           
            System.Test.startTest();
                Order oRecord = [Select Id, Status from Order Limit 1];
                oRecord.Status = CommonConstant.ORDER_STATUS_COMPLETED;

                PricebookEntry entry = TestDataFactory.createPricebookEntry();
                insert entry;

                Product2 lProduct = [Select Id from Product2 Limit 1];

                OrderItem item = TestDataFactory.createOrderItem(oRecord.Id, entry.Id);
                item.Product2Id = lProduct.Id;
                insert item;
                
                update oRecord;
                Test.getEventBus().deliver();
            System.Test.stopTest();
        }

        BrandRelationship__c updatedRecord = [Select Id, Status__c, Type__c from BrandRelationship__c Limit 1];
        System.assertEquals(CommonConstant.BRAND_TYPE_USER, updatedRecord.Type__c );
        System.assertEquals(CommonConstant.BRAND_STATUS_NEW, updatedRecord.Status__c );
    }

    @isTest
    static void test_updateBrandRelationship_User() {
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];      

        System.runAs(sysad) {   
            BrandRelationship__c brand = [Select Id, Status__c, WinBack__c from BrandRelationship__c Limit 1];
            brand.Type__c = CommonConstant.BRAND_TYPE_USER;
            brand.Status__c =  CommonConstant.BRAND_STATUS_LAPSED;
            update brand;

            System.Test.startTest();
                Order oRecord = [Select Id, Status from Order Limit 1];
                oRecord.Status = CommonConstant.ORDER_STATUS_COMPLETED;

                PricebookEntry entry = TestDataFactory.createPricebookEntry();
                insert entry;
                
                Product2 lProduct = [Select Id from Product2 Limit 1];

                OrderItem item = TestDataFactory.createOrderItem(oRecord.Id, entry.Id);
                item.Product2Id = lProduct.Id;
                insert item;

                update oRecord;
                Test.getEventBus().deliver();
            System.Test.stopTest();
        }

        BrandRelationship__c updatedRecord = [Select Id, Status__c, WinBack__c from BrandRelationship__c Limit 1];
        System.assertEquals(true, updatedRecord.WinBack__c );
        System.assertEquals(CommonConstant.BRAND_STATUS_EXISTING, updatedRecord.Status__c );
    }

    @isTest
    static void test_updateContactTransactionDate() {
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];      

        System.runAs(sysad) {   
            Boolean updateFirstRecord = true;
            List<Order> oRecord = [Select Id, Status, EndDate from Order];
            PricebookEntry entry = TestDataFactory.createPricebookEntry();
            insert entry;
            
            List<Product2> lProduct = [Select Id from Product2];

            List<OrderItem> oiList = new List<OrderItem>();
            OrderItem item = TestDataFactory.createOrderItem(oRecord[0].Id, entry.Id);
            item.Product2Id = lProduct[0].Id;
            oiList.add(item);

            OrderItem item2 = TestDataFactory.createOrderItem(oRecord[1].Id, entry.Id);
            item2.Product2Id = lProduct[1].Id;
            oiList.add(item2);

            UtilityClass.insertList(oiList);

            System.Test.startTest();
                for (Order rec : oRecord) {
                    rec.Status = CommonConstant.ORDER_STATUS_COMPLETED;

                    if (updateFirstRecord) {
                        rec.EndDate = Date.today().addDays(4);
                        updateFirstRecord = false;
                    }
                }

                // update oRecord;
                UtilityClass.updateList(oRecord);
                Test.getEventBus().deliver();
                Contact updatedRecord = [Select Id, LatestTransactionDate__c, FirstTransactionDate__c from Contact Limit 1];
                //end date in TestDataFactory.createOrder is Date.today().addDays(2)
                //it should retain the value because the end date we updated is much latest
                System.assertEquals(Date.today().addDays(2), updatedRecord.FirstTransactionDate__c );
                System.assertEquals(Date.today().addDays(4), updatedRecord.LatestTransactionDate__c );

                Order delRec = oRecord.get(0);
                delRec.Status = CommonConstant.ORDER_STATUS_DRAFT;
                update delRec;
                Test.getEventBus().deliver();

                delete delRec;
                updatedRecord = [Select Id, LatestTransactionDate__c, FirstTransactionDate__c from Contact Limit 1];                
                System.assertEquals(Date.today().addDays(2), updatedRecord.LatestTransactionDate__c );
            System.Test.stopTest();
        }
    }

    @isTest
    static void test_orderCountDelete() {
            
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];    
        
        System.runAs(sysad) {
            List<Case> c = TestDataFactory.createPHCase(1);
            database.insert(c);
            List<Order> o = TestDataFactory.newOrder(1);
            o[0].Case__c = c[0].id;
            system.test.startTest();
            database.insert(o);
            Test.getEventBus().deliver();
            database.delete(o);
            system.test.stopTest();
        }
    }

    @isTest
    static void test_relatedCampaignUpdate() {
        User sysad = [SELECT Id FROM User WHERE Alias='tstSysAd' Limit 1];
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id campId = [SELECT Id FROM Campaign WHERE Name = 'Marketing Campaign'].Id;
        Id campId2 = [SELECT Id FROM Campaign WHERE Name = 'Social Campaign'].Id;

        System.runAs(sysad) {
            List<Order> lOrder = TestDataFactory.createOrder(1, accountId, contactId, Test.getStandardPricebookId());
            lOrder[0].RelatedCampaign__c = campId;
            insert lOrder;
            Test.getEventBus().deliver();

            List<Order> orderAfterInsert = [SELECT Id, Channel__c FROM Order WHERE RelatedCampaign__c = :campId LIMIT 1];
            System.assertNotEquals(null, orderAfterInsert[0].Channel__c, 'Channel should be automatically populated');

            lOrder[0].RelatedCampaign__c = campId2;
            update lOrder[0];
            Test.getEventBus().deliver();
            List<Order> orderAfterUpdate = [SELECT Id, Channel__c FROM Order WHERE RelatedCampaign__c = :campId2 LIMIT 1];
            System.assertNotEquals(orderAfterInsert[0].Channel__c, orderAfterUpdate[0].Channel__c, 'Channel should be updated.');

            lOrder[0].RelatedCampaign__c = null;
            update lOrder[0];
            Test.getEventBus().deliver();
            List<Order> orderAfterNull = [SELECT Id, Channel__c FROM Order ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals(null, orderAfterNull[0].Channel__c, 'Order Channel should be updated to BLANK.');
        }
    }

    @isTest
    static void test_validatePreferredDeliveryTime() {
        User sysad = [SELECT Id FROM User WHERE Alias='tstSysAd' Limit 1];
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id campId = [SELECT Id FROM Campaign WHERE Name = 'Marketing Campaign'].Id;
        Id campId2 = [SELECT Id FROM Campaign WHERE Name = 'Social Campaign'].Id;

        System.runAs(sysad) {
            List<Order> lOrder = TestDataFactory.createOrder(1, accountId, contactId, Test.getStandardPricebookId());
            lOrder[0].EffectiveDate = Date.newInstance(2019, 17, 6);
            lOrder[0].EndDate = Date.newInstance(2019, 30, 6);
            lOrder[0].PreferredDeliveryDate__c = lOrder[0].EffectiveDate.addDays(1);
            
            try {
                insert lOrder;
                Test.getEventBus().deliver();
            } catch(DMLException e) {
                System.assert(e.getMessage().contains('Preferred Delivery Date must be at least'), 'message=' + e.getMessage());
            }

            lOrder[0].PreferredDeliveryDate__c = Date.newInstance(2019, 20, 6);
            update lOrder;
            Test.getEventBus().deliver();

            try {
                lOrder[0].PreferredDeliveryDate__c = Date.newInstance(2019, 26, 6);
                update lOrder;
                Test.getEventBus().deliver();
            } catch(DMLException e) {
                System.assert(e.getMessage().contains('Preferred Delivery Date must not fall on a Sunday'), 'message=' + e.getMessage());
            }
        }
    }
    
    @isTest
    static void test_updateMembershipPH() {
      User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
      System.runAs(sysad) {        
        System.Test.startTest();
          Order oRecord = [Select Id, Status from Order Limit 1];
          Membership__c memRecord = [Select Id,Recent_Product_Purchased__c from Membership__c Limit 1];
          oRecord.ParentMembership__c = memRecord.Id;
          update oRecord;
          Test.getEventBus().deliver();
        System.Test.stopTest();
      }
  
      Membership__c updatedRecord = [Select Id, Recent_Product_Purchased__c from Membership__c Limit 1];
      System.assertNotEquals(null, updatedRecord.Recent_Product_Purchased__c, 'Recent Product Purchased should be automatically populated');
    }

    @isTest
    static void test_deleteOrders() {
        List<Order> oRecord = [SELECT Id, Delivery_Pattern__c, Frequency__c FROM Order];

        System.Test.startTest();
            delete oRecord;
        System.Test.stopTest();
    }

    @isTest
    static void test_orderListWithMultipleOrderItems() {
        List<Order> oRecord = [SELECT Id, Delivery_Pattern__c, Frequency__c FROM Order LIMIT 1];
        List<OrderItem> insertRecords = new List<OrderItem>();
        oRecord[0].Delivery_Pattern__c = '7';
        oRecord[0].Frequency__c = 3;

        Product2 lProduct = [SELECT Id FROM Product2 LIMIT 1];

        PricebookEntry entry = TestDataFactory.createPricebookEntry('TW');
        insert entry;

        // List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
        // // insert lOrder;
        // UtilityClass.insertList(lOrder);
        // Test.getEventBus().deliver();       
        
        // List<OrderItem> oiList = new List<OrderItem>();

        OrderItem item = TestDataFactory.createOrderItem(oRecord.get(0).Id, entry.Id);
        item.Product2Id = lProduct.Id;
        // insert item;
        insertRecords.add(item);

        OrderItem item2 = TestDataFactory.createOrderItem(oRecord.get(0).Id, entry.Id);
        item2.Product2Id = lProduct.Id;
        // insert item2;
        insertRecords.add(item2);

        UtilityClass.insertList(insertRecords);

        System.Test.startTest();
            UtilityClass.insertList(insertRecords);
            update oRecord;
            // OrderTriggerHelper.updateHasMultipleOrderProductsCheckbox(oRecord);
        System.Test.stopTest();
    }

    @isTest
    static void test_orderListWithMultipleOrderItemsStatusDraft() {
        List<Order> oRecord = [SELECT Id, Delivery_Pattern__c, Frequency__c FROM Order LIMIT 1];
        oRecord[0].Type = 'Telesales - Outbound';
        oRecord[0].Has_Multiple_Order_Products__c = true;

        List<OrderItem> insertRecords = new List<OrderItem>();

        Product2 lProduct = [SELECT Id FROM Product2 LIMIT 1];

        PricebookEntry entry = TestDataFactory.createPricebookEntry('TW');
        insert entry;

        // List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
        // // insert lOrder;
        // UtilityClass.insertList(lOrder);
        // Test.getEventBus().deliver();       
        
        // List<OrderItem> oiList = new List<OrderItem>();

        OrderItem item = TestDataFactory.createOrderItem(oRecord.get(0).Id, entry.Id);
        item.Product2Id = lProduct.Id;
        // insert item;
        insertRecords.add(item);

        OrderItem item2 = TestDataFactory.createOrderItem(oRecord.get(0).Id, entry.Id);
        item2.Product2Id = lProduct.Id;
        // insert item2;
        insertRecords.add(item2);

        // UtilityClass.insertList(insertRecords);

        System.Test.startTest();
            UtilityClass.insertList(insertRecords);
            update oRecord;
            // OrderTriggerHelper.updateHasMultipleOrderProductsCheckbox(oRecord);
        System.Test.stopTest();
    }

    @isTest
    static void test_orderListWithMultipleOrderItemsStatusTransferred() {
        List<Order> oRecord = [SELECT Id, Delivery_Pattern__c, Frequency__c FROM Order LIMIT 1];
        oRecord[0].Type = 'Telesales - Outbound';
        oRecord[0].Status = 'Transferred';

        List<OrderItem> insertRecords = new List<OrderItem>();

        Product2 lProduct = [SELECT Id FROM Product2 LIMIT 1];

        PricebookEntry entry = TestDataFactory.createPricebookEntry('TW');
        insert entry;

        // List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
        // // insert lOrder;
        // UtilityClass.insertList(lOrder);
        // Test.getEventBus().deliver();       
        
        // List<OrderItem> oiList = new List<OrderItem>();

        OrderItem item = TestDataFactory.createOrderItem(oRecord.get(0).Id, entry.Id);
        item.Product2Id = lProduct.Id;
        // insert item;
        insertRecords.add(item);

        OrderItem item2 = TestDataFactory.createOrderItem(oRecord.get(0).Id, entry.Id);
        item2.Product2Id = lProduct.Id;
        // insert item2;
        insertRecords.add(item2);

        // UtilityClass.insertList(insertRecords);

        System.Test.startTest();
            UtilityClass.insertList(insertRecords);
            update oRecord;
            // OrderTriggerHelper.updateHasMultipleOrderProductsCheckbox(oRecord);
        System.Test.stopTest();
    }

    @isTest
    static void test_orderListWithSingleOrderItem() {
        List<Order> oRecord = [SELECT Id, Delivery_Pattern__c, Frequency__c FROM Order];
        List<OrderItem> insertRecords = new List<OrderItem>();
        oRecord[1].Type = 'Telesales - Outbound';

        Product2 lProduct = [SELECT Id FROM Product2 LIMIT 1];

        PricebookEntry entry = TestDataFactory.createPricebookEntry('TW');
        insert entry;

        // List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
        // // insert lOrder;
        // UtilityClass.insertList(lOrder);
        // Test.getEventBus().deliver();       
        
        // List<OrderItem> oiList = new List<OrderItem>();

        OrderItem item = TestDataFactory.createOrderItem(oRecord.get(1).Id, entry.Id);
        item.Product2Id = lProduct.Id;
        // insert item;
        insertRecords.add(item);

        // OrderItem item2 = TestDataFactory.createOrderItem(oRecord.get().Id, entry.Id);
        // item2.Product2Id = lProduct.Id;
        // // insert item2;
        // insertRecords.add(item2);

        // UtilityClass.insertList(insertRecords);

        System.Test.startTest();
            UtilityClass.insertList(insertRecords);
            update oRecord;
            // OrderTriggerHelper.updateHasMultipleOrderProductsCheckbox(oRecord);
        System.Test.stopTest();
    }

    @isTest
    static void test_orderListWithSingleOrderItemStatusTransferred() {
        List<Order> oRecord = [SELECT Id, Delivery_Pattern__c, Frequency__c FROM Order];
        List<OrderItem> insertRecords = new List<OrderItem>();
        oRecord[1].Type = 'Telesales - Outbound';
        oRecord[1].Status = 'Transferred';

        Product2 lProduct = [SELECT Id FROM Product2 LIMIT 1];

        PricebookEntry entry = TestDataFactory.createPricebookEntry('TW');
        insert entry;

        // List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
        // // insert lOrder;
        // UtilityClass.insertList(lOrder);
        // Test.getEventBus().deliver();       
        
        // List<OrderItem> oiList = new List<OrderItem>();

        OrderItem item = TestDataFactory.createOrderItem(oRecord.get(1).Id, entry.Id);
        item.Product2Id = lProduct.Id;
        // insert item;
        insertRecords.add(item);

        // OrderItem item2 = TestDataFactory.createOrderItem(oRecord.get().Id, entry.Id);
        // item2.Product2Id = lProduct.Id;
        // // insert item2;
        // insertRecords.add(item2);

        // UtilityClass.insertList(insertRecords);

        System.Test.startTest();
            UtilityClass.insertList(insertRecords);
            update oRecord;
            // OrderTriggerHelper.updateHasMultipleOrderProductsCheckbox(oRecord);
        System.Test.stopTest();
    }

    @isTest
    static void test_orderListWithSingleRepeatOrderAndCloned() {
        // List<Order> oRecord = [SELECT Id, Type, Status, Repeat_Order__c, Is_Cloned__c, Delivery_Pattern__c, Frequency__c FROM Order];
        // List<Order> oRecord = new List<Order>();
        List<OrderItem> insertRecords = new List<OrderItem>();
        List<Account> a = [SELECT Id FROM Account LIMIT 1];
        List<Contact> c = [SELECT Id FROM Contact WHERE AccountId = :a[0].Id];
        List<Order> o = TestDataFactory.createOrder(1, a.get(0).Id, c.get(0).Id, Test.getStandardPricebookId());
        insert o;

        o[0].Status = 'Transferred';
        o[0].Repeat_Order__c = true;
        o[0].Is_Cloned__c = true;

        // oRecord[1].Type = 'Telesales - Outbound';
        // oRecord[1].Status = 'Transferred';
        // oRecord[1].Repeat_Order__c = true;
        // oRecord[1].Is_Cloned__c = true;

        Product2 lProduct = [SELECT Id FROM Product2 LIMIT 1];

        PricebookEntry entry = TestDataFactory.createPricebookEntry('TW');
        insert entry;

        OrderItem item = TestDataFactory.createOrderItem(o[0].Id, entry.Id);
        item.Product2Id = lProduct.Id;
        insertRecords.add(item);

        System.Test.startTest();
            UtilityClass.insertList(insertRecords);
            update o;
        System.Test.stopTest();
    }
}