/*
* @author        Rey Austral
* @date          7.15.2019
* @description   Test class for MailSampleLabelController
* @revision(s) 
*/
@isTest
private class MailSampleLabelControllerTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {	    		    	
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			PricebookEntry entry = TestDataFactory.createPricebookEntry();
			Insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
			Insert lOrder;			
			
			OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			item.OrderedFor__c = lContact.get(0).Id;
			insert item;

			lOrder.get(0).Status = CommonConstant.ORDER_STATUS_TRANSFERRED;
			lOrder.get(0).Type = CommonConstant.ORDER_TYPE_SAMPLEREQUEST;
			lOrder.get(0).FileExportDate__c = Date.today();
			update lOrder;
		}
    }

	@isTest
	static void test_querySampleItemReport() {
		User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
		System.runAs(sysad) {	    	
			System.Test.startTest();
			System.debug([SELECT Id, Name FROM ContentWorkspace]);
				List<OrderItem> orderList = MailSampleLabelController.querySampleItemReport(Date.today(), Date.today());
				MailSampleLabelController controller = new MailSampleLabelController();
				MailSampleLabelController.OrderReportWrapper filestring = MailSampleLabelController.getExcelFileAsBase64String(Date.today(),Date.today());
			System.Test.stopTest();
		

			System.assertEquals(1 , orderList.size());
			System.assertEquals('VW5pdC5UZXN0', filestring.fileContent);
		}
	}
}