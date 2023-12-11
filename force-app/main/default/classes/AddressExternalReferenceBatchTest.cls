@isTest
public class AddressExternalReferenceBatchTest {  
    @testsetup
    static void setupData() {
        Account a = TestDataFactory.createTestHousehold(1, 'TW')[0];
        Contact adult = TestDataFactory.createContact(true, a.Id, null, Date.parse('01/01/1990'), '0912345678');
        Contact child = TestDataFactory.createContact(false, a.Id, adult.Id, Date.parse('01/01/2022'), '');
        Affiliate_Value__c cityDefault = TestDataFactory.createAffiliateValue('City', 'TEST_CITY_DEFAULT', 'TW', null);
        Affiliate_Value__c districtDefault = TestDataFactory.createAffiliateValue('District', 'TEST_DISTRICT_DEFAULT', 'TW', cityDefault.Id);
        String streetNameDefault = 'TEST_STREET_DEFAULT';
        AddressTriggerHandler.DoNotRunTest = true;
        TestDataFactory.createAddress(true, adult.Id, 'Taiwan', cityDefault.Id, districtDefault.Id, null, streetNameDefault);
    }
    static testmethod void test_updateAddressExternalRef() {
        Contact con = [SELECT Id FROM Contact WHERE RecordType.Name = 'Adult' AND Phone = '0912345678'][0];
        Address__c addr = [SELECT Country__c, External_Reference_Number__c FROM Address__c WHERE ParentContact__c =: con.Id][0];
        System.assertEquals(addr.External_Reference_Number__c, null);
        System.debug(addr);
        Test.startTest();
        AddressExternalReferenceBatch batch = new AddressExternalReferenceBatch('Taiwan', 0, 60); 
        System.schedule('jobName', '0 5 * * * ?', batch);
        Database.executebatch(batch, 100);
        Test.stopTest();
        
        Address__c addrCheck = [SELECT External_Reference_Number__c FROM Address__c WHERE ParentContact__c =: con.Id][0];
        System.assert(!String.isBlank(addrCheck.External_Reference_Number__c) );
    }
}