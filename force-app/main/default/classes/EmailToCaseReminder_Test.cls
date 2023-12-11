@isTest
public class EmailToCaseReminder_Test {
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
            c.ReminderStatus__c = 'Initial Response';
            c.AbbottAwarenessDate__c = Date.Today().addDays(-2);
            c.SuppliedEmail = 'test@email.com';
            insert c;
			c.LastReminderSentDate__c = Date.Today().addDays(-2);
            update c;
		}
    }

    static testmethod void testOther() {
        Test.startTest();
            EmailToCaseReminder_Batch b = new EmailToCaseReminder_Batch('PH');
            System.assert(!b.conditionMatch('Text', 'Not Equal', '1', '1'));
            System.assert(b.conditionMatch('Text', 'Not Equal', '1', '2'));
            System.assert(!b.conditionMatch('Number', 'Equal', '1', '2'));
            System.assert(b.conditionMatch('Number', 'Not Equal', '1', '2'));
            System.assert(!b.conditionMatch('Number', 'Greater Than', '1', '2'));
            System.assert(!b.conditionMatch('Number', 'Greater Than or Equal', '1', '2'));
            System.assert(b.conditionMatch('Number', 'Less Than', '1', '2'));
            System.assert(b.conditionMatch('Number', 'Less Than or Equal', '1', '2'));

            System.assertEquals(' = ', b.queryConditonTranslator('Equal'));
            System.assertEquals(' != ', b.queryConditonTranslator('Not Equal'));
            System.assertEquals(' > ', b.queryConditonTranslator('Greater Than'));
            System.assertEquals(' >= ', b.queryConditonTranslator('Greater Than or Equal'));
            System.assertEquals(' < ', b.queryConditonTranslator('Less Than'));
            System.assertEquals(' <= ', b.queryConditonTranslator('Less Than or Equal'));
        Test.stopTest();
    }

    static testmethod void sendEmail() {
        List<Case> caseList = new List<Case>([SELECT RecordType.Name, ReminderStatus__c, LastReminderSentDateCount__c FROM Case]);

        Test.startTest();
			EmailToCaseReminder_Batch b = new EmailToCaseReminder_Batch('IN');
            Database.executeBatch(b, 200);

            String sch = '0 0 23 * * ?'; 
            system.schedule('Spam sched', sch, new EmailToCaseReminder_Sched('IN') );
    	Test.stopTest();

        caseList = new List<Case>([SELECT ReminderStatus__c FROM Case]);
        System.assertEquals('First Reminder', caseList[0].ReminderStatus__c);
    }

    static testmethod void uncontactable() {
        Case c = [SELECT RecordType.Name, ReminderStatus__c, LastReminderSentDateCount__c FROM Case];

        Test.startTest();
            c.ReminderStatus__c = 'Pending - Uncontactable';
            update c;
    	Test.stopTest();
    }
}