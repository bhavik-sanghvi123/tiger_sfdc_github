@isTest
private class ProcessSampleOrderBatchTest {

    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {
	    	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            lProduct[0].Market__c = 'SG';
            update lProduct;
            
	    	List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
            lChannel[0].Market__c = 'SG';
            update lChannel;
            
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount[0].Market__c = 'SG';
            update lAccount;
            
			List<Contact> lContact = TestDataFactory.createSGTestAdultContact(1, lAccount.get(0).Id);
            
            List<Contact> childCon = TestDataFactory.createSGTestChildContact(1, lAccount[0].Id);
            childCon[0].Birthdate = System.today() - 1;
            childCon[0].Parent__c = lContact[0].Id;
            childCon[0].Active__c = True;
            childCon[0].Verified__c = True;
            update childCon;
			
			//Create Region
	        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
            lRegion[0].Market__c = 'SG';
            update lRegion;
	        //Create City
	        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
            lCity[0].Market__c = 'SG';
            update lCity;
            
	        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, lContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
	        PricebookEntry entry = TestDataFactory.createPricebookEntry('SG');
			Insert entry;
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, entry.Product2Id);
            lBrand[0].User__c = childCon[0].Id;
            update lBrand;
		}
    }
    
    public static testMethod  void executeBatch() {
        ChannelResponse__c ch = new ChannelResponse__c();
		ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
		ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
		ch.RegistrationDate__c = Date.today();
        ch.IsSample_Requested__c = True;
        ch.ProductSampleRequested__c = [Select Id From Product2 Limit 1].Id;
        ch.DeliveryAddress__c = [Select Id From Address__c Limit 1].Id;
        ch.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING;
        
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
        
        Test.startTest();
		System.runAs(sysad) {
			Insert ch;
            
        	ProcessSampleOrderBatch psob = new ProcessSampleOrderBatch();
            Database.executeBatch(psob, 200);

            ProcessSampleOrderScheduler pss = new ProcessSampleOrderScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Sample Order Batch Job', sch, pss);
        Test.stopTest();
    	}
        
        ChannelResponse__c ch2 = new ChannelResponse__c();
        ch2 = [Select Id, OrderCreationStatus__c From ChannelResponse__c Limit 1];
        
        System.assertEquals(CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDINGMILKCODE, ch2.OrderCreationStatus__c);
    }
}