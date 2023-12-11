@isTest 
public class OrderProductTrigger_Test{

  @testsetup
  static void setupData() {
    User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'TH; TW');
    insert sysad;
      
    System.runAs(sysad) {
      // List<Product2> lProducts = TestDataFactory.createTestBrandProduct(1);
      // lProduct.get(0).Market__c = 'TW';
      // update lProduct;

      List<Product2> lProduct = new List<Product2>();
      lProduct.add(TestDataFactory.createTestBrandProductNoInsert(1)[0]);
      lProduct.add(TestDataFactory.createTestBrandProductTWNoInsert(1)[0]);
      UtilityClass.insertList(lProduct);

      // List<Account> lAccount = TestDataFactory.createTestHousehold(1);
      // lAccount.get(0).Market__c = 'TW';
      // update lAccount;

      List<Account> lAccount = new List<Account>();
      lAccount.add(TestDataFactory.createTestHouseholdNoInsert(1, CommonConstant.MARKET_TH)[0]);
      lAccount.add(TestDataFactory.createTestHouseholdNoInsert(1, CommonConstant.MARKET_TW)[0]);
      UtilityClass.insertList(lAccount);

      // List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
      List<Contact> lContact = new List<Contact>();
      lContact.add(TestDataFactory.createTestAdultContactNoInsert(1, lAccount.get(0).Id)[0]);
      lContact.add(TestDataFactory.createTestAdultContactNoInsert(1, lAccount.get(1).Id)[0]);
      lContact.add(TestDataFactory.createTestChildContactNoInsert(1, lAccount.get(1).Id)[0]);
      UtilityClass.insertList(lContact);

      Map<String, Contact> mContact = new Map<String, Contact>();
      mContact.put(CommonConstant.CONTACT_CHILD_TYPE, lContact[2]);

      // List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProduct.get(0).Id);
      List<BrandRelationship__c> lBrand = new List<BrandRelationship__c>();
      lBrand.add(TestDataFactory.createTestBrandRelationShipNoInsert(1, lContact.get(0).Id, lProduct.get(0).Id)[0]);
      lBrand.add(TestDataFactory.createTestBrandRelationShipNoInsert(1, lContact.get(1).Id, lProduct.get(1).Id)[0]);
      UtilityClass.insertList(lBrand);
        
      //Create Call Case
      Id caseRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
      // Case callCase = TestDataFactory.createCaseCall(lAccount.get(0).Id, lContact.get(0).Id);
      // callcase.RecordTypeId= caseRId;
      // update callCase;

      List<Case> callCases = new List<Case>();
      callcases.add(TestDataFactory.createCaseCallNoInsert(lAccount.get(0).Id, lContact.get(0).Id));
      callcases.add(TestDataFactory.createCaseCallNoInsert(lAccount.get(1).Id, lContact.get(1).Id));
      callcases[0].RecordTypeId= caseRId;
      callcases[1].RecordTypeId= caseRId;
      UtilityClass.insertList(callCases);
      
      List<PricebookEntry> entryList = new List<PricebookEntry>();
      entryList.add(TestDataFactory.createPricebookEntry(CommonConstant.MARKET_TH));
      entryList.add(TestDataFactory.createPricebookEntry(CommonConstant.MARKET_TW));
      UtilityClass.insertList(entryList);

      // List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
      //Insert lOrder;
      
      List<Order> lOrder = new List<Order>();
      lOrder.addAll(TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId()));
      lOrder.addAll(TestDataFactory.createOrder(2, lAccount.get(1).Id, lContact.get(1).Id, Test.getStandardPricebookId()));
      UtilityClass.insertList(lOrder);
                  
      //Create Promotion Record
      List<Promotion__c> lPromotion = TestDataFactory.createPromotionNoInsert(2);
      lPromotion.get(0).Market__c = CommonConstant.MARKET_TH;
      lPromotion.get(1).Market__c = CommonConstant.MARKET_TW;
      UtilityClass.insertList(lPromotion);
      
      //Create Promotion Item
      // List<PromotionItem__c> lPromotionItem = TestDataFactory.createPromotionItem(1,entryList[0].Product2Id ,lpromotion.get(0).Id);
      List<PromotionItem__c> lPromotionItem = new List<PromotionItem__c>();
      lPromotionItem.add(TestDataFactory.createPromotionItemNoInsert(1,entryList[0].Product2Id ,lpromotion.get(0).Id)[0]);
      lPromotionItem.add(TestDataFactory.createPromotionItemNoInsert(1,entryList[1].Product2Id ,lpromotion.get(1).Id)[0]);
      UtilityClass.insertList(lPromotionItem);
      
      //Create Order Item
      // OrderItem item1 = TestDataFactory.createOrderItem(lOrder[0].Id, entryList[0].Id);
      // item1.PromotionItem__c =  lPromotionItem.get(0).Id;
      // insert item1;  

      List<OrderItem> orderItemList = new List<OrderItem>();
      orderItemList.add(TestDataFactory.createOrderItem(lOrder[0].Id, entryList[0].Id));
      orderItemList.add(TestDataFactory.createOrderItem(lOrder[1].Id, entryList[0].Id));
      orderItemList.add(TestDataFactory.createOrderItem(lOrder[2].Id, entryList[1].Id));
      orderItemList.add(TestDataFactory.createOrderItem(lOrder[3].Id, entryList[1].Id));
      orderItemList[0].PromotionItem__c = lPromotionItem.get(0).Id;
      // orderItemList[2].OrderedFor__c = mContact.get(CommonConstant.CONTACT_CHILD_TYPE).Id;
      UtilityClass.insertList(orderItemList);

      // Affiliate_Value__c av = TestDataFactory.createAffiliateNoInsert('TW','TW-OCR-0006');
      // av.RecordTypeId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Order Cancellation Reason').getRecordTypeId();
      // insert av;

      List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
      avList.add(TestDataFactory.createAffiliateNoInsert('TH','TH-OCR-0006'));
      avList.add(TestDataFactory.createAffiliateNoInsert('TW','TW-OCR-0007'));
      avList[0].RecordTypeId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Order Cancellation Reason').getRecordTypeId();
      avList[1].RecordTypeId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Order Cancellation Reason').getRecordTypeId();
      UtilityClass.insertList(avList);
    }
  }

  private static testMethod void getPromotionTest(){
    System.Test.startTest();
      OrderItem item1 = [SELECT Id,Promotion__c,PromotionItem__c FROM OrderItem WHERE PromotionItem__c != null];
      update item1;

      List<contact> c =[select id from Contact];
      List<id> cid= new List<id>();

      for(Contact con: c){
          cid.add(con.id);
      }

      List<Order> Ols = [select id,OrderedBy__c from Order where OrderedBy__c in: cid];
      List<OrderItem> OILs= [Select Id, TotalPrice from OrderItem where Product_Family__c = 'Adult'];
    System.Test.stopTest();
    
    PromotionItem__c pi = [SELECT Id, Promotion__c FROM PromotionItem__c LIMIT 1];   
    System.assertEquals(item1.Promotion__c, pi.Promotion__c );
  }

  private static testMethod void updateCallOrderInfoTest1(){
      List<OrderItem> orderItemList = new List<OrderItem>();
      
      System.Test.startTest();
          Case callCase = [SELECT Id, RecordType.Name,TotalNumberoftheProductsOrdered__c,NumberOfConversion__c,NumberOfRetention__c,NumberOfCrossSell__c,NumberOfTrial__c,NumberOfWinBack__c,NumberOfUpSell__c
                          FROM Case LIMIT 1];

          Order callOrder = [SELECT Id, Case__c FROM Order LIMIT 1];
          callOrder.Case__c = callCase.Id;
          update callOrder;

          PricebookEntry entry = [Select Id FROM PricebookEntry LIMIT 1];

          OrderItem conversion = TestDataFactory.createOrderItem(callOrder.Id, entry.Id);
          conversion.Category__c = 'Conversion';
          // insert conversion ;
          
          OrderItem retention = TestDataFactory.createOrderItem(callOrder.Id, entry.Id);
          retention.Category__c = 'Retention';
          // insert retention;

          orderItemList.add(conversion);
          orderItemList.add(retention);

          UtilityClass.insertList(orderItemList);
      System.Test.stopTest();
      
      Case updatedCallCase = [SELECT Id, RecordType.Name,TotalNumberoftheProductsOrdered__c,NumberOfConversion__c,NumberOfRetention__c,NumberOfCrossSell__c,NumberOfTrial__c,NumberOfWinBack__c,NumberOfUpSell__c
                          FROM Case LIMIT 1];
      
      // System.assertEquals(true, updatedCallCase != null);
      // System.assertEquals(3, Integer.valueOf(updatedCallCase.TotalNumberoftheProductsOrdered__c));
      // System.assertEquals(1, Integer.valueOf(updatedCallCase.NumberofConversion__c));
      // System.assertEquals(1, Integer.valueOf(updatedCallCase.NumberofRetention__c));
  }

  private static testMethod void updateCallOrderInfoTest2(){
    List<OrderItem> orderItemList = new List<OrderItem>();
    
    System.Test.startTest();
        Case callCase = [SELECT Id, RecordType.Name,TotalNumberoftheProductsOrdered__c,NumberOfConversion__c,NumberOfRetention__c,NumberOfCrossSell__c,NumberOfTrial__c,NumberOfWinBack__c,NumberOfUpSell__c
        FROM Case LIMIT 1];

        Order callOrder = [SELECT Id, Case__c FROM Order LIMIT 1];
        callOrder.Case__c = callCase.Id;
        update callOrder;

        PricebookEntry entry = [Select Id FROM PricebookEntry LIMIT 1];

        OrderItem crosssell = TestDataFactory.createOrderItem(callOrder.Id, entry.Id);
        crosssell.Category__c = 'Cross-Sell';
        // insert crosssell ;
        
        OrderItem upsell = TestDataFactory.createOrderItem(callOrder.Id, entry.Id);
        upsell.Category__c = 'Up-Sell';
        // insert upsell ;

        orderItemList.add(crosssell);
        orderItemList.add(upsell);

        UtilityClass.insertList(orderItemList);
    System.Test.stopTest();
    
    Case updatedCallCase = [SELECT Id, RecordType.Name,TotalNumberoftheProductsOrdered__c,NumberOfConversion__c,NumberOfRetention__c,NumberOfCrossSell__c,NumberOfTrial__c,NumberOfWinBack__c,NumberOfUpSell__c
                        FROM Case LIMIT 1];
    
    // system.assertEquals(3, Integer.valueOf(updatedCallCase.TotalNumberoftheProductsOrdered__c));
    // system.assertEquals(1, Integer.valueOf(updatedCallCase.NumberofCrossSell__c));
    // system.assertEquals(1, Integer.valueOf(updatedCallCase.NumberofUpSell__c));
  }

  private static testMethod void updateCallOrderInfoTest3(){
    List<OrderItem> orderItemList = new List<OrderItem>();
    
    System.Test.startTest();
        Case callCase = [SELECT Id, RecordType.Name,TotalNumberoftheProductsOrdered__c,NumberOfConversion__c,NumberOfRetention__c,NumberOfCrossSell__c,NumberOfTrial__c,NumberOfWinBack__c,NumberOfUpSell__c
                        FROM Case LIMIT 1];
        
        Order callOrder = [SELECT Id, Case__c FROM Order LIMIT 1];
        callOrder.Case__c = callCase.Id;
        update callOrder;
        
        PricebookEntry entry = [Select Id FROM PricebookEntry LIMIT 1];

        OrderItem winback = TestDataFactory.createOrderItem(callOrder.Id, entry.Id);
        winback.Category__c = 'Win Back';
        // insert winback ;
        
        OrderItem trial = TestDataFactory.createOrderItem(callOrder.Id, entry.Id);
        trial.Category__c = 'Trial';
        // insert trial ;

        orderItemList.add(winback);
        orderItemList.add(trial);

        UtilityClass.insertList(orderItemList);
    System.Test.stopTest();
    
    Case updatedCallCase = [SELECT Id, RecordType.Name,TotalNumberoftheProductsOrdered__c,NumberOfConversion__c,NumberOfRetention__c,NumberOfCrossSell__c,NumberOfTrial__c,NumberOfWinBack__c,NumberOfUpSell__c
                        FROM Case LIMIT 1];
    
    // system.assertEquals(3, Integer.valueOf(updatedCallCase.TotalNumberoftheProductsOrdered__c));
    // system.assertEquals(1, Integer.valueOf(updatedCallCase.NumberofWinBack__c));
    // system.assertEquals(1, Integer.valueOf(updatedCallCase.NumberofTrial__c));  
  }

  private static testMethod void updateCallOrderInfoTest4(){
    List<OrderItem> orderItemList = new List<OrderItem>();
    
    System.Test.startTest();
        List<Contact> cList = [SELECT Id, Name, RecordType.Name, Parent__c FROM Contact WHERE Account.Market__c = :CommonConstant.MARKET_TW];
        Map<String, Contact> cMap = new Map<String, Contact>();
        List<Order> callOrder = [SELECT Id, Status, OrderedBy__c, OrderedBy__r.Account.Market__c, OrderedBy__r.RecordType.Name FROM Order WHERE OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];
        List<OrderItem> orderItemList2 = [SELECT Id, OrderedFor__c, OrderedFor__r.RecordType.Name FROM OrderItem WHERE Order.OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];

        for(Contact c : cList) {
          if(c.RecordType.Name == CommonConstant.CONTACT_CHILD_RECORDTYPE) {
            cMap.put(CommonConstant.CONTACT_CHILD_RECORDTYPE, c);
          }
          else if(c.RecordType.Name == CommonConstant.CONTACT_ADULT_RECORDTYPE) {
            cMap.put(CommonConstant.CONTACT_ADULT_RECORDTYPE, c);
          }
        }

        cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Parent__c = cMap.get(CommonConstant.CONTACT_ADULT_RECORDTYPE).Id;
        UtilityClass.updateList(cMap.values());

        orderItemList2[0].OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        orderItemList2[1].OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        UtilityClass.updateList(orderItemList2);

        callOrder[0].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        callOrder[1].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        UtilityClass.updateList(callOrder);
        
        PricebookEntry entry = [Select Id, Product2.Market__c FROM PricebookEntry WHERE Product2.Market__c = :CommonConstant.MARKET_TW LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(callOrder[0].Id, entry.Id);
        oi.OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        
        orderItemList.add(oi);

        UtilityClass.insertList(orderItemList);
    System.Test.stopTest();

    System.assertEquals(2, orderItemList2.size(), 'orderItemList2 should have 2');
    System.assertEquals(true, cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).RecordType.Name == CommonConstant.CONTACT_CHILD_RECORDTYPE, 'Should be child contact');
    System.assertEquals(true, cMap.get(CommonConstant.CONTACT_ADULT_RECORDTYPE).RecordType.Name == CommonConstant.CONTACT_ADULT_RECORDTYPE, 'Should be adult contact');
    System.assertEquals(true, cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Parent__c == cMap.get(CommonConstant.CONTACT_ADULT_RECORDTYPE).Id, 'Adult should be child\'s parent');
    System.assertEquals(true, callOrder[0].Status == CommonConstant.ORDER_STATUS_SUBMITTED, 'Past order Status should be Submitted');
    System.assertEquals(cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id, orderItemList2[0].OrderedFor__c, 'orderItemList2[0].OrderedFor__c should match');
    
    for(Order o : callOrder) {
      System.assertEquals(true, o != null, 'Should not be null');
      System.assertEquals(true, o.OrderedBy__r.Account.Market__c == CommonConstant.MARKET_TW, 'Should be TW market');
    }
  }

  private static testMethod void updateCallOrderInfoTest5(){
    List<OrderItem> orderItemList = new List<OrderItem>();
    
    System.Test.startTest();
        List<Contact> cList = [SELECT Id, Name, RecordType.Name, Parent__c FROM Contact WHERE Account.Market__c = :CommonConstant.MARKET_TW];
        Map<String, Contact> cMap = new Map<String, Contact>();
        List<Order> callOrder = [SELECT Id, Status, OrderedBy__c, OrderedBy__r.Account.Market__c, OrderedBy__r.RecordType.Name FROM Order WHERE OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];
        List<OrderItem> orderItemList2 = [SELECT Id, OrderedFor__c, OrderedFor__r.RecordType.Name FROM OrderItem WHERE Order.OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];

        for(Contact c : cList) {
          if(c.RecordType.Name == CommonConstant.CONTACT_CHILD_RECORDTYPE) {
            cMap.put(CommonConstant.CONTACT_CHILD_RECORDTYPE, c);
          }
          else if(c.RecordType.Name == CommonConstant.CONTACT_ADULT_RECORDTYPE) {
            cMap.put(CommonConstant.CONTACT_ADULT_RECORDTYPE, c);
          }
        }

        cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Parent__c = cMap.get(CommonConstant.CONTACT_ADULT_RECORDTYPE).Id;
        UtilityClass.updateList(cMap.values());

        orderItemList2[0].OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        orderItemList2[1].OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        UtilityClass.updateList(orderItemList2);

        callOrder[0].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        callOrder[1].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        UtilityClass.updateList(callOrder);
        
        PricebookEntry entry = [Select Id, Product2.Market__c FROM PricebookEntry WHERE Product2.Market__c = :CommonConstant.MARKET_TW LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(callOrder[0].Id, entry.Id);
        oi.OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        oi.Quantity = 5.0;
        
        orderItemList.add(oi);

        UtilityClass.insertList(orderItemList);
    System.Test.stopTest();
    
    for(Order o : callOrder) {
      System.assertEquals(true, o != null, 'Should not be null');
      System.assertEquals(true, o.OrderedBy__r.Account.Market__c == CommonConstant.MARKET_TW, 'Should be TW market');
    }
  }

  private static testMethod void updateCallOrderInfoTest6(){
    List<OrderItem> orderItemList = new List<OrderItem>();
    
    System.Test.startTest();
        List<Contact> cList = [SELECT Id, Name, BirthDate, RecordType.Name, Parent__c FROM Contact WHERE Account.Market__c = :CommonConstant.MARKET_TW];
        Map<String, Contact> cMap = new Map<String, Contact>();
        List<Order> callOrder = [SELECT Id, Status, OrderedBy__c, OrderedBy__r.Account.Market__c, OrderedBy__r.RecordType.Name FROM Order WHERE OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];
        List<OrderItem> orderItemList2 = [SELECT Id, OrderedFor__c, OrderedFor__r.RecordType.Name FROM OrderItem WHERE Order.OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];

        for(Contact c : cList) {
          if(c.RecordType.Name == CommonConstant.CONTACT_CHILD_RECORDTYPE) {
            cMap.put(CommonConstant.CONTACT_CHILD_RECORDTYPE, c);
          }
          else if(c.RecordType.Name == CommonConstant.CONTACT_ADULT_RECORDTYPE) {
            cMap.put(CommonConstant.CONTACT_ADULT_RECORDTYPE, c);
          }
        }

        cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Parent__c = cMap.get(CommonConstant.CONTACT_ADULT_RECORDTYPE).Id;
        cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).BirthDate = Date.today().addMonths(15);
        UtilityClass.updateList(cMap.values());

        orderItemList2[0].OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        orderItemList2[1].OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        UtilityClass.updateList(orderItemList2);

        callOrder[0].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        callOrder[1].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        UtilityClass.updateList(callOrder);
        
        PricebookEntry entry = [Select Id, Product2.Market__c FROM PricebookEntry WHERE Product2.Market__c = :CommonConstant.MARKET_TW LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(callOrder[0].Id, entry.Id);
        oi.OrderedFor__c = cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Id;
        oi.Quantity = 5.0;
        
        orderItemList.add(oi);

        UtilityClass.insertList(orderItemList);
    System.Test.stopTest();
    
    for(Order o : callOrder) {
      System.assertEquals(true, o != null, 'Should not be null');
      System.assertEquals(true, o.OrderedBy__r.Account.Market__c == CommonConstant.MARKET_TW, 'Should be TW market');
    }
  }

  private static testMethod void updateCallOrderInfoTest7(){
    List<OrderItem> orderItemList = new List<OrderItem>();
    
    System.Test.startTest();
        List<Order> callOrder = [SELECT Id, Status, OrderedBy__c, OrderedBy__r.Account.Market__c, OrderedBy__r.RecordType.Name FROM Order WHERE OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];

        callOrder[0].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        callOrder[1].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        UtilityClass.updateList(callOrder);
        
        PricebookEntry entry = [Select Id, Product2.Market__c FROM PricebookEntry WHERE Product2.Market__c = :CommonConstant.MARKET_TW LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(callOrder[0].Id, entry.Id);
        
        orderItemList.add(oi);

        UtilityClass.insertList(orderItemList);
    System.Test.stopTest();
    
    for(Order o : callOrder) {
      System.assertEquals(true, o != null, 'Should not be null');
      System.assertEquals(true, o.OrderedBy__r.Account.Market__c == CommonConstant.MARKET_TW, 'Should be TW market');
    }
  }

  private static testMethod void updateCallOrderInfoTest8(){
    List<OrderItem> orderItemList = new List<OrderItem>();
    
    System.Test.startTest();
        List<Order> callOrder = [SELECT Id, Status, OrderedBy__c, OrderedBy__r.Account.Market__c, OrderedBy__r.RecordType.Name FROM Order WHERE OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];

        callOrder[0].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        callOrder[1].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        UtilityClass.updateList(callOrder);
        
        PricebookEntry entry = [Select Id, Product2.Market__c FROM PricebookEntry WHERE Product2.Market__c = :CommonConstant.MARKET_TW LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(callOrder[0].Id, entry.Id);
        oi.Quantity = 5.0;
        
        orderItemList.add(oi);

        UtilityClass.insertList(orderItemList);
    System.Test.stopTest();
    
    for(Order o : callOrder) {
      System.assertEquals(true, o != null, 'Should not be null');
      System.assertEquals(true, o.OrderedBy__r.Account.Market__c == CommonConstant.MARKET_TW, 'Should be TW market');
    }
  }

  private static testMethod void updateCallOrderInfoTest9(){
    List<OrderItem> orderItemList = new List<OrderItem>();
    
    System.Test.startTest();
        List<Contact> cList = [SELECT Id, Name, BirthDate, RecordType.Name, Parent__c FROM Contact WHERE Account.Market__c = :CommonConstant.MARKET_TW];
        Map<String, Contact> cMap = new Map<String, Contact>();
        List<Order> callOrder = [SELECT Id, Status, OrderedBy__c, OrderedBy__r.Account.Market__c, OrderedBy__r.RecordType.Name FROM Order WHERE OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];
        List<OrderItem> orderItemList2 = [SELECT Id, OrderedFor__c, OrderedFor__r.RecordType.Name FROM OrderItem WHERE Order.OrderedBy__r.Account.Market__c = :CommonConstant.MARKET_TW];

        for(Contact c : cList) {
          if(c.RecordType.Name == CommonConstant.CONTACT_CHILD_RECORDTYPE) {
            cMap.put(CommonConstant.CONTACT_CHILD_RECORDTYPE, c);
          }
          else if(c.RecordType.Name == CommonConstant.CONTACT_ADULT_RECORDTYPE) {
            cMap.put(CommonConstant.CONTACT_ADULT_RECORDTYPE, c);
          }
        }

        cMap.get(CommonConstant.CONTACT_CHILD_RECORDTYPE).Parent__c = cMap.get(CommonConstant.CONTACT_ADULT_RECORDTYPE).Id;
        cMap.get(CommonConstant.CONTACT_ADULT_RECORDTYPE).EstimatedDueDate__c = Date.today().addMonths(15);
        UtilityClass.updateList(cMap.values());

        callOrder[0].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        callOrder[1].Status = CommonConstant.ORDER_STATUS_SUBMITTED;
        UtilityClass.updateList(callOrder);
        
        PricebookEntry entry = [Select Id, Product2.Market__c FROM PricebookEntry WHERE Product2.Market__c = :CommonConstant.MARKET_TW LIMIT 1];

        OrderItem oi = TestDataFactory.createOrderItem(callOrder[0].Id, entry.Id);
        oi.Quantity = 5.0;
        
        orderItemList.add(oi);

        UtilityClass.insertList(orderItemList);
    System.Test.stopTest();
    
    for(Order o : callOrder) {
      System.assertEquals(true, o != null, 'Should not be null');
      System.assertEquals(true, o.OrderedBy__r.Account.Market__c == CommonConstant.MARKET_TW, 'Should be TW market');
    }
  }

  private static testMethod void updatePartialStatusCompleted(){
    List<OrderItem> oiList = [Select Id, Order.Id, Status__c from OrderItem];

    for (OrderItem oi: oiList ) {
      oi.Status__c = 'Completed';
    }

    System.Test.startTest();
    update oiList;
    System.Test.stopTest();
    Order o = [Select Status from Order limit 1];
    System.assertEquals('Completed', o.Status);
  }

  private static testMethod void updatePartialStatusCancelled(){
    System.Test.startTest();
    List<OrderItem> oiList = [Select Id, Status__c from OrderItem];
    for (OrderItem oi: oiList ) {
      oi.Status__c = 'Cancelled';
    }
    update oiList;
    System.Test.stopTest();
    Order o = [Select Status from Order limit 1];
    System.assertEquals('Cancelled - Upon Delivery', o.Status);
  }
}