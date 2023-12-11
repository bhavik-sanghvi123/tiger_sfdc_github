@isTest
private with sharing class AccountTriggerHandlerTest {
    @testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {	    	
	    	//2 account with 1 contact for each account
			List<Account> lAccount = TestDataFactory.createTestHousehold(2);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
            List<Contact> lContact1 = TestDataFactory.createTestAdultContact(1, lAccount.get(1).Id);			
		}
    }

    /*
* @author        Rey Austral
* @date          
* @description   Test class for AccountTriggerHandler
* @revision(s) 
*/
    @isTest 
    static void test_mergeAccount() {
        List<Account> accountlist = [Select Id, MasterRecordId from Account];
        List<Contact> contactList = [Select Id, PrimaryContact__c from Contact];
        Id masterId = accountlist.get(1).Id;
        for (Contact con : contactList){
            con.PrimaryContact__c = true;
        }
        Update contactList;
        System.Test.startTest();
            Database.merge(accountlist.get(1), accountlist.get(0));
        System.Test.stopTest();
        accountlist = [Select Id, MasterRecordId from Account];
        //expected to be deleted
        System.assertEquals(1, accountlist.size());
        //the field primary contact will updated to false under the deleted account 
        contactList = [Select Id, PrimaryContact__c from Contact where PrimaryContact__c = true];
        System.assertEquals(1, contactList.size());
        //master account will have now two contact under it
        contactList = [Select Id, PrimaryContact__c from Contact where AccountId =: masterId];
        System.assertEquals(2, contactList.size());
    }

    @isTest 
    static void test_deleteAccount() {
        User usr = [Select id from User where Profile.Name != 'System Administrator' Limit 1];
        List<Account> accountlist = [Select Id, MasterRecordId from Account];
        Boolean hasError = false;
        System.runAs(usr) {
            System.Test.startTest();
                try {
                    delete accountlist;    
                } catch(Exception ex) {
                    hasError = ex.getMessage().contains('You have no access to delete this record');
                }
                
            System.Test.stopTest();
            System.assertEquals(true, hasError);
        }
    }
}