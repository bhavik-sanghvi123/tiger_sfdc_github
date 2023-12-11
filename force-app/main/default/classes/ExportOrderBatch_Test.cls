@isTest
public class ExportOrderBatch_Test {
	
    @testsetup static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {	    		    	
			List<Account> lAccount = TestDataFactory.createTestHouseholdSG(1);
            // lAccount.get(0).Market__c= 'SG';
            // UtilityClass.updateList(lAccount);

			List<Contact> lContact = TestDataFactory.createSGTestAdultContact(1, lAccount.get(0).Id);
			PricebookEntry entry = TestDataFactory.createPricebookEntry('SG');
			insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
			// Insert lOrder;		
            UtilityClass.insertList(lOrder);
			
            // List<OrderItem> oiList = new List<OrderItem>();
			// OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			// // insert item;
            // oiList.add(item);
            
            // // OrderItem item2 = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			// // // insert item2;
            // // oiList.add(item2);

            // UtilityClass.insertList(oiList);

			// lOrder.get(0).Status = CommonConstant.ORDER_STATUS_SUBMITTED;
            // lOrder.get(0).Type = CommonConstant.ORDER_TYPE_SAMPLEREQUEST;
			// // update lOrder;
            // UtilityClass.updateList(lOrder);
		}
    }

	static testMethod void test1() {
        User sysadVN = TestDataFactory.createUser('System Administrator', 'tstVN' , 'VN');
        insert sysadVN;
        
        System.runAs(sysadVN) {	    		    	
            List<OrderItem> orderItemList = new List<OrderItem>();
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount.get(0).Market__c= 'VN';
            UtilityClass.updateList(lAccount);
            
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			PricebookEntry entry = TestDataFactory.createPricebookEntry('VN');
			insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
			UtilityClass.insertList(lOrder);			
			
			OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
            orderItemList.add(item);
            
            OrderItem item2 = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			orderItemList.add(item2);

            UtilityClass.insertList(orderItemList);

			lOrder.get(0).Status = CommonConstant.ORDER_STATUS_SUBMITTED;
            
            System.Test.startTest();
                UtilityClass.updateList(lOrder);
                Database.Executebatch(new ExportOrderBatch('VN',true));                        
                Database.Executebatch(new ExportOrderBatch_Cleanup());
            System.Test.stopTest();
            List<OrderExport2__c> vnOrder = [Select id from OrderExport2__c where Order__r.Account.Market__c = 'VN'];
            System.assertEquals(1, vnOrder.size());
		}
	}
    
    static testMethod void test2() {
        // User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
        User sysadVSG = TestDataFactory.createUser('System Administrator', 'tstSG' , 'SG');
        insert sysadVSG;
        
        System.runAs(sysadVSG) {
            List<OrderItem> orderItemList = new List<OrderItem>();
            
			List<Account> lAccount = TestDataFactory.createTestHouseholdSG(1);
            lAccount.get(0).Market__c= 'SG';
            UtilityClass.updateList(lAccount);
            
			List<Contact> lContact = TestDataFactory.createTestAdultContactSG(1, lAccount.get(0).Id);
			PricebookEntry entry = TestDataFactory.createPricebookEntry('SG');
			insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
            List<Order> lOrder2 = [SELECT Id, Status, Type, AccountId, OrderedBy__c, EffectiveDate, Pricebook2Id, EndDate FROM Order];
            System.debug('lOrder2: ' + lOrder2);

			UtilityClass.insertList(lOrder);			
			
			OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
            orderItemList.add(item);

            List<Product2> pList = TestDataFactory.createTestBrandProductSG(1);
            UtilityClass.insertList(pList);

            orderItemList[0].Product2Id = pList[0].Id;

            UtilityClass.insertList(orderItemList);

            lOrder.get(0).Status = CommonConstant.ORDER_STATUS_SUBMITTED;
            lOrder.get(0).Type = CommonConstant.ORDER_TYPE_SAMPLEREQUEST;

            System.Test.startTest();
                UtilityClass.updateList(lOrder);
                ID batchprocessid = Database.Executebatch(new ExportOrderBatch('SG',false));  
            	ID batchprocessid2 = Database.Executebatch(new ExportOrderBatch_Cleanup());
            System.Test.stopTest();
            List<OrderExport2__c> sgOrder = [Select id from OrderExport2__c where Order__r.Account.Market__c = 'SG'];
            System.assertEquals(1, sgOrder.size());
        }
	}

    static testMethod void test3(){
		User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
		System.runAs(sysad) {	    
            Test.startTest();

                String cronStr = '0 0 0 3 9 ? 2050';
                String jobId = System.schedule('test_ExportOrderBatch_Sched_VN', cronStr, new ExportOrderBatch_Sched_VN());
                String jobId2 = System.schedule('test_ExportOrderBatch_Cleanup_Sched', cronStr, new ExportOrderBatch_CleanUp_Sched());

                // Get the information from the CronTrigger API object
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                NextFireTime
                FROM CronTrigger WHERE id = :jobId];

                // Verify the expressions are the same
                System.assertEquals(cronStr, ct.CronExpression);

                // Verify the job has not run
                System.assertEquals(0, ct.TimesTriggered);

            Test.stopTest();
        }
    }
}