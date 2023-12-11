/*
* @author        Rey Austral
* @date          4.17.2019
* @description   Test class for RewardReportGeneratorController
* @revision(s) 
*/
@isTest
private class RewardReportGeneratorControllerTest {
	
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {	    		    	
			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			lContact.get(0).RewardPoints__c = 1000;
			Update lContact;

			List<Reward__c> lReward = TestDataFactory.createReward(4,lContact.get(0).Id, Date.today());
			List<Reward__c> lRedeemReward = TestDataFactory.createReward(2,lContact.get(0).Id, Date.today());
			
			List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);	      
	        lProduct[0].AvailableForRewardRedemption__c = TRUE;
	        lProduct[0].RewardsPointsRequired__c = 200;
	        update lProduct[0];

			Id recTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_REDEEM_RECORDTYPE).getRecordTypeId();
			for(Reward__c rew : lRedeemReward) {
				rew.RecordTypeId = recTypeId;
				rew.DeliveryStatus__c =  CommonConstant.ORDER_STATUS_SUBMITTED;
				rew.Quantity__c = 1;
				rew.ProductForRedemption__c = lProduct.get(0).Id;
			}

			Update lRedeemReward;
		}
    }

	@isTest
	static void test_queryOrderItemReport() {
		User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
		System.runAs(sysad) {	    	
			System.Test.startTest();
			System.debug([SELECT Id, Name FROM ContentWorkspace]);
				List<Reward__c> rewardList = RewardReportGeneratorController.queryRewardItemReport();
				RewardReportGeneratorController controller = new RewardReportGeneratorController();
				RewardReportGeneratorController.RewardReportWrapper filestring = RewardReportGeneratorController.getExcelFileAsBase64String();
			System.Test.stopTest();
		

			System.assertEquals(2 , rewardList.size());
			System.assertEquals('VW5pdC5UZXN0', filestring.fileContent);
		}
	}
	
}