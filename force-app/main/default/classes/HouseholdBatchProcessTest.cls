@isTest 
public class HouseholdBatchProcessTest{

    @testsetup
    static void setupData() {
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);
        
        //Create Child with Milk Code Restriction Enabled
        List<Contact> lChildContact = TestDataFactory.createTestChildContact(1, lAccount.get(0).Id);
        lChildContact[0].Birthdate = Date.today();
        lChildContact[0].MilkCodeRestriction__c = TRUE;
        update lChildContact;

        //Create Primary Adult Contact
        List<Contact> lPrimaryContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        lPrimaryContact[0].PrimaryContact__c = TRUE;
        lPrimaryContact[0].Email = 'testdata@test.com';
        update lPrimaryContact;

        //Update Account details
        lAccount[0].NumberOfHouseholdMembers__c = 0;
        lAccount[0].NumberOfPrimaryContacts__c = 0;
        lAccount[0].NumberOfAdults__c = 0;
        lAccount[0].NumberOfChildren__c = 0;
        lAccount[0].ChildrenUnderMilkCodeRestriction__c = 0;
        lAccount[0].PrimaryContact__c = '';
        lAccount[0].PrimaryContactEmail__c = '';
        lAccount[0].PrimaryContactPhone__c = '';
        update lAccount;

    }

    public static testMethod  void testBatchJob() {
        System.Test.startTest();
            HouseholdBatchProcess hbp = new HouseholdBatchProcess();
            Database.executeBatch(hbp, 200);
        System.Test.stopTest();

        List<Account> lAccountAfterUpdate = [SELECT NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, NumberOfAdults__c, NumberOfChildren__c, 
                                            ChildrenUnderMilkCodeRestriction__c, PrimaryContact__c, PrimaryContactEmail__c, PrimaryContactPhone__c
                                            FROM Account LIMIT 1];

        System.assertEquals(2, lAccountAfterUpdate[0].NumberOfHouseholdMembers__c, 'Number of Household Members should be 2');
        System.assertEquals(1, lAccountAfterUpdate[0].NumberOfPrimaryContacts__c, 'Number of Primary Contacts should be 1');
        System.assertEquals(1, lAccountAfterUpdate[0].NumberOfAdults__c, 'Number of Adults should be 1');
        System.assertEquals(1, lAccountAfterUpdate[0].NumberOfChildren__c, 'Number of Children should be 1');
        System.assertEquals(1, lAccountAfterUpdate[0].ChildrenUnderMilkCodeRestriction__c, 'Children Under Milk Code Restriction should be 1');
        System.assertNotEquals(null, lAccountAfterUpdate[0].PrimaryContact__c, 'Primary Contact should be populated');
        System.assertNotEquals(null, lAccountAfterUpdate[0].PrimaryContactEmail__c, 'Primary Contact Email should be populated');
        System.assertNotEquals(null, lAccountAfterUpdate[0].PrimaryContactPhone__c, 'Primary Contact Phone should be populated');
    }
}