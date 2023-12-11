/*
* @author        Rey Austral
* @date          1.28.2019
* @description   Test class for BrandNewRegistrationBatch and BrandNewRegistrationBatchScheduler
* @revision(s) 
*/
@isTest
private class BrandNewRegistrationBatchTest {
	
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
	    System.runAs(sysad) {
            Test.enableChangeDataCapture();
            List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
	        List<Campaign> campList = new List<Campaign>();
	        List<Account> accList = TestDataFactory.createTestHousehold(1);
	        accList.get(0).Market__c = 'VN';
			Update accList;
            Test.getEventBus().deliver();
			List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
			List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
			lProduct.get(0).Market__c = 'VN';
			Update lProduct;
            Test.getEventBus().deliver();
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, conList.get(0).Id, lProduct.get(0).Id);
            
		}
    }

	@isTest static void test_exportBatch() {		
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
        System.runAs(sysad) {    
            Test.enableChangeDataCapture();
            ChannelResponse__c latestCh = new ChannelResponse__c();
            latestCh.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
            latestCh.Channel__c = [Select Id From Channel__c Limit 1].Id;
            latestCh.RegistrationDate__c = Date.today().addYears(-2);
            Insert latestCh;
            Test.getEventBus().deliver();
            System.Test.startTest();
            System.debug([SELECT Id, NewtoBrandDate__c, Market__c FROM BrandRelationship__c]);
                BrandNewRegistrationBatch ucs = new BrandNewRegistrationBatch(latestCh.BrandRelationship__r.Market__c, '', null);
                Database.executeBatch(ucs, 200);
            System.Test.stopTest();

            //the record is beyond the valid range based on the custom meta data, the check box should now be false
            List<BrandRelationship__c> chList = [SELECT Id  FROM BrandRelationship__c WHERE NewtoBrand__c = false];
            System.assertEquals(1, chList.size());  
        }  	
	}
	
	@isTest static void test_scheduler() {
		// Implement test code
		BrandNewRegistrationBatchScheduler job = new BrandNewRegistrationBatchScheduler();
		String sch = '0 0 23 * * ?'; 
		Id scID = System.schedule('Test New Reg Batch Job', sch, job);

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
	
}