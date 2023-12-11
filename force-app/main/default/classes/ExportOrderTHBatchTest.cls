/*
* @author        Rey Austral
* @date          9.30.2019
* @description   Test class for ExportOrderTHBatch and ExportOrderTHBatchScheduler
* @revision(s) 
*/
@isTest
private class ExportOrderTHBatchTest {
	
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'TH');
        insert sysad;
        
        System.runAs(sysad) {                       
            List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount.get(0).Market__c = 'TH';
            Update lAccount;

            List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
            PricebookEntry entry = TestDataFactory.createPricebookEntry('TH');
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
    		ExportOrderTHBatch ucs = new ExportOrderTHBatch('TH');
    		Database.executeBatch(ucs, 200);
    	System.Test.stopTest();

    	List<ContentVersion> contentList = [SELECT Id, ContentDocumentId FROM ContentVersion];
        //txt file and csv
    	System.assertEquals(1, contentList.size());    	
	}
	
	@isTest static void test_scheduler_TH() {
		// Implement test code
		ExportOrderTHBatchScheduler job = new ExportOrderTHBatchScheduler();
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
	
	@isTest static void test_scheduler_ID() {
		// Implement test code
		ExportOrderIDBatchScheduler job = new ExportOrderIDBatchScheduler();
		String sch = '0 0 23 * * ?'; 
		Id scID = System.schedule('Test Export Order Batch Job ID', sch, job);

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