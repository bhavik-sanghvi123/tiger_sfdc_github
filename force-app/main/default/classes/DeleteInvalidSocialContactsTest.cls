@isTest
private class DeleteInvalidSocialContactsTest {
    public static Id fbRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback').getRecordTypeId();
    public static Id iqRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inquiry').getRecordTypeId();

    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'Social Studio Integration User' , 'SG');
        sysad.Username = 'SocialStudioIntegrationUser@test.com';
        sysad.Alias = 'ssiu';
        sysad.Email = 'SocialStudioIntegrationUser@test.com';
        insert sysad;
        
        System.runAs(sysad) {
            Account a1 = new Account(Name = 'SG Social Contacts', Market__c = 'SG');
            insert a1;
            
    		Contact c1 = new Contact(FirstName = 'Social', LastName = 'Person', AccountId = a1.Id);
            insert c1;
            
            Contact c2 = new Contact(FirstName = 'Social2', LastName = 'Person2', AccountId = a1.Id);
            insert c2;
            
            Case cas1 = new Case(RecordTypeId = fbRTId, AccountId = a1.Id, ContactId = c2.Id, Status = 'New', Origin = 'Facebook', IsSocialCase__c = true);
            insert cas1;
            
            SocialPersona persona = new SocialPersona();
            persona.ParentId = c2.Id;
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
    
    public static testMethod void executeBatch() {
        List<Contact> conList = new List<Contact>();
        User sysad = [Select Id From User where LastName = 'Social Studio Integration User' limit 1];
        
        Test.startTest();
		System.runAs(sysad) {
			DeleteInvalidSocialContactsBatch discb = new DeleteInvalidSocialContactsBatch();
            Database.executeBatch(discb, 200);

            DeleteInvalidSocialContactsScheduler discs = new DeleteInvalidSocialContactsScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Sample Social Batch Job', sch, discs);
    	}
    	Test.stopTest();
    	
    	conList = [select Id from Contact where Name = 'Social Person'];
    	
    	System.assertEquals(true, conList.isEmpty());
    }
}