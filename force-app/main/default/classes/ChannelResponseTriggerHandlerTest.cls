/*
* @author        Rey Austral
* @date          
* @description   Test class for ChannelResponseTriggerHandler
* @revision(s) 
*/
@isTest
private class ChannelResponseTriggerHandlerTest {
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
			Test.getEventBus().deliver();
		}
    }

	@isTest static void test_DeleteExistingResponse() {
		Test.enableChangeDataCapture();
		List<ChannelResponse__c> crList = new List<ChannelResponse__c>();
		Id brandId = [Select Id from BrandRelationship__c Limit 1].Id;
		Id channelId =  [Select Id From Channel__c Limit 1].Id;
		for(Integer ctr=0;ctr<4;ctr++) {
			ChannelResponse__c ch = new ChannelResponse__c();
			ch.BrandRelationship__c = brandId;
			ch.Channel__c =channelId;
			ch.RegistrationDate__c = Date.today().addDays(ctr);
			crList.add(ch);
		}
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			Insert crList;
			Test.getEventBus().deliver();	
			BrandRelationship__c updatedBrand = [Select LatestChannelResponseDate__c, FirstChannelResponseDate__c from BrandRelationship__c where Id=:brandId];
			//current value of first and latest after the insert
			System.assertEquals(Date.today(), updatedBrand.FirstChannelResponseDate__c);
			System.assertEquals(Date.today().addDays(3), updatedBrand.LatestChannelResponseDate__c);
			Delete crList.get(0);
			Delete crList.get(3);
			Test.getEventBus().deliver();

			updatedBrand = [Select LatestChannelResponseDate__c, FirstChannelResponseDate__c from BrandRelationship__c where Id=:brandId];
			//first and latest should be updated with a new value after the record has been deleted			
			System.assertEquals(Date.today().addDays(1), updatedBrand.FirstChannelResponseDate__c);
			System.assertEquals(Date.today().addDays(2), updatedBrand.LatestChannelResponseDate__c);
			//delete all record
			List<ChannelResponse__c> crDeletedList = new List<ChannelResponse__c>();
			crDeletedList.add( crList.get(1) );
			crDeletedList.add( crList.get(2) );
			Delete crDeletedList;
			Test.getEventBus().deliver();

			updatedBrand = [Select LatestChannelResponseDate__c, FirstChannelResponseDate__c from BrandRelationship__c where Id=:brandId];
			//first and latest date should be empty if all response date has been remove
			System.assertEquals(Null, updatedBrand.FirstChannelResponseDate__c);
			System.assertEquals(Null, updatedBrand.LatestChannelResponseDate__c);
		}
	}

	@isTest static void test_createNewResponse() {
		Test.enableChangeDataCapture();

		ChannelResponse__c ch = new ChannelResponse__c();
		ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
		ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
		ch.RegistrationDate__c = Date.today();
		User sysad = [Select Id, Market__c From User where LastName = 'tstSysAd'];
		System.debug(sysad);
		System.runAs(sysad) {
			Insert ch;
			Test.getEventBus().deliver();
		
			BrandRelationship__c updatedBrand = [Select LatestChannelResponseDate__c, FirstChannelResponseDate__c from BrandRelationship__c where Id =: ch.BrandRelationship__c];
			//they should have the same value because the brand only contains 1 channel response
			System.assertEquals(Date.Today(), updatedBrand.FirstChannelResponseDate__c);
			System.assertEquals(Date.Today(), updatedBrand.LatestChannelResponseDate__c);

			// //inserting another record with the date is greater than the previous date
			// ChannelResponse__c latestCh = new ChannelResponse__c();
			// latestCh.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			// latestCh.Channel__c = [Select Id From Channel__c Limit 1].Id;
			// latestCh.RegistrationDate__c = Date.today().addDays(1);
			// Insert latestCh;
			// Test.getEventBus().deliver();
			// updatedBrand = [Select LatestChannelResponseDate__c, FirstChannelResponseDate__c from BrandRelationship__c where Id =: ch.BrandRelationship__c];
			// //First date should not change
			// System.assertEquals(Date.today(), updatedBrand.FirstChannelResponseDate__c);
			// //latest date should be updated
			// System.assertEquals(Date.today().addDays(1), updatedBrand.LatestChannelResponseDate__c);

			// //insert a record that is much earlier than the 1st record
			// ChannelResponse__c earlyCh = new ChannelResponse__c();
			// earlyCh.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			// earlyCh.Channel__c = [Select Id From Channel__c Limit 1].Id;
			// earlyCh.RegistrationDate__c = Date.today().addDays(-1);
			// Insert earlyCh;
			// Test.getEventBus().deliver();
			// updatedBrand = [Select LatestChannelResponseDate__c, FirstChannelResponseDate__c from BrandRelationship__c where Id =: ch.BrandRelationship__c];
			// //First date should change
			// System.assertEquals(Date.today().addDays(-1), updatedBrand.FirstChannelResponseDate__c);
			// //latest date should not be updated
			// System.assertEquals(Date.today().addDays(1), updatedBrand.LatestChannelResponseDate__c);
		}
	}

	@isTest static void test_Classification() {
		Test.enableChangeDataCapture();
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			List<ChannelResponse__c> toInsert = new List<ChannelResponse__c>();

			ChannelResponse__c ch = new ChannelResponse__c();
			ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
			ch.RegistrationDate__c = Date.today().addDays(-1);
			toInsert.add(ch);
			Test.getEventBus().deliver();

			ChannelResponse__c ch2 = new ChannelResponse__c();
			ch2.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch2.Channel__c = [Select Id From Channel__c Limit 1].Id;
			ch2.RegistrationDate__c = Date.today();
			toInsert.add(ch2);
			Test.getEventBus().deliver();

			insert ch;
			Test.getEventBus().deliver();
			insert ch2;
			Test.getEventBus().deliver();
			List<ChannelResponse__c> chList = [Select Id,Classification__c from ChannelResponse__c where Id in: toInsert];
			
			System.assertEquals(CommonConstant.CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME, chList.get(0).Classification__c);			
			System.assertEquals(CommonConstant.CHANNELRESPONSE_CLASSIFICATION_SAMEBRAND, chList.get(1).Classification__c);
		}
	}

	static testMethod void testsched(){

		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			List<ChannelResponse__c> toInsert = new List<ChannelResponse__c>();

			ChannelResponse__c ch = new ChannelResponse__c();
			ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
			ch.RegistrationDate__c = Date.today().addDays(-1);
			toInsert.add(ch);

			ChannelResponse__c ch2 = new ChannelResponse__c();
			ch2.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch2.Channel__c = [Select Id From Channel__c Limit 1].Id;
			ch2.RegistrationDate__c = Date.today();
			toInsert.add(ch2);

			insert toInsert;
		}
        Test.startTest();

            String cronStr = '0 0 0 3 9 ? 2050';
            String jobId2 = System.schedule('BRMissingChannelResponse_Batch_Test', cronStr, new BRMissingChannelResponse_Sched());

			Database.executebatch(new BRMissingChannelResponse_Batch(''));

        Test.stopTest();
		
		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
		NextFireTime
		FROM CronTrigger WHERE id = :jobId2];

		// Verify the expressions are the same
		System.assertEquals(cronStr, ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
    }
	
	// @isTest static void test_UpdateExistingResponse() {
	// 	List<ChannelResponse__c> crList = new List<ChannelResponse__c>();
	// 	Id brandId = [Select Id from BrandRelationship__c Limit 1].Id;
	// 	Id channelId =  [Select Id From Channel__c Limit 1].Id;
	// 	for(Integer ctr=0;ctr<4;ctr++) {
	// 		ChannelResponse__c ch = new ChannelResponse__c();
	// 		ch.BrandRelationship__c = brandId;
	// 		ch.Channel__c =channelId;
	// 		ch.RegistrationDate__c = Date.today().addDays(ctr);
	// 		crList.add(ch);
	// 	}
	// 	User sysad = [Select Id From User where LastName = 'tstSysAd'];
	// 	System.runAs(sysad) {
	// 		Insert crList;

	// 		List<ChannelResponse__c> updatedCrList = new List<ChannelResponse__c>();
	// 		ChannelResponse__c ch = crList.get(1);
	// 		ch.RegistrationDate__c = Date.today().addDays(-1);
	// 		updatedCrList.add(ch);
	// 		ChannelResponse__c latestCh = crList.get(2);
	// 		latestCh.RegistrationDate__c = Date.today().addDays(10);
	// 		updatedCrList.add(latestCh);

	// 		System.test.startTest();
	// 			Update updatedCrList;
	// 		System.test.stopTest();

	// 		BrandRelationship__c updatedBrand = [Select LatestChannelResponseDate__c, FirstChannelResponseDate__c from BrandRelationship__c where Id =: ch.BrandRelationship__c];
	// 		//first and latest should be updated with a new value
	// 		System.assertEquals(updatedBrand.FirstChannelResponseDate__c, Date.today().addDays(-1));
	// 		System.assertEquals(updatedBrand.LatestChannelResponseDate__c,Date.today().addDays(10));

	// 	}
	// }
/*
	@isTest static void test_SampleOrderCreation() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			ChannelResponse__c ch = new ChannelResponse__c();
			ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
			ch.RegistrationDate__c = Date.today();
			ch.IsSample_Requested__c = true;
			ch.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING;
			ch.DeliveryAddress__c =  [Select Id from Address__c Limit 1].Id;
            ch.ProductSampleRequested__c = [Select Id from Product2 where Name = 'Test Product'].Id;
			System.test.startTest();
				insert ch;
			System.test.stopTest();
			List<Order> order = [Select Id,Type from Order];
			System.assertEquals(1, order.size(), 'New order should be created');
			System.assertEquals(CommonConstant.ORDER_TYPE_SAMPLEREQUEST, order.get(0).Type);

			ch = [Select Id, OrderCreationStatus__c from ChannelResponse__c where Id=: ch.Id];
			System.assertEquals(CommonConstant.CHANNELRESPONSE_ORDERSTATUS_SUCCESSFUL, ch.OrderCreationStatus__c);
		}
	}

	@isTest static void test_SampleOrderIneligible() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			ChannelResponse__c ch = new ChannelResponse__c();
			ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
			ch.RegistrationDate__c = Date.today();
			ch.IsSample_Requested__c = true;
			ch.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING;
			ch.DeliveryAddress__c =  [Select Id from Address__c Limit 1].Id;
            ch.ProductSampleRequested__c = [Select Id from Product2 where Name = 'Test Product'].Id;
			System.test.startTest();
				insert ch;

				ChannelResponse__c ch2 = new ChannelResponse__c();
				ch2.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
				ch2.Channel__c = [Select Id From Channel__c Limit 1].Id;
				ch2.RegistrationDate__c = Date.today();
				ch2.IsSample_Requested__c = true;
				ch2.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING;
				ch2.DeliveryAddress__c =  [Select Id from Address__c Limit 1].Id;
				ch2.ProductSampleRequested__c = [Select Id from Product2 where Name = 'Test Product'].Id;

				insert ch2;

			System.test.stopTest();
			

			ch2 = [Select Id, OrderCreationStatus__c from ChannelResponse__c where Id=: ch2.Id];
			System.assertEquals(CommonConstant.CHANNELRESPONSE_ORDERSTATUS_INELIGBLE, ch2.OrderCreationStatus__c);
		}
	}

	@isTest static void test_SampleOrderCreationUpdate() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			ChannelResponse__c ch = new ChannelResponse__c();
			ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
			ch.RegistrationDate__c = Date.today();
			ch.ProductSampleRequested__c = [Select Id from Product2 where Name = 'Test Product'].Id;
			ch.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING;
			ch.DeliveryAddress__c =  [Select Id from Address__c Limit 1].Id;
			System.test.startTest();
				insert ch;
				
				ch.IsSample_Requested__c = true;
				update ch;
			System.test.stopTest();
			List<Order> order = [Select Id,Type from Order];
			System.assertEquals(1, order.size(), 'New order should be created');
			System.assertEquals(CommonConstant.ORDER_TYPE_SAMPLEREQUEST, order.get(0).Type);

			ch = [Select Id, OrderCreationStatus__c from ChannelResponse__c where Id=: ch.Id];
			System.assertEquals(CommonConstant.CHANNELRESPONSE_ORDERSTATUS_SUCCESSFUL, ch.OrderCreationStatus__c);
		}
	}

	@isTest static void test_SampleOrderCreation_MissingAddress() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			ChannelResponse__c ch = new ChannelResponse__c();
			ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
			ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
			ch.RegistrationDate__c = Date.today();
			ch.IsSample_Requested__c = true;
			ch.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING;
			
			System.test.startTest();
				insert ch;
			System.test.stopTest();
			List<Order> order = [Select Id,Type from Order];
			System.assertEquals(0, order.size(), 'No order created');
			

			ch = [Select Id, OrderCreationStatus__c from ChannelResponse__c where Id=: ch.Id];
			System.assertEquals(CommonConstant.CHANNELRESPONSE_ORDERSTATUS_MISSINGADDRESS, ch.OrderCreationStatus__c);
		}
	}
*/
	
}