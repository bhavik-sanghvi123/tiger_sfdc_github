/*************************************************************************************************
* @author         Monika Parihar
* @date           11/08/2021
* @description    Class to execute batch job ContactTradeChannelUpdateBatch
* @testClass      ContactTradeChannelUpdateBatchTest
* @revision(s)
************************************************************************************************/
global class ContactTradeChannelUpdateBatchScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    ContactTradeChannelUpdateBatch b = new ContactTradeChannelUpdateBatch();
    Database.ExecuteBatch(b, 200);
  }
}