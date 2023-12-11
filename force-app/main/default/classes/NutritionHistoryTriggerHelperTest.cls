/*------------------------------------------------------------
Author:      Crissar Ibarra
Description: Test class for NutritionHistoryTriggerHelper

History
10/25/2021   cribarra     Created
-------------------------------------------------------------------------------------------*/

@isTest
private with sharing class NutritionHistoryTriggerHelperTest {
    
    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'MY');
        insert sysad;
        
        System.runAs(sysad) {        
            List<Account> lAccount = TestDataFactory.createTestHouseholdMY(1);
            List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount[0].Id);
            List<Contact> lContactChild = TestDataFactory.createTestChildContact(1, lAccount[0].Id); 
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            List<BrandRelationship__c> lBR = TestDataFactory.createTestBrandRelationShipwithUser(1, lContact[0].id, lContactChild[0].id, lProduct[0].id);          
        	Case c = TestDataFactory.createCaseCall(lAccount[0].Id, lContact[0].Id); 
        }
    }
    
    @isTest 
    static void createNutritionHistory() {

        ID childID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        ID adultID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        User usr = [Select id from User Limit 1];
        
        List<Contact> childList = [Select Id from Contact WHERE RecordTypeID =: childID];
        List<Contact> adultList = [Select Id from Contact WHERE RecordTypeID =: adultID];
        
        Medical_Diagnosis__c md = new Medical_Diagnosis__c();
        md.Contact__c = adultList[0].id;
        md.EndUser__c = childList[0].id;
        md.Height__c = 123;
        md.Height_Status__c = 'good';
        md.Height_Percentile__c = '15th to 50th Percentile';
        
        Test.startTest();
            insert md;
        Test.stopTest();
        
        for(BrandRelationship__c br :  [SELECT ID, Height__c, Height_Status__c, Height_Percentile__c FROM BrandRelationship__c WHERE User__c IN: childList]){
            System.AssertEquals(br.Height__c, md.Height__c);
            System.AssertEquals(br.Height_Status__c, String.valueof(md.Height_Status__c));
            System.AssertEquals(br.Height_Percentile__c , String.valueof(md.Height_Percentile__c ));
        }
        
    }
    
    @isTest
    static void updateCaseNHTest(){
        ID childID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        ID adultID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        User usr = [Select id from User Limit 1];
        
        List<Contact> childList = [Select Id from Contact WHERE RecordTypeID =: childID];
        List<Contact> adultList = [Select Id from Contact WHERE RecordTypeID =: adultID];
        Case c = [SELECT Id FROM Case WHERE ContactId =: adultList[0].Id LIMIT 1];
        Medical_Diagnosis__c md = new Medical_Diagnosis__c();
        md.Contact__c = adultList[0].id;
        md.EndUser__c = childList[0].id;
        md.Height__c = 123;
        md.Height_Status__c = 'good';
        md.Height_Percentile__c = '15th to 50th Percentile';
        md.Related_Case__c = c.Id;
        md.CreatedforIntegration__c = true;
        
        Test.startTest();
            insert md;
        Test.stopTest();
        
        Case cUpdated = [SELECT Id, MedicalDiagnosis__c FROM Case WHERE Id =: c.Id];
        System.assertEquals(md.Id, cUpdated.MedicalDiagnosis__c);
    }
}