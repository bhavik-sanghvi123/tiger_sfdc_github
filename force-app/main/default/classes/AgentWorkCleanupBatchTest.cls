@isTest
private class AgentWorkCleanupBatchTest {
    @testsetup
    static void setupData() {
        List<Campaign> campList = new List<Campaign>();
        List<Account> accList = TestDataFactory.createTestHousehold(1);
        List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
        campList.add(TestDataFactory.createCampaign('Test Campaign 1', 'Similac', 'PH'));
        insert campList;
    }
    
    @isTest
    static void runCleanupBatch() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        ServiceChannel serChan = [SELECT Id FROM ServiceChannel WHERE Masterlabel = 'Case'];
        List<Case> caseList = new List<Case>();
        
        User user1 = new User();
        user1.id = UserInfo.getUserId();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id from Contact limit 1];
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        
        Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
        ca1.ContactId = conList[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'New';
        ca1.AccountId = a1.Id;
        ca1.CallRegarding__c = conList[0].Id;
        ca1.Campaign__c = camp1.Id;
        caseList.add(ca1);
        
        Case ca2 = new Case();
        ca2.RecordtypeId = callRTId;
        ca2.ContactId = conList[0].Id;
        ca2.CallType__c = 'Outbound';
        ca2.Status = 'New';
        ca2.AccountId = a1.Id;
        ca2.CallRegarding__c = conList[0].Id;
        ca2.Campaign__c = camp1.Id;
        caseList.add(ca2);
        
        insert caseList;
        
        List<AgentWork> agentWorks = new List<AgentWork>();
        
        for(Case caseRec : caseList) {
            agentWorks.add(new AgentWork(ServiceChannelId = serChan.Id,
                                         WorkItemId = caseRec.Id,
                                         UserId = user1.Id));
        }
        
        insert agentWorks;
        
        Datetime previousDate = Datetime.now().addDays(-15);
        Test.setCreatedDate(agentWorks.get(0).Id, previousDate);
        
        System.runAs(user1){
            System.Test.startTest();
            
            AgentWorkCleanupBatch ucs = new AgentWorkCleanupBatch();
            Database.executeBatch(ucs, 200);
            
            System.Test.stopTest();            
        }        
    }

    	@isTest static void test_scheduler() {
		// Implement test code
		AgentWorkCleanupBatchScheduler job = new AgentWorkCleanupBatchScheduler();
		String sch = '0 0 23 * * ?'; 
		Id scID = System.schedule('Test New Reg Batch Job', sch, job);

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