//@isTest
public class PostChannelResponseTrigger_Test {} /*
    
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {
	    	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
	    	List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			
			//Create Region
	        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
	        //Create City
	        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
	        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, lContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
	        PricebookEntry entry = TestDataFactory.createPricebookEntry();
			Insert entry;
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, entry.Product2Id);

			//insert a record that is much earlier than the 1st record
			ChannelResponse__c earlyCh = new ChannelResponse__c();
			earlyCh.BrandRelationship__c = lBrand[0].Id;
			earlyCh.Channel__c = lChannel[0].Id;
			earlyCh.RegistrationDate__c = Date.today().addDays(-1);
			Insert earlyCh;
		}
    }

    static testMethod void testBatch() {
        Test.startTest();
            Database.executeBatch(new PostChannelResponseTrigger_Batch(false, 'SELECT Id FROM ChannelResponse__c'));
        Test.stopTest();
    }

    static testMethod void testSched() {
        Test.startTest();
            String sch = '0 0 23 * * ?'; 
            system.schedule('test PostChannelResponseTrigger_Sched', sch, new PostChannelResponseTrigger_Sched(false, ''));
        Test.stopTest();
    }
}*/