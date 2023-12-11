/*
* @author        Rey Austral
* @date          10.21.2019
* @description   Test class for TaskTriggerHelper
* @revision(s) 
*/
@isTest
private class TaskTriggerHelperTest {
    @testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
	    System.runAs(sysad) {
	        List<Campaign> campList = new List<Campaign>();
	        List<Account> accList = TestDataFactory.createTestHousehold(1);
	        accList.get(0).Market__c = 'VN';
			Update accList;

			List<Contact> conList = TestDataFactory.createTestAdultContact(2, accList.get(0).Id);		
            conList.get(1).LastName = 'VN CTI Rep Contact';
            update conList.get(1);
		}
    }
    
    @isTest
    static void test_queryCallRecord() {
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
        System.runAs(sysad) {           
            System.Test.startTest();
                Task t = new Task();               
                t.OwnerId = sysad.Id;
                t.CallType = 'Inbound';
                Insert t;
               
            System.Test.stopTest();
        	Task updatedTask = [Select id, whoid from task];
            System.assertNotEquals(null, updatedTask.whoid);
        }
    }
}