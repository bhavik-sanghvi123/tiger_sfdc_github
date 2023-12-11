// @isTest for deletion
public class CaseTriggerBatchTest {} /*
	
	@testsetup
    static void setupData() {
    	List<User> usrList =  [Select Id From User where LastName = 'Migration'];
    	User sysad = new User();
    	if (usrList.isEmpty()) {
	    	sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
	    	sysad.FirstName = 'Data';
	    	sysad.LastName = 'Migration';
	        insert sysad;
    	} else {
    		sysad = usrList.get(0);
    	}

        System.runAs(sysad) {	
	        List<Campaign> campList = new List<Campaign>();
	        List<Account> accList = TestDataFactory.createTestHousehold(1);
			List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
	        campList.add(TestDataFactory.createCampaign('Test Campaign 1', 'Similac', 'PH'));
	        insert campList;
    	}
    }
    
    @isTest
    static void testForCompleteDate() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Id srRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('Successful_Reason').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        List<Case> updatedCaseList = new List<Case>();
        List<Case> caseListToUpdate = new List<Case>();
        List<Case> caseListToAssert = new List<Case>();
        List<Contact> conList2 = new List<Contact>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id, FirstCallDate__c, LastCallDate__c from Contact limit 1];
        conList[0].FirstCallDate__c = System.today() + 5;
        conList[0].LastCallDate__c = System.today() - 5;
        update conList;
        
		Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        
        User sysad = [Select Id From User where LastName = 'Migration'];
		System.runAs(sysad) {  
	        Affiliate_Value__c af1 = new Affiliate_Value__c();
	        af1.Name = 'Success Test';
	        af1.AffiliateValue__c = 'Success Test';
	        af1.Market__c = 'PH';
	        af1.Active__c = true;
	        insert af1;
	        
	        Case ca1 = new Case();
	        ca1.RecordtypeId = callRTId;
	        ca1.ContactId = conList[0].Id;
	        ca1.CallType__c = 'Outbound';
	        ca1.Status = 'Completed';
	        ca1.AccountId = a1.Id;
	        ca1.CallRegarding__c = conList[0].Id;
	        ca1.Campaign__c = camp1.Id;
	        ca1.CallOutcome__c = 'Successful';
	        ca1.SuccessfulReason__c = af1.Id;
	        
	        insert ca1;
	        ca1.CallCompletedDate__c = Date.today().adddays(-15);
	        update ca1;
	        Test.setCreatedDate(ca1.Id, DateTime.newInstance(2019,06,08));

	        Case ca2 = new Case();
	        ca2.RecordtypeId = callRTId;
	        ca2.ContactId = conList[0].Id;
	        ca2.CallType__c = 'Outbound';
	        ca2.Status = 'Completed';
	        ca2.AccountId = a1.Id;
	        ca2.CallRegarding__c = conList[0].Id;
	        ca2.Campaign__c = camp1.Id;
	        ca2.CallOutcome__c = 'Successful';
	        ca2.SuccessfulReason__c = af1.Id;
	        
	        insert ca2;
	        ca2.CallCompletedDate__c = Date.today().adddays(20);
	        update ca2;
	        Test.setCreatedDate(ca2.Id, DateTime.newInstance(2019,06,09));

	        System.Test.startTest();
	        	CaseTriggerBatch umd = new CaseTriggerBatch();
	        	Database.executeBatch(umd, 200);
	        System.Test.stopTest();
	        
	        
	        caseListToAssert = [select Id, CallCompletedDate__c, CallOutcome__c, SuccessfulReason__c from Case where Id =: ca1.Id or Id=:ca2.Id];
	        
	        System.assertEquals(true, caseListToAssert[0].CallCompletedDate__c != null);
    	}
    }
	
} */