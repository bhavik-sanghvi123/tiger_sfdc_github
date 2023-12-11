@isTest
private class TransferCallPageControllerTest {

    @testsetup
    static void setupData() {
        Id phRoleId = [SELECT Id FROM UserRole WHERE Name = 'ANI - Philippines'].Id;
        User testUser = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        testUser.UserRoleId = phRoleId;
        insert testUser;

        System.runAs(testUser) {
            //Create Call Transfer Reason
            List<Affiliate_Value__c> lCallTransfer = TestDataFactory.createTestCallTransferReason(1, 'PH');
            //Create Preferred Language
            Affiliate_Value__c language = TestDataFactory.createAffiliate('PH', 'English');

            List<Account> accountList = TestDataFactory.createTestHousehold(1);
            List<Contact> contactList = TestDataFactory.createTestAdultContact(1, accountList.get(0).Id);
            contactList[0].PreferredLanguage__c = language.Id;
            Case caseRec = TestDataFactory.createCaseCall(accountList.get(0).Id, contactList.get(0).Id);
        }
    }

    private static testMethod void fetchUserMarketTest() {
        String result;
        String sysAdMarket = [SELECT Id, Market__c FROM User LIMIT 1].Market__c;
        User sysAd = [SELECT Id FROM User LIMIT 1];

        System.Test.startTest();
            System.runAs(sysAd) {
                result = TransferCallPageController.fetchUserMarket();   
            }
        System.Test.stopTest();

        System.assertEquals(sysAdMarket, result, 'User is under PH Market.');
    }

    private static testMethod void getLanguageTest() {
        Id rtId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Preferred Language').getRecordTypeId();
        Case caseRec;
        String language;
        User sysAd = [SELECT Id FROM User LIMIT 1];
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        Id avId = [SELECT Id FROM Affiliate_Value__c WHERE RecordTypeId = :rtId].Id;

        System.Test.startTest();
            System.runAs(sysAd) {
                caseRec = TransferCallPageController.fetchContact(caseId); 
                language = TransferCallPageController.fetchLanguage(avId);
            }
        System.Test.stopTest();

        System.assertNotEquals(null, Contact.PreferredLanguage__r.Name, 'Contact\'s Market is not null');
        System.assertNotEquals(null, language, 'Language is not null');
    }

     private static testMethod void transferCallTest() {
        Id plId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Preferred Language').getRecordTypeId();
        Id ctrId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Preferred Language').getRecordTypeId();
        String sysAdMarket = [SELECT Id, Market__c FROM User LIMIT 1].Market__c;
        User sysAd = [SELECT Id FROM User LIMIT 1];

        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;
        Id languageId = [SELECT Id FROM Affiliate_Value__c WHERE RecordTypeId = :plId].Id;
        Id callTransferId = [SELECT Id FROM Affiliate_Value__c WHERE RecordTypeId = :ctrId].Id;
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;

        Id origCaseOwnerId = [Select Id, OwnerId FROM Case LIMIT 1].OwnerId;

        System.Test.startTest();
            System.runAs(sysAd) {
                Id phRoleId = [SELECT Id FROM UserRole WHERE Name = 'ANI - Philippines'].Id;
                User testUser = TestDataFactory.createUser('System Administrator', 'tstUser2' , 'PH');
                testUser.UserRoleId = phRoleId;
                insert testUser;

                /*TransferCallPageController.transferCall(caseId, testUser.Id, callTransferId, conId, languageId);
                Id newCaseOwnerId = [Select Id, OwnerId FROM Case LIMIT 1].OwnerId;
                System.assertNotEquals(origCaseOwnerId, newCaseOwnerId, 'Case Owner should be updated.');*/
            }
        System.Test.stopTest();
    }

}