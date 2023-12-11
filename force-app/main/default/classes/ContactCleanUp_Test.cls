// @isTest for deletion
public class ContactCleanUp_Test {} /* {
    @testsetup
    static void setupData() {
    
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);    

        //Create Primary Adult Contact
        List<Contact> lPrimaryContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        lPrimaryContact[0].EstimatedDueDate__c = Date.Today().addMonths(8);
        update lPrimaryContact;

        //Create Address
        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, lPrimaryContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
        Test.setCreatedDate(lAddress[0].Id, Date.TODAY());

        
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        
        Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
        ca1.ContactId = lPrimaryContact[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'New';
        ca1.AccountId = lAccount[0].Id;
        ca1.CallRegarding__c = lPrimaryContact[0].Id;
        ca1.CallOutcome__c = 'Successful';
        ca1.SuccessfulReason__c = TestDataFactory.createTestSuccessfulReason(1, 'PH')[0].Id;
        insert ca1;

        Case ca2 = new Case();
        ca2.RecordtypeId = callRTId;
        ca2.ContactId = lPrimaryContact[0].Id;
        ca2.CallType__c = 'Outbound';
        ca2.Status = 'New';
        ca2.AccountId = lAccount[0].Id;
        ca2.CallRegarding__c = lPrimaryContact[0].Id;
        insert ca2;


    }

    static testMethod void test1(){
        Test.startTest();
            Database.executeBatch(new ContactCleanUp());
        Test.stopTest();
    }
} */