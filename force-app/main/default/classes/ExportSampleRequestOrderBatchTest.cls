/*
* @author        Crissar Ibarra
* @date          8.27.2021
* @description   Test class for ExportSampleRequestOrderBatchScheduler and ExportSampleRequestOrderBatch
* @revision(s) 
*/
@isTest
private class ExportSampleRequestOrderBatchTest {
  
  @testsetup
    static void setupData() {
      User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {                       
            List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount.get(0).Market__c = 'SG';
            Update lAccount;

            List<Contact> lContact = TestDataFactory.createSGTestAdultContact(1, lAccount.get(0).Id);
            PricebookEntry entry = TestDataFactory.createPricebookEntry('SG');
            Insert entry;

            List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
            Insert lOrder;   
            Test.setCreatedDate(lOrder.get(0).Id, DateTime.now().addDays(-1));       
            
            OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
            insert item;

            lOrder.get(0).Status = CommonConstant.ORDER_STATUS_SUBMITTED;
            update lOrder;
            
            List<OrderExport2__c> oeList = TestDataFactory.createOE(1, lOrder);
            insert oeList;
        }
    }

  @isTest static void test_exportBatch() {    
    
    List<OrderExport2__c> oeList = [SELECT ID FROM OrderExport2__c];
    
    Datetime yesterday = DateTime.now().addDays(-1);
    
    for(OrderExport2__c oe : oeList){
        Test.setCreatedDate(oe.id,yesterday);
    }
    
    System.Test.startTest();
        ExportSampleRequestOrderBatch ucs = new ExportSampleRequestOrderBatch();
        Database.executeBatch(ucs, 200);
    System.Test.stopTest();

      List<ContentVersion> contentList = [SELECT Id, ContentDocumentId FROM ContentVersion];
        //txt file and csv
      System.assertEquals(1, contentList.size());      
  }
  
  @isTest static void test_scheduler() {
    // Implement test code
    ExportSampleRequestOrderBatchScheduler job = new ExportSampleRequestOrderBatchScheduler();
    String sch = '0 0 23 * * ?'; 
    Id scID = System.schedule('Test Export Order Batch Job', sch, job);

    CronTrigger ct = [SELECT Id,
                          CronExpression,
                          TimesTriggered,
                          NextFireTime                          
                          FROM CronTrigger
                          WHERE Id = : scID];
       
        
  }
  
}