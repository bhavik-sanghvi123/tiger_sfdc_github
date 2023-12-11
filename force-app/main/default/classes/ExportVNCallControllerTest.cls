@isTest
private class ExportVNCallControllerTest {
	 @testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
	    System.runAs(sysad) {
	        List<Campaign> campList = new List<Campaign>();
	        List<Account> accList = TestDataFactory.createTestHousehold(1);
	        accList.get(0).Market__c = 'VN';
			Update accList;

			List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
			List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
			lProduct.get(0).Market__c = 'VN';
			Update lProduct;

			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, conList.get(0).Id, lProduct.get(0).Id);

			Campaign cam = TestDataFactory.createCampaign('Test Campaign 1', 'Similac', 'VN');
			cam.External_Call_Execution__c = true;
			Insert cam;

	        Case call = TestDataFactory.createCaseCall(accList.get(0).Id, conList.get(0).Id );
	        call.Market__c = 'VN';
	        call.Campaign__c = cam.Id;
	        call.ExtractedFlag__c = false;
			call.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
	        Update call;

	        //Create Address
	        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
	        //Create City
	        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
	        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, conList.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
		}
    }

	@isTest
	static void test_queryOrderItemReport() {
		User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
		System.runAs(sysad) {	    	
			System.Test.startTest();
			System.debug([SELECT Id, Name FROM ContentWorkspace]);
				ExportVNCallController.queryAgentName();
				List<ExportVNCallController.callWrapper> callList = ExportVNCallController.queryRecordData(sysad.Id);
				ExportVNCallController controller = new ExportVNCallController();
				ExportVNCallController.CallReportWrapper filestring = ExportVNCallController.getExcelFileAsBase64String(sysad.Id);
			System.Test.stopTest();
			Case c = [Select Campaign__r.External_Call_Execution__c, ExtractedFlag__c, Market__c, Status, recordtype.name from Case Limit 1];
			system.debug(c);
			system.debug(c.Campaign__r.External_Call_Execution__c);
			system.debug(c.recordtype.name );

			System.assertEquals(1 , callList.size());
			System.assertEquals('VW5pdC5UZXN0', filestring.fileContent);
		}
	}
	

}