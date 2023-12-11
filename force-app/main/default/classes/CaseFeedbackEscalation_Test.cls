@isTest
public class CaseFeedbackEscalation_Test {

    @testsetup
    static void setup() {

        Id caseRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Feedback').getRecordTypeId();
        Id channelRId = Schema.SObjectType.Channel__c.getRecordTypeInfosByName().get('Trade').getRecordTypeId();

        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'IN');
        insert sysad;

        System.runAs(sysad) {

            // create Account
			Account lAccount = TestDataFactory.createTestHousehold(1)[0];
            lAccount.Market__c = 'IN';

            // create product
            PricebookEntry entry = TestDataFactory.createPricebookEntry('IN');
            Insert entry;

            Product2 lProductbr = TestDataFactory.createTestBrandProduct(1)[0];
            lProductbr.Market__c = 'IN';	
            lProductbr.ProductHierarchyLevel__c = 'Brand';	

            // create state
            Affiliate_Value__c region = TestDataFactory.createTestState(1)[0];
            region.Market__c = 'IN';

            // create email escalation
            TestDataFactory.createTestEscalation(3, 'IN', region.Id, lProductbr.Id);

            // create channel StoreWherePurchased__c
            Channel__c channel = TestDataFactory.createTestChannel(1)[0];
            channel.Market__c = 'IN';
            channel.RecordTypeId = channelRId;
            channel.Type__c = 'Traditional';    

            List<Sobject> objList = new List<Sobject>();
            objList.add(lAccount);
            objList.add(region);
            objList.add(channel);
            objList.add(lProductbr);
            update objList;

            // Create Case
            Case c = new Case();
            c.RecordtypeId = caseRId;
            c.Status = 'New';
            c.AccountId = lAccount.Id;
            c.StoreWherePurchased__c = channel.Id;
            c.Product__c = lProductbr.Id;
            c.State__c = region.Id;
            c.AbbottAwarenessDate__c = Date.Today().addDays(-1);
            insert c;
        }
    }

    static testMethod void testEscalation1() {
        User usr = [SELECT Id FROM User WHERE Username = 'tstSysAd@test.com'];

        Case c = [SELECT id FROM Case];

        System.runAs(usr) {
            Test.startTest();

                c.Status = 'Escalated';
                update c;
            Test.stopTest();

        }

        c = [SELECT LevelofEscalation__c FROM Case];
        System.assertEquals('Level 1', c.LevelofEscalation__c);
    }

    static testMethod void testEscalation2() {
        User usr = [SELECT Id FROM User WHERE Username = 'tstSysAd@test.com'];

        Case c = [SELECT id FROM Case];

        System.runAs(usr) {
            Test.startTest();
                CaseFeedbackEscalation_Batch b = new CaseFeedbackEscalation_Batch('IN');
                Database.executeBatch(b);

                String sch = '0 0 23 * * ?'; 
                system.schedule('test feedback', sch, new CaseFeedbackEscalation_Sched('IN') );
            Test.stopTest();
        }

        c = [SELECT DaysOpen__c , LevelofEscalation__c FROM Case];
        System.debug(c.DaysOpen__c);
        System.assertEquals('Level 2', c.LevelofEscalation__c);
    }

    
}