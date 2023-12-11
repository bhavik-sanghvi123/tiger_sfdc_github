@isTest 
public class ContactTriggerHelperTest{
    
    @testsetup
    static void setupData() {
        Test.enableChangeDataCapture();
        
        //Create Household record
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);
        
        //Create Primary Child Contact Record
        List<Contact> primaryChildCon = TestDataFactory.createTestChildContact(1, lAccount.get(0).Id);
        Test.getEventBus().deliver();
        primaryChildCon[0].PrimaryContact__c = TRUE;
        update primaryChildCon[0];
        Test.getEventBus().deliver();
        
        //Create Non-Primary Child Contact Record
        List<Contact> nonPrimaryAdultCon = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        Test.getEventBus().deliver();
        nonPrimaryAdultCon[0].Phone = '97582353212';
        update nonPrimaryAdultCon[0];
        Test.getEventBus().deliver();
    }
    
    private static testMethod void updateTrackingOnInsert() {
        Test.enableChangeDataCapture();
        
        Id householdId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Account acc = [Select NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                       NumberOfAdults__c, NumberOfChildren__c
                       FROM Account WHERE Id =: householdId];
        
        Contact initialCon = [SELECT Id, PrimaryContact__c FROM Contact LIMIT 1];
        initialCon.PrimaryContact__c = FALSE;
        update initialCon;
        Test.getEventBus().deliver();
        
        System.Test.startTest();
        //Create Primary Child Contact Record
        List<Contact> primaryChildCon = TestDataFactory.createTestChildContact(1, householdId);
        primaryChildCon[0].PrimaryContact__c = TRUE;
        update primaryChildCon[0];
        Test.getEventBus().deliver();
        
        //Create Adult Contact Record
        List<Contact> primaryAdultCon = TestDataFactory.createTestAdultContact(1, householdId);
        primaryAdultCon[0].PrimaryContact__c = FALSE;
        update primaryAdultCon[0];
        Test.getEventBus().deliver();
        
        Contact milkContact = new Contact();
        milkContact.Type__c = 'Child';
        milkContact.LastName = 'ChildMilk';
        milkContact.AccountId = householdId;
        milkContact.Parent__c = primaryAdultCon[0].Id;
        milkContact.Birthdate = Date.today();
        insert milkContact;
        Test.getEventBus().deliver();
        
        System.Test.stopTest();
        
        Account updatedAccount = [Select NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                                  NumberOfAdults__c, NumberOfChildren__c
                                  FROM Account WHERE Id =: householdId];
        
        System.assertEquals(acc.NumberOfHouseholdMembers__c + 3, updatedAccount.NumberOfHouseholdMembers__c, 'Number of Household Members should be incremented by 3');
        System.assertEquals(acc.NumberOfPrimaryContacts__c, updatedAccount.NumberOfPrimaryContacts__c, 'Number of Primary Contacts should remain as 1');
        System.assertEquals(acc.NumberOfChildren__c + 2, updatedAccount.NumberOfChildren__c, 'Number of Children should be incremented by 2');
        System.assertEquals(acc.NumberOfAdults__c + 1, updatedAccount.NumberOfAdults__c, 'Number of Adults should be incremented by 1');
    }
    
    
    private static testMethod void updateTrackingOnUpdate() {
        Test.enableChangeDataCapture();
        
        Account acc = [Select NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                       NumberOfAdults__c, NumberOfChildren__c
                       FROM Account LIMIT 1];
        
        Contact con = [SELECT Id, LastName, Type__c, PrimaryContact__c FROM Contact WHERE Type__c = 'Child' LIMIT 1];
        con.LastName = 'Adult';
        con.Type__c = 'Adult';
        con.PrimaryContact__c = FALSE;
        con.Verified__c = true;
        
        Contact con2 = [SELECT Id, LastName, Type__c, PrimaryContact__c FROM Contact WHERE Type__c = 'Adult' LIMIT 1];
        con2.LastName = 'Child';
        con2.Type__c = 'Child';
        con2.PrimaryContact__c = TRUE;
        con2.PrimaryCarer__c = con.Id;
        con2.Birthdate = Date.today();
        
        System.Test.startTest();
        update con;
        Test.getEventBus().deliver();
        update con2;
        Test.getEventBus().deliver();
        System.Test.stopTest();
        
        Account updatedAccount = [Select NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                                  NumberOfAdults__c, NumberOfChildren__c,ChildrenUnderMilkCodeRestriction__c
                                  FROM Account LIMIT 1];
        
        System.assertEquals(acc.NumberOfHouseholdMembers__c, updatedAccount.NumberOfHouseholdMembers__c, 'Number of Household Members should be retained');
        System.assertEquals(acc.NumberOfPrimaryContacts__c, updatedAccount.NumberOfPrimaryContacts__c, 'Number of Primary Contacts should be retained');
        System.assertEquals(acc.NumberOfChildren__c, updatedAccount.NumberOfChildren__c, 'Number of Children should be retained');
        System.assertEquals(acc.NumberOfAdults__c, updatedAccount.NumberOfAdults__c, 'Number of Adults should be retained');
        //System.assertEquals(1, updatedAccount.ChildrenUnderMilkCodeRestriction__c, 'Number of Childer with milk code should be increment by 1');
    }
    
    private static testMethod void updateTrackingOnDelete() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) { 
            Test.enableChangeDataCapture();
            
            List<Contact> conListforDelete = [SELECT Id, LastName, Type__c, PrimaryContact__c FROM Contact LIMIT 2];
            Account acc = [Select NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                           NumberOfAdults__c, NumberOfChildren__c
                           FROM Account LIMIT 1];
            
            
            delete conListforDelete;
            Test.getEventBus().deliver();
            
            Account updatedAccount = [Select NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                                      NumberOfAdults__c, NumberOfChildren__c
                                      FROM Account LIMIT 1];
            
            System.assertEquals(acc.NumberOfHouseholdMembers__c - 2, updatedAccount.NumberOfHouseholdMembers__c, 'Number of Household Members should be decremented by 1');
            System.assertEquals(acc.NumberOfPrimaryContacts__c - 1, updatedAccount.NumberOfPrimaryContacts__c, 'Number of Primary Contacts should be decremented by 1');
            System.assertEquals(acc.NumberOfChildren__c - 1, updatedAccount.NumberOfChildren__c, 'Number of Children should be decremented by 1');
            System.assertEquals(acc.NumberOfAdults__c - 1, updatedAccount.NumberOfAdults__c, 'Number of Adults should be decremented by 1');
        }
    }
    
    private static testMethod void testForPopulateAgeRange() {
        Test.enableChangeDataCapture();
        List<Contact> conToInsert1 = new List<Contact>();
        Id childRT = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        
        Account acc1 = [select Id from Account limit 1];
        
        Contact con1 = new Contact();
        con1.LastName = 'LastName - wa1';        
        con1.AccountId = acc1.Id;
        con1.RecordTypeId = childRT;
        con1.Phone =  '02837746553';
        con1.Type__c = 'Child';
        con1.Birthdate = System.today().addMonths(-12);
        
        Contact con2 = new Contact();
        con2.LastName = 'LastName - wa2';        
        con2.AccountId = acc1.Id;
        con2.RecordTypeId = childRT;
        con2.Phone =  '02837746554';
        con2.Type__c = 'Child';
        con2.Birthdate = System.today().addMonths(-24);
        
        Contact con3 = new Contact();
        con3.LastName = 'LastName - wa3';        
        con3.AccountId = acc1.Id;
        con3.RecordTypeId = childRT;
        con3.Phone =  '02837746555';
        con3.Type__c = 'Child';
        con3.Birthdate = System.today().addMonths(-36);
        
        Contact con4 = new Contact();
        con4.LastName = 'LastName - wa4';        
        con4.AccountId = acc1.Id;
        con4.RecordTypeId = childRT;
        con4.Phone =  '02837746556';
        con4.Type__c = 'Child';
        con4.Birthdate = System.today().addMonths(-48);
        
        Contact con5 = new Contact();
        con5.LastName = 'LastName - wa5';        
        con5.AccountId = acc1.Id;
        con5.RecordTypeId = childRT;
        con5.Phone =  '02837746557';
        con5.Type__c = 'Child';
        con5.Birthdate = System.today().addMonths(-60);
        
        Contact con6 = new Contact();
        con6.LastName = 'LastName - wa6';        
        con6.AccountId = acc1.Id;
        con6.RecordTypeId = childRT;
        con6.Phone =  '02837746558';
        con6.Type__c = 'Child';
        con6.Birthdate = System.today().addMonths(-72);
        
        Contact con1b = new Contact();
        con1b.LastName = 'LastName - wa7';        
        con1b.AccountId = acc1.Id;
        con1b.RecordTypeId = childRT;
        con1b.Phone =  '02837746513';
        con1b.Type__c = 'Child';
        con1b.AgeRange__c = '1-2 Years';
        
        Contact con2b = new Contact();
        con2b.LastName = 'LastName - wa8';        
        con2b.AccountId = acc1.Id;
        con2b.RecordTypeId = childRT;
        con2b.Phone =  '02837746514';
        con2b.Type__c = 'Child';
        con2b.AgeRange__c = '2-3 Years';
        
        Contact con3b = new Contact();
        con3b.LastName = 'LastName - wa9';        
        con3b.AccountId = acc1.Id;
        con3b.RecordTypeId = childRT;
        con3b.Phone =  '02837746515';
        con3b.Type__c = 'Child';
        con3b.AgeRange__c = '3-4 Years';
        
        Contact con4b = new Contact();
        con4b.LastName = 'LastName - wa10';        
        con4b.AccountId = acc1.Id;
        con4b.RecordTypeId = childRT;
        con4b.Phone =  '02837746516';
        con4b.Type__c = 'Child';
        con4b.AgeRange__c = '4-5 Years';
        
        Contact con5b = new Contact();
        con5b.LastName = 'LastName - wa11';        
        con5b.AccountId = acc1.Id;
        con5b.RecordTypeId = childRT;
        con5b.Phone =  '02837746517';
        con5b.Type__c = 'Child';
        con5b.AgeRange__c = '5-6 Years';
        
        Contact con6b = new Contact();
        con6b.LastName = 'LastName - wa12';        
        con6b.AccountId = acc1.Id;
        con6b.RecordTypeId = childRT;
        con6b.Phone =  '02837746518';
        con6b.Type__c = 'Child';
        con6b.AgeRange__c = '6 Years and Above';
        
        conToInsert1.add(con1);
        conToInsert1.add(con2);
        conToInsert1.add(con3);
        conToInsert1.add(con4);
        conToInsert1.add(con5);
        conToInsert1.add(con6);
        conToInsert1.add(con1b);
        conToInsert1.add(con2b);
        conToInsert1.add(con3b);
        conToInsert1.add(con4b);
        conToInsert1.add(con5b);
        conToInsert1.add(con6b);
        
        insert conToInsert1;
        Test.getEventBus().deliver();
        
        Map<String, Contact> conMap = new Map<String, Contact>();
        List<Contact> updatedContacts = new List<Contact>();
        updatedContacts = [select Id, LastName, AgeRange__c, AgeRangeUpdatedDate__c from Contact where Id in :conToInsert1];
        
        for(Contact conRec : updatedContacts) {
            conMap.put(conRec.LastName, conRec);
        }
        
        System.assertEquals('1-2 Years', conMap.get('LastName - wa1').AgeRange__c);
        System.assertEquals('2-3 Years', conMap.get('LastName - wa2').AgeRange__c);
        System.assertEquals('3-4 Years', conMap.get('LastName - wa3').AgeRange__c);
        System.assertEquals('4-5 Years', conMap.get('LastName - wa4').AgeRange__c);
        System.assertEquals('5-6 Years', conMap.get('LastName - wa5').AgeRange__c);
        System.assertEquals('6 Years and Above', conMap.get('LastName - wa6').AgeRange__c);
        System.assertEquals(System.today().addMonths(-12), conMap.get('LastName - wa7').AgeRangeUpdatedDate__c);
        System.assertEquals(System.today().addMonths(-24), conMap.get('LastName - wa8').AgeRangeUpdatedDate__c);
        System.assertEquals(System.today().addMonths(-36), conMap.get('LastName - wa9').AgeRangeUpdatedDate__c);
        System.assertEquals(System.today().addMonths(-48), conMap.get('LastName - wa10').AgeRangeUpdatedDate__c);
        System.assertEquals(System.today().addMonths(-60), conMap.get('LastName - wa11').AgeRangeUpdatedDate__c);
        System.assertEquals(System.today().addMonths(-72), conMap.get('LastName - wa12').AgeRangeUpdatedDate__c);
    }
     private static testMethod void createChildContactTWTest() {
        
        Id householdId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Account acc = [Select NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                       NumberOfAdults__c, NumberOfChildren__c
                       FROM Account WHERE Id =: householdId];
        
        //adult contact
        List<Contact> nonPrimaryAdultCon = TestDataFactory.createTestAdultContact(1, acc.Id);
        update nonPrimaryAdultCon[0];
        
        //child contact
        Contact milkContact = new Contact();
        milkContact.Type__c = 'Child';
        milkContact.LastName = 'ChildMilk';
        milkContact.AccountId = householdId;
        milkContact.Parent__c = nonPrimaryAdultCon[0].Id;
        milkContact.Birthdate = Date.today();
        insert milkContact;
        
        nonPrimaryAdultCon[0].EstimatedDueDate__c = System.today().addDays(3);
        
        System.Test.startTest();
        update nonPrimaryAdultCon[0];
        System.Test.stopTest();
    }
    
    static testMethod void testCountryPhoneUpdate() {
        Contact c = [SELECT Id, Phone, CountryCodeMobile__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE];
        Account a = [SELECT Id, Market__c FROM Account LIMIT 1];

        a.Market__c = CommonConstant.MARKET_TW;

        System.Test.startTest();
        update a;
        update c;
        System.Test.stopTest();
    }
    
    static testMethod void testResetEmailBounced() {
        Contact c = [SELECT Id, Phone, CountryCodeMobile__c FROM Contact WHERE Type__c = :CommonConstant.CONTACT_ADULT_TYPE];
        c.Email = 'test@test.com';
        c.EmailBounced__c = true;
        update c;

        System.Test.startTest();
        c.Email = 'test1@test.com';
        update c;
        System.Test.stopTest();
        
        Contact cUpdated = [SELECT Id, EmailBounced__c FROM Contact WHERE Id =: c.Id];
        System.assertEquals(cUpdated.EmailBounced__c, false);
    }
}