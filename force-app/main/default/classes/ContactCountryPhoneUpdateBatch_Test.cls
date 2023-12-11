@isTest
public class ContactCountryPhoneUpdateBatch_Test {
    @TestSetup
    static void setup(){
        Test.enableChangeDataCapture();
        
        //Create Household record
        List<Account> lAccount = TestDataFactory.createTestHouseholdNoInsert(1, CommonConstant.MARKET_TW);
        UtilityClass.insertList(lAccount);
        
        //Create Primary Child Contact Record
        List<Contact> primaryChildCon = TestDataFactory.createTestChildContact(1, lAccount.get(0).Id);
        Test.getEventBus().deliver();
        primaryChildCon[0].PrimaryContact__c = TRUE;
        update primaryChildCon[0];
        Test.getEventBus().deliver();
        
        //Create Non-Primary Child Contact Record
        List<Contact> nonPrimaryAdultCon = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        Test.getEventBus().deliver();
        nonPrimaryAdultCon[0].Phone = '09961239876';
        update nonPrimaryAdultCon[0];
        Test.getEventBus().deliver();
    }

    static testMethod void runContactCountryPhoneUpdateBatch() {
        ContactCountryPhoneUpdateBatch ccpub = new ContactCountryPhoneUpdateBatch();

        System.Test.startTest();
        Database.executebatch(new ContactCountryPhoneUpdateBatch(), 200);
        System.Test.stopTest();
    }
}