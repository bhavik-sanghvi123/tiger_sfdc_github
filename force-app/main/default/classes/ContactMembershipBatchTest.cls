@isTest
public class ContactMembershipBatchTest {
    @testSetup
    static void setUp(){
        Account a1 = TestDataFactory.createTestHousehold(1, 'PH')[0];
        Account a2 = TestDataFactory.createTestHousehold(1, 'PH')[0];
        Account a3 = TestDataFactory.createTestHousehold(1, 'PH')[0];
        Contact con1 = TestDataFactory.createContact(true, a1.Id, null, Date.valueOf('1990-01-01'), '0999999999');
        Contact con2 = TestDataFactory.createContact(true, a2.Id, null, Date.valueOf('1992-01-01'), '0999999991');
        Contact con3 = TestDataFactory.createContact(true, a3.Id, null, Date.valueOf('1994-01-01'), '0999999992');
        PricebookEntry pbeEnsure = TestDataFactory.createPricebookEntry('PH', 'USD');
        PricebookEntry pbeGlucerna = TestDataFactory.createProductAndPricebookEntryDiffBrand('PH', 'USD', pbeEnsure.Pricebook2Id, 'Glucerna');
        PricebookEntry pbePediasure = TestDataFactory.createProductAndPricebookEntryDiffBrand('PH', 'USD', pbeEnsure.Pricebook2Id, 'Pediasure');
        PricebookEntry pbeSimilac = TestDataFactory.createProductAndPricebookEntryDiffBrand('PH', 'USD', pbeEnsure.Pricebook2Id, 'Similac');
        List<Membership__c> membershipInsertList = new List<Membership__c>();
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con1.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 1111 1111 11111 1', pbeEnsure.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con1.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 2111 1111 11111 1', pbeGlucerna.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con1.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 4111 1111 11111 1', pbePediasure.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con1.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 5111 1111 11111 1', pbeSimilac.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con1.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 1111 1111 11111 2', pbeEnsure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con1.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 2111 1111 11111 2', pbeGlucerna.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con1.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 4111 1111 11111 2', pbePediasure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con1.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 5111 1111 11111 2', pbeSimilac.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con2.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 1111 1111 11111 3', pbeEnsure.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con2.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 2111 1111 11111 3', pbeGlucerna.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con2.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 4111 1111 11111 3', pbePediasure.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con2.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 5111 1111 11111 3', pbeSimilac.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con2.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 1111 1111 11111 4', pbeEnsure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con2.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 2111 1111 11111 4', pbeGlucerna.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con2.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 4111 1111 11111 4', pbePediasure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con2.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 5111 1111 11111 4', pbeSimilac.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con3.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 1111 1111 11111 5', pbeEnsure.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con3.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 2111 1111 11111 5', pbeGlucerna.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con3.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 4111 1111 11111 5', pbePediasure.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con3.Id, Date.Today().addDays(-2), Date.Today().addDays(-1), '9222 5111 1111 11111 5', pbeSimilac.Product2Id, 'Expired'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con3.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 1111 1111 11111 6', pbeEnsure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con3.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 2111 1111 11111 6', pbeGlucerna.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con3.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 4111 1111 11111 6', pbePediasure.Product2Id, 'New'));
        membershipInsertList.add(TestDataFactory.createMembershipRecord(con3.Id, Date.Today().addDays(1), Date.Today().addDays(2), '9222 5111 1111 11111 6', pbeSimilac.Product2Id, 'New'));
        insert membershipInsertList;
    }
    static testmethod void testContactMembershipBatch(){
        Test.startTest();
        ContactMembershipBatch batch = new ContactMembershipBatch(); 
        Database.executebatch(batch, 200);
        Test.stopTest();
        for(Contact con : [SELECT Id, MembershipId_Ensure__c, MembershipId_Glucerna__c, MembershipId_Pediasure__c, MembershipId_Similac__c, 
                           MembershipNumberOfDaysDormant_Ensure__c, MembershipNumberOfDaysDormant_Glucerna__c, MembershipNumberOfDaysDormant_Pediasure__c, MembershipNumberOfDaysDormant_Similac__c,
                           MembershipNumberOfTransactions_Ensure__c, MembershipNumberOfTransactions_Glucerna__c, MembershipNumberOfTransactions_Pediasure__c, MembershipNumberOfTransactions_Similac__c,
                           MembershipRecentProduct_Ensure__c, MembershipRecentProduct_Glucerna__c, MembershipRecentProduct_Pediasure__c, MembershipRecentProduct_Similac__c,
                           MembershipStartDate_Ensure__c, MembershipStartDate_Glucerna__c, MembershipStartDate_Pediasure__c, MembershipStartDate_Similac__c, 
                           MembershipStatus_Ensure__c, MembershipStatus_Glucerna__c, MembershipStatus_Pediasure__c, MembershipStatus_Similac__c FROM Contact WHERE Phone IN ('0999999999','0999999991','0999999992')])
        {
            System.assertEquals(con.MembershipStatus_Ensure__c, 'New');   
            System.assertEquals(con.MembershipStatus_Glucerna__c, 'New');
            System.assertEquals(con.MembershipStatus_Pediasure__c, 'New');
            System.assertEquals(con.MembershipStatus_Similac__c, 'New');
        }
    }
    
    static testmethod void testContactMembershipBatchSchedule(){
        Test.startTest();
        System.schedule('ContactMembershipBatch', '0 0 13 * * ?', new ContactMembershipBatch());
        Test.stopTest();
        for(Contact con : [SELECT Id, MembershipId_Ensure__c, MembershipId_Glucerna__c, MembershipId_Pediasure__c, MembershipId_Similac__c, 
                           MembershipNumberOfDaysDormant_Ensure__c, MembershipNumberOfDaysDormant_Glucerna__c, MembershipNumberOfDaysDormant_Pediasure__c, MembershipNumberOfDaysDormant_Similac__c,
                           MembershipNumberOfTransactions_Ensure__c, MembershipNumberOfTransactions_Glucerna__c, MembershipNumberOfTransactions_Pediasure__c, MembershipNumberOfTransactions_Similac__c,
                           MembershipRecentProduct_Ensure__c, MembershipRecentProduct_Glucerna__c, MembershipRecentProduct_Pediasure__c, MembershipRecentProduct_Similac__c,
                           MembershipStartDate_Ensure__c, MembershipStartDate_Glucerna__c, MembershipStartDate_Pediasure__c, MembershipStartDate_Similac__c, 
                           MembershipStatus_Ensure__c, MembershipStatus_Glucerna__c, MembershipStatus_Pediasure__c, MembershipStatus_Similac__c FROM Contact WHERE Phone IN ('0999999999','0999999991','0999999992')])
        {
            System.assertEquals(con.MembershipStatus_Ensure__c, 'New');   
            System.assertEquals(con.MembershipStatus_Glucerna__c, 'New');
            System.assertEquals(con.MembershipStatus_Pediasure__c, 'New');
            System.assertEquals(con.MembershipStatus_Similac__c, 'New');
        }
    }
}