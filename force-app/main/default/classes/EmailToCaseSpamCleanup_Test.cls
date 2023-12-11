@isTest
public class EmailToCaseSpamCleanup_Test {

    @testsetup
    static void setup() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'IN');
        insert sysad;
    	User datamigration = TestDataFactory.createUser('System Administrator', 'datami' , 'IN');
		datamigration.username = 'datamigration@tigerani.abbott.comtest';
        insert datamigration;
        
        System.runAs(sysad) {
			
	        Campaign camp = TestDataFactory.createCampaign('Test Campaign 1', 'Ensure', 'IN');
			insert camp;

			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount[0].Market__c = 'IN';
            update lAccount;

			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
	        
		    Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback').getRecordTypeId();

			Case c = new Case();
            c.RecordtypeId = RTId;
            c.ContactId = lContact[0].Id;
            c.CallType__c = 'Outbound';
            c.Status = 'New';
            c.AccountId = lAccount[0].Id;
            c.CallRegarding__c = lContact[0].Id;
			c.Campaign__c = camp.Id;
            c.ReminderStatus__c = 'Closed - Reassigned';
            c.AbbottAwarenessDate__c = Date.Today().addDays(-2);
            insert c;
		}
    }

    static testmethod void deleteSpam() {
        List<Case> caseList = new List<Case>([SELECT Id FROM Case]);
        Test.startTest();
			EmailToCaseSpamCleanup_Batch b = new EmailToCaseSpamCleanup_Batch('IN');
            Database.executeBatch(b, 200);

            String sch = '0 0 23 * * ?'; 
            system.schedule('Spam sched', sch, new EmailToCaseSpamCleanup_Sched('IN'));
    	Test.stopTest();

        caseList = new List<Case>([SELECT Id FROM Case]);
        System.assert(caseList.isEmpty());
    }
}