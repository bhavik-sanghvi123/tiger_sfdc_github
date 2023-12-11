/*
* @author        Rey Austral
* @date          8.19.2019
* @description   Test class for AddressCustomLookupController
* @revision(s) 
*/
@isTest
private class AddressCustomLookupControllerTest {
    @testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
	    System.runAs(sysad) {
	        List<Campaign> campList = new List<Campaign>();
	        List<Account> accList = TestDataFactory.createTestHousehold(1);
	        accList.get(0).Market__c = 'VN';
			Update accList;

			List<Contact> conList = TestDataFactory.createTestAdultContact(15, accList.get(0).Id);	
            Affiliate_Value__c avCity = TestDataFactory.createAffiliateValue('City', 'Test City', 'VN', null);
            Affiliate_Value__c avDistrict =TestDataFactory.createAffiliateValue('District', 'Test District', 'VN', avCity.Id);
		}
    }
    
    @isTest
    static void test_fetchRecords() {
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
        Affiliate_Value__c city = [SELECT Id FROM Affiliate_Value__c WHERE RecordType.Name = 'City' AND Name = 'Test City'][0];
        System.runAs(sysad) {           
            System.Test.startTest();    
                //LastName is the actual name of the contact person
                List<AddressCustomLookupController.RecordsData> contactList = AddressCustomLookupController.fetchRecords('Contact','Name','LastName','','','Adult');   
            	List<AddressCustomLookupController.RecordsData> district = AddressCustomLookupController.fetchRecords('Affiliate_Value__c','Name','Test','ParentAffiliateValue__c',city.Id,'District');
            try{
                List<AddressCustomLookupController.RecordsData> districtErr = AddressCustomLookupController.fetchRecords('Affiliate_Value__c','Names','Test','ParentAffiliateValue__c',city.Id,'District');
            }catch(Exception e){
                System.debug('Error--'+e.getMessage());
            }
        	
            
            System.Test.stopTest();

            System.assertEquals(15 , contactList.size());
            System.assertEquals('Test District' , district[0].label);
        }
    }

    @isTest
    static void test_fetchTopRecords() {
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
        Affiliate_Value__c city = [SELECT Id FROM Affiliate_Value__c WHERE RecordType.Name = 'City' AND Name = 'Test City'][0];
        System.runAs(sysad) {           
            System.Test.startTest();    
                //LastName is the actual name of the contact person
                List<AddressCustomLookupController.RecordsData> contactList = AddressCustomLookupController.fetchTopRecords('Contact','Name','LastName','','','Adult');   
            	List<AddressCustomLookupController.RecordsData> district = AddressCustomLookupController.fetchTopRecords('Affiliate_Value__c','Name','Test','ParentAffiliateValue__c',city.Id,'District');
            try{
                List<AddressCustomLookupController.RecordsData> districtErr = AddressCustomLookupController.fetchTopRecords('Affiliate_Value__c','Names','Test','ParentAffiliateValue__c',city.Id,'District');
            }catch(Exception e){
                System.debug('Error--'+e.getMessage());
            }
            
            System.Test.stopTest();
            //only 10 result will be retrieved even if the total contact records is 15
            System.assertEquals(10 , contactList.size());
            System.assertEquals('Test District' , district[0].label);
        }
    }
}