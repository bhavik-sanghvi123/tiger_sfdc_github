@isTest
public class CaseNutritionHistoryBatchTest {
	@testSetup
    static void setup(){
        Account acctTW = TestDataFactory.createTestHousehold(1, 'TW')[0];
        List<Contact> contactList = new List<Contact>();
        Contact adultContact = TestDataFactory.createTestAdultContact(1, acctTW.Id)[0];
        Contact childContact = TestDataFactory.createTestChildContact(1, acctTW.Id)[0];
    }
    
    static testmethod void testMDBatch1(){
        Contact adult = [SELECT Id FROM Contact WHERE Type__c = 'Adult'][0];
        Contact child = [SELECT Id FROM Contact WHERE Type__c = 'Child'][0];
        Case c = new Case();
        c.ContactId = adult.Id;
        c.CallRegarding__c = child.Id;
        c.Market__c = 'TW';
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        insert c;
        Test.startTest();
        CaseNutritionHistoryBatch batch = new CaseNutritionHistoryBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        
        Medical_Diagnosis__c md = [SELECT Id, Contact__c FROM Medical_Diagnosis__c WHERE Related_Case__c =: c.Id];
        System.assertEquals(md.Contact__c, c.CallRegarding__c);
    }
    
    static testmethod void testMDBatch2(){
        Contact adult = [SELECT Id FROM Contact WHERE Type__c = 'Adult'][0];
        Case c = new Case();
        c.ContactId = adult.Id;
        c.Market__c = 'TW';
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        insert c;
        Test.startTest();
        CaseNutritionHistoryBatch batch = new CaseNutritionHistoryBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        
        Medical_Diagnosis__c md = [SELECT Id, Contact__c FROM Medical_Diagnosis__c WHERE Related_Case__c =: c.Id];
        System.assertEquals(md.Contact__c, c.ContactId);
    }
    
    static testmethod void testMDBatchSched(){
        Contact child = [SELECT Id FROM Contact WHERE Type__c = 'Child'][0];
        Contact adult = [SELECT Id FROM Contact WHERE Type__c = 'Adult'][0];
        Case c = new Case();
        c.CallRegarding__c = child.Id;
        c.ContactId = adult.Id;
        c.Market__c = 'TW';
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        insert c;
        Test.startTest();
        CaseNutritionHistoryBatch batch = new CaseNutritionHistoryBatch();
        String sch = '0 0 * * * ?';
        System.schedule('Case_NH_Batch | Daily | Hourly', sch, batch);
        Test.stopTest();
    }
}