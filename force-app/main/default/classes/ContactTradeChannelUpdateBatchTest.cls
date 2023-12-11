/*************************************************************************************************
* @author         Monika Parihar
* @date           11/08/2021
* @description    Test class for ContactTradeChannelUpdateBatch
* @revision(s)
************************************************************************************************/
@isTest
public class ContactTradeChannelUpdateBatchTest {
     /*************************************************************************************************
    * @author         Monika Parihar
    * @date           12/08/2021
    * @description    Method to Test batch class ContactTradeChannelUpdateBatch
    ************************************************************************************************/
    static testMethod void contactTradeChannelUpdateBatchTestMethod() 
    {
           
        List<Account> account = TestDataFactory.createTestHousehold(1);
        account.get(0).Market__c = 'TW';
        update account;
        
        Datetime lastYear = Datetime.now().addDays(-365);
        

        List<Contact> contact = TestDataFactory.createTestAdultContact(1, account.get(0).Id);
        
        List<BrandRelationship__c> brandRelationship = TestDataFactory.createTestBrandRelationShip(1, contact.get(0).Id,null);
        
        List<Channel__c> channel = TestDataFactory.createTestChannel(1);
        channel.get(0).Market__c = 'TW';
        channel.get(0).Name = 'Trade_BrandSwitch_PED';
        update channel;
        
        ChannelResponse__c channelResponse = TestDataFactory.createTestChannelResponse(brandRelationship.get(0),channel.get(0));
       
        
        Test.startTest();

            ContactTradeChannelUpdateBatch obj = new ContactTradeChannelUpdateBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    /*************************************************************************************************
    * @author         Monika Parihar
    * @date           11/08/2021
    * @description    Method to Test  class ContactTradeChannelUpdateBatchScheduler
    ************************************************************************************************/
    public static testMethod void testschedule() {

        Test.StartTest();
        ContactTradeChannelUpdateBatchScheduler sh1 = new ContactTradeChannelUpdateBatchScheduler();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
}