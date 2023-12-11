/***********************************************************************
* @author        Monika Parihar    
* @date          8/10/2021
* @description   Test class for Batch MC_Contact_SyncEligibilityTWBatch
* @revision(s)
**************************************************************************/
@isTest
public with sharing class MC_Contact_SyncEligibilityTWBatchTest {
    
    @TestSetup
    static void setupData(){
        User sysadTW = TestDataFactory.createUser('System Administrator', 'tstAdTW' , 'TW');
        insert sysadTW;

        
       System.runAs(sysadTW){
                //create Household
                List<Account> accList = TestDataFactory.createTestHousehold(1);
                accList[0].Market__c = 'TW';
                update accList;
                //create Primary adultContact
                List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
       }
        
    }
    static testmethod void MC_Contact_SyncEligibilityTWBatchTest(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_TW LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, Latest_Contacted_Date__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_TW LIMIT 1];
        primaryCon.Active__c = true;
        primaryCon.LineOptOut__c = false;
        primaryCon.Active__c = true;
        primaryCon.Blacklisted__c = false;
        primaryCon.MasterOptOut__c = false;
        primaryCon.PrimaryContact__c =true;
        //primaryCon.Latest_Contacted_Date__c = Date.today().addMonths(-2); //set not eligible date
        update primaryCon;

        Test.startTest();
        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityTWBatch(),200);
        Test.stopTest();
    }
}