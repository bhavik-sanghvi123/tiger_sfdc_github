@isTest
public class ExperianAddressValidationBatchTest {
    @testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'dtaInteg' , 'SG');
        insert sysad;
        sysAd.FirstName = 'Data';
        sysAd.LastName = 'Integration';
        update sysad;
        
        System.runAs(sysad) {	    	
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount[0].Market__c = 'SG';
            update lAccount[0];
            
			List<Contact> lContact = TestDataFactory.createSGTestAdultContact(1, lAccount.get(0).Id);
            List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
            List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);		
           
            List<Address__c> lAddressDefault = TestDataFactory.createTestDefaultAddress(1, lContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
            lAddressDefault[0].PostalCode__c = '208749';
            update lAddressDefault[0];
            
            /**
            List<Address__c> lAddressNonDefault = TestDataFactory.createTestNonDefaultAddress(1, lContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
            lAddressNonDefault[0].PostalCode__c = '2087XX';
            update lAddressNonDefault[0];
			**/
        }
    }
    
    public static testMethod  void testUpdate() {
    	System.Test.startTest();
    		ExperianAddressValidationBatch eav = new ExperianAddressValidationBatch();
    		Database.executeBatch(eav, 50);

    		ExperianAddressValidationSchedule job = new ExperianAddressValidationSchedule();
    		String sch = '0 0 23 * * ?'; 
    		system.schedule('Validate Address to Experian Integration', sch, job);
    		
    	System.Test.stopTest();
   	}   
}