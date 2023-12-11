@isTest
public class OrderUploadTWBatchTest {
    @testSetup
    static void setup(){
        //Household 1
        Account a1 = TestDataFactory.createTestHousehold(1, 'TW')[0];
        Contact adult1 = TestDataFactory.createContact(true, a1.Id, null, Date.parse('01/01/1990'), '0912345678');
        Contact child1 = TestDataFactory.createContact(false, a1.Id, adult1.Id, Date.Today().addMonths(-6), '');
        Affiliate_Value__c cityDefault1 = TestDataFactory.createAffiliateValue('City', 'TEST_CITY_DEFAULT', 'TW', null);
        Affiliate_Value__c districtDefault1 = TestDataFactory.createAffiliateValue('District', 'TEST_DISTRICT_DEFAULT', 'TW', cityDefault1.Id);
        String streetNameDefault1 = 'TEST_STREET_DEFAULT';
		Address__c addressDefault1 = TestDataFactory.createAddress(true, adult1.Id, 'Taiwan', cityDefault1.Id, districtDefault1.Id, null, streetNameDefault1);
        
        //Household 2
        Account a2 = TestDataFactory.createTestHousehold(1, 'TW')[0];
        Contact adult2 = TestDataFactory.createContact(true, a2.Id, null, Date.parse('01/01/1990'), '0911111111');
        Contact child2 = TestDataFactory.createContact(false, a2.Id, adult2.Id, Date.Today().addMonths(-6), '');
        Affiliate_Value__c cityNonDefault2 = TestDataFactory.createAffiliateValue('City', 'TEST_CITY_NON_DEFAULT', 'TW', null);
        Affiliate_Value__c districtNonDefault2 = TestDataFactory.createAffiliateValue('District', 'TEST_DISTRICT_NON_DEFAULT', 'TW', cityNonDefault2.Id);
        String streetNameNonDefault2 = 'TEST_STREET_NON_DEFAULT';
        Address__c addressNonDefault2 = TestDataFactory.createAddress(false, adult2.Id, 'Taiwan', cityNonDefault2.Id, districtNonDefault2.Id, null, streetNameNonDefault2);
        
        AbbottPartner__c ap = TestDataFactory.createAbbottPartner('TW', 'Dietician', 'AA');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry('TW', 'TWD');
        PricebookEntry pbe1 = TestDataFactory.createProductAndPricebookEntryOnly('TW', 'TWD', pbe.Pricebook2Id);
        PricebookEntry pbe2 = TestDataFactory.createProductAndPricebookEntryOnly('TW', 'TWD', pbe.Pricebook2Id);
        PricebookEntry pbe3 = TestDataFactory.createProductAndPricebookEntryOnly('TW', 'TWD', pbe.Pricebook2Id);
    }
    
    static testmethod void happyPath(){
        Date dToday = Date.today().addMonths(-6);
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        PricebookEntry pbe = [SELECT Id, Product2Id, Pricebook2Id, Pricebook2.Name, ProductCode FROM PricebookEntry LIMIT 1][0];
        TW_Order_Manual__c two = TestDataFactory.createTWOrderManual('0912345678', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        Test.startTest();
        OrderUploadTWBatch batch = new OrderUploadTWBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        
        TW_Order_Manual__c twoUpdated = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two.Id];
        Order orderRec = [SELECT Id, Status FROM Order WHERE TW_Order_Manual_ID__c =: twoUpdated.Id LIMIT 1];
        System.assertEquals('Success', twoUpdated.Status__c);
        System.assertEquals('Submitted', orderRec.Status);
    }

    static testmethod void firstLevelValidation(){
        Date dToday1 = Date.today().addMonths(-6);
        Date dToday2 = Date.today().addMonths(-8);
        DateTime dt1 = DateTime.newInstance(dToday1.year(), dToday1.month(),dToday1.day());
        DateTime dt2 = DateTime.newInstance(dToday2.year(), dToday2.month(),dToday2.day());
        PricebookEntry pbe = [SELECT Id, Product2Id, Pricebook2Id, Pricebook2.Name, ProductCode FROM PricebookEntry LIMIT 1][0];
        //Phone and Birthdate must be populated
        TW_Order_Manual__c two1 = TestDataFactory.createTWOrderManual('', dt1.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        //Tax ID must be numeric
        TW_Order_Manual__c two2 = TestDataFactory.createTWOrderManual('0912345678', dt1.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '1234aaaa', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        //Child not found
        TW_Order_Manual__c two3 = TestDataFactory.createTWOrderManual('0912345678', dt2.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        //Mother not found
        TW_Order_Manual__c two4 = TestDataFactory.createTWOrderManual('09123456789', dt1.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        Test.startTest();
        OrderUploadTWBatch batch = new OrderUploadTWBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        
        TW_Order_Manual__c twoUpdated1 = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two1.Id];
        TW_Order_Manual__c twoUpdated2 = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two2.Id];
        TW_Order_Manual__c twoUpdated3 = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two3.Id];
        TW_Order_Manual__c twoUpdated4 = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two4.Id];
        
        System.assertEquals('Error', twoUpdated1.Status__c);
        System.assertEquals('Error', twoUpdated2.Status__c);
        System.assertEquals('Error', twoUpdated3.Status__c);
        System.assertEquals('Error', twoUpdated4.Status__c);
    }
    
    static testmethod void productValidation(){
        Date dToday = Date.today().addMonths(-6);
        Date dToday1 = Date.today().addMonths(-24);
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        DateTime dt1 = DateTime.newInstance(dToday1.year(), dToday1.month(),dToday1.day());
        PricebookEntry pbe = [SELECT Id, Product2Id, Pricebook2Id, Pricebook2.Name, ProductCode FROM PricebookEntry LIMIT 1][0];
        //No Products
        TW_Order_Manual__c two1 = TestDataFactory.createTWOrderManual('0912345678', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', '', '', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        //No Quanitity
        TW_Order_Manual__c two2 = TestDataFactory.createTWOrderManual('0912345678', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        //No Pricebook name
        TW_Order_Manual__c two3 = TestDataFactory.createTWOrderManual('0912345678', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', '');
        //Purchase Limit
        TW_Order_Manual__c two4 = TestDataFactory.createTWOrderManual('0912345678', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '2', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        //Child age does not fit product birth range
        Contact adult = [SELECT Id, AccountId FROM Contact WHERE PrimaryContact__c = true LIMIT 1][0];
        Contact child = TestDataFactory.createContact(false, adult.AccountId, adult.Id, Date.parse('01/01/2020'), '');
        TW_Order_Manual__c two5 = TestDataFactory.createTWOrderManual('0912345678', dt1.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        //No existing product code
        TW_Order_Manual__c two6 = TestDataFactory.createTWOrderManual('0912345678', dt1.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', 'abcdefg', '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        //No Pricebookname
        TW_Order_Manual__c two7 = TestDataFactory.createTWOrderManual('0912345678', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', 'abcdefg');
        //No PricebookEntry for Product
        Product2 extraProduct = TestDataFactory.createTestBrandProductTW(1)[0];
        TW_Order_Manual__c two8 = TestDataFactory.createTWOrderManual('0912345678', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', extraProduct.ProductCode, '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        
        Test.startTest();
        OrderUploadTWBatch batch = new OrderUploadTWBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        
        for(TW_Order_Manual__c two : [SELECT Id, Status__c FROM TW_Order_Manual__c]){
            System.assertEquals('Error', two.Status__c);
        }
    }
    
    static testmethod void addressValidation(){
        Date dToday = Date.today().addMonths(-6);
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        List<PricebookEntry> pbeList = [SELECT Id, Product2Id, Pricebook2Id, Pricebook2.Name, ProductCode FROM PricebookEntry];
        
        //Create New Address - City and District not existing
        TW_Order_Manual__c two1 = TestDataFactory.createTWOrderManual('0911111111', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                      'TEST_CITY_NOT_EXISTING', 'TEST_DISTRICT_NOT_EXISTING', 'TEST_STREET_NOT_EXISTING', '12345678', 'TEST_TAX', pbeList[0].ProductCode, '1', '', '',
                                                                      '', '', '', '', pbeList[0].Pricebook2.Name);
        //Create New Address - City and District existing
        TW_Order_Manual__c two2 = TestDataFactory.createTWOrderManual('0911111111', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                      'TEST_CITY_DEFAULT', 'TEST_DISTRICT_DEFAULT', 'TEST_STREET_DEFAULT', '12345678', 'TEST_TAX', pbeList[1].ProductCode, '1', '', '',
                                                                      '', '', '', '', pbeList[1].Pricebook2.Name);
        //Address Found in Related Addresses
        TW_Order_Manual__c two3 = TestDataFactory.createTWOrderManual('0911111111', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                      'TEST_CITY_NON_DEFAULT', 'TEST_DISTRICT_NON_DEFAULT', 'TEST_STREET_NON_DEFAULT', '12345678', 'TEST_TAX', pbeList[2].ProductCode, '1', '', '',
                                                                      '', '', '', '', pbeList[2].Pricebook2.Name);
        
        //No Related Address - Create new
        TW_Order_Manual__c two4 = TestDataFactory.createTWOrderManual('0900000000', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                      'TEST_CITY_NON_DEFAULT', 'TEST_DISTRICT_NON_DEFAULT', 'TEST_STREET_NON_DEFAULT', '12345678', 'TEST_TAX', pbeList[3].ProductCode, '1', '', '',
                                                                      '', '', '', '', pbeList[3].Pricebook2.Name);
        Test.startTest();
         //Household 3
        Account a3 = TestDataFactory.createTestHousehold(1, 'TW')[0];
        Contact adult3 = TestDataFactory.createContact(true, a3.Id, null, Date.parse('01/01/1990'), '0900000000');
        Contact child3 = TestDataFactory.createContact(false, a3.Id, adult3.Id, Date.Today().addMonths(-6), '');
        
        OrderUploadTWBatch batch = new OrderUploadTWBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        
        TW_Order_Manual__c twoUpdated1 = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two1.Id];
        TW_Order_Manual__c twoUpdated2 = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two2.Id];
        TW_Order_Manual__c twoUpdated3 = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two3.Id];
        TW_Order_Manual__c twoUpdated4 = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two4.Id];
        
        System.assertEquals('Success', twoUpdated1.Status__c);
        System.assertEquals('Success', twoUpdated2.Status__c);
        System.assertEquals('Success', twoUpdated3.Status__c);
        System.assertEquals('Success', twoUpdated4.Status__c);
    }
    
    static testmethod void insertAllObjectThenError(){
        Date dToday = Date.today().addMonths(-6);
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        PricebookEntry pbe = [SELECT Id, Product2Id, Pricebook2Id, Pricebook2.Name, ProductCode FROM PricebookEntry LIMIT 1][0];
		//Error in Order PreferredDeliveryTime__c
        TW_Order_Manual__c two = TestDataFactory.createTWOrderManual('0911111111', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm ABCD', '03/01/2022', 'other', 'AA', 'AA',
                                                                     'TEST_CITY_NOT_EXISTING', 'TEST_DISTRICT_NOT_EXISTING', 'TEST_STREET_NOT_EXISTING', '12345678', 'TEST_TAX', pbe.ProductCode, '1', '', '',
                                                                     '', '', '', '', pbe.Pricebook2.Name);
        Test.startTest();
        OrderUploadTWBatch batch = new OrderUploadTWBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        
        TW_Order_Manual__c twoUpdated = [SELECT Id, Status__c FROM TW_Order_Manual__c WHERE Id =: two.Id];
        System.assertEquals('Error', twoUpdated.Status__c);
    }
    
    static testmethod void insertAllObjectBulkTest(){
        Date dToday = Date.today().addMonths(-6);
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        List<PricebookEntry> pbeInsertList = new List<PricebookEntry>();
        List<TW_Order_Manual__c> twoInsertList = new List<TW_Order_Manual__c>();
        Integer numOfRecords = 200;
        
        PricebookEntry pbe = [SELECT Id, Product2Id, Pricebook2Id, Pricebook2.Name, ProductCode FROM PricebookEntry LIMIT 1][0];
        List<Product2> insertProductList = TestDataFactory.createProductMultipleNoInsert(numOfRecords, 'TW', 'TWD', pbe.Pricebook2Id);
        insert insertProductList;
        
        for(Product2 p : [SELECT Id FROM Product2 WHERE ParentBrand__c != null]){
            PricebookEntry pbeInsert = TestDataFactory.createPricebookEntryNoInsert('TW', 'TWD', pbe.Pricebook2Id, p.Id);
        	pbeInsertList.add(pbeInsert);
        }
        insert pbeInsertList;
        
        for(PricebookEntry pbeInsert : pbeInsertList){
            TW_Order_Manual__c two = TestDataFactory.createTWOrderManualNoInsert('0911111111', dt.format('MM/dd/yyyy'), 'Cash on Delivery', 'VAT II', 'Slot B : 12noon - 3pm', '03/01/2022', 'other', 'AA', 'AA',
                                                                                 'TEST_CITY_NOT_EXISTING', 'TEST_DISTRICT_NOT_EXISTING', 'TEST_STREET_NOT_EXISTING', '12345678', 'TEST_TAX', pbeInsert.ProductCode, '1', '', '',
                                                                                 '', '', '', '', pbeInsert.Pricebook2.Name);
            twoInsertList.add(two);
        }
        insert twoInsertList;
        
        Test.startTest();
        OrderUploadTWBatch batch = new OrderUploadTWBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        
        Set<String> twoIds = new Set<String>();
        for(TW_Order_Manual__c twoUpdated : [SELECT Id, Status__c FROM TW_Order_Manual__c]){
            twoIds.add(twoUpdated.Id);
            System.assertEquals('Success', twoUpdated.Status__c);   
        }
        for(Order orderRec : [SELECT Id, Status FROM Order WHERE TW_Order_Manual_ID__c IN: twoIds]){
            System.assertEquals('Submitted', orderRec.Status);   
        }
    }
}