/*
* @author        Rey Austral
* @date          1.28.2019
* @description   Test class for ExportOrderSGBatch and ExportOrderSGBatchScheduler
* @revision(s) 
*/
@isTest
private class CallRelatedListControllerTest {
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

			Campaign cam = TestDataFactory.createCampaign('Test Campaign 1', 'Similac', 'VN');
			cam.External_Call_Execution__c = true;
			Insert cam;

	        Case call = TestDataFactory.createCaseCall(accList.get(0).Id, conList.get(0).Id );
	        call.Market__c = 'VN';	       
	        call.ExtractedFlag__c = false;
            call.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
	        Update call;
	     
		}
    }
    
    @isTest
    static void test_queryCallRecord() {
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
        System.runAs(sysad) {           
            System.Test.startTest();
                Id contactId = [Select Id from Contact limit 1].Id;
                
                List<Case> orderList = CallRelatedListController.getCall(1,1,contactId);
                orderList = CallRelatedListController.queryCall(contactId);
                Integer totalCount = CallRelatedListController.getTotalCount(contactId);
                String recordTypeId = CallRelatedListController.getCallRecordType();
               
            System.Test.stopTest();
        

            System.assertEquals(1 , orderList.size());
            System.assert(String.isNotEmpty(recordTypeId));
        }
    }
}