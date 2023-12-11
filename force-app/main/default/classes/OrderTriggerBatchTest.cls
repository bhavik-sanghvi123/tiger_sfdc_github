// @isTest for deletion
public class OrderTriggerBatchTest {} /*
	
	@testsetup
    static void setupData() {
    	List<User> usrList =  [Select Id From User where id = '0050o00000VWCHmAAP'];
    	User sysad = new User();
    	if (usrList.isEmpty()) {
	    	sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
	    	sysad.FirstName = 'Data';
	    	sysad.LastName = 'Migration';
	        insert sysad;
    	} else {
    		sysad = usrList.get(0);
    	}
        
        System.runAs(sysad) {	  
        	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1); 		    	
			
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProduct.get(0).Id);

			PricebookEntry entry = TestDataFactory.createPricebookEntry();
			Insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
			Insert lOrder;			
			
			OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			insert item;

			OrderItem item2 = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			insert item2;

			OrderItem item3 = TestDataFactory.createOrderItem(lOrder.get(1).Id, entry.Id);
			insert item3;
		}
    }

	@isTest
	static void test_updateBrandRelationship_Lead() {
		User sysad = [Select id from User where id = '0050o00000VWCHmAAP' Limit 1];
		System.runAs(sysad) {	  
			Order oRecord = [Select Id, Status from Order Limit 1];
			oRecord.Status = CommonConstant.ORDER_STATUS_COMPLETED;
			update oRecord;
			Test.setCreatedDate(oRecord.Id, DateTime.newInstance(2019,06,01));

			System.Test.startTest();
				
				OrderTriggerBatch umd = new OrderTriggerBatch();
            	Database.executeBatch(umd, 200);
			System.Test.stopTest();
		}

		BrandRelationship__c updatedRecord = [Select Id, Status__c, Type__c from BrandRelationship__c Limit 1];
		System.assertEquals(CommonConstant.BRAND_TYPE_USER, updatedRecord.Type__c );
		System.assertEquals(CommonConstant.BRAND_STATUS_NEW, updatedRecord.Status__c );
	}

	@isTest
	static void test_updateBrandRelationship_User() {
		User sysad = [Select id from User where id = '0050o00000VWCHmAAP' Limit 1];

		System.runAs(sysad) {	
			BrandRelationship__c brand = [Select Id, Status__c, WinBack__c from BrandRelationship__c Limit 1];
			brand.Type__c = CommonConstant.BRAND_TYPE_USER;
			brand.Status__c =  CommonConstant.BRAND_STATUS_LAPSED;
			update brand;
			Order oRecord = [Select Id, Status from Order Limit 1];
			oRecord.Status = CommonConstant.ORDER_STATUS_COMPLETED;
			update oRecord;
			Test.setCreatedDate(oRecord.Id, DateTime.newInstance(2019,06,01));
			System.Test.startTest();
				
				OrderTriggerBatch umd = new OrderTriggerBatch();
            	Database.executeBatch(umd, 200);
			System.Test.stopTest();
		}

		BrandRelationship__c updatedRecord = [Select Id, Status__c, WinBack__c from BrandRelationship__c Limit 1];
		System.assertEquals(true, updatedRecord.WinBack__c );
		System.assertEquals(CommonConstant.BRAND_STATUS_EXISTING, updatedRecord.Status__c );
	}

	@isTest
	static void test_updateContactTransactionDate() {
		User sysad = [Select id from User where id = '0050o00000VWCHmAAP' Limit 1];

		System.runAs(sysad) {	
			Boolean updateFirstRecord = true;
			List<Order> oRecord = [Select Id, Status, EndDate from Order ];
			for (Order rec : oRecord) {
				rec.Status = CommonConstant.ORDER_STATUS_COMPLETED;
				if (updateFirstRecord) {
					rec.EndDate = Date.today().addDays(4);
					updateFirstRecord = false;
				}
			}				
			update oRecord;
			Test.setCreatedDate(oRecord.get(0).Id, DateTime.newInstance(2019,06,01));

			System.Test.startTest();
				
				OrderTriggerBatch umd = new OrderTriggerBatch();
            	Database.executeBatch(umd, 200);
				
			System.Test.stopTest();

			Contact updatedRecord = [Select Id, LatestTransactionDate__c, FirstTransactionDate__c from Contact Limit 1];
			//end date in TestDataFactory.createOrder is Date.today().addDays(2)
			//it should retain the value because the end date we updated is much latest
			System.assertEquals(Date.today().addDays(2), updatedRecord.FirstTransactionDate__c );
			System.assertEquals(Date.today().addDays(4), updatedRecord.LatestTransactionDate__c );
		}
	}

	@isTest
	static void test_updateMembership() {
		
		User sysad = [Select id from User where id = '0050o00000VWCHmAAP' Limit 1];
		System.runAs(sysad) {	
			Membership__c mem = new Membership__c();
			mem.Status__c = 'New'    	;
			mem.MembershipId__c = '111123';
			insert mem;
			
			Order oRecord = [Select Id, Status,ParentMembership__c from Order Limit 1];
			oRecord.Status = CommonConstant.ORDER_STATUS_COMPLETED;
			oRecord.ParentMembership__c = mem.Id;
			update oRecord;
			Test.setCreatedDate(oRecord.Id, DateTime.newInstance(2019,06,01));

			System.Test.startTest();
				
				OrderTriggerBatch umd = new OrderTriggerBatch();
            	Database.executeBatch(umd, 200);
			System.Test.stopTest();
		}
	}

	@isTest
	static void test_updateMembershipCancelOrder() {
		
		User sysad = [Select id from User where id = '0050o00000VWCHmAAP' Limit 1];
		System.runAs(sysad) {	
			Membership__c mem = new Membership__c();
			mem.Status__c = 'New'    	;
			mem.MembershipId__c = '111123';
			mem.MembershipStartDate__c = Date.today().addDays(-91);
			insert mem;

			Order oRecord = [Select Id, Status,ParentMembership__c from Order Limit 1];
			oRecord.Status = 'Cancelled - Abandoned';
			oRecord.ParentMembership__c = mem.Id;
			update oRecord;

			Test.setCreatedDate(oRecord.Id, DateTime.newInstance(2019,06,01));
			System.Test.startTest();
				
			
				OrderTriggerBatch umd = new OrderTriggerBatch();
            	Database.executeBatch(umd, 200);
			System.Test.stopTest();
		}
	}
   
	
}*/