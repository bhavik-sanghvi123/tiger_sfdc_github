@isTest
private class UpdateAgeRangeBatchTest {

    @testsetup
    static void setupData() {
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);
        
        List<Contact> conToInsert1 = new List<Contact>();
		Id childRT = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        
        Contact con1 = new Contact();
        con1.LastName = 'LastName - wa1';        
        con1.AccountId = lAccount[0].Id;
        con1.RecordTypeId = childRT;
        con1.Phone =  '02837746553';
        con1.Type__c = 'Child';
        con1.Birthdate = System.today().addMonths(-12);
        
        Contact con2 = new Contact();
        con2.LastName = 'LastName - wa2';        
        con2.AccountId = lAccount[0].Id;
        con2.RecordTypeId = childRT;
        con2.Phone =  '02837746554';
        con2.Type__c = 'Child';
        con2.Birthdate = System.today().addMonths(-24);
        
        Contact con3 = new Contact();
        con3.LastName = 'LastName - wa3';        
        con3.AccountId = lAccount[0].Id;
        con3.RecordTypeId = childRT;
        con3.Phone =  '02837746555';
        con3.Type__c = 'Child';
        con3.Birthdate = System.today().addMonths(-36);
        
        Contact con4 = new Contact();
        con4.LastName = 'LastName - wa4';        
        con4.AccountId = lAccount[0].Id;
        con4.RecordTypeId = childRT;
        con4.Phone =  '02837746556';
        con4.Type__c = 'Child';
        con4.Birthdate = System.today().addMonths(-48);
        
        Contact con5 = new Contact();
        con5.LastName = 'LastName - wa5';        
        con5.AccountId = lAccount[0].Id;
        con5.RecordTypeId = childRT;
        con5.Phone =  '02837746557';
        con5.Type__c = 'Child';
        con5.Birthdate = System.today().addMonths(-60);
        
        Contact con6 = new Contact();
        con6.LastName = 'LastName - wa6';        
        con6.AccountId = lAccount[0].Id;
        con6.RecordTypeId = childRT;
        con6.Phone =  '02837746558';
        con6.Type__c = 'Child';
        con6.Birthdate = System.today().addMonths(-72);
        
        Contact con1b = new Contact();
        con1b.LastName = 'LastName - wa7';        
        con1b.AccountId = lAccount[0].Id;
        con1b.RecordTypeId = childRT;
        con1b.Phone =  '02837746513';
        con1b.Type__c = 'Child';
        con1b.AgeRange__c = '1-2 Years';
        
        Contact con2b = new Contact();
        con2b.LastName = 'LastName - wa8';        
        con2b.AccountId = lAccount[0].Id;
        con2b.RecordTypeId = childRT;
        con2b.Phone =  '02837746514';
        con2b.Type__c = 'Child';
        con2b.AgeRange__c = '2-3 Years';
        
        Contact con3b = new Contact();
        con3b.LastName = 'LastName - wa9';        
        con3b.AccountId = lAccount[0].Id;
        con3b.RecordTypeId = childRT;
        con3b.Phone =  '02837746515';
        con3b.Type__c = 'Child';
        con3b.AgeRange__c = '3-4 Years';
        
        Contact con4b = new Contact();
        con4b.LastName = 'LastName - wa10';        
        con4b.AccountId = lAccount[0].Id;
        con4b.RecordTypeId = childRT;
        con4b.Phone =  '02837746516';
        con4b.Type__c = 'Child';
        con4b.AgeRange__c = '4-5 Years';
        
        Contact con5b = new Contact();
        con5b.LastName = 'LastName - wa11';        
        con5b.AccountId = lAccount[0].Id;
        con5b.RecordTypeId = childRT;
        con5b.Phone =  '02837746517';
        con5b.Type__c = 'Child';
        con5b.AgeRange__c = '5-6 Years';
        
        Contact con6b = new Contact();
        con6b.LastName = 'LastName - wa12';        
        con6b.AccountId = lAccount[0].Id;
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
        
        Contact con7 = new Contact();
        con7.LastName = 'LastName - wa13';        
        con7.AccountId = lAccount[0].Id;
        con7.RecordTypeId = childRT;
        con7.Phone =  '02837746529';
        con7.Type__c = 'Child';
        con7.Birthdate = System.today().addMonths(-72);
        insert con7;
        con7.AgeRange__c = '5-6 Years';
        update con7;
    }
    
    public static testMethod void executeBatch() {
        Test.startTest();
			UpdateAgeRangeBatch uarb = new UpdateAgeRangeBatch();
            Database.executeBatch(uarb, 200);

            UpdateAgeRangeBatchScheduler uarbs = new UpdateAgeRangeBatchScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test UpdateAgeRangeBatch Job', sch, uarbs);
        Test.stopTest();
    }
}