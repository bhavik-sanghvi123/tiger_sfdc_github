/*
* @author        Rey Austral
* @date          1.24.2019
* @description   Test class for BrandRelationship_PathController
* @revision(s) 
*/
@isTest
private class BrandRelationship_PathControllerTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;

        System.runAs(sysad) {	  
	    	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProduct.get(0).Id);
		}
    }

	@isTest static void test_getPath() {
		// Implement test code
		BrandRelationship__c brand = [Select Id from BrandRelationship__c Limit 1];
		System.Test.startTest();		
			List<BrandRelationship_PathController.StatusPathWrapper> lWrapper = BrandRelationship_PathController.getPath(brand.Id);
		System.Test.stopTest();
		//the wrapper should contain some value, if not the code has an error or there is no value currently in the status field
		System.assertNotEquals(lWrapper.size(), 0);

	}
	
	@isTest static void test_getPath_LastValueSelected() {
		// Implement test code
		//currently the qualified value is the 3rd value in the status field
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			BrandRelationship__c brand = [Select Id, Status__c from BrandRelationship__c Limit 1];
			brand.Status__c = 'Qualified';
			Update brand;

			System.Test.startTest();		
				List<BrandRelationship_PathController.StatusPathWrapper> lWrapper = BrandRelationship_PathController.getPath(brand.Id);
			System.Test.stopTest();

			//since the selected value is the third value, the first value should be already completed
			System.assertEquals(lWrapper.get(0).isCompleted, true);
		}		
	}
	
}