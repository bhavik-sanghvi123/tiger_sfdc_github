@isTest
public class MC_Milestones_Test {

    @testSetup
    static void setup(){
        
        // create household
        Account acctPH = TestDataFactory.createTestHousehold(1, 'PH')[0];
        Account acctTW = TestDataFactory.createTestHousehold(1, 'TW')[0];

        // create mother and child contacts
        List<Contact> contactList = new List<Contact>();
        Contact adultContactPH = TestDataFactory.createTestAdultContact(1, acctPH.Id)[0];
        List<Contact> childContactPH = TestDataFactory.createTestChildContact(2, acctPH.Id);
        
        Contact adultContactTW = TestDataFactory.createTestAdultContact(1, acctTW.Id)[0];
        List<Contact> childContactTW = TestDataFactory.createTestChildContact(2, acctTW.Id);        

        adultContactPH.EstimatedDueDate__c = Date.Today().addMonths(9).addDays(-5);
        childContactPH[0].BirthDate = Date.Today().addMonths(-1);
        childContactPH[1].BirthDate = Date.Today().addMonths(1);

        adultContactTW.EstimatedDueDate__c = Date.Today().addMonths(9).addDays(-5);
        childContactTW[0].BirthDate = Date.Today().addMonths(-1);
        childContacttw[1].BirthDate = Date.Today().addMonths(1);
        
        contactList.add(adultContactPH);
        contactList.add(childContactPH[0]);
        contactList.add(childContactPH[1]);
        
        contactList.add(adultContactTW);
        contactList.add(childContactTW[0]);
        contactList.add(childContactTW[1]);

        UtilityClass.updateList(contactList);

        // create product
        Product2 prod = TestDataFactory.createTestBrandProduct(1)[0];

        // create BR for mother
        BrandRelationship__c brandRelationshipPH = TestDataFactory.createTestBrandRelationShip(1, adultContactPH.Id, prod.Id)[0];  
        BrandRelationship__c brandRelationshipTW = TestDataFactory.createTestBrandRelationShip(1, adultContactTW.Id, prod.Id)[0];  
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(brandRelationshipPH.Id, yesterday);
        Test.setCreatedDate(brandRelationshipTW.Id, yesterday);
        // create BR for child
        TestDataFactory.createTestBrandRelationShipwithUser2(2, adultContactPH.Id, childContactPH, prod.Id);
        TestDataFactory.createTestBrandRelationShipwithUser2(2, adultContactTW.Id, childContactTW, prod.Id);
     
        List<BrandRelationship__c> brList = new List<BrandRelationship__c>();
        brandRelationshipPH.Household__c = acctPH.Id;
        brandRelationshipTW.Household__c = acctTW.Id;
        update brList;
        
        System.debug([SELECT Id,Active__c,Account.Market__c,RecordType.Name,PrimaryContact__c, AgeinMonths__c,WeeksOfPregnancy__c FROM Contact WHERE Id =: adultContactPH.Id]);
        System.debug([SELECT Id,Active__c,Account.Market__c,RecordType.Name,PrimaryContact__c, AgeinMonths__c,WeeksOfPregnancy__c FROM Contact WHERE Id =: adultContactTW.Id]);
        System.debug([SELECT Id,Active__c,Account.Market__c,RecordType.Name,PrimaryContact__c, AgeinMonths__c,WeeksOfPregnancy__c FROM Contact WHERE Id =: childContactPH]);
        System.debug([SELECT Id,Active__c,Account.Market__c,RecordType.Name,PrimaryContact__c, AgeinMonths__c,WeeksOfPregnancy__c FROM Contact WHERE Id =: childContactTW]);
    }
    
    static testMethod void milestoneTest1(){
        TestDataFactory.createMilestone('TW', 'Weeks of Pregnancy', '1');
        TestDataFactory.createMilestone('TW', 'Age In Months', '1');
        Test.startTest();
        System.enqueueJob(new MC_Milestones_Queueable(true, null));
        Test.stopTest();
    }
    
    static testMethod void milestoneTest2(){
        TestDataFactory.createMilestone('TW', 'Age In Months', '1');
        TestDataFactory.createMilestone('TW', 'Age In Months', '-1');
        Test.startTest();
        System.enqueueJob(new MC_Milestones_Queueable(true, null));
        Test.stopTest();
    }
    
    static testMethod void milestoneTest3(){
        TestDataFactory.createMilestone('PH', 'Weeks of Pregnancy', '1');
        TestDataFactory.createMilestone('PH', 'Age In Months', '1');
        Test.startTest();
        System.enqueueJob(new MC_Milestones_Queueable(true, null));
        Test.stopTest();
    }
    
    static testMethod void milestoneTest4(){
        TestDataFactory.createMilestone('PH', 'Age In Months', '1');
        TestDataFactory.createMilestone('PH', 'Age In Months', '-1');
        Test.startTest();
        System.enqueueJob(new MC_Milestones_Queueable(true, null));
        Test.stopTest();
    }
    
    static testMethod void milestoneTest5(){
        TestDataFactory.createMilestone('PH', 'Weeks of Pregnancy', '1');
        TestDataFactory.createMilestone('TW', 'Age In Months', '1');
        Test.startTest();
        System.enqueueJob(new MC_Milestones_Queueable(true, null));
        Test.stopTest();
    }
    
    static testMethod void milestoneTest6(){
        TestDataFactory.createMilestone('PH', 'Age In Months', '-1');
        TestDataFactory.createMilestone('TW', 'Weeks of Pregnancy', '1');
        Test.startTest();
        System.enqueueJob(new MC_Milestones_Queueable(true, null));
        Test.stopTest();
    }
    
    static testMethod void milestoneTest7(){
        TestDataFactory.createMilestone('PH', 'Age In Months', '-1');
        TestDataFactory.createMilestone('TW', 'Weeks of Pregnancy', '1');
        TestDataFactory.createMilestone('TW', 'Age In Months', '1');
        Test.startTest();
        System.enqueueJob(new MC_Milestones_Queueable(true, null));
        Test.stopTest();
    }

    static testMethod void runPHMilestonesSchedulable(){
        Test.startTest();
            String cronStr = '0 0 0 3 9 ? 2050';
            String jobId2 = System.schedule('MCTRiggerTest', cronStr, new MC_Milestones_Sched());
        Test.stopTest();
    }

    static testMethod void runBatch() {
        TestDataFactory.createMilestone('PH', 'Age In Months', '1');
        TestDataFactory.createMilestone('PH', 'Age In Months', '-1');
        Map<Id, Milestone__c> milestoneMap = new Map<Id, Milestone__c>([SELECT Id FROM Milestone__c]);
        Set<Id> mIds = milestoneMap.keySet();
        
        Test.startTest();
            Database.executebatch(new MC_Milestones(mIds));
        Test.stopTest();
    }
}