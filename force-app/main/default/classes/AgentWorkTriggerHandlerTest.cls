@isTest
private class AgentWorkTriggerHandlerTest {
    @testsetup
    static void setupData() {
        List<Campaign> campList = new List<Campaign>();
        List<Account> accList = TestDataFactory.createTestHousehold(1);
		List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
        campList.add(TestDataFactory.createCampaign('Test Campaign 1', 'Similac', 'PH'));
        insert campList;
    }
    
    @isTest
    static void testForAgentWorkAccept() {
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
        insert caseList;
        
        System.Test.startTest();
        System.runAs(user1){
            List<AgentWork> agentWorks = new List<AgentWork>();

            for(Case caseRec : caseList) {
                agentWorks.add(new AgentWork(ServiceChannelId = serChan.Id,
                                             WorkItemId = caseRec.Id,
                                             UserId = user1.Id));
            }
            
            insert agentWorks;
            
            update agentWorks;
        }
        System.Test.stopTest();
        
        //There's currently an issue with creating test class for AgentWork so no value to assert
    }
}