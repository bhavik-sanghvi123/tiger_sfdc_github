@isTest
public class DeleteRecordsBatchTest {
    @testSetup
    static void setup(){
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
        System.runAs(sysad) {
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            lProduct.get(0).Market__c = 'VN';
            lProduct.get(0).ProductCode = '123';
            Update lProduct;
            
            List<Channel__c>  lChannel = TestDataFactory.createTestChannel(1);
            lChannel.get(0).Market__c = 'VN';
            lChannel.get(0).Channel_Ref_No__c = 'FB';
            lChannel.get(0).Name = 'FB';
            lChannel.get(0).RecordTypeId = Schema.SObjectType.Channel__c.getRecordTypeInfosByName().get(CommonConstant.CHANNEL_OTHER_ONLINE_RECORDTYPE).getRecordTypeId();
            update lChannel;
            
            TestDataFactory.createAffiliate('VN','English');
            TestDataFactory.createAffiliate('VN','Malay');
            
            Campaign cam = TestDataFactory.createCampaign('Cam','Similac','VN');
            cam.ExternalId__c = '123';
            Insert cam;
            
            List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
            lCity.get(0).Market__c = 'VN';
            update lCity;
            
            List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
            lRegion.get(0).Market__c = 'VN';
            update lRegion;
            
            TestDataFactory.createTestWard(1, 'VN');
            TestDataFactory.createTestDistrict(1, 'VN');
            TestDataFactory.createTestEthnicity(1, 'VN');
            TestDataFactory.createTestSwitchReason(1, 'VN');
            
            VN_contact_manual__c vnCon1 = TestDataFactory.createVNContactManual('VN', 'Street', 'Test City', '123', 'ProductName -1', 'User', 'New', 'LastName', 'test@test.com', '0911111111', 'FB', 'FB', '10/10/2022', '123');
            VN_contact_manual__c vnCon2 = TestDataFactory.createVNContactManual('VN', 'Street', 'Test City', '123', 'ProductName -1', 'User', 'New', 'LastName', 'test@test.com', '0911111112', 'FB', 'FB', '10/10/2022', '123');
            VN_contact_manual__c vnCon3 = TestDataFactory.createVNContactManual('VN', 'Street', 'Test City', '123', 'ProductName -1', 'User', 'New', 'LastName', 'test@test.com', '0911111113', 'FB', 'FB', '10/10/2022', '123');
            List<VN_contact_manual__c> vnConList = new List<VN_contact_manual__c>{vnCon1, vnCon2, vnCon3};
            insert vnConList;
        }
    }
    
    static testmethod void test_validObjectName(){
        Test.startTest();
        DeleteRecordsBatch batch = new DeleteRecordsBatch('VN_contact_manual__c', 0, null, 0, 20);
        Database.executebatch(batch, 20);
        Test.stopTest();
        List<VN_contact_manual__c> vnConCheck = [SELECT Id FROM VN_contact_manual__c];
        System.assertEquals(vnConCheck.size(), 0);
    } 
    static testmethod void test_invalidObjectName(){
        Test.startTest();
        DeleteRecordsBatch batch = new DeleteRecordsBatch('VN_contact_manual', 0, null, 0, 20);
        Database.executebatch(batch, 20);
        Test.stopTest();
        List<VN_contact_manual__c> vnConCheck = [SELECT Id FROM VN_contact_manual__c];
        System.assertEquals(vnConCheck.size(), 3);
    }
    static testmethod void test_validFieldName(){
        Test.startTest();
        Map<String,String> fieldFilterMap = new Map<String,String>();
        fieldFilterMap.put('contact_mobilephone__c','0911111111');
        DeleteRecordsBatch batch = new DeleteRecordsBatch('VN_contact_manual__c', 0, fieldFilterMap, 0, 20);
        Database.executebatch(batch, 20);
        Test.stopTest();
        List<VN_contact_manual__c> vnConCheck = [SELECT Id FROM VN_contact_manual__c];
        System.assertEquals(vnConCheck.size(), 2);
    } 
    static testmethod void test_invalidFieldName(){
        Test.startTest();
        Map<String,String> fieldFilterMap = new Map<String,String>();
        fieldFilterMap.put('contact_mobilephone','0911111111');
        DeleteRecordsBatch batch = new DeleteRecordsBatch('VN_contact_manual__c', 0, fieldFilterMap, 0, 20);
        Database.executebatch(batch, 20);
        Test.stopTest();
        List<VN_contact_manual__c> vnConCheck = [SELECT Id FROM VN_contact_manual__c];
        System.assertEquals(vnConCheck.size(), 0);
    } 
    static testmethod void test_schedule(){
        Test.startTest();
        System.schedule('DeleteRecordsBatch', '0 0 13 * * ?', new DeleteRecordsBatch('', 0, null, 0, 100));
        Test.stopTest();
    }
    static testmethod void test_deleteOtherObject(){
        Account a = TestDataFactory.createTestHousehold(1, 'ID')[0];
        Contact adult = TestDataFactory.createContact(true, a.Id, null, Date.parse('01/01/1990'), '0912345678');
        Contact child = TestDataFactory.createContact(false, a.Id, adult.Id, Date.parse('01/01/2022'), '');
        Affiliate_Value__c cityDefault = TestDataFactory.createAffiliateValue('City', 'TEST_CITY_DEFAULT', 'ID', null);
        Affiliate_Value__c districtDefault = TestDataFactory.createAffiliateValue('District', 'TEST_DISTRICT_DEFAULT', 'ID', cityDefault.Id);
        String streetNameDefault = 'TEST_STREET_DEFAULT';
		Address__c addressDefault = TestDataFactory.createAddress(true, adult.Id, 'Indonesia', cityDefault.Id, districtDefault.Id, null, streetNameDefault);
        AbbottPartner__c ap = TestDataFactory.createAbbottPartner('ID', 'Dietician', 'AA');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry('ID', 'IDR');
        PricebookEntry pbe1 = TestDataFactory.createProductAndPricebookEntryDiffBrand('ID', 'IDR', pbe.Pricebook2Id, 'Pediasure');
        Product2 prod1 = [SELECT Id, ParentBrand__c FROM Product2 WHERE Id =: pbe1.Product2Id];
        Channel__c channel = TestDataFactory.createTestChannel(1, 'ID', 'TEST_CHANNEL')[0];
        Campaign campPed = TestDataFactory.createCampaignInsert('ID1.0_Pediasure_Call1_Verificationcall', 'Pediasure', 'ID', prod1.ParentBrand__c);
        BrandRelationship__c br1 = TestDataFactory.createTestBrandRelationShipwithUser(1, adult.Id, child.Id, prod1.Id)[0];
        ChannelResponse__c cr1 = TestDataFactory.createTestChannelResponseMultiple(1, br1, channel, addressDefault, prod1, true, 'Pending')[0];
        
        Test.startTest();
        Map<String,String> fieldFilterMap1 = new Map<String,String>();
        fieldFilterMap1.put('OrderCreationStatus__c','Pending');
        DeleteRecordsBatch batch = new DeleteRecordsBatch('ChannelResponse__c', 0, fieldFilterMap1, 100, 20);
        Database.executebatch(batch, 20);
        Map<String,String> fieldFilterMap2 = new Map<String,String>();
        fieldFilterMap2.put('Market__c','ID');
        DeleteRecordsBatch batch1 = new DeleteRecordsBatch('Account', 0, fieldFilterMap2, 5, 20);
        Database.executebatch(batch1, 20);
        Map<String,String> fieldFilterMap3 = new Map<String,String>();
        fieldFilterMap3.put('Market__c','ID');
        fieldFilterMap3.put('Phone','0912345678');
        fieldFilterMap3.put('RecordType.Name','Adult');
        DeleteRecordsBatch batch2 = new DeleteRecordsBatch('Contact', 0, fieldFilterMap3, 1, 20);
        Database.executebatch(batch2, 20);
        Test.stopTest();
        /*List<ChannelResponse__c> crCheck = [SELECT Id FROM ChannelResponse__c WHERE OrderCreationStatus__c = 'Pending'];
        System.assertEquals(crCheck.size(), 0);
        List<Account> acctCheck = [SELECT Id FROM Account WHERE Market__c = 'ID'];
        System.assertEquals(acctCheck.size(), 1);
        List<Contact> conCheck = [SELECT Id FROM Contact WHERE Market__c = 'ID' AND Phone = '0912345678' AND RecordType.Name = 'Adult'];
        System.assertEquals(conCheck.size(), 0);*/
    }
}