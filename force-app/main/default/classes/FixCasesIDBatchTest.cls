@isTest
public class FixCasesIDBatchTest {
    @testSetup
    static void setup(){
        User u = TestDataFactory.createUser('System Administrator', 'mcid', 'ID', 'MC', 'Connect-CRM ID');
        insert u;
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
        PricebookEntry pbe2 = TestDataFactory.createProductAndPricebookEntryDiffBrand('ID', 'IDR', pbe.Pricebook2Id, 'Ensure');
        PricebookEntry pbe3 = TestDataFactory.createProductAndPricebookEntryDiffBrand('ID', 'IDR', pbe.Pricebook2Id, 'Pediasure');
        Product2 prod1 = [SELECT Id, ParentBrand__c FROM Product2 WHERE Id =: pbe1.Product2Id];
        Product2 prod2 = [SELECT Id, ParentBrand__c FROM Product2 WHERE Id =: pbe2.Product2Id];
        Product2 prod3 = [SELECT Id, ParentBrand__c FROM Product2 WHERE Id =: pbe3.Product2Id];

        Channel__c channel = TestDataFactory.createTestChannel(1, 'ID', 'TEST_CHANNEL')[0];
        Campaign campPed = TestDataFactory.createCampaignInsert('ID1.0_Pediasure_Call1_Verificationcall', 'Pediasure', 'ID', prod1.ParentBrand__c);
        Campaign campEns = TestDataFactory.createCampaignInsert('ID2.0_Ensure_Call1_Verificationcall', 'Ensure', 'ID', prod2.ParentBrand__c);
        Campaign campRet = TestDataFactory.createCampaignInsert('ID1.2_Pediasure_Offline_Call2_Strike', 'Pediasure', 'ID', prod3.ParentBrand__c);
        
        BrandRelationship__c br1 = TestDataFactory.createTestBrandRelationShipwithUser(1, adult.Id, child.Id, prod1.Id)[0];
        BrandRelationship__c br2 = TestDataFactory.createTestBrandRelationShipwithUser(1, adult.Id, child.Id, prod2.Id)[0];
        BrandRelationship__c br3 = TestDataFactory.createTestBrandRelationShipwithUser(1, adult.Id, child.Id, prod3.Id)[0];
        ChannelResponse__c cr1 = TestDataFactory.createTestChannelResponseMultiple(1, br1, channel, addressDefault, prod1, true, 'Pending')[0];
        ChannelResponse__c cr2 = TestDataFactory.createTestChannelResponseMultiple(1, br2, channel, addressDefault, prod2, true, 'Pending')[0];
        ChannelResponse__c cr3 = TestDataFactory.createTestChannelResponseMultiple(1, br3, channel, addressDefault, prod3, true, 'Pending')[0];
    }
    static testmethod void missingCase(){
        Test.startTest();
        ChannelResponse__c crEns = [SELECT Id, Name FROM ChannelResponse__c WHERE BrandRelationship__r.KeyBrand__c = 'Ensure' LIMIT 1][0];
        ChannelResponse__c crPed = [SELECT Id, Name FROM ChannelResponse__c WHERE BrandRelationship__r.KeyBrand__c = 'Pediasure' LIMIT 1][0];
        List<String> crNames = new List<String>{crEns.Name, crPed.Name};
            
        FixCasesIDBatch batch = new FixCasesIDBatch(crNames, 'Missing', ''); 
        Database.executebatch(batch, 200);
        Test.stopTest();
    }
    static testmethod void retentionCase(){
        Test.startTest();
        List<String> crNames = new List<String>();
        for(ChannelResponse__c cr : [SELECT Id, Name FROM ChannelResponse__c WHERE BrandRelationship__r.KeyBrand__c = 'Pediasure']){
            crNames.add(cr.Name);
        }
        
        FixCasesIDBatch batch = new FixCasesIDBatch(crNames, 'Retention', 'ID1.2_Pediasure_Offline_Call2_Strike'); 
        Database.executebatch(batch, 200);
        Test.stopTest();
    }
    static testmethod void noCR(){
        List<String> crNames = new List<String>();
            
        Test.startTest();
        FixCasesIDBatch batch = new FixCasesIDBatch(crNames, 'Missing', ''); 
        Database.executebatch(batch, 200);
        Test.stopTest();
    }
}