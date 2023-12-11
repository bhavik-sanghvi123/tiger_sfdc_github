@isTest
private class VNManualDeliveryStatusTriggerHelperTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
        System.runAs(sysad) {	    	      

	        TestDataFactory.createTestOrderCancellationReason(1, 'VN');	       
	      
		}
    }

	@isTest static void test_insertRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_Manual_Delivery_Status__c rec = new VN_Manual_Delivery_Status__c();

			//validate address
			rec = new VN_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Cancelled - Upon Delivery';	
				rec.order_cancellation_reason__c = 'Invalid';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Cancelled';	
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Completed';	
				rec.order_delivery_date__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Completed';	
				rec.order_delivery_date__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Completed';	
				rec.source_created_date__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_Manual_Delivery_Status__c();
			try {
				rec.order_status__c = 'Invalid';
				rec.order_cancellation_reason__c = 'Test Order Cancellation Reason';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}
	
}