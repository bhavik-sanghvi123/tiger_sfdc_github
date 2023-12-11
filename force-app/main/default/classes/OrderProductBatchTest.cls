// for deletion @isTest
public class OrderProductBatchTest {} /*
	
	@testsetup
    static void setupData() {
     	List<User> usrList =  [Select Id From User where LastName = 'Migration'];
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

			//Create Promotion Record
			List<Promotion__c> lPromotion = TestDataFactory.createPromotion(1);

			//Create Promotion Item
			List<PromotionItem__c> lPromotionItem = TestDataFactory.createPromotionItem(1,entry.Product2Id ,lpromotion.get(0).Id);

			//Create Order Item
			OrderItem item1 = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			item1.PromotionItem__c =  lPromotionItem.get(0).Id;
			insert item1 ;
    	}
    }
    
    Private static testMethod void getPromotionTest(){   
     	  
    	  test.StartTest();     
	  		OrderProductBatch umd = new OrderProductBatch();
        	Database.executeBatch(umd, 200);
    	  test.StopTest();
         OrderItem item1 = [SELECT Id,Promotion__c,PromotionItem__c FROM OrderItem WHERE PromotionItem__c != null];  
          //update item1;
          PromotionItem__c pi = [SELECT Id, Promotion__c FROM PromotionItem__c LIMIT 1];   
          System.assertEquals(item1.Promotion__c, pi.Promotion__c );
    }
	
}*/