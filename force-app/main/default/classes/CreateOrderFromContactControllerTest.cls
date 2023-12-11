@isTest
public class CreateOrderFromContactControllerTest {
    
    @isTest
    static void pageLoad () {
        Test.startTest();
        CreateOrderFromContactController.CreateOrderElements elem = CreateOrderFromContactController.pageOnInit('', NULL, '', NULL, '', '','');
        Test.stopTest();
        
        System.Assert(elem != NULL, 'Page elements not loaded properly');
    }
    
    @isTest
    static void fetchContacts () {
        Account acc 	= TestDataFactory.createTestHousehold(1)[0];
        acc.Market__c = 'SG';
        update acc;
        
        Contact con		= TestDataFactory.createSGTestAdultContact(1, acc.Id)[0];
        Product2 prod 	= TestDataFactory.createTestBrandProduct(1)[0];
        
        Address__c add = TestDataFactory.createTestDefaultAddress(1, con.Id, NULL, null)[0];
        add.ParentHousehold__c = acc.Id;
        update add;
        
        TestDataFactory.createTestBrandRelationShip(1, con.Id, prod.Id);
        
        Test.startTest();
        List<CreateOrderFromContactController.ContactForOrder> conList = CreateOrderFromContactController.getContacts('', NULL, '', NULL, '', '','');
        Test.stopTest();
                
        System.Assert(conList.size() > 0, 'No list returned');
    }

    @isTest
    static void createOrder () {
        
        Account acc 	= TestDataFactory.createTestHousehold(1)[0];
        acc.Market__c	= 'SG';
        update acc;
        
        Contact con				= TestDataFactory.createSGTestAdultContact(1, acc.Id)[0];
    
        PricebookEntry pbEntry 	= TestDataFactory.createPricebookEntry('SG');
        insert pbEntry;
        
        String orderStr = '{"Type":"Telesales - Outbound","Status":"Draft","EffectiveDate":"2021-04-27","CurrencyIsoCode":"MYR","Pricebook2Id":"' + pbEntry.Pricebook2Id + '","RelatedCampaign__c":null,"PaymentMethod__c":"None"}';
        
        Map<Object, Object> objCon = new Map<Object, Object>();
        objCon.put('campaignNames', 'Test, Test, Test Campaign!');
        objCon.put('householdId', acc.Id);
        objCon.put('id', con.Id);
        objCon.put('market', 'PH');
        objCon.put('name', 'Eligibility PH');
        List<Object> objList = new List<Object>{(Object)objCon};
        
        Test.startTest();
        CreateOrderFromContactController.createOrder(orderStr, objList);
        Test.stopTest();
    }
    
    @isTest
    static void createOrderProd () {
        
        Account acc 	= TestDataFactory.createTestHousehold(1)[0];
        acc.Market__c = 'SG';
        update acc;
        
        Contact con				= TestDataFactory.createSGTestAdultContact(1, acc.Id)[0];
        PricebookEntry pbEntry 	= TestDataFactory.createPricebookEntry('SG');
        insert pbEntry;
        
        Order ord = TestDataFactory.createOrder(1, acc.Id, con.Id, pbEntry.Pricebook2Id)[0];
        insert ord;
        
        String orderStr = '{"Product2Id":"' + pbEntry.Product2Id + '","Category__c":null, "Quantity":1}';
        
        Map<Object, Object> objCon = new Map<Object, Object>();
        objCon.put('householdId', acc.Id);
        objCon.put('id', con.Id);
        objCon.put('market', con.Market__c);
        objCon.put('name', con.Name);
        objCon.put('orderId', ord.Id);
        objCon.put('pricebookId', pbEntry.Pricebook2Id);
        List<Object> objList = new List<Object>{(Object)objCon};
        
        Test.startTest();
        CreateOrderFromContactController.createOrderProd(orderStr, objList);
        Test.stopTest();
    }
    
}