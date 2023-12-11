/*
* @author        Rey Austral
* @date          1.28.2019
* @description   Test class for MilkCodeNonRestrictionBatch and MilkCodeNonRestrictionBatchScheduler
* @revision(s) 
*/
@isTest
private class MilkCodeNonRestrictionBatchTest {
	
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {	    	
	    	List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			List<Contact> lChildContact = TestDataFactory.createTestChildContact(1, lAccount.get(0).Id);
		}
    }

	@isTest static void test_creationRecordBatch() {
		Contact con = [Select Id,MilkCodeRestriction__c from Contact Where Type__c =: CommonConstant.CONTACT_CHILD_TYPE Limit 1];
		//must change once the final value for PH in the meta data has been given
		con.Birthdate = Date.today().addYears(-4);
		con.MilkCodeRestriction__c = true;
		Update con;

		System.Test.startTest();
    		MilkCodeNonRestrictionBatch ucs = new MilkCodeNonRestrictionBatch();
    		Database.executeBatch(ucs, 200);
    	System.Test.stopTest();

    	//the child is beyond the valid range based on the custom meta data, the check box should now be false
    	List<Contact> childContactList = [Select Id from Contact where MilkCodeRestriction__c = false AND Type__c =: CommonConstant.CONTACT_CHILD_TYPE];
    	System.assertEquals(1, childContactList.size());    	
	}
	
	@isTest static void test_scheduler() {
		// Implement test code
		MilkCodeNonRestrictionBatchScheduler job = new MilkCodeNonRestrictionBatchScheduler();
		String sch = '0 0 23 * * ?'; 
		Id scID = System.schedule('Test Non Milk Restriction Batch Job', sch, job);

		CronTrigger ct = [SELECT Id,
                          CronExpression,
                          TimesTriggered,
                          NextFireTime                          
                          FROM CronTrigger
                          WHERE Id = : scID];

        //asserting the schedule job values        
        System.assertEquals(0, ct.TimesTriggered);        
        System.assertEquals('0 0 23 * * ?', ct.CronExpression);        
        
	}
	
}