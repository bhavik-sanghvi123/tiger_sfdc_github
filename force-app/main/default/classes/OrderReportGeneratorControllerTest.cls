/*
* @author        Rey Austral
* @date          3.8.2019
* @description   Test class for OrderReportGeneratorController
* @revision(s) 
*/
@isTest
private class OrderReportGeneratorControllerTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {	    		    	
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			lAccount.get(0).Market__c = 'SG';
			update lAccount;

			List<Contact> lContact = TestDataFactory.createSGTestAdultContact(1, lAccount.get(0).Id);
			PricebookEntry entry = TestDataFactory.createPricebookEntry('SG');
			Insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
			Insert lOrder;			
			
			OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			insert item;

			lOrder.get(0).Status = CommonConstant.ORDER_STATUS_SUBMITTED;
			lOrder.get(0).Type = CommonConstant.ORDER_TYPE_SAMPLEREQUEST;
			update lOrder;
		}
    }

	@isTest
	static void test_queryOrderItemReport() {
		User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
		System.runAs(sysad) {	    	
			System.Test.startTest();
			System.debug([SELECT Id, Name FROM ContentWorkspace]);
				List<OrderItem> orderList = OrderReportGeneratorController.queryOrderItemReport();
				OrderReportGeneratorController controller = new OrderReportGeneratorController();
				OrderReportGeneratorController.OrderReportWrapper filestring = OrderReportGeneratorController.getExcelFileAsBase64String();
			System.Test.stopTest();
		

			System.assertEquals(1 , orderList.size());
			System.assertNotEquals('', filestring.fileContent);
		}
	}
}