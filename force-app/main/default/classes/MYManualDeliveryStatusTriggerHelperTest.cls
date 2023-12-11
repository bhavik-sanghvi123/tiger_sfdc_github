@isTest
private class MYManualDeliveryStatusTriggerHelperTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'MY');
        insert sysad;
        
        System.runAs(sysad) {	    	      

	        TestDataFactory.createTestOrderCancellationReason(1, 'MY');	       
	      
		}
    }

	@isTest static void test_insertRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			MY_Manual_Delivery_Status__c rec = new MY_Manual_Delivery_Status__c();

			//validate address
			rec = new MY_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Cancelled - Upon Delivery';	
				rec.order_cancellation_reason__c = 'Invalid';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}			

			rec = new MY_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Completed';	
				rec.order_delivery_date__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new MY_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Completed';	
				rec.order_delivery_date__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new MY_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Completed';	
				rec.source_created_date__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}		

			
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}
	
}