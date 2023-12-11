@isTest
public class BrandRelationshipCRInfoBatchTest {
    @testSetup
    static void setup(){
        Account a = TestDataFactory.createTestHousehold(1, 'TW')[0];
        Contact adult = TestDataFactory.createContact(true, a.Id, null, Date.parse('01/01/1990'), '09123456');
        Contact child = TestDataFactory.createContact(false, a.Id, adult.Id, Date.today().addMonths(-8), '09110011');
        Contact child1 = TestDataFactory.createContact(false, a.Id, adult.Id, Date.today().addMonths(-8), '09000000');
        Affiliate_Value__c cityDefault = TestDataFactory.createAffiliateValue('City', 'TEST_CITY_DEFAULT', 'TW', null);
        Affiliate_Value__c districtDefault = TestDataFactory.createAffiliateValue('District', 'TEST_DISTRICT_DEFAULT', 'TW', cityDefault.Id);
        String streetNameDefault = 'TEST_STREET_DEFAULT';
        Address__c addressDefault = TestDataFactory.createAddress(true, adult.Id, 'Taiwan', cityDefault.Id, districtDefault.Id, null, streetNameDefault);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry('TW', 'TWD');
        Product2 prod1 = TestDataFactory.createProductDiffBrand('TW', 'TWD', pbe.Pricebook2Id, 'Similac', 'SIMILAC MOM');
        Product2 prod2 = TestDataFactory.createProductDiffBrand('TW', 'TWD', pbe.Pricebook2Id, 'Similac', 'SIMILAC MOM');
        Channel__c channel = TestDataFactory.createTestChannel(1, 'TW', 'TEST_CHANNEL')[0];
        Campaign campSim = TestDataFactory.createCampaignInsert('SG-SimilacMum-Con&Ren-Call', 'Similac', 'TW', prod1.ParentBrand__c);
    }
    static testmethod void test_schedule(){
        Test.startTest();
        System.schedule('BrandRelationshipCRInfoBatch', '0 0 3 * * ?', new BrandRelationshipCRInfoBatch('TW', null, Date.Today().addDays(-7), null, null));
        Test.stopTest();
    }
    static testmethod void test1(){
        Account a = [SELECT Id FROM Account WHERE Market__c = 'TW'][0];
        Contact child = [SELECT Id, Parent__c FROM Contact WHERE AccountId =: a.Id AND RecordType.Name = 'Child' AND Phone = '09000000'][0];
        Contact child1 = [SELECT Id, Parent__c FROM Contact WHERE AccountId =: a.Id AND RecordType.Name = 'Child' AND Phone = '09110011'][0];
        Campaign campaign = [SELECT Id, Product__c, Product__r.Name FROM Campaign WHERE Name = 'SG-SimilacMum-Con&Ren-Call'][0];
        Channel__c channel = [SELECT Id FROM Channel__c WHERE Name = 'TEST_CHANNEL'][0];
        List<Product2> prodList = [SELECT Id, Name, ParentBrand__c FROM Product2 WHERE Name = 'SIMILAC MOM' AND Keybrand__c = 'Similac' AND ParentBrand__c != null LIMIT 2];
        Address__c addr = [SELECT Id FROM Address__c WHERE Country__c = 'Taiwan'][0];
        Test.startTest();
        BrandRelationship__c br1 = TestDataFactory.createTestBrandRelationShipwithUser(1, child.Parent__c, child.Id, prodList[0].Id)[0];
        ChannelResponse__c cr1 = TestDataFactory.createTestChannelResponseMultiple(1, br1, channel, addr, prodList[0], true, 'Pending')[0];
        BrandRelationship__c br2 = TestDataFactory.createTestBrandRelationShipwithUser(1, child.Parent__c, child.Id, prodList[1].Id)[0];
        ChannelResponse__c cr21 = TestDataFactory.createTestChannelResponseMultiple(1, br2, channel, addr, prodList[1], true, 'Pending')[0];
        ChannelResponse__c cr22 = TestDataFactory.createTestChannelResponseMultiple(1, br2, channel, addr, prodList[1], true, 'Pending')[0];
        BrandRelationship__c br3 = TestDataFactory.createTestBrandRelationShipwithUser(1, child1.Parent__c, child1.Id, prodList[0].Id)[0];
        ChannelResponse__c cr31 = TestDataFactory.createTestChannelResponseMultiple(1, br3, channel, addr, prodList[0], true, 'Pending')[0];
        ChannelResponse__c cr32 = TestDataFactory.createTestChannelResponseMultiple(1, br3, channel, addr, prodList[0], true, 'Pending')[0];
        ChannelResponse__c cr33 = TestDataFactory.createTestChannelResponseMultiple(1, br3, channel, addr, prodList[0], true, 'Pending')[0];
        BrandRelationship__c brBefore1 = [SELECT Id, FirstChannelResponse__c, FirstChannelResponseDate__c, LatestChannelResponse__c, LatestChannelResponseDate__c FROM BrandRelationship__c WHERE Id =: br1.Id];
        BrandRelationship__c brBefore2 = [SELECT Id, FirstChannelResponse__c, FirstChannelResponseDate__c, LatestChannelResponse__c, LatestChannelResponseDate__c FROM BrandRelationship__c WHERE Id =: br2.Id];
        BrandRelationship__c brBefore3 = [SELECT Id, FirstChannelResponse__c, FirstChannelResponseDate__c, LatestChannelResponse__c, LatestChannelResponseDate__c FROM BrandRelationship__c WHERE Id =: br3.Id];
        System.assertEquals(brBefore1.FirstChannelResponse__c, null);
        System.assertEquals(brBefore2.FirstChannelResponse__c, null);
        System.assertEquals(brBefore3.FirstChannelResponse__c, null);
        BrandRelationshipCRInfoBatch batch = new BrandRelationshipCRInfoBatch('TW', null, Date.Today().addDays(-7), Date.Today(), null); 
        Database.executebatch(batch, 20);
        Test.stopTest();
        BrandRelationship__c brAfter1 = [SELECT Id, FirstChannelResponse__c, FirstChannelResponseDate__c, LatestChannelResponse__c, LatestChannelResponseDate__c FROM BrandRelationship__c WHERE Id =: br1.Id];
        BrandRelationship__c brAfter2 = [SELECT Id, FirstChannelResponse__c, FirstChannelResponseDate__c, LatestChannelResponse__c, LatestChannelResponseDate__c FROM BrandRelationship__c WHERE Id =: br2.Id];
        BrandRelationship__c brAfter3 = [SELECT Id, FirstChannelResponse__c, FirstChannelResponseDate__c, LatestChannelResponse__c, LatestChannelResponseDate__c FROM BrandRelationship__c WHERE Id =: br3.Id];
        System.assert(brAfter1.FirstChannelResponse__c != null);
        System.assert(brAfter2.FirstChannelResponse__c != null);
        System.assert(brAfter3.FirstChannelResponse__c != null);
    }
}