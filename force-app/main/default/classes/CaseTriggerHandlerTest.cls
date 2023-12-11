@isTest
private class CaseTriggerHandlerTest {
    
    @testsetup
    static void setupData() {
        Test.enableChangeDataCapture();
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        sysad.Market__c += ' SG MY PH ANZ IN ID';
        System.runAs(new User(Id = UserInfo.getUserId())){
           insert sysad; 
        }
        
        
        List<Campaign> campList = new List<Campaign>();
        List<Account> accList = TestDataFactory.createTestHousehold(3);
        accList[1].Market__c = 'SG';
        accList[2].Market__c = 'TW';
        update accList;
        
        //List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
        List<Contact> conList = new List<Contact>();
        conList.add(TestDataFactory.createTestAdultContact(1, accList.get(0).Id)[0]);
        conList.add(TestDataFactory.createSGTestAdultContact(1, accList.get(1).Id)[0]);
        conList.add(TestDataFactory.createTestAdultContact(1, accList.get(2).Id)[0]);
        
        List<Product2> prod = TestDataFactory.createTestBrandProduct(3);
        prod[1].Market__c = 'SG';
        prod[2].Market__c = 'TW';
        update prod;
        
        List<BrandRelationship__c> brList = new List<BrandRelationship__c>();
        brList.add(TestDataFactory.createTestBrandRelationShip(1, conList.get(0).Id, prod[0].Id)[0]);
        brList.add(TestDataFactory.createTestBrandRelationShip(1, conList.get(1).Id, prod[1].Id)[0]);
        brList.add(TestDataFactory.createTestBrandRelationShip(1, conList.get(2).Id, prod[2].Id)[0]);
        
        List<Channel__c> chList = TestDataFactory.createTestChannel(3);
        chList[1].Market__c = 'SG';
        chList[2].Market__c = 'TW';
        update chList;
        
        ChannelResponse__c cr = TestDataFactory.createTestChannelResponse(brList[0], chList[0]);
        ChannelResponse__c cr2 = TestDataFactory.createTestChannelResponse(brList[1], chList[1]);
        ChannelResponse__c cr3 = TestDataFactory.createTestChannelResponse(brList[2], chList[2]);
        
        campList.add(TestDataFactory.createCampaign('Test Campaign SG 1', 'Similac', 'SG'));
        campList.add(TestDataFactory.createCampaign('Test Campaign SG 2', 'Ensure', 'SG'));
        campList.add(TestDataFactory.createCampaign('Test Campaign TW 1', 'Similac', 'TW'));
        campList.add(TestDataFactory.createCampaign('Test Campaign TW 2', 'Ensure', 'TW'));
        campList.add(TestDataFactory.createCampaign('Test Campaign 2', 'Ensure', 'PH'));
        campList.add(TestDataFactory.createCampaign('Test Campaign 1', 'Similac', 'PH'));
        insert campList;
    }
    
    @isTest
    static void testForCompleteDate() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Id srRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('Successful_Reason').getRecordTypeId();
      
        List<Case> caseList = new List<Case>();
        List<Case> updatedCaseList = new List<Case>();
        List<Case> caseListToUpdate = new List<Case>();
        List<Case> caseListToAssert = new List<Case>();
        List<Contact> conList2 = new List<Contact>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id, FirstCallDate__c, LastCallDate__c from Contact limit 1];
        conList[0].FirstCallDate__c = System.today() + 5;
        conList[0].LastCallDate__c = System.today() - 5;
        update conList;
        
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        
        Affiliate_Value__c af1 = new Affiliate_Value__c();
        af1.Name = 'Success Test';
        af1.AffiliateValue__c = 'Success Test';
        af1.Market__c = 'PH';
        af1.Active__c = true;
        insert af1;
        
        Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
       
        ca1.ContactId = conList[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'New';
        ca1.AccountId = a1.Id;
        ca1.CallRegarding__c = conList[0].Id;
        ca1.Campaign__c = camp1.Id;
        caseList.add(ca1);
        
        Case ca2 = new Case();
        ca2.RecordtypeId = callRTId;
        
        ca2.ContactId = conList[0].Id;
        ca2.CallType__c = 'Outbound';
        ca2.Status = 'New';
        ca2.AccountId = a1.Id;
        ca2.CallRegarding__c = conList[0].Id;
        ca2.Campaign__c = camp1.Id;
        caseList.add(ca2);

        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(2);
        lProduct[0].AvailableBrandRelationship__c = true;
        lProduct[0].AvailableForCurrentAndPreviousBrand__c = true;
        lProduct[0].CompetitorProduct__c = false;
        lProduct[1].AvailableForCurrentAndPreviousBrand__c = true;
        update lProduct;
        
        Channel__c chan = TestDataFactory.createTestChannel(1)[0];

        try{
        insert caseList;
        Test.getEventBus().deliver();
        } catch(DmlException e) {
    System.debug('The following exception has occurred: ' + e.getMessage());
}
        
        caseListToUpdate = [select Id, Status, CallOutcome__c, SuccessfulReason__c from Case where Id in :caseList];
        caseListToUpdate[0].Status = 'Completed';
        caseListToUpdate[0].CallOutcome__c = 'Successful';
        caseListToUpdate[0].SuccessfulReason__c = af1.Id;
        caseListToUpdate[0].PreviousBrandUsed__c = lProduct[0].Id;
        caseListToUpdate[0].CurrentBrandUsed__c = lProduct[0].Id;
        caseListToUpdate[0].BrandSwitchReason__c = af1.Id;
        caseListToUpdate[0].Channel__c = chan.Id;
        caseListToUpdate[0].PrimaryProductDiscussed__c = lProduct[0].Id;
        

        caseListToUpdate[1].Status = 'Completed';
        caseListToUpdate[1].CallOutcome__c = 'Successful';
        caseListToUpdate[1].SuccessfulReason__c = af1.Id;
        caseListToUpdate[1].PreviousBrandUsed__c = lProduct[1].Id;
        caseListToUpdate[1].CurrentBrandUsed__c = lProduct[1].Id;
        caseListToUpdate[1].BrandSwitchReason__c = af1.Id;
        caseListToUpdate[1].Channel__c = chan.Id;
        caseListToUpdate[1].PrimaryProductDiscussed__c = lProduct[1].Id;
        
        
        
        System.Test.startTest();
        update caseListToUpdate;
        System.Test.stopTest();
        
        caseListToUpdate[0].Status = 'Completed';
        caseListToUpdate[0].CallOutcome__c = 'Uncontactable';
        caseListToUpdate[0].SuccessfulReason__c = af1.Id;
        
        caseListToUpdate[1].Status = 'Completed';
        caseListToUpdate[1].CallOutcome__c = 'Invalid';
        caseListToUpdate[1].SuccessfulReason__c = af1.Id;
        try {
            update caseListToUpdate;
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.getEventBus().deliver();
        
        caseListToAssert = [select Id, CallCompletedDate__c, CallOutcome__c, SuccessfulReason__c from Case where Id in :caseListToUpdate];
        
        System.assertEquals(true, caseListToAssert[0].CallCompletedDate__c != null);
        
        // call batch job
        Database.executeBatch(new OmniChannel_CleanUp());
        
        String cronStr = '0 0 0 3 9 ? 2050';
        String jobId2 = System.schedule('OmniChannel_CleanUp_Test', cronStr, new OmniChannel_CleanUp_Sched());
    }
    
    @isTest
    static void testForUpdateDatesInsertUpdate() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Id srRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('Successful_Reason').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        List<Case> updatedCaseList = new List<Case>();
        List<Case> caseListToUpdate = new List<Case>();
        List<Case> caseListToAssert = new List<Case>();
        List<Contact> conListToAssert = new List<Contact>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id from Contact limit 1];
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        
        Affiliate_Value__c af1 = new Affiliate_Value__c();
        af1.Name = 'Success Test';
        af1.AffiliateValue__c = 'Success Test';
        af1.Market__c = 'PH';
        af1.Active__c = true;
        insert af1;
        
        Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
        ca1.ContactId = conList[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'Completed';
        ca1.AccountId = a1.Id;
        ca1.CallRegarding__c = conList[0].Id;
        ca1.Campaign__c = camp1.Id;
        ca1.CallOutcome__c = 'Successful';
        ca1.SuccessfulReason__c = af1.Id;
        caseList.add(ca1);
        
        Case ca2 = new Case();
        ca2.RecordtypeId = callRTId;
        ca2.ContactId = conList[0].Id;
        ca2.CallType__c = 'Outbound';
        ca2.Status = 'Completed';
        ca2.AccountId = a1.Id;
        ca2.CallRegarding__c = conList[0].Id;
        ca2.Campaign__c = camp1.Id;
        ca2.CallOutcome__c = 'Successful';
        ca2.SuccessfulReason__c = af1.Id;
        caseList.add(ca2);
        
        System.Test.startTest();
        try {
        insert caseList;
        } catch(DmlException e) {
    System.debug('The following exception has occurred: ' + e.getMessage());
}
        System.Test.stopTest();
        Test.getEventBus().deliver();
        
        caseListToAssert = [select Id, CallCompletedDate__c, CallOutcome__c, SuccessfulReason__c from Case where Id in :caseList limit 1];
        conListToAssert = [select Id, FirstCallDate__c, LastCallDate__c from Contact where Id in :conList];
        
        //System.assertEquals(caseListToAssert[0].CallCompletedDate__c.date(), conListToAssert[0].FirstCallDate__c.date());
        //System.assertEquals(caseListToAssert[0].CallCompletedDate__c.date(), conListToAssert[0].LastCallDate__c.date());
    }
    
    @isTest
    static void testForUpdateDatesDelete() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Id srRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('Successful_Reason').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        List<Case> updatedCaseList = new List<Case>();
        List<Case> caseListToDelete = new List<Case>();
        List<Case> caseListToAssert = new List<Case>();
        List<Contact> conListToAssert = new List<Contact>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id from Contact limit 1];
        conList[0].FirstCallDate__c = System.today() + 5;
        conList[0].LastCallDate__c = System.today() - 5;
        update conList;
        
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        
        Affiliate_Value__c af1 = new Affiliate_Value__c();
        af1.Name = 'Success Test';
        af1.AffiliateValue__c = 'Success Test';
        af1.Market__c = 'PH';
        af1.Active__c = true;
        insert af1;
        
        Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
        ca1.ContactId = conList[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'Completed';
        ca1.AccountId = a1.Id;
        ca1.CallRegarding__c = conList[0].Id;
        ca1.Campaign__c = camp1.Id;
        ca1.CallOutcome__c = 'Successful';
        ca1.SuccessfulReason__c = af1.Id;
        caseList.add(ca1);
        Test.getEventBus().deliver();
        
        Case ca2 = new Case();
        ca2.RecordtypeId = callRTId;
        ca2.ContactId = conList[0].Id;
        ca2.CallType__c = 'Outbound';
        ca2.Status = 'Completed';
        ca2.AccountId = a1.Id;
        ca2.CallRegarding__c = conList[0].Id;
        ca2.Campaign__c = camp1.Id;
        ca2.CallOutcome__c = 'Successful';
        ca2.SuccessfulReason__c = af1.Id;
        caseList.add(ca2);
        
        insert caseList;
        Test.getEventBus().deliver();
        
        caseListToDelete = [select Id, CallCompletedDate__c, CallOutcome__c, SuccessfulReason__c from Case where Id in :caseList limit 1];
        
        System.Test.startTest();
        delete caseListToDelete;
        System.Test.stopTest();
        
        caseListToAssert = [select Id, CallCompletedDate__c, CallOutcome__c, SuccessfulReason__c from Case where Id in :caseList limit 1];
        conListToAssert = [select Id, FirstCallDate__c, LastCallDate__c from Contact where Id in :conList];
        
        System.assertEquals(caseListToAssert[0].CallCompletedDate__c.date(), conListToAssert[0].FirstCallDate__c.date());
        System.assertEquals(caseListToAssert[0].CallCompletedDate__c.date(), conListToAssert[0].LastCallDate__c.date());
    }
    
     @isTest
    static void testSuccessfulUnsuccessfulReason() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Id srRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('Successful_Reason').getRecordTypeId();
        Id usrRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('UnsuccessfulReason').getRecordTypeId();
        Id ucrRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('UncontactableReason').getRecordTypeId();
        Id inrRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('InvalidReason').getRecordTypeId();

        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id from Contact limit 1];
        List<Case> caseList = new List<Case>();

        Affiliate_Value__c af1 = new Affiliate_Value__c();
        af1.Name = 'Success Test';
        af1.AffiliateValue__c = 'Success Test';
        af1.Market__c = 'PH';
        af1.Active__c = true;
        af1.RecordTypeId = srRTId;
        insert af1;

        Affiliate_Value__c af2 = new Affiliate_Value__c();
        af2.Name = 'Unsuccess Test';
        af2.AffiliateValue__c = 'Unsuccess Test';
        af2.Market__c = 'PH';
        af2.Active__c = true;
        af2.RecordTypeId = usrRTId;
        insert af2;
        
        Affiliate_Value__c af3 = new Affiliate_Value__c();
        af3.Name = 'uncontactable Test';
        af3.AffiliateValue__c = 'uncontactable Test';
        af3.Market__c = 'PH';
        af3.Active__c = true;
        af3.RecordTypeId = ucrRTId;
        insert af3;
        
        Affiliate_Value__c af4 = new Affiliate_Value__c();
        af4.Name = 'Invalid Test';
        af4.AffiliateValue__c = 'Invalid Test';
        af4.Market__c = 'PH';
        af4.Active__c = true;
        af4.RecordTypeId = inrRTId;
        insert af4;

        Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
        ca1.ContactId = conList[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'Completed';
        ca1.AccountId = a1.Id;
        ca1.CallRegarding__c = conList[0].Id;
        ca1.CallOutcome__c = 'Successful';
        ca1.SuccessfulReason__c = af1.Id;
        ca1.UnsuccessfulReason__c = af2.Id;
        ca1.UncontactableReason__c = af3.Id;
        ca1.InvalidReason__c = af4.Id;
        ca1.Market__c = 'PH';
        caseList.add(ca1);

        Case ca2 = new Case();
        ca2.RecordtypeId = callRTId;
        ca2.ContactId = conList[0].Id;
        ca2.CallType__c = 'Outbound';
        ca2.Status = 'Completed';
        ca2.AccountId = a1.Id;
        ca2.CallRegarding__c = conList[0].Id;
        ca2.CallOutcome__c = 'Unsuccessful';
        ca2.SuccessfulReason__c = af1.Id;
        ca2.UnsuccessfulReason__c = af2.Id;
        ca2.UncontactableReason__c = af3.Id;
        ca2.InvalidReason__c = af4.Id;
        ca2.Market__c = 'PH';
        caseList.add(ca2);
        
        Case ca3 = new Case();
        ca3.RecordtypeId = callRTId;
        ca3.ContactId = conList[0].Id;
        ca3.CallType__c = 'Outbound';
        ca3.Status = 'Completed';
        ca3.AccountId = a1.Id;
        ca3.CallRegarding__c = conList[0].Id;
        ca3.CallOutcome__c = 'uncontactable';
        ca3.SuccessfulReason__c = af1.Id;
        ca3.UnsuccessfulReason__c = af2.Id;
        ca3.UncontactableReason__c = af3.Id;
        ca3.InvalidReason__c = af4.Id;
        ca3.Market__c = 'PH';
        caseList.add(ca3);
        
        Case ca4 = new Case();
        ca4.RecordtypeId = callRTId;
        ca4.ContactId = conList[0].Id;
        ca4.CallType__c = 'Outbound';
        ca4.Status = 'Completed';
        ca4.AccountId = a1.Id;
        ca4.CallRegarding__c = conList[0].Id;
        ca4.CallOutcome__c = 'Invalid';
        ca4.SuccessfulReason__c = af1.Id;
        ca4.UnsuccessfulReason__c = af2.Id;
        ca4.UncontactableReason__c = af3.Id;
        ca4.InvalidReason__c = af4.Id;
        ca4.Market__c = 'PH';
        caseList.add(ca4);
        
        try{
        insert caseList;
        } catch(DmlException e) {
    System.debug('The following exception has occurred: ' + e.getMessage());
}
        Test.getEventBus().deliver();
        /*
        Id ca1UnsuccessfulReason = [SELECT Id, UnsuccessfulReason__c FROM Case WHERE CallOutcome__c = 'Successful' LIMIT 1].UnsuccessfulReason__c;
        Id ca2SuccessfulReason = [SELECT Id, SuccessfulReason__c FROM Case WHERE CallOutcome__c = 'Unsuccessful' LIMIT 1].SuccessfulReason__c;
        Id ca3UncontactableReason = [SELECT Id, UncontactableReason__c FROM Case WHERE CallOutcome__c = 'Uncontactable' LIMIT 1].UncontactableReason__c;
        Id ca4InvalidReason = [SELECT Id, InvalidReason__c FROM Case WHERE CallOutcome__c = 'Invalid' LIMIT 1].InvalidReason__c;

        System.assertEquals(null, ca1UnsuccessfulReason, 'Unsuccessful Reason should be updated to BLANK.');
        System.assertEquals(null, ca2SuccessfulReason, 'Successful Reason should be updated to BLANK.');
        System.assertEquals(null, ca3UncontactableReason, 'Uncontactable Reason should be updated to BLANK.');
        System.assertEquals(null, ca4InvalidReason, 'Invalid Reason should be updated to BLANK.');

        ca1.CallOutcome__c = 'Unsuccessful';
        ca1.UnsuccessfulReason__c = af2.Id;
        update ca1;
        Test.getEventBus().deliver();

        ca2.CallOutcome__c = 'Successful';
        ca2.SuccessfulReason__c = af1.Id;
        update ca2;
        Test.getEventBus().deliver();
        
        ca3.CallOutcome__c = 'Invalid';
        ca3.InvalidReason__c = af4.Id;
        update ca3;
        Test.getEventBus().deliver();

        ca4.CallOutcome__c = 'Uncontactable';
        ca4.UncontactableReason__c = af3.Id;
        update ca4;
        Test.getEventBus().deliver();
        
        Id ca2UnsuccessfulReasonUpdate = [SELECT Id, UnsuccessfulReason__c FROM Case WHERE CallOutcome__c = 'Successful' LIMIT 1].UnsuccessfulReason__c;
        Id ca1SuccessfulReasonUpdate = [SELECT Id, SuccessfulReason__c FROM Case WHERE CallOutcome__c = 'Unsuccessful' LIMIT 1].SuccessfulReason__c;
        Id ca4InvalidReasonUpdate = [SELECT Id, InvalidReason__c FROM Case WHERE CallOutcome__c = 'Invalid' LIMIT 1].InvalidReason__c;
        Id ca3UnContactableReasonUpdate = [SELECT Id, UncontactableReason__c FROM Case WHERE CallOutcome__c = 'Uncontactable' LIMIT 1].UncontactableReason__c;

        System.assertEquals(null, ca2UnsuccessfulReasonUpdate, 'Unsuccessful Reason should be updated to BLANK.');
        System.assertEquals(null, ca1SuccessfulReasonUpdate, 'Successful Reason should be updated to BLANK.');
        System.assertEquals(null, ca4InvalidReasonUpdate, 'Invalid Reason should be updated to BLANK.');
        System.assertEquals(null, ca3UncontactableReasonUpdate, 'Uncontactable Reason should be updated to BLANK.');
        */
    }
    
    @isTest
    static void testForPopulateBrandUsed() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        List<Case> updatedCaseList = new List<Case>();
        List<Case> caseListToDelete = new List<Case>();
        List<Case> caseListToAssert = new List<Case>();
        List<Contact> conListToAssert = new List<Contact>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id from Contact limit 1];
        conList[0].FirstCallDate__c = System.today() + 5;
        conList[0].LastCallDate__c = System.today() - 5;
        update conList;
        
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        
        Affiliate_Value__c af1 = new Affiliate_Value__c();
        af1.Name = 'Success Test';
        af1.AffiliateValue__c = 'Success Test';
        af1.Market__c = 'PH';
        af1.Active__c = true;
        insert af1;
      
        
        
        Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
        ca1.ContactId = conList[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'Completed';
        ca1.AccountId = a1.Id;
        ca1.CallRegarding__c = conList[0].Id;
        ca1.Campaign__c = camp1.Id;
        ca1.CallOutcome__c = 'Successful';
        ca1.SuccessfulReason__c = af1.Id;
        //caseList.add(ca1);
       
   
     
        
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(2);
        lProduct[0].AvailableBrandRelationship__c = true;
        lProduct[0].AvailableForCurrentAndPreviousBrand__c = true;
        lProduct[0].CompetitorProduct__c = false;
        lProduct[1].AvailableForCurrentAndPreviousBrand__c = true;
        update lProduct;
        
        
        
        BrandRelationship__c brand = new BrandRelationship__c();                
        brand.Type__c = 'Lead';
        brand.Status__c = 'Contacted';            
        brand.BrandRelationship__c = lProduct[0].Id;
        brand.User__c =  [Select Id from Contact Limit 1].Id;
        brand.PrimaryContact__c = [Select Id from Contact Limit 1].Id;   
        brand.Active__c = true;
        brand.CurrentBrand__c = lProduct[0].Id;
        brand.PreviousBrand__c = lProduct[1].Id;
        
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {
            test.StartTest();
            
            insert ca1;
            insert brand;
            
            ca1.ConvertedBR__c = brand.Id;
            update ca1;
            test.StopTest();
        }
        
        Case ca2 = [select Id, CurrentBrandUsed__c, PreviousBrandUsed__c from Case where Id = :ca1.Id];
        
        System.assertEquals(brand.CurrentBrand__c, ca2.CurrentBrandUsed__c);
        System.assertEquals(brand.PreviousBrand__c, ca2.PreviousBrandUsed__c);
    }
    
        @isTest
    static void testForPopulateBrandUseddd() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        List<Case> updatedCaseList = new List<Case>();
        List<Case> caseListToDelete = new List<Case>();
        List<Case> caseListToAssert = new List<Case>();
        List<Contact> conListToAssert = new List<Contact>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id from Contact limit 1];
        conList[0].FirstCallDate__c = System.today() + 5;
        conList[0].LastCallDate__c = System.today() - 5;
        update conList;
        
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        
     
        
          Affiliate_Value__c af1 = new Affiliate_Value__c();
        af1.Name = 'Success Test';
        af1.AffiliateValue__c = 'Success Test';
        af1.Market__c = 'PH';
        af1.Active__c = true;
        insert af1;
        
        
      
         Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
        ca1.ContactId = conList[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'Completed';
        ca1.AccountId = a1.Id;
        ca1.CallRegarding__c = conList[0].Id;
        ca1.Campaign__c = camp1.Id;
        ca1.CallOutcome__c = 'Successful';
        ca1.SuccessfulReason__c = af1.Id;
     
        
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(2);
        lProduct[0].AvailableBrandRelationship__c = true;
        lProduct[0].AvailableForCurrentAndPreviousBrand__c = true;
        lProduct[0].CompetitorProduct__c = false;
        lProduct[1].AvailableForCurrentAndPreviousBrand__c = true;
        update lProduct;
        
        
        
        BrandRelationship__c brand = new BrandRelationship__c();                
        brand.Type__c = 'Lead';
        brand.Status__c = 'Contacted';            
        brand.BrandRelationship__c = lProduct[0].Id;
        brand.User__c =  [Select Id from Contact Limit 1].Id;
        brand.PrimaryContact__c = [Select Id from Contact Limit 1].Id;   
        brand.Active__c = true;
        brand.CurrentBrand__c = null;
        brand.PreviousBrand__c = null;
        
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {
            test.StartTest();
            
            insert ca1;
            insert brand;
            
            ca1.ConvertedBR__c = null;
            update ca1;
            test.StopTest();
        }
        
        Case ca2 = [select Id, CurrentBrandUsed__c, PreviousBrandUsed__c from Case where Id = :ca1.Id];
         
        System.assertEquals(null, ca2.CurrentBrandUsed__c);
        System.assertEquals(null, ca2.PreviousBrandUsed__c);
    }
    
    @isTest
    static void testForPopulateBrandSwitch() {
        User sysad = [Select Id, Market__c From User where LastName = 'tstSysAd'];
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Id srRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('Successful_Reason').getRecordTypeId();
        Id bsRRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('BrandSwitchReason').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        List<Case> updatedCaseList = new List<Case>();
        List<Case> caseListToDelete = new List<Case>();
        List<Case> caseListToAssert = new List<Case>();
        List<Contact> conListToAssert = new List<Contact>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id from Contact limit 1];
        conList[0].FirstCallDate__c = System.today() + 5;
        conList[0].LastCallDate__c = System.today() - 5;
        update conList;
        
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        
        Affiliate_Value__c af1 = new Affiliate_Value__c();
        af1.Name = 'Success Test';
        af1.AffiliateValue__c = 'Success Test';
        af1.Market__c = 'PH';
        af1.Active__c = true;
        insert af1;
        
        Affiliate_Value__c af2 = new Affiliate_Value__c();
        af2.Name = 'No Idea';
        af2.AffiliateValue__c = 'No Idea';
        af2.Market__c = 'PH';
        af2.Active__c = true;
        af2.RecordTypeId = bsRRTId;
        insert af2;
        
        System.debug('switch T:: ' + [SELECT Name, Market__c, Active__c FROM Affiliate_Value__c WHERE Id =: af2.Id]);
        
        Case ca1 = new Case();
        ca1.RecordtypeId = callRTId;
        ca1.ContactId = conList[0].Id;
        ca1.CallType__c = 'Outbound';
        ca1.Status = 'Completed';
        ca1.AccountId = a1.Id;
        ca1.CallRegarding__c = conList[0].Id;
        ca1.Campaign__c = camp1.Id;
        ca1.CallOutcome__c = 'Successful';
        ca1.SuccessfulReason__c = af1.Id;
        //caseList.add(ca1);
        BrandRelationship__c brand = new BrandRelationship__c();  
        System.runAs(sysad) {
            Test.startTest();
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(5);
            lProduct[0].AvailableBrandRelationship__c = true;
            lProduct[0].AvailableForCurrentAndPreviousBrand__c = true;
            lProduct[0].CompetitorProduct__c = false;
            lProduct[1].AvailableBrandRelationship__c = true;
            lProduct[1].AvailableForCurrentAndPreviousBrand__c = true;
            lProduct[1].CompetitorProduct__c = false;
            lProduct[2].AvailableBrandRelationship__c = true;
            lProduct[2].AvailableForCurrentAndPreviousBrand__c = true;
            lProduct[2].CompetitorProduct__c = false;
            lProduct[3].ProductHierarchyLevel__c = 'Product';
            lProduct[4].ProductHierarchyLevel__c = 'Product';
            update lProduct;
            system.debug('lProduct[0]: ' + lProduct[0]);
            
            
            brand.Type__c = 'Lead';
            brand.Status__c = 'Contacted';            
            brand.BrandRelationship__c = lProduct[0].Id;
            brand.User__c =  [Select Id from Contact Limit 1].Id;
            brand.PrimaryContact__c = [Select Id from Contact Limit 1].Id;   
            brand.Active__c = true;
            brand.CurrentBrand__c = lProduct[0].Id;
            brand.PreviousBrand__c = lProduct[1].Id;
            brand.SKU__c = lProduct[3].Id;
            insert brand;
            
            Channel__c chan = TestDataFactory.createTestChannel(1)[0];
            ChannelResponse__c cr = TestDataFactory.createTestChannelResponse(brand, chan);
            
            
            
            
            ca1.RelatedChannelResponse__c = cr.Id;
            ca1.RelatedBrandRelationship__c = brand.Id;
            insert ca1;
            Test.getEventBus().deliver();
            
            ca1.BrandSwitchReason__c = af2.Id;
            ca1.CurrentBrandUsed__c = lProduct[1].Id;
            ca1.PreviousBrandUsed__c = lProduct[2].Id;
            ca1.SKU__c = lProduct[4].Id;
            update ca1;
            
            Test.stopTest();
            Test.getEventBus().deliver();
        }
        
        brand = [SELECT CurrentBrand__c, PreviousBrand__c, BrandSwitchReason__c, SKU__c FROM BrandRelationship__c WHERE Id =: brand.Id];
        System.assertEquals(ca1.CurrentBrandUsed__c, brand.CurrentBrand__c);
        System.assertEquals(ca1.PreviousBrandUsed__c, brand.PreviousBrand__c);
        System.assertEquals(ca1.BrandSwitchReason__c, brand.BrandSwitchReason__c);
        System.assertEquals(ca1.SKU__c, brand.SKU__c);
    }
    
    @isTest
    static void testEmailToCase() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inquiry').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        con.FirstCallDate__c = System.today() + 5;
        con.LastCallDate__c = System.today() - 5;
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = 'New';
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        
        Test.startTest();
        insert c;
        Test.stopTest();
        Test.getEventBus().deliver();
        
        c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        System.assertEquals(con.id, c.ContactId);
        System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method2() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inquiry').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        con.FirstCallDate__c = System.today() + 5;
        con.LastCallDate__c = System.today() - 5;
       
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = feedbackRTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
         c.ContactId = con.id;
         c.AbbottAwarenessDate__c = System.today();
        insert c;
        
        Test.startTest();
        //c.RecordtypeId = feedbackRTId;
        //update c;
       // insert c;
        Test.stopTest();
        Test.getEventBus().deliver();
        
        c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method3() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        //UserRole uRole = [SELECT Id FROM UserRole WHERE Name =: 'ANI - Philippines'];
        //User sysad = TestDataFactory.createUser('PH - ANI Call Center Agent', 'abcd89' , 'PH');
        //sysad.UserRoleId = uRole.Id;
        //insert sysad;
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        con.FirstCallDate__c = System.today() + 5;
        con.LastCallDate__c = System.today() - 5;
        con.FirstCall__c = null;
        con.LatestCall__c = null;
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
        c.ContactId = con.id;
        insert c;
        
        Test.startTest();
        //System.runAs(sysad) {
        try {
            c.OwnerId = UserInfo.getUserId();
            c.RecordtypeId = feedbackRTId;
            //c.IsSocialCase__c = false;
            c.Status = 'Closed - Reviewed';
            c.Description = 'wdwd';
            update c;
            //insert m;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        //  }
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method4() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inquiry').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        //List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        //List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        con.FirstCallDate__c = System.today() + 5;
        con.LastCallDate__c = System.today() - 5;
        con.Email = 'test@test.com';
        con.MB_Mobile__c = '918899009988';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = feedbackRTId;
        c.CallType__c = 'Outbound';
        c.Status = 'New';
        c.Origin = Label.WHATSAPP_ORIGIN;//'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.ContactPhone__c = '918899009988';
        //c.EscalatedTo__c = createTestRegion[0].Id;
        //c.StoreWherePurchased__c = createTestChannel[0].Id;
        try {
            insert c;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.startTest();
        //c.RecordtypeId = feedbackRTId;
        //update c;
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method5() {
        Id RTIdcall = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inquiry').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        //List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, entry.Product2Id);
        //List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        //List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        con.FirstCallDate__c = System.today() + 5;
        con.LastCallDate__c = System.today() - 5;
        con.Email = 'test@test.com';
        con.MB_Mobile__c = '918899009988';
        update con;
        
        PricebookEntry entry = TestDataFactory.createPricebookEntry();
        Insert entry;
        
        List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, con.Id, entry.Product2Id);
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = 'New';
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.ContactPhone__c = '918899009988';
        c.ConvertedBR__c = lBrand[0].Id;
        //c.EscalatedTo__c = createTestRegion[0].Id;
        //c.StoreWherePurchased__c = createTestChannel[0].Id;
        //try {
        insert c;
        //} catch(DmlException e) {
        //System.debug('The following exception has occurred: ' + e.getMessage());
        //}
        Test.startTest();
        //c.RecordtypeId = feedbackRTId;
        //update c;
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method6() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        //UserRole uRole = [SELECT Id FROM UserRole WHERE Name =: 'ANI - Philippines'];
        //User sysad = TestDataFactory.createUser('PH - ANI Call Center Agent', 'abcd89' , 'PH');
        //sysad.UserRoleId = uRole.Id;
        //insert sysad;
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        con.FirstCallDate__c = System.today() + 5;
        con.LastCallDate__c = System.today() - 5;
        con.FirstCall__c = null;
        con.LatestCall__c = null;
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
        c.ContactId = con.id;
        insert c;
        
        Test.startTest();
        //System.runAs(sysad) {
        try {
            c.OwnerId = UserInfo.getUserId();
            c.RecordtypeId = RTId;
            //c.IsSocialCase__c = false;
            c.Status = 'Closed - Reviewed';
            c.Description = 'wdwd';
            update c;
            //insert m;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        //  }
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method7() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        //UserRole uRole = [SELECT Id FROM UserRole WHERE Name =: 'ANI - Philippines'];
        //User sysad = TestDataFactory.createUser('PH - ANI Call Center Agent', 'abcd89' , 'PH');
        //sysad.UserRoleId = uRole.Id;
        //insert sysad;
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        BrandRelationship__c br = [SELECT Id FROM BrandRelationship__c LIMIT 1];
        con.FirstCallDate__c = System.today() + 5;
        con.LastCallDate__c = System.today() - 5;
        con.FirstCall__c = null;
        con.LatestCall__c = null;
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
        c.ContactId = con.id;
        c.ConvertedBR__c = br.Id;
        insert c;
        
        Test.startTest();
        //System.runAs(sysad) {
        try {
            c.OwnerId = UserInfo.getUserId();
            c.RecordtypeId = RTId;
            //c.IsSocialCase__c = false;
            c.Status = 'Closed - Reviewed';
            c.Description = 'wdwd';
            c.ReminderStatus__c = 'Initial Response';
            update c;
            
            delete c;
            //insert m;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        //  }
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method8() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        User sysad = [SELECT Id, Username FROM USER WHERE Username = 'tstSysAd@test.com'];
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        BrandRelationship__c br = [SELECT Id FROM BrandRelationship__c WHERE Market__c = 'TW' LIMIT 1];
        List<Campaign> camps = [SELECT Id FROM Campaign WHERE Market__c = 'TW' LIMIT 2];
        ChannelResponse__c cr = [SELECT Id FROM ChannelResponse__c LIMIT 1];
        con.FirstCallDate__c = null;
        con.LastCallDate__c = null;
        con.FirstCall__c = null;
        con.LatestCall__c = null;
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
        c.ContactId = con.id;
        c.ConvertedBR__c = br.Id;
        c.RelatedCampaign__c = camps[0].Id;
        insert c;
        
        Test.startTest();
        System.runAs(sysad) {
            try {
                c.OwnerId = UserInfo.getUserId();
                c.RecordtypeId = RTId;
                //c.IsSocialCase__c = false;
                c.Status = 'Closed - Reviewed';
                c.Description = 'wdwd';
                c.ReminderStatus__c = 'Initial Response';
                c.RelatedCampaign__c = camps[1].Id;
                c.RelatedChannelResponse__c = cr.Id;
                update c;
                //insert m;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method9() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        User sysad = [SELECT Id, Username FROM USER WHERE Username = 'tstSysAd@test.com'];
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        BrandRelationship__c br = [SELECT Id FROM BrandRelationship__c WHERE Market__c = 'SG' LIMIT 1];
        List<Campaign> camps = [SELECT Id FROM Campaign LIMIT 2];
        System.assertEquals(2, camps.size(), 'It is supposed to have 2.');
        
        ChannelResponse__c cr = [SELECT Id FROM ChannelResponse__c LIMIT 1];
        con.FirstCallDate__c = null;
        con.LastCallDate__c = null;
        con.FirstCall__c = null;
        con.LatestCall__c = null;
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
        c.ContactId = con.id;
        c.ConvertedBR__c = br.Id;
        c.RelatedCampaign__c = camps[0].Id;
        c.Market__c = 'SG';
        insert c;
        
        Test.startTest();
        System.runAs(sysad) {
            try {
                c.OwnerId = UserInfo.getUserId();
                c.RecordtypeId = RTId;
                //c.IsSocialCase__c = false;
                c.Status = 'Closed - Reviewed';
                c.Description = 'wdwd';
                c.ReminderStatus__c = 'Initial Response';
                c.RelatedCampaign__c = camps[1].Id;
                c.RelatedChannelResponse__c = cr.Id;
                c.Market__c = 'SG';
                update c;
                //insert m;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method10() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        User sysad = [SELECT Id, Username FROM USER WHERE Username = 'tstSysAd@test.com'];
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        BrandRelationship__c br = [SELECT Id FROM BrandRelationship__c WHERE Market__c = 'TW' LIMIT 1];
        List<Campaign> camps = [SELECT Id FROM Campaign WHERE Market__c = 'TW' LIMIT 2];
        con.FirstCallDate__c = null;
        con.LastCallDate__c = null;
        con.FirstCall__c = null;
        con.LatestCall__c = null;
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
        c.ContactId = con.id;
        c.ConvertedBR__c = br.Id;
        c.RelatedCampaign__c = camps[0].Id;
        c.Market__c = 'TW';
        insert c;
        
        Test.startTest();
        System.runAs(sysad) {
            try {
                c.OwnerId = UserInfo.getUserId();
                c.RecordtypeId = RTId;
                //c.IsSocialCase__c = false;
                c.Status = 'Closed - Reviewed';
                c.Description = 'wdwd';
                c.ReminderStatus__c = 'Initial Response';
                c.RelatedCampaign__c = camps[1].Id;
                c.RelatedChannelResponse__c = null;
                c.Market__c = 'TW';
                update c;
                //insert m;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method11() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        User sysad = [SELECT Id, Username FROM USER WHERE Username = 'tstSysAd@test.com'];
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        BrandRelationship__c br = [SELECT Id FROM BrandRelationship__c WHERE Market__c = 'TW' LIMIT 1];
        List<Campaign> camps = [SELECT Id FROM Campaign WHERE Market__c = 'TW' LIMIT 2];
        con.FirstCallDate__c = null;
        con.LastCallDate__c = null;
        con.FirstCall__c = null;
        con.LatestCall__c = null;
        con.Email = 'test@test.com';
        update con;
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
        c.ContactId = con.id;
        c.RelatedCampaign__c = camps[0].Id;
        c.Market__c = 'TW';
        c.ConvertedBR__c = br.Id;
        insert c;
        
        Test.startTest();
        System.runAs(sysad) {
            try {
                c.OwnerId = UserInfo.getUserId();
                c.RecordtypeId = RTId;
                //c.IsSocialCase__c = false;
                c.Status = 'Closed - Reviewed';
                c.Description = 'wdwd';
                c.ReminderStatus__c = 'Initial Response';
                c.RelatedCampaign__c = '7011y0000003Jm2AAE';
                c.RelatedChannelResponse__c = null;
                c.Market__c = 'TW';
                c.ConvertedBR__c = null;
                update c;
                //insert m;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
    
    @isTest
    static void Method12() {
        Id RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Group  q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Feedback and Inquiry - IN'];
        Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
        List<Affiliate_Value__c> createTestRegion = TestDataFactory.createTestRegion(1);
        List<Channel__c> createTestChannel = TestDataFactory.createTestChannel(1);
        User sysad = [SELECT Id, Username FROM USER WHERE Username = 'tstSysAd@test.com'];
        
        Account a1 = [select Id from Account limit 1];
        Contact con = [select Id from Contact limit 1];
        BrandRelationship__c br = [SELECT Id FROM BrandRelationship__c WHERE Market__c = 'TW' LIMIT 1];
        List<Campaign> camps = [SELECT Id FROM Campaign WHERE Market__c = 'TW' LIMIT 2];
        
        Test.startTest();
        List<Affiliate_Value__c> affList = new List<Affiliate_Value__c>();
        affList.add(TestDataFactory.createTestCity(1)[0]);
        affList.add(createTestRegion[0]);
        affList[0].Market__c = 'TW';
        affList[1].Market__c = 'TW';
        update affList;
        
        List<Address__c> affList2 = new List<Address__c>();
        affList2.add(TestDataFactory.createTestDefaultAddressNoInsert(1, con.Id, affList.get(1).Id, affList.get(0).Id, 'Taiwan')[0]);
        insert affList2;
        
        Address__c addr = [SELECT Id FROM Address__c LIMIT 1];
        con.FirstCallDate__c = null;
        con.LastCallDate__c = null;
        con.FirstCall__c = null;
        con.LatestCall__c = null;
        con.Email = 'test@test.com';
        con.Default_Address__c = addr.Id;
        update con;
        
        List<Case> caseToInsert = new List<Case>();  
        
        Case c = new Case();
        c.RecordtypeId = RTId;
        c.CallType__c = 'Outbound';
        c.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c.Origin = 'Email';
        c.SuppliedEmail = 'test@test.com';
        c.OwnerId = q.Id;
        c.EscalatedTo__c = createTestRegion[0].Id;
        c.StoreWherePurchased__c = createTestChannel[0].Id;
        c.ContactId = con.id;
        c.RelatedCampaign__c = camps[0].Id;
        c.Market__c = 'TW';
        caseToInsert.add(c);

		   
        Case c1 = new Case();
        c1.RecordtypeId = RTId;
        c1.CallType__c = 'Outbound';
        c1.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c1.Origin = Label.WHATSAPP_ORIGIN;
        c1.SuppliedEmail = 'test@test.com';
        c1.OwnerId = q.Id;
        c1.EscalatedTo__c = createTestRegion[0].Id;
        c1.StoreWherePurchased__c = createTestChannel[0].Id;
        //c1.ContactId = con.id;
        c1.RelatedCampaign__c = camps[0].Id;
        c1.Market_MessageBird__c = 'ID';
        caseToInsert.add(c1);
        
        Case c2 = new Case();
        c2.RecordtypeId = RTId;
        c2.CallType__c = 'Outbound';
        c2.Status = CommonConstant.CASE_STATUS_ESCALATED;
        c2.Origin = Label.WHATSAPP_ORIGIN;
        c2.SuppliedEmail = 'test@test.com';
        c2.OwnerId = q.Id;
        c2.EscalatedTo__c = createTestRegion[0].Id;
        c2.StoreWherePurchased__c = createTestChannel[0].Id;
        //c1.ContactId = con.id;
        c2.RelatedCampaign__c = camps[0].Id;
        c2.Market_MessageBird__c = 'IN';
        caseToInsert.add(c2);
        
        insert caseToInsert;
        
        System.runAs(sysad) {
            try {
                c.OwnerId = UserInfo.getUserId();
                c.RecordtypeId = RTId;
                //c.IsSocialCase__c = false;
                c.Status = 'Closed - Reviewed';
                c.Description = 'wdwd';
                c.ReminderStatus__c = 'Initial Response';
                c.RelatedCampaign__c = camps[1].Id;
                c.RelatedChannelResponse__c = null;
                c.Market__c = 'TW';
                update c;
                //insert m;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        Test.stopTest();
        Test.getEventBus().deliver();
        
        //c = [SELECT Market__c, ContactId, AccountId FROM Case Limit 1];
        //System.assertEquals(con.id, c.ContactId);
        //System.assertEquals(a1.id, c.AccountId);
    }
}