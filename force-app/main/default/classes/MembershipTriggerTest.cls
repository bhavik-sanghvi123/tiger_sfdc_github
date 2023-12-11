@isTest
public class MembershipTriggerTest {
    @testSetup
    static void setUp(){
        Account a = TestDataFactory.createTestHousehold(1, 'PH')[0];
        Contact con = TestDataFactory.createContact(true, a.Id, null, Date.valueOf('1990-01-01'), '0999999999');
        PricebookEntry pbeEnsure = TestDataFactory.createPricebookEntry('PH', 'USD');
        PricebookEntry pbeGlucerna = TestDataFactory.createProductAndPricebookEntryDiffBrand('PH', 'USD', pbeEnsure.Pricebook2Id, 'Glucerna');
        PricebookEntry pbePediasure = TestDataFactory.createProductAndPricebookEntryDiffBrand('PH', 'USD', pbeEnsure.Pricebook2Id, 'Pediasure');
        PricebookEntry pbeSimilac = TestDataFactory.createProductAndPricebookEntryDiffBrand('PH', 'USD', pbeEnsure.Pricebook2Id, 'Similac');
        List<Membership__c> membershipInsertList = new List<Membership__c>();
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 1111 1111 11111 1', pbeEnsure.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 2111 1111 11111 1', pbeGlucerna.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 4111 1111 11111 1', pbePediasure.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 5111 1111 11111 1', pbeSimilac.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 1111 1111 11111 2', pbeEnsure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 2111 1111 11111 2', pbeGlucerna.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 4111 1111 11111 2', pbePediasure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 5111 1111 11111 2', pbeSimilac.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 1111 1111 11111 3', pbeEnsure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 2111 1111 11111 3', pbeGlucerna.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 4111 1111 11111 3', pbePediasure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 5111 1111 11111 3', pbeSimilac.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 1111 1111 11111 4', null, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 2111 1111 11111 4', null, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 4111 1111 11111 4', null, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 5111 1111 11111 4', null, 'New'));
        insert membershipInsertList;
        for(Membership__c mem : [SELECT Id FROM Membership__c WHERE MembershipId__c like '%111 2']){
            Test.setCreatedDate(mem.id, Date.Today().addDays(-1));
        }
    }
    static testmethod void testcopyMembershipToContact_Insert(){
        Contact con = [SELECT Id FROM Contact WHERE Phone = '0999999999'][0];
        List<Membership__c> membershipInsertList = new List<Membership__c>();
        for(PricebookEntry pbe : [SELECT Id, Product2Id, Product2.Keybrand__c FROM PricebookEntry]){
            Membership__c mem = new Membership__c();
            if(pbe.Product2.Keybrand__c == 'Ensure') mem = TestDataFactory.createMembershipRecord(con.Id, Date.Today(), Date.Today().addDays(1), '9222 1111 1111 11111 5', pbe.Product2Id, 'Activated');
            else if(pbe.Product2.Keybrand__c == 'Glucerna') mem = TestDataFactory.createMembershipRecord(con.Id, Date.Today(), Date.Today().addDays(1), '9222 2111 1111 11111 5', pbe.Product2Id, 'Activated');
            else if(pbe.Product2.Keybrand__c == 'Pediasure') mem = TestDataFactory.createMembershipRecord(con.Id, Date.Today(), Date.Today().addDays(1), '9222 4111 1111 11111 5', pbe.Product2Id, 'Activated');
            else if(pbe.Product2.Keybrand__c == 'Similac') mem = TestDataFactory.createMembershipRecord(con.Id, Date.Today(), Date.Today().addDays(1), '9222 5111 1111 11111 5', pbe.Product2Id, 'Activated');
            membershipInsertList.add(mem);
        }
        Test.startTest();
        insert membershipInsertList;
        Test.stopTest();
        Contact conCheck = [SELECT Id, MembershipId_Ensure__c, MembershipId_Glucerna__c, MembershipId_Pediasure__c, MembershipId_Similac__c, 
                            MembershipNumberOfDaysDormant_Ensure__c, MembershipNumberOfDaysDormant_Glucerna__c, MembershipNumberOfDaysDormant_Pediasure__c, MembershipNumberOfDaysDormant_Similac__c,
                            MembershipNumberOfTransactions_Ensure__c, MembershipNumberOfTransactions_Glucerna__c, MembershipNumberOfTransactions_Pediasure__c, MembershipNumberOfTransactions_Similac__c,
                            MembershipRecentProduct_Ensure__c, MembershipRecentProduct_Glucerna__c, MembershipRecentProduct_Pediasure__c, MembershipRecentProduct_Similac__c,
                            MembershipStartDate_Ensure__c, MembershipStartDate_Glucerna__c, MembershipStartDate_Pediasure__c, MembershipStartDate_Similac__c, 
                            MembershipStatus_Ensure__c, MembershipStatus_Glucerna__c, MembershipStatus_Pediasure__c, MembershipStatus_Similac__c FROM Contact WHERE Id =: con.Id][0];
        System.assertEquals(conCheck.MembershipId_Ensure__c, '9222 1111 1111 11111 5');
        System.assertEquals(conCheck.MembershipId_Glucerna__c, '9222 2111 1111 11111 5');
        System.assertEquals(conCheck.MembershipId_Pediasure__c, '9222 4111 1111 11111 5');
        System.assertEquals(conCheck.MembershipId_Similac__c, '9222 5111 1111 11111 5');
        System.assertEquals(conCheck.MembershipStatus_Ensure__c, 'Activated');
        System.assertEquals(conCheck.MembershipStatus_Glucerna__c, 'Activated');
        System.assertEquals(conCheck.MembershipStatus_Pediasure__c, 'Activated');
        System.assertEquals(conCheck.MembershipStatus_Similac__c, 'Activated');
    }
    static testmethod void testcopyMembershipToContact_Update(){
        Contact con = [SELECT Id FROM Contact WHERE Phone = '0999999999'][0];
        List<Membership__c> membershipUpdateList = new List<Membership__c>();
        for(Membership__c mem : [SELECT Id FROM Membership__c WHERE MembershipId__c like '%111 3']){
            mem.Status__c = 'Activated';
            mem.MembershipStartDate__c = Date.Today();
            mem.NumberOfTransactions__c = 1;
            membershipUpdateList.add(mem);
        }
        Test.startTest();
        update membershipUpdateList;
        Test.stopTest();
        Contact conCheck = [SELECT Id, MembershipId_Ensure__c, MembershipId_Glucerna__c, MembershipId_Pediasure__c, MembershipId_Similac__c, 
                            MembershipNumberOfDaysDormant_Ensure__c, MembershipNumberOfDaysDormant_Glucerna__c, MembershipNumberOfDaysDormant_Pediasure__c, MembershipNumberOfDaysDormant_Similac__c,
                            MembershipNumberOfTransactions_Ensure__c, MembershipNumberOfTransactions_Glucerna__c, MembershipNumberOfTransactions_Pediasure__c, MembershipNumberOfTransactions_Similac__c,
                            MembershipRecentProduct_Ensure__c, MembershipRecentProduct_Glucerna__c, MembershipRecentProduct_Pediasure__c, MembershipRecentProduct_Similac__c,
                            MembershipStartDate_Ensure__c, MembershipStartDate_Glucerna__c, MembershipStartDate_Pediasure__c, MembershipStartDate_Similac__c, 
                            MembershipStatus_Ensure__c, MembershipStatus_Glucerna__c, MembershipStatus_Pediasure__c, MembershipStatus_Similac__c FROM Contact WHERE Id =: con.Id][0];
        System.assertEquals(conCheck.MembershipId_Ensure__c, '9222 1111 1111 11111 3');
        System.assertEquals(conCheck.MembershipId_Glucerna__c, '9222 2111 1111 11111 3');
        System.assertEquals(conCheck.MembershipId_Pediasure__c, '9222 4111 1111 11111 3');
        System.assertEquals(conCheck.MembershipId_Similac__c, '9222 5111 1111 11111 3');
        System.assertEquals(conCheck.MembershipStatus_Ensure__c, 'Activated');
        System.assertEquals(conCheck.MembershipStatus_Glucerna__c, 'Activated');
        System.assertEquals(conCheck.MembershipStatus_Pediasure__c, 'Activated');
        System.assertEquals(conCheck.MembershipStatus_Similac__c, 'Activated');
        System.assertEquals(conCheck.MembershipStartDate_Ensure__c, Date.Today());
        System.assertEquals(conCheck.MembershipStartDate_Glucerna__c, Date.Today());
        System.assertEquals(conCheck.MembershipStartDate_Pediasure__c, Date.Today());
        System.assertEquals(conCheck.MembershipStartDate_Similac__c, Date.Today());
        System.assertEquals(conCheck.MembershipNumberOfTransactions_Ensure__c, 1);
        System.assertEquals(conCheck.MembershipNumberOfTransactions_Glucerna__c, 1);
        System.assertEquals(conCheck.MembershipNumberOfTransactions_Pediasure__c, 1);
        System.assertEquals(conCheck.MembershipNumberOfTransactions_Similac__c, 1);
    }
}