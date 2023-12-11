@isTest 
public class AddressTriggerHelperTest{

    @testsetup
    static void setupData() {
    
        //Create Household record
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);
        //Create Non-Primary Child Contact Record
        List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        //Create Region
        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
        //Create City
        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
        
    }

    private static testMethod void getHouseholdTest() {
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id regionId = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_REGION_RECORDTYPE LIMIT 1].Id;
        Id cityId  = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_CITY_RECORDTYPE LIMIT 1].Id;

        System.Test.startTest();
            //Create Address
            List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, contactId, regionId, cityId);
        System.Test.stopTest();

        Contact con = [SELECT Region__c, AccountId FROM Contact WHERE Id =: contactId];
        Address__c address = [SELECT ParentHousehold__c FROM Address__c LIMIT 1];       

        System.assertEquals(con.Region__c, lAddress[0].Region__c, 'Contact Region should be populated with the Region of the Default Address.');
        System.assertEquals(con.AccountId, address.ParentHousehold__c, 'Address Parent Household should be populated with the Contact\'s Household.');
    }

    private static testMethod void checkDefaultAddressTest() {
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id regionId = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_REGION_RECORDTYPE LIMIT 1].Id;
        Id cityId  = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_CITY_RECORDTYPE LIMIT 1].Id;

        //Create Address
        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, contactId, regionId, cityId);
        
        System.Test.startTest();
            try {
                List<Address__c> lAddressNew = TestDataFactory.createTestDefaultAddress(1, contactId, regionId, cityId);
            } catch(DMLException e) {
                System.assert(e.getMessage().contains('Unable to save record'), 'message=' + e.getMessage());
            }
        System.Test.stopTest();
    }

    private static testMethod void updateDefaultAddressTest() {
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id regionId = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_REGION_RECORDTYPE LIMIT 1].Id;
        Id cityId  = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_CITY_RECORDTYPE LIMIT 1].Id;

        //Create Address
        List<Address__c> lDefaultAddress = TestDataFactory.createTestDefaultAddress(1, contactId, regionId, cityId);
        
        System.Test.startTest();
        	try {
            	List<Address__c> lAddress = TestDataFactory.createTestNonDefaultAddress(1, contactId, regionId, cityId);
            
                lAddress[0].DefaultAddress__c = TRUE;
                update lAddress[0];
            } catch(DMLException e) {
                System.assert(e.getMessage().contains('Unable to save record'), 'message=' + e.getMessage());
            }

            lDefaultAddress[0].DefaultAddress__c = FALSE;
            update lDefaultAddress[0];

            Contact con = [SELECT Region__c, AccountId FROM Contact WHERE Id =: contactId];
            System.assertEquals(con.Region__c, null, 'Contact\'s Region should be updated to null.');

            lDefaultAddress[0].DefaultAddress__c = TRUE;
            update lDefaultAddress[0];

            Contact conAfterUpdate = [SELECT Region__c, AccountId FROM Contact WHERE Id =: contactId];
            System.assertEquals(conAfterUpdate.Region__c, lDefaultAddress[0].Region__c, 'Contact Region should be populated with the Region of the Default Address.');

        System.Test.stopTest();


    }

    private static testMethod void deleteRegionTest() {
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id regionId = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_REGION_RECORDTYPE LIMIT 1].Id;
        Id cityId  = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_CITY_RECORDTYPE LIMIT 1].Id;

        //Create Address
        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, contactId, regionId, cityId);
        
        System.Test.startTest();
            delete lAddress;
        System.Test.stopTest();

        Contact con = [SELECT Region__c, AccountId FROM Contact WHERE Id =: contactId];
        System.assertEquals(null, con.Region__c, 'Contact\'s Region should be updated to null.');
    }

    private static testMethod void checkExternalIdTest() {
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id regionId = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_REGION_RECORDTYPE LIMIT 1].Id;
        Id cityId  = [SELECT Id, RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name =: CommonConstant.AFFILIATE_CITY_RECORDTYPE LIMIT 1].Id;
        List<Address__c> lAddressNew = new List<Address__c>();

        Test.startTest();
            try {
                lAddressNew = TestDataFactory.createTestDefaultAddress(1, contactId, regionId, cityId);
            } catch(DMLException e) {
                System.assert(e.getMessage().contains('Unable to save record'), 'message=' + e.getMessage());
            }
        Test.stopTest();
        List<Address__c> lAddressCheck = [SELECT Id, External_Reference_Number__c FROM Address__c WHERE ParentContact__c =: lAddressNew[0].ParentContact__c];
        if(!lAddressCheck.isEmpty()){
            System.debug(lAddressCheck[0]);
            System.debug(lAddressCheck[0].External_Reference_Number__c);
            System.assert(!String.isBlank(lAddressCheck[0].External_Reference_Number__c) );
        }
        
    }
}