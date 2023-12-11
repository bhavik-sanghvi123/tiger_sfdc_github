/*------------------------------------------------------------
Author      : Mario Christ
Description : Test class for Dice Membership Creation

History
22-Nov-2022   Mario Christ   Created class
-------------------------------------------------------------------------------------------*/
@isTest
public class DiceMembershipCreation_Test {
    @testsetup
    static void setup() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;

        Dice_Custom_Setting__c setting = new Dice_Custom_Setting__c();
        setting.Key__c = 'DiceEcardAPIDate';
        setting.Value__c = '2022-11-15';
        insert setting;

        
        System.runAs(sysad) {
            //create Household
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount[0].Market__c = 'PH';
            update lAccount;

            //create Contact
            List<Contact> lContact = TestDataFactory.createTestAdultContact(5, lAccount[0].Id);

            for(Contact contactRec : lContact){
                contactRec.ChildrenUnderMilkCodeRestriction__c = 0;
                contactRec.SMSOptOut__c = false;
                contactRec.DoNotCall = false;
                contactRec.Active__c = true;
            }

            update lContact;
            

            //create Product
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);

            //create BR
            BrandRelationship__c lBr1 = TestDataFactory.createTestBrandRelationShip(1, lContact[0].Id,lProduct[0].Id)[0];
            lBr1.FirstTransactionDate__c = null;
            update lBr1;

            //create Channel
            Channel__c lChannel = TestDataFactory.createTestChannel(1, 'PH', 'Test Facebook')[0];

            //create CR
            ChannelResponse__c crRec1 = TestDataFactory.createTestChannelResponse(lBr1, lChannel);

            System.debug(crRec1);
            
		}
    }

    public static testMethod void executeBatchFailed() {
        User sysad = [SELECT Id FROM User WHERE Alias = 'tstSysAd' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DiceHTTPCalloutMockFailed());
		System.runAs(sysad) {
			DiceMembershipCreation_Batch diceBatch = new DiceMembershipCreation_Batch();
            Database.executeBatch(diceBatch, 200);
    	}
    	Test.stopTest();
    	
        ChannelResponse__c crRec1Test =[SELECT Id, DiceEcardStatus__c FROM ChannelResponse__c LIMIT 1];
        System.debug(crRec1Test);
    	
    	System.assertEquals('Failed', crRec1Test.DiceEcardStatus__c);
    }

    public static testMethod void executeBatchFailed2() {
        User sysad = [SELECT Id FROM User WHERE Alias = 'tstSysAd' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DiceHTTPCalloutMockFailed2());
		System.runAs(sysad) {
			DiceMembershipCreation_Batch diceBatch = new DiceMembershipCreation_Batch();
            Database.executeBatch(diceBatch, 200);
    	}
    	Test.stopTest();
    	
        ChannelResponse__c crRec1Test =[SELECT Id, DiceEcardStatus__c FROM ChannelResponse__c LIMIT 1];
        System.debug(crRec1Test);
    	
    	System.assertEquals('Failed-BrandError', crRec1Test.DiceEcardStatus__c);
    }

    public static testMethod void executeBatchFailed3() {
        User sysad = [SELECT Id FROM User WHERE Alias = 'tstSysAd' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DiceHTTPCalloutMockFailed3());
		System.runAs(sysad) {
			DiceMembershipCreation_Batch diceBatch = new DiceMembershipCreation_Batch();
            Database.executeBatch(diceBatch, 200);
    	}
    	Test.stopTest();
    	
        ChannelResponse__c crRec1Test =[SELECT Id, DiceEcardStatus__c FROM ChannelResponse__c LIMIT 1];
        System.debug(crRec1Test);
    	
    	System.assertEquals('Failed-LimitExceeded', crRec1Test.DiceEcardStatus__c);
    }

    public static testMethod void executeBatchFailed4() {
        User sysad = [SELECT Id FROM User WHERE Alias = 'tstSysAd' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DiceHTTPCalloutMockFailed4());
		System.runAs(sysad) {
			DiceMembershipCreation_Batch diceBatch = new DiceMembershipCreation_Batch();
            Database.executeBatch(diceBatch, 200);
    	}
    	Test.stopTest();
    	
        ChannelResponse__c crRec1Test =[SELECT Id, DiceEcardStatus__c FROM ChannelResponse__c LIMIT 1];
        System.debug(crRec1Test);
    	
    	System.assertEquals('Failed-ECardsNotAvailable', crRec1Test.DiceEcardStatus__c);
    }

    public static testMethod void executeBatchSuccess() {
        User sysad = [SELECT Id FROM User WHERE Alias = 'tstSysAd' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DiceHTTPCalloutMockSuccess());
		System.runAs(sysad) {
			DiceMembershipCreation_Batch diceBatch = new DiceMembershipCreation_Batch();
            Database.executeBatch(diceBatch, 200);
    	}
    	Test.stopTest();
    	
        ChannelResponse__c crRec1Test =[SELECT Id, DiceEcardStatus__c FROM ChannelResponse__c LIMIT 1];
        System.debug(crRec1Test);
    	
    	System.assertEquals('Created', crRec1Test.DiceEcardStatus__c);
    }
}