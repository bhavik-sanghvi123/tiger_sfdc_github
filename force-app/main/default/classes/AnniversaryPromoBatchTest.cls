@isTest
public class AnniversaryPromoBatchTest {
    static testMethod void testMethod1() 
    {
           
        List<Account> account = TestDataFactory.createTestHousehold(1);
        account.get(0).Market__c = 'TW';
        update account;
        
        Datetime lastYear = Datetime.now().addDays(-365);
        

        List<Contact> contact = TestDataFactory.createTestAdultContact(1, account.get(0).Id);
        contact[0].Total_Purchase_Anniversary_Amount_Adult__c = 400000;
        contact[0].FirstTransactionDate__c = system.today();
        Test.setCreatedDate(contact[0].Id, lastYear); 
        update contact;
        
        Test.startTest();

            AnniversaryPromoBatch obj = new AnniversaryPromoBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    public static testMethod void testschedule() {

        Test.StartTest();
        AnniversaryPromoBatchScheduler sh1 = new AnniversaryPromoBatchScheduler();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
}