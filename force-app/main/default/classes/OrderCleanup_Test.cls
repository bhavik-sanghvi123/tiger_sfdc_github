// @isTest for deletion
public class OrderCleanup_Test {} /*
    @testsetup
    static void setupData() {
    	User sysad = new User();
        sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        sysad.FirstName = 'Data';
        sysad.LastName = 'Migration';
        sysad.UserName = 'datamigration@tigerani.abbott.comtest';
        insert sysad;
        
        System.runAs(sysad) {    

			List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);           

			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProduct.get(0).Id);

			PricebookEntry entry = TestDataFactory.createPricebookEntry();
			Insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
			Insert lOrder;

			OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			insert item;
            
		    Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
			
	        Campaign camp = TestDataFactory.createCampaign('New User Call 1', 'Ensure', 'PH');
			insert camp;
			Case ca1 = new Case();
            ca1.RecordtypeId = callRTId;
            ca1.ContactId = lContact[0].Id;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId = lAccount[0].Id;
            ca1.CallRegarding__c = lContact[0].Id;
			ca1.Campaign__c = camp.Id;
            insert ca1;
    	}
    }

    static testMethod void test1(){
        Test.startTest();
            Database.executebatch(new OrderCleanup());
        Test.stopTest();
    }
} */