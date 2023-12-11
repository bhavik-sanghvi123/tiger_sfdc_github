@isTest
private class AcceptSocialCaseControllerTest {
	public static Id fbRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback').getRecordTypeId();
    public static Id iqRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inquiry').getRecordTypeId();
    
    @testsetup
    static void setupData() {
        List<Account> accList = TestDataFactory.createTestHousehold(1);
		List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
    }
    
    @isTest
    static void testForAcceptCase() {
        List<Account> accList = [select Id from Account limit 1];
		List<Contact> conList = [select Id from Contact where AccountId = :accList.get(0).Id limit 1];
        
        Case c1 = new Case(RecordTypeId = fbRTId, AccountId = accList[0].Id, ContactId = conList[0].Id, Status = 'New', Origin = 'Facebook', IsSocialCase__c = true);
        insert c1;
        Case c2 = new Case(RecordTypeId = iqRTId, AccountId = accList[0].Id, ContactId = conList[0].Id, Status = 'New', Origin = 'Facebook', IsSocialCase__c = true, CaseAccepted__c = true);
        insert c2;
        
        AcceptSocialCaseController.acceptSocialCase(c1.Id);
        AcceptSocialCaseController.isSocial(c1.Id);
        String retVal = AcceptSocialCaseController.acceptSocialCase(c2.Id);
        AcceptSocialCaseController.acceptSocialCase(null);
        AcceptSocialCaseController.isSocial(null);
        
        Case c3 = [select Id, CaseAccepted__c, Status from Case where Id = :c1.Id];
        
        System.assertEquals(true, c3.CaseAccepted__c);
        System.assertEquals('First Level Investigation', c3.Status);
        System.assertEquals('Case is already accepted', retVal);
    }
}