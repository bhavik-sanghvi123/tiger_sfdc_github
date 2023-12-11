@isTest
public class IndividualEmailTriggerTest {
    @testSetup
    static void setUp(){
        Account a = TestDataFactory.createTestHousehold(1, 'PH')[0];
        Contact con = TestDataFactory.createContact(true, a.Id, null, Date.valueOf('1990-01-01'), '0999999999');
        et4ae5__Business_Unit__c businessUnit = TestDataFactory.createBusinessUnit(true, '1234567');
        et4ae5__Automated_Send__c autoSend = TestDataFactory.createAutomatedSend(true, businessUnit.Id, 'TEST EMAIL NAME', 'abc@gmail.com', 'TEST FROM NAME', 'TEST SUBJECT');
        List<et4ae5__IndividualEmailResult__c> ierList = TestDataFactory.createIERMultiple(con.Id, false, false, autoSend.Id, 2);
    }
    
	static testmethod void testcopyBounceStatusToContact_Insert(){
        Contact con = [SELECT Id, EmailBounced__c FROM Contact WHERE Phone = '0999999999'][0];
        System.assertEquals(false, con.EmailBounced__c);
        et4ae5__Automated_Send__c autoSend = [SELECT Id FROM et4ae5__Automated_Send__c LIMIT 1][0];
        Test.startTest();
        et4ae5__IndividualEmailResult__c ier = TestDataFactory.createIER(con.Id, true, false, autoSend.Id);
        Test.stopTest();
        Contact conCheck = [SELECT Id, EmailBounced__c FROM Contact WHERE Id =: con.Id][0];
        System.assertEquals(true, conCheck.EmailBounced__c);
    }
    static testmethod void testcopyBounceStatusToContact_Update(){
        Contact con = [SELECT Id, EmailBounced__c FROM Contact WHERE Phone = '0999999999'][0];
        System.assertEquals(false, con.EmailBounced__c);
        List<et4ae5__IndividualEmailResult__c> ierList = [SELECT Id FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__Contact__c =: con.Id];
        Test.startTest();
        ierList[0].et4ae5__SoftBounce__c = true;
        ierList[1].et4ae5__HardBounce__c = true;
        update ierList;
        Test.stopTest();
        Contact conCheck = [SELECT Id, EmailBounced__c FROM Contact WHERE Id =: con.Id][0];
        System.assertEquals(true, conCheck.EmailBounced__c);
    }
}