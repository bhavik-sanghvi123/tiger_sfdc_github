/*
* @author        Ezzel Montesa
* @date          01.25.2021
* @description   Test class for MC_Contact_SyncEligibilityBatch
* @revision(s) 
*/
@isTest
public with sharing class MC_Contact_SyncEligibilityBatchTest {
    
    @TestSetup
    static void setupData(){
        List<User> userList = new List<User>();
        User sysadANZ = TestDataFactory.createUser('System Administrator', 'tstAdANZ' , 'ANZ');
        userList.add(sysadANZ);
        User sysadID = TestDataFactory.createUser('System Administrator', 'tstAdID' , 'ID');
        userList.add(sysadID);
        User sysadIN = TestDataFactory.createUser('System Administrator', 'tstAdIN' , 'IN');
        userList.add(sysadIN);
        User sysadMY = TestDataFactory.createUser('System Administrator', 'tstAdMY' , 'MY');
        userList.add(sysadMY);
        User sysadPH = TestDataFactory.createUser('System Administrator', 'tstAdPH' , 'PH');
        userList.add(sysadPH);
        User sysadSG = TestDataFactory.createUser('System Administrator', 'tstAdSG' , 'SG');
        userList.add(sysadSG);
        User sysadTH = TestDataFactory.createUser('System Administrator', 'tstAdTH' , 'TH');
        userList.add(sysadTH);
        User sysadVN = TestDataFactory.createUser('System Administrator', 'tstAdVN' , 'VN');
        userList.add(sysadVN);
        insert userList;

        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        for(User sysAD : userList){
            System.runAs(sysAD){
                //create Household
                accList.add(TestDataFactory.createTestHouseholdNoInsert(1, sysAD.Market__c)[0]);
            }
        }
        insert accList;
        for(Account acc : accList){
            Contact con = TestDataFactory.createTestAdultContactNoInsert(1, acc.Id)[0];
            if(acc.Market__c == 'SG'){
                con.Phone = con.Phone.substring(0,con.Phone.length()-2);
            }
            conList.add(con);
        }
        insert conList;
    }
    
    static testmethod void testANZFalse(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_ANZ LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, Latest_Contacted_Date__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_ANZ LIMIT 1];
        primaryCon.Active__c = true;
        primaryCon.Latest_Contacted_Date__c = Date.today().addMonths(-2); //set not eligible date
        update primaryCon;
        System.debug(household.Market__c);
        System.debug(primaryCon.Market__c);
        
        Test.startTest();

        //Create Rewards
        List<Reward__c> newRewardsList = TestDataFactory.createReward(1, primaryCon.Id, Date.today());

        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityBatch ('ANZ', 1,''),200);
        Test.stopTest();

        Contact getContact = [SELECT Id, Market__c, MC_Sync_Eligibility_PH__c FROM Contact WHERE Id = :primaryCon.Id];
        Reward__c getReward = [SELECT Id, MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c, 
                               MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c 
                               FROM Reward__c WHERE Contact__c  = :primaryCon.Id LIMIT 1];
        System.assertEquals(false, getReward.MC_Sync_Eligibility_ANZ__c);
    }
    static testmethod void testIDTrue(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_ID LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, Latest_Contacted_Date__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_ID LIMIT 1];
        primaryCon.Active__c = true;
        primaryCon.MC_Sync_Eligibility_ID__c = false;
        primaryCon.Latest_Contacted_Date__c = Date.today();
        update primaryCon;
        System.debug(household.Market__c);
        System.debug(primaryCon.Market__c);

        Test.startTest();

        //Create Rewards
        List<Reward__c> newRewardsList = TestDataFactory.createReward(1, primaryCon.Id, Date.today());

        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityBatch ('ID', 1,''),200);
        Test.stopTest();

        Contact getContact = [SELECT Id, Market__c, MC_Sync_Eligibility_PH__c FROM Contact WHERE Id = :primaryCon.Id];
        Reward__c getReward = [SELECT Id, MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c, 
                               MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c 
                               FROM Reward__c WHERE Contact__c  = :primaryCon.Id LIMIT 1];
        System.assertEquals(true, getReward.MC_Sync_Eligibility_ID__c);
    }
    static testmethod void testINFalse(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_IN LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, Latest_Contacted_Date__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_IN LIMIT 1];
        primaryCon.Active__c = true;
        primaryCon.Latest_Contacted_Date__c = Date.today().addMonths(-2); //set not eligible date
        update primaryCon;
        System.debug(household.Market__c);
        System.debug(primaryCon.Market__c);

        Test.startTest();

        //Create Rewards
        List<Reward__c> newRewardsList = TestDataFactory.createReward(1, primaryCon.Id, Date.today());

        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityBatch ('IN', 1,''),200);
        Test.stopTest();

        Contact getContact = [SELECT Id, Market__c, MC_Sync_Eligibility_PH__c FROM Contact WHERE Id = :primaryCon.Id];
        Reward__c getReward = [SELECT Id, MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c, 
                               MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c 
                               FROM Reward__c WHERE Contact__c  = :primaryCon.Id LIMIT 1];
        System.assertEquals(false, getReward.MC_Sync_Eligibility_IN__c);
    }
    static testmethod void testMYFalse(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_MY LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, Latest_Contacted_Date__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_MY LIMIT 1];
        primaryCon.Active__c = true;
        primaryCon.Latest_Contacted_Date__c = Date.today().addMonths(-2); //set not eligible date
        update primaryCon;
        System.debug(household.Market__c);
        System.debug(primaryCon.Market__c);

        Test.startTest();

        //Create Rewards
        List<Reward__c> newRewardsList = TestDataFactory.createReward(1, primaryCon.Id, Date.today());

        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityBatch ('MY', 1,''),200);
        Test.stopTest();

        Contact getContact = [SELECT Id, Market__c, MC_Sync_Eligibility_PH__c FROM Contact WHERE Id = :primaryCon.Id];
        Reward__c getReward = [SELECT Id, MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c, 
                               MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c 
                               FROM Reward__c WHERE Contact__c  = :primaryCon.Id LIMIT 1];
        System.assertEquals(false, getReward.MC_Sync_Eligibility_MY__c);
    }
    static testmethod void testPHFalse(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_PH LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, Latest_Contacted_Date__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_PH LIMIT 1];
        primaryCon.Active__c = true;
        primaryCon.Latest_Contacted_Date__c = Date.today().addMonths(-2); //set not eligible date
        update primaryCon;
        System.debug(household.Market__c);
        System.debug(primaryCon.Market__c);

        Test.startTest();

        //Create Rewards
        List<Reward__c> newRewardsList = TestDataFactory.createReward(1, primaryCon.Id, Date.today());

        
        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityBatch ('PH', 1,''),200);
        Test.stopTest();

        Contact getContact = [SELECT Id, Market__c, MC_Sync_Eligibility_PH__c FROM Contact WHERE Id = :primaryCon.Id];
        Reward__c getReward = [SELECT Id, MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c, 
                               MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c 
                               FROM Reward__c WHERE Contact__c  = :primaryCon.Id LIMIT 1];
        System.assertEquals(false, getReward.MC_Sync_Eligibility_PH__c);
    }
    
    static testmethod void testSGTrue(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_SG LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, Latest_Contacted_Date__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_SG LIMIT 1];
        primaryCon.Active__c = true;
        primaryCon.MC_Sync_Eligibility_SG__c = false;
        primaryCon.Latest_Contacted_Date__c = Date.today();
        update primaryCon;
        System.debug(household.Market__c);
        System.debug(primaryCon.Market__c);

        Test.startTest();

        //Create Rewards
        List<Reward__c> newRewardsList = TestDataFactory.createReward(1, primaryCon.Id, Date.today());

        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityBatch ('SG', 1,''),200);
        Test.stopTest();

        Contact getContact = [SELECT Id, Market__c, MC_Sync_Eligibility_PH__c FROM Contact WHERE Id = :primaryCon.Id];
        Reward__c getReward = [SELECT Id, MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c, 
                               MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c 
                               FROM Reward__c WHERE Contact__c  = :primaryCon.Id LIMIT 1];
        System.assertEquals(true, getReward.MC_Sync_Eligibility_SG__c);
    }
    static testmethod void testTHNotActive(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_TH LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, Latest_Contacted_Date__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_TH LIMIT 1];
        primaryCon.Active__c = false;
        primaryCon.Latest_Contacted_Date__c = Date.today();
        update primaryCon;
        System.debug(household.Market__c);
        System.debug(primaryCon.Market__c);

        Test.startTest();

        //Create Rewards
        List<Reward__c> newRewardsList = TestDataFactory.createReward(1, primaryCon.Id, Date.today());

        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityBatch ('TH', 1,''),200);
        Test.stopTest();

        Contact getContact = [SELECT Id, Market__c FROM Contact WHERE Id = :primaryCon.Id];
        Reward__c getReward = [SELECT Id, MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c, 
                               MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c 
                               FROM Reward__c WHERE Contact__c  = :primaryCon.Id LIMIT 1];
        
        System.assertEquals(false, getReward.MC_Sync_Eligibility_TH__c);
    }
    static testmethod void testVNContactOptOut(){
        Account household = [SELECT Id, Market__c FROM Account WHERE Market__c = :CommonConstant.MARKET_VN LIMIT 1];
        Contact primaryCon = [SELECT Id, Market__c, Active__c, HasOptedOutOfEmail, SMSOptOut__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE AND Market__c = :CommonConstant.MARKET_VN LIMIT 1];
        primaryCon.Active__c = true;
        primaryCon.HasOptedOutOfEmail = true;
        primaryCon.SMSOptOut__c = true;
        primaryCon.Latest_Contacted_Date__c = Date.today().addMonths(-2); //set not eligible date
        update primaryCon;
        System.debug(household.Market__c);
        System.debug(primaryCon.Market__c);

        Test.startTest();
        
        //Create Rewards
        List<Reward__c> newRewardsList = TestDataFactory.createReward(1, primaryCon.Id, Date.today());


        Id batchJobId = Database.executeBatch(new MC_Contact_SyncEligibilityBatch ('VN', 1,''),200);
        Test.stopTest();

        Contact getContact = [SELECT Id, Market__c FROM Contact WHERE Id = :primaryCon.Id];
        Reward__c getReward = [SELECT Id, MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c, 
                               MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c 
                               FROM Reward__c WHERE Contact__c  = :primaryCon.Id LIMIT 1];
        
        System.assertEquals(false, getReward.MC_Sync_Eligibility_VN__c);
    }
}