@isTest 
public class MembershipNumberOfTransactionsBatchTest {
    @testsetup
    static void setupData() {
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);
        List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        List<Membership__c> lMembership = TestDataFactory.createMembership(2, lContact.get(0).Id, -90);
        lMembership[0].MembershipId__c = 'TESTMEM1';
        update lMembership[0];
        lMembership[0].MembershipId__c = 'TESTMEM2';
        update lMembership[1];
        
        List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, null);
        insert lOrder;
        lOrder[0].EffectiveDate = System.today().addDays(-10);
        lOrder[0].EndDate = System.today().addDays(-2);
        lOrder[0].ParentMembership__c = lMembership[0].Id;
        update lOrder[0];
    }

    public static testMethod  void testBatch() {
        List<Membership__c> membershipBeforeUpdate = [SELECT Id, NumberOfTransactions__c FROM Membership__c LIMIT 1];
        membershipBeforeUpdate[0].NumberOfTransactions__c = 0;
        update membershipBeforeUpdate[0];

        System.Test.startTest();
            MembershipNumberOfTransactionsBatch mnt = new MembershipNumberOfTransactionsBatch();
            Database.executeBatch(mnt, 200);
        System.Test.stopTest();

        List<Membership__c> membershipAfterUpdate = [SELECT Id, NumberOfTransactions__c FROM Membership__c LIMIT 1];
        System.assertNotEquals(membershipBeforeUpdate[0].NumberOfTransactions__c, membershipAfterUpdate[0].NumberOfTransactions__c, 'Membership Number of Transactions should be modified');
    }
}