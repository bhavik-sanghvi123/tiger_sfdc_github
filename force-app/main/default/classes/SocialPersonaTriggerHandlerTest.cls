@isTest
private class SocialPersonaTriggerHandlerTest {
	public static Id fbRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback').getRecordTypeId();
    public static Id iqRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inquiry').getRecordTypeId();
    
    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        
        System.runAs(sysad) { 
        List<Case> caseList = new List<Case>();
        Account a1 = new Account(Name = 'SG Social Contacts', Market__c = 'SG');
        insert a1;
        
		Contact c1 = new Contact(FirstName = 'Social', LastName = 'Person', AccountId = a1.Id, Phone = '47129472');
        insert c1;
        
        Case cas1 = new Case(RecordTypeId = fbRTId, AccountId = a1.Id, ContactId = c1.Id, Status = 'New', Origin = 'Facebook', IsSocialCase__c = true);
        insert cas1;
        
        SocialPersona persona = new SocialPersona();
        persona.ParentId = c1.Id;
        persona.Name = 'Author';
        persona.RealName = 'Social Persona';
        persona.Provider = 'Facebook';
        persona.MediaProvider = 'Facebook';
        persona.ExternalId = 'ExternalUserId';
        persona.AuthorLabels = 'SG';
        insert persona;
        
        SocialPost post = new SocialPost();
        post.ParentId = cas1.Id;
        post.PersonaId = persona.Id;
       	post.Name = 'source1';
        post.Content = 'content1';
        post.Posted = System.today();
        post.PostUrl = 'PostUrl1';
        post.Provider = 'Facebook';
        post.MessageType = 'Private';
        post.ExternalPostId = 'ExternalPostId1';
        post.R6PostId = 'R6PostId1';
        post.Classification = 'Product / Service Complaints';
        post.PostPriority = 'High';
        insert post;
        }
    }
    
    @isTest
    static void testForAcceptCase() {
        User sysad = [SELECT Id FROM User WHERE alias = 'tstSysAd'];
        
        System.runAs(sysad) { 
        Set<Id> caseIds = new Set<Id>();
        Account a1 = new Account(Name = 'Person', Market__c = 'SG');
        insert a1;
        
		Contact c1 = new Contact(FirstName = 'Social2', LastName = 'Person2', AccountId = a1.Id, Phone = '47129474');
        insert c1;
        
        SocialPersona persona = [select Id, ParentId from SocialPersona limit 1];
        persona.ParentId = c1.Id;
        Test.startTest();
        update persona;
        Test.stopTest();
        
        for(SocialPost sposRec : [select Id, ParentId from SocialPost where PersonaId = :persona.Id]) {
            caseIds.add(sposRec.ParentId);
        }
        
        List<Case> caseList = [select Id, ContactId, AccountId from Case where Id in :caseIds];
        
        System.assertEquals(a1.Id, caseList[0].AccountId);
        System.assertEquals(c1.Id, caseList[0].ContactId);
        }
    }
}