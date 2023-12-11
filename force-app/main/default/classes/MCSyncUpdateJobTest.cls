@isTest
public class MCSyncUpdateJobTest {
    @testSetup
    static void setup(){
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        System.runAs(sysad) {
            Account a1 = TestDataFactory.createTestHousehold(1, 'VN')[0];
            Account a2 = TestDataFactory.createTestHousehold(1, 'VN')[0];
            Contact adult1 = TestDataFactory.createContact(true, a1.Id, null, Date.parse('01/01/1990'), '0912345678');
            Contact adult2 = TestDataFactory.createContact(true, a2.Id, null, Date.parse('01/01/1991'), '0912345789');
            Contact child1 = TestDataFactory.createContact(false, a1.Id, adult1.Id, Date.today().addMonths(-8), '0911001122');
            Contact child2 = TestDataFactory.createContact(false, a2.Id, adult2.Id, Date.today().addMonths(-7), '0911001234');
        }
    }
    static testmethod void testFalseToTrue(){        
        Test.startTest();
        MCSyncUpdateJob batch = new MCSyncUpdateJob('VN', 'Adult', TRUE, 10); 
        Database.executebatch(batch, 20);
        Test.stopTest();
        
        List<Contact> conUpdated = [SELECT Id FROM Contact WHERE RecordType.Name = 'Adult' AND MC_Sync_Eligibility_VN__c = TRUE];
        System.assertEquals(conUpdated.size(), 2);
    }
    static testmethod void testTrueToFalse(){
        Contact adult1 = [SELECT Id, MC_Sync_Eligibility_VN__c FROM Contact WHERE Phone = '0912345678'];
        adult1.MC_Sync_Eligibility_VN__c = TRUE;
        update adult1;
        
        Test.startTest();
        MCSyncUpdateJob batch = new MCSyncUpdateJob('VN', 'Adult', FALSE, 10); 
        Database.executebatch(batch, 20);
        Test.stopTest();
        
        List<Contact> conUpdated = [SELECT Id FROM Contact WHERE RecordType.Name = 'Adult' AND MC_Sync_Eligibility_VN__c = FALSE];
        System.assertEquals(conUpdated.size(), 2);
    }
    static testmethod void testFalseToTrueOtherMarket(){        
        Test.startTest();
        MCSyncUpdateJob batch = new MCSyncUpdateJob('ANZ', 'Adult', TRUE, 10); 
        Database.executebatch(batch, 20);
        Test.stopTest();
        
        List<Contact> conUpdated = [SELECT Id FROM Contact WHERE RecordType.Name = 'Adult' AND MC_Sync_Eligibility_ANZ__c = TRUE];
        System.assertEquals(conUpdated.size(), 0);
    }
    static testmethod void testFalseToTrueChild(){        
        Test.startTest();
        MCSyncUpdateJob batch = new MCSyncUpdateJob('VN', 'Child', TRUE, 10); 
        Database.executebatch(batch, 20);
        Test.stopTest();
        
        List<Contact> conUpdated = [SELECT Id FROM Contact WHERE RecordType.Name = 'Child' AND MC_Sync_Eligibility_VN__c = TRUE];
        System.assertEquals(conUpdated.size(), 2);
    }
    static testmethod void test_schedule(){
        Test.startTest();
        System.schedule('MCSyncUpdateJob', '0 10 11 1/1 * ? *', new MCSyncUpdateJob('VN', 'Adult', FALSE, 5000));
        Test.stopTest();
    }
}