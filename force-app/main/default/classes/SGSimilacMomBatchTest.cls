@isTest
public class SGSimilacMomBatchTest {
    @testSetup
    static void setup(){
        Account a = TestDataFactory.createTestHousehold(1, 'SG')[0];
        Contact adult = TestDataFactory.createContact(true, a.Id, null, Date.parse('01/01/1990'), '09123456');
        Contact child = TestDataFactory.createContact(false, a.Id, adult.Id, Date.today().addMonths(-8), '09110011');
        Contact child1 = TestDataFactory.createContact(false, a.Id, adult.Id, Date.today().addMonths(-8), '09000000');
        Affiliate_Value__c cityDefault = TestDataFactory.createAffiliateValue('City', 'TEST_CITY_DEFAULT', 'SG', null);
        Affiliate_Value__c districtDefault = TestDataFactory.createAffiliateValue('District', 'TEST_DISTRICT_DEFAULT', 'SG', cityDefault.Id);
        String streetNameDefault = 'TEST_STREET_DEFAULT';
        Address__c addressDefault = TestDataFactory.createAddress(true, adult.Id, 'Singapore', cityDefault.Id, districtDefault.Id, null, streetNameDefault);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry('SG', 'SGD');
        Product2 prod1 = TestDataFactory.createProductDiffBrand('SG', 'SGD', pbe.Pricebook2Id, 'Similac', 'SIMILAC MOM');
        Product2 prod2 = TestDataFactory.createProductDiffBrand('SG', 'SGD', pbe.Pricebook2Id, 'Similac', 'SIMILAC MOM');
        Channel__c channel = TestDataFactory.createTestChannel(1, 'SG', 'TEST_CHANNEL')[0];
        Campaign campSim = TestDataFactory.createCampaignInsert('SG-SimilacMum-Con&Ren-Call', 'Similac', 'SG', prod1.ParentBrand__c);
    }
    static testmethod void test_schedule(){
        Test.startTest();
        System.schedule('SGSimilacMomBatch', '0 0 3 1,20 * ?', new SGSimilacMomBatch());
        Test.stopTest();
    }
    static testmethod void testSuccess(){
        Account a = [SELECT Id FROM Account WHERE Market__c = 'SG'][0];
        Contact child = [SELECT Id, Parent__c FROM Contact WHERE AccountId =: a.Id AND RecordType.Name = 'Child' AND Phone = '09000000'][0];
        Contact child1 = [SELECT Id, Parent__c FROM Contact WHERE AccountId =: a.Id AND RecordType.Name = 'Child' AND Phone = '09110011'][0];
        Campaign campaign = [SELECT Id, Product__c, Product__r.Name FROM Campaign WHERE Name = 'SG-SimilacMum-Con&Ren-Call'][0];
        Channel__c channel = [SELECT Id FROM Channel__c WHERE Name = 'TEST_CHANNEL'][0];
        List<Product2> prodList = [SELECT Id, Name, ParentBrand__c FROM Product2 WHERE Name = 'SIMILAC MOM' AND Keybrand__c = 'Similac' AND ParentBrand__c != null LIMIT 2];
        Address__c addr = [SELECT Id FROM Address__c WHERE Country__c = 'Singapore'][0];
        Test.startTest();
        BrandRelationship__c br1 = TestDataFactory.createTestBrandRelationShipwithUser(1, child.Parent__c, child.Id, prodList[0].Id)[0];
        ChannelResponse__c cr1 = TestDataFactory.createTestChannelResponseMultiple(1, br1, channel, addr, prodList[0], true, 'Pending')[0];
        BrandRelationship__c br2 = TestDataFactory.createTestBrandRelationShipwithUser(1, child.Parent__c, child.Id, prodList[1].Id)[0];
        ChannelResponse__c cr2 = TestDataFactory.createTestChannelResponseMultiple(1, br2, channel, addr, prodList[1], true, 'Pending')[0];
        BrandRelationship__c br3 = TestDataFactory.createTestBrandRelationShipwithUser(1, child1.Parent__c, child1.Id, prodList[0].Id)[0];
        ChannelResponse__c cr3 = TestDataFactory.createTestChannelResponseMultiple(1, br3, channel, addr, prodList[0], true, 'Pending')[0];
        Case c = TestDataFactory.createCall('New', a.Id, child.Parent__c, child.Id, 'SG Similac Mom Maternal Con and Ret Call', campaign.Id, 'Outbound', channel.Id, 'SG');
        SGSimilacMomBatch batch = new SGSimilacMomBatch(); 
        Database.executebatch(batch, 20);
        Test.stopTest();
        List<Case> caseCheck = [SELECT Id FROM Case WHERE ContactId =: child1.Parent__c AND CallRegarding__c =: child1.Id AND Subject = 'SG Similac Mom Maternal Con and Ret Call'];
        System.assertEquals(caseCheck.size(), 1);
    }
    
    static testmethod void testError(){
        Account a = [SELECT Id FROM Account WHERE Market__c = 'SG'][0];
        Contact child = [SELECT Id, Parent__c FROM Contact WHERE AccountId =: a.Id AND RecordType.Name = 'Child' AND Phone = '09000000'][0];
        Contact child1 = [SELECT Id, Parent__c FROM Contact WHERE AccountId =: a.Id AND RecordType.Name = 'Child' AND Phone = '09110011'][0];
        Campaign campaign = [SELECT Id, Product__c, Product__r.Name FROM Campaign WHERE Name = 'SG-SimilacMum-Con&Ren-Call'][0];
        Channel__c channel = [SELECT Id FROM Channel__c WHERE Name = 'TEST_CHANNEL'][0];
        List<Product2> prodList = [SELECT Id, Name, ParentBrand__c FROM Product2 WHERE Name = 'SIMILAC MOM' AND Keybrand__c = 'Similac' AND ParentBrand__c != null LIMIT 2];
        Address__c addr = [SELECT Id FROM Address__c WHERE Country__c = 'Singapore'][0];
        Test.startTest();
        BrandRelationship__c br1 = TestDataFactory.createTestBrandRelationShipwithUser(1, child.Parent__c, child.Id, prodList[0].Id)[0];
        ChannelResponse__c cr1 = TestDataFactory.createTestChannelResponseMultiple(1, br1, channel, addr, prodList[0], true, 'Pending')[0];
        BrandRelationship__c br2 = TestDataFactory.createTestBrandRelationShipwithUser(1, child.Parent__c, child.Id, prodList[1].Id)[0];
        ChannelResponse__c cr2 = TestDataFactory.createTestChannelResponseMultiple(1, br2, channel, addr, prodList[1], true, 'Pending')[0];
        BrandRelationship__c br3 = TestDataFactory.createTestBrandRelationShipwithUser(1, child1.Parent__c, child1.Id, prodList[0].Id)[0];
        ChannelResponse__c cr3 = TestDataFactory.createTestChannelResponseMultiple(1, br3, channel, addr, prodList[0], true, 'Pending')[0];
        Case c = TestDataFactory.createCall('New', a.Id, child.Parent__c, child.Id, 'SG Similac Mom Maternal Con and Ret Call', campaign.Id, 'Outbound', channel.Id, 'SG');
        Test.stopTest();
        child.DoNotCall = true;
        child1.DoNotCall = true;
        Contact parent = new Contact(Id = child.Parent__c, DoNotCall = true);
        List<Contact> conUpdate = new List<Contact>{child, child1, parent};
        update conUpdate;
        SGSimilacMomBatch batch = new SGSimilacMomBatch(); 
        Database.executebatch(batch, 20);
        List<Case> caseCheck = [SELECT Id FROM Case WHERE ContactId =: child1.Parent__c AND CallRegarding__c =: child1.Id AND Subject = 'SG Similac Mom Maternal Con and Ret Call'];
        System.assert(caseCheck.isEmpty());
    }
}