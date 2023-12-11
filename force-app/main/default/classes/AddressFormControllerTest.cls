@isTest
public class AddressFormControllerTest {
    @testsetup
    static void setupData() {
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('City').getRecordTypeId();  
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {
            List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
            List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
        	List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
			List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, lContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
            
            //Create Singapore City
            Affiliate_Value__c city = new Affiliate_Value__c();          
            city.Name = 'Singapore';
            city.Market__c = 'SG';
            city.AffiliateValue__c = 'Singapore';
            city.Active__c = TRUE;
            city.RecordTypeId = idRecType;
            insert city;
        }
    }
    
    private static testMethod void fetchUserDetailsTest() {
        User testUser = [Select Id, Market__c, UserRoleId From User where LastName = 'tstSysAd'];
        User userDetail = new User();
        
        System.runAs(testUser) {
            System.Test.startTest();
            userDetail = AddressFormController.fetchUserDetails();
            System.Test.stopTest();
        }
        
        System.assertEquals(userDetail.Market__c, testUser.Market__c, 'Market should be derived from User\'s Market Value.');
        
    }
    
    private static testMethod void getRecordAccessAndDetailsTest() {
        User testUser = [Select Id, Market__c, UserRoleId From User where LastName = 'tstSysAd'];
        Id addressId = [Select Id FROM Address__c LIMIT 1].Id;
        Boolean hasAccess = false;
        Address__c addressRecord = new Address__c();
        
        System.runAs(testUser) {
            System.Test.startTest();
            hasAccess = AddressFormController.getRecordAccess(addressId);
            addressRecord = AddressFormController.getAddressRecordDetails(addressId);
            System.Test.stopTest();
        }
        
        System.assertEquals(true, hasAccess, 'User should have access to the Address record.');
        System.assertEquals(addressId, addressRecord.Id, 'Record details should be retrienved.');
        
    }
    
    private static testMethod void getExperianTokenTest() {
        System.Test.startTest();
        String token = AddressFormController.getExperianToken();
        System.Test.stopTest();
        
        System.assertNotEquals(null, token, 'Experian token should be returned');
    }
    
    private static testMethod void getAffiliateSingaporeCityTest() {
        User testUser = [Select Id, Market__c, UserRoleId From User where LastName = 'tstSysAd'];
        String sgId;
        
        System.runAs(testUser) {
            System.Test.startTest();
            sgId = AddressFormController.getAffiliateSingaporeCity();
            System.Test.stopTest();
        }
        
        System.assertNotEquals(null, sgId, 'Singapore Affiliate City Id should be returned');
    }
}