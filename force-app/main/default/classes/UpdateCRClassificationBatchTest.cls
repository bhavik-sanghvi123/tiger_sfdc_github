// for deletion @isTest
public class UpdateCRClassificationBatchTest {} /*
	
	@testsetup
    static void setupData() {
    	List<User> usrList =  [Select Id From User where LastName = 'Migration'];
    	User sysad = new User();
    	if (usrList.isEmpty()) {
	    	sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
	    	sysad.FirstName = 'Data';
	    	sysad.LastName = 'Migration';
	        insert sysad;
    	} else {
    		sysad = usrList.get(0);
    	}
        
        System.runAs(sysad) {
	    	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
			lProduct.get(0).Market__c = 'SG';
			Update lProduct;

	    	List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
			lChannel.get(0).Market__c = 'SG';
			Update lChannel;
			
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			lAccount.get(0).Market__c = 'SG';
			Update lAccount;

			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			
			//Create Region
	        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
			lRegion.get(0).Market__c = 'SG';
			Update lRegion;

	        //Create City
	        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
			lCity.get(0).Market__c = 'SG';
			Update lCity;

	        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, lContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
	        PricebookEntry entry = TestDataFactory.createPricebookEntry('SG');
			Insert entry;
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, entry.Product2Id);
		}
    }
	
	@isTest static void test_Classification() {
		User sysad = [Select Id From User where LastName = 'Migration'];
		System.runAs(sysad) {
			List<ChannelResponse__c> toInsert = new List<ChannelResponse__c>();

			ChannelResponse__c ch = new ChannelResponse__c();
			ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
			
			ch.RegistrationDate__c = Date.today();
			toInsert.add(ch);

			ChannelResponse__c ch2 = new ChannelResponse__c();
			ch2.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch2.Channel__c = [Select Id From Channel__c Limit 1].Id;
            DateTime dt = Datetime.newInstance(2018, 11, 8);
			ch2.RegistrationDate__c = dt;
			toInsert.add(ch2);

			insert toInsert;

			
			toInsert.get(0).Classification__c = null;
			toInsert.get(1).Classification__c = null;
			update toInsert;
		

			System.test.startTest();
                UpdateCRClassificationBatch umd = new UpdateCRClassificationBatch();
        	    Database.executeBatch(umd, 200);
			System.test.stopTest();
			List<ChannelResponse__c> chList = [Select Id,Classification__c,RegistrationDate__c from ChannelResponse__c where Id in: toInsert];
			
			System.assertEquals(CommonConstant.CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME, chList.get(0).Classification__c);			
			System.assertEquals(CommonConstant.CHANNELRESPONSE_CLASSIFICATION_SAMEBRAND, chList.get(1).Classification__c);
		}
	}

	@isTest static void test_scheduler() {
		// Implement test code
		UpdateCRClassificationBatchScheduler job = new UpdateCRClassificationBatchScheduler();
		String sch = '0 0 23 * * ?'; 
		Id scID = System.schedule('Test Update Classification Batch Job', sch, job);

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
	
}*/