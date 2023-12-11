// @isTest for deletion
public class ContactBatchProcessTest{

    // @testsetup
    // static void setupData() {
    //     List<Account> lAccount = TestDataFactory.createTestHousehold(1);
    //     List<Contact> lContact = TestDataFactory.createTestChildContact(1, lAccount.get(0).Id);
    //     lContact[0].Birthdate = Date.today();
    //     update lContact;

    // }

    // public static testMethod  void testBatchJob() {
    //     System.Test.startTest();
    //         ContactBatchProcess cbp = new ContactBatchProcess();
    //         Database.executeBatch(cbp, 200);
    //     System.Test.stopTest();

    //     List<Contact> lContactAfterUpdate = [SELECT Id, MilkCodeRestriction__c FROM Contact LIMIT 1];
    //     System.assertEquals(TRUE, lContactAfterUpdate[0].MilkCodeRestriction__c, 'Milk Code Restriction should be TRUE.');
    // }
}