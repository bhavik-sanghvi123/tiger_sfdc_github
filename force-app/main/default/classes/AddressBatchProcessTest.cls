// @isTest  for deletion
public class AddressBatchProcessTest{} /*

    @testsetup
    static void setupData() {
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);    

        //Create Primary Adult Contact
        List<Contact> lPrimaryContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);

        //Create Address
        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, lPrimaryContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);

        lPrimaryContact[0].Region__c = null;
        update lPrimaryContact[0];
    }

    public static testMethod  void testBatchJob() {
        List<Contact> lContactBeforeUpdate = [SELECT Id, Region__c FROM Contact LIMIT 1];
        List<Address__c> lAddress = [SELECT Id, ParentContact__c, Region__c FROM Address__c LIMIT 1];

        System.Test.startTest();
            AddressBatchProcess abp = new AddressBatchProcess();
            Database.executeBatch(abp, 200);
        System.Test.stopTest();

        List<Contact> lContactAfterUpdate = [SELECT Id, Region__c FROM Contact LIMIT 1];
        System.assertEquals(null, lContactBeforeUpdate[0].Region__c, 'Contact\'s Region is not populated');
        System.assertEquals(lAddress[0].Region__c, lContactAfterUpdate[0].Region__c, 'Contact\'s Region should be populated with the Default Address Region');
    }
} */