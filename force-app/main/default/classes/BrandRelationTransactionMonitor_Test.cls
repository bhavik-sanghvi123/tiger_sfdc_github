@isTest
public class BrandRelationTransactionMonitor_Test {
    @testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {	  
            List<Product2> pList = new List<Product2>();

        	Product2 lProductbr = TestDataFactory.createTestBrandProduct2(1)[0];
			lProductbr.Market__c = 'SG';	    
			lProductbr.AvailableBrandRelationship__c = true;
			// update lProductbr;
            pList.add(lProductbr);

			Product2 lProduct = TestDataFactory.createTestBrandProduct2(1)[0];
			lProduct.Market__c = 'SG';	    
			lProduct.BrandRelationshipLink__c = lProductbr.Id;
			// update lProduct;
            pList.add(lProduct);

            UtilityClass.insertList(pList);

			List<Account> lAccount = TestDataFactory.createTestHousehold2(1);
			lAccount[0].Market__c = 'SG';
			// update lAccount;
            UtilityClass.insertList(lAccount);

			List<Contact> lContact = TestDataFactory.createSGTestAdultContact(1, lAccount.get(0).Id);
			
			List<Channel__c> lChannel = TestDataFactory.createTestChannel(2);
			lChannel[0].Name = 'Marketing Channel`';
			lChannel[0].Market__c = 'SG';
			lChannel[1].Name = 'Social Channel';
			lChannel[1].Market__c = 'SG';
			// update lChannel;
            UtilityClass.insertList(lChannel);
			
            List<Campaign> cList = new List<Campaign>();

			Campaign camp = TestDataFactory.createCampaign('Marketing Campaign', 'Similac', 'SG');
			camp.Channel__c = lChannel.get(0).Id;
			// insert camp;
            cList.add(camp);

			Campaign camp2 = TestDataFactory.createCampaign('Social Campaign', 'Pediasure', 'SG');
			camp2.Channel__c = lChannel.get(1).Id;
			// insert camp2;
            cList.add(camp2);
            UtilityClass.insertList(cList);

			PricebookEntry entry = TestDataFactory.createPricebookEntry('SG');
			insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
			// insert lOrder;		
            UtilityClass.insertList(lOrder);

            List<OrderItem> oiList = new List<OrderItem>();

			OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			item.Product2Id = lProduct.Id;
			// insert item;
            oiList.add(item);
            System.debug('item: ' + item.Id);

			OrderItem item2 = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			item2.Product2Id = lProduct.Id;
			// insert item2;
            oiList.add(item2);
            System.debug('item2: ' + item2.Id);

			OrderItem item3 = TestDataFactory.createOrderItem(lOrder.get(1).Id, entry.Id);
			item3.Product2Id = lProduct.Id;
			// insert item3;
            oiList.add(item3);
            System.debug('item3: ' + item3.Id);

            UtilityClass.insertList(oiList);

			item3 = [SELECT Product2Id FROM OrderItem WHERE Id =: item3.Id][0];
			update new Product2(Id = item3.Product2Id, BrandRelationshipLink__c = lProductbr.Id);

            // delete any brand relationship
            Delete [SELECT Id FROM BrandRelationship__c];
            lOrder[0].Status = CommonConstant.ORDER_STATUS_COMPLETED;
            lOrder[1].Status = CommonConstant.ORDER_STATUS_COMPLETED;
            // update lOrder;
            UtilityClass.updateList(lOrder);

            List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProductbr.Id);
		}
    }


    static testMethod void LinkunprocessedOrderItem() {
		User sysad = TestDataFactory.createUser('System Administrator', 'tstSysA1' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {	
            List<BrandRelationship__c> brList = new List<BrandRelationship__c>();
            List<BrandRelationship__c> brList2 = [SELECT Id FROM BrandRelationship__c];
            for(BrandRelationship__c br: brList2){
                br.FirstTransactionDate__c = null;
                br.LatestTransactionDate__c = null;
                br.Status__c = 'Qualified';
                brList.add(br);
            }
            // update brList;
            
            Test.startTest();
                UtilityClass.updateList(brList);
                ID batchprocessid = Database.executeBatch(new BrandRelationTransactionMonitor(true));
                System.debug('batchprocessid: ' + batchprocessid);
            Test.stopTest();
            
            // assert BrandRelationshipLinkStatus__c is now true
            List<OrderItem> oiList = [SELECT BrandRelationshipLinkStatus__c FROM OrderItem];

            System.debug('oiList: ' + oiList);

            for(OrderItem oi: oiList){
                System.debug('oi: ' + oi);
                System.assert(oi.BrandRelationshipLinkStatus__c);
            }
        }
    }

    static testMethod void testsched(){
        Test.startTest();

            String cronStr = '0 0 0 3 9 ? 2050';
            String jobId2 = System.schedule('BrandRelationTransactionMonitor_Daily_Test', cronStr, new BrandRelationTransactionMonitor_Sched());
            String jobId3 = System.schedule('BrandRelationTransactionMonitor_Hourly_Test', cronStr, new BrandRelationTransactionMonitor_Sched_H());

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId2];

            // Verify the expressions are the same
            System.assertEquals(cronStr, ct.CronExpression);

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}