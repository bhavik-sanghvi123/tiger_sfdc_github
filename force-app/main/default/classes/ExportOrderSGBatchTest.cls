/*
* @author        Rey Austral
* @date          1.28.2019
* @description   Test class for ExportOrderSGBatch and ExportOrderSGBatchScheduler
* @revision(s) 
*/
@isTest
private class ExportOrderSGBatchTest {
	
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
        }
    }

	@isTest static void test_exportBatch() {		

		System.Test.startTest();
    		ExportOrderSGBatch ucs = new ExportOrderSGBatch();
    		Database.executeBatch(ucs, 200);
    	System.Test.stopTest();

    	List<ContentVersion> contentList = [SELECT Id, ContentDocumentId FROM ContentVersion];
        //txt file and csv
    	System.assertEquals(2, contentList.size());    	
	}
	
	@isTest static void test_scheduler() {
		// Implement test code
		ExportOrderSGBatchScheduler job = new ExportOrderSGBatchScheduler();
		String sch = '0 0 23 * * ?'; 
		Id scID = System.schedule('Test Export Order Batch Job', sch, job);

		CronTrigger ct = [SELECT Id,
                          CronExpression,
                          TimesTriggered,
                          NextFireTime                          
                          FROM CronTrigger
                          WHERE Id = : scID];

        //asserting the schedule job values        
        System.assertEquals(0, ct.TimesTriggered);        
        System.assertEquals('0 0 23 * * ?', ct.CronExpression);        
        
	}
	
}