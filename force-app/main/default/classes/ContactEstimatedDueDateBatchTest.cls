@isTest
private class ContactEstimatedDueDateBatchTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {	    	
	    	List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
			List<Account> lAccount = TestDataFactory.createTestHousehold(1, 'SG');
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
            PricebookEntry pbe = TestDataFactory.createPricebookEntry('SG', 'SGD');
            Product2 prod = TestDataFactory.createProductDiffBrand('SG', 'SGD', pbe.Pricebook2Id, 'Similac Mom', 'SIMILAC MOM CHILD', 'SG_BR_ABSM_CHILD');
		}
    }

	@isTest static void test_creationRecordBatch() {
		Contact con = [Select Id,EstimatedDueDate__c from Contact Limit 1];
		con.EstimatedDueDate__c = Date.today();
		con.PrimaryContact__c = true;
		Update con;

		System.Test.startTest();
    		ContactEstimatedDueDateBatch ucs = new ContactEstimatedDueDateBatch();
    		Database.executeBatch(ucs, 200);
    	System.Test.stopTest();

    	List<Contact> childContactList = [Select Id from Contact where Type__c =: CommonConstant.CONTACT_CHILD_TYPE];
    	System.assertEquals(1, childContactList.size());    	
	}
	
	@isTest static void test_withExistingChild() {
		Contact con = [Select Id,EstimatedDueDate__c,AccountId from Contact Limit 1];
		con.EstimatedDueDate__c = Date.today();
		con.PrimaryContact__c = true;
		Update con;

		Contact child = new Contact();
		child.LastName = 'CHild 1';
		child.Parent__c = con.Id;
		child.Birthdate = Date.today().addDays(-1);
		child.Type__c = CommonConstant.CONTACT_CHILD_TYPE;
		child.AccountId = con.AccountId;
		insert child;

		System.Test.startTest();
    		ContactEstimatedDueDateBatch ucs = new ContactEstimatedDueDateBatch();
    		Database.executeBatch(ucs, 200);
    	System.Test.stopTest();

    	List<Contact> childContactList = [Select Id from Contact where Type__c =: CommonConstant.CONTACT_CHILD_TYPE];
    	System.assertEquals(2, childContactList.size());    	
	}

	@isTest static void test_withSameBirthdate() {
		Contact con = [Select Id,EstimatedDueDate__c,AccountId from Contact Limit 1];
		con.EstimatedDueDate__c = Date.today();
		con.PrimaryContact__c = true;
		Update con;

		Contact child = new Contact();
		child.LastName = 'CHild 1';
		child.Parent__c = con.Id;
		child.Birthdate = Date.today();
		child.Type__c = CommonConstant.CONTACT_CHILD_TYPE;
		child.AccountId = con.AccountId;
		insert child;

		System.Test.startTest();
    		ContactEstimatedDueDateBatch ucs = new ContactEstimatedDueDateBatch();
    		Database.executeBatch(ucs, 200);
    	System.Test.stopTest();

    	List<Contact> childContactList = [Select Id from Contact where Type__c =: CommonConstant.CONTACT_CHILD_TYPE];
    	//cannot be more than 1 , no new child should be created
    	System.assertEquals(1, childContactList.size());    	
	}

	@isTest static void test_scheduler() {
		// Implement test code
		ContactEstimatedDueDateSchedule job = new ContactEstimatedDueDateSchedule();
		String sch = '0 0 23 * * ?'; 
		Id scID = System.schedule('Test Cost Estimate Batch Job', sch, job);

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