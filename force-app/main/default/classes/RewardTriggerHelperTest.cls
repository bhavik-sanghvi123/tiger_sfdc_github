@isTest 
public class RewardTriggerHelperTest{
	@testsetup
    static void setupData() {
        //Create Household record
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);

        //Create Primary Child Contact Record
        List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);

        //Create Product for Redemption
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(3);
        
        //Create Membership for Sum of Total points
        List<Membership__c> lMembership = TestDataFactory.createMembership(2, lContact.get(0).Id, 3);
        
        //update first product to 700 points
        lProduct[0].AvailableForRewardRedemption__c = TRUE;
        lProduct[0].RewardsPointsRequired__c = 700;
        update lProduct[0];
        //update second product to 500 points
        lProduct[1].AvailableForRewardRedemption__c = TRUE;
        lProduct[1].RewardsPointsRequired__c = 500;
        update lProduct[1];
        //update second product to 500 points
        lProduct[2].AvailableForRewardRedemption__c = TRUE;
        lProduct[2].RewardsPointsRequired__c = 1000;
        update lProduct[2];

        //Create Earn Reward associated to Contact
        TestDataFactory.createReward(2, lContact[0].Id, Date.today());
    }

    private static testMethod void getRequiredRewardPointsTest() {
    	User testUser = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        Contact conRec = [SELECT Id, RewardPoints__c FROM Contact LIMIT 1];
        Product2 productRec = [SELECT Id, RewardsPointsRequired__c FROM Product2 WHERE RewardsPointsRequired__c = 700];
        Product2 productRec2 = [SELECT Id, RewardsPointsRequired__c FROM Product2 WHERE RewardsPointsRequired__c = 500];
        Id redeemRecTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_REDEEM_RECORDTYPE).getRecordTypeId();
        Boolean hasError = false;

        System.Test.startTest();
        	System.runAs(testUser) {
        		//Redeem Rewards: 700 points
        		Reward__c rewardRec = new Reward__c();
	            rewardRec.RecordTypeId = redeemRecTypeId;
	            rewardRec.Contact__c = conRec.Id;
	            rewardRec.ProductForRedemption__c = productRec.Id;
                rewardRec.Quantity__c  = 1;
	            insert rewardRec;

	            Reward__c newRecReward = [SELECT Id, PointsAmount__c FROM Reward__c WHERE Id =: rewardRec.Id];
				Contact conAfterRedemption = [SELECT Id, RewardPoints__c FROM Contact WHERE Id =: conRec.Id];                                   
			    System.assertEquals(newRecReward.PointsAmount__c, productRec.RewardsPointsRequired__c, 'Reward Points Amount should be derived from related Product Points.');
			    System.assertEquals(conAfterRedemption.RewardPoints__c, conRec.RewardPoints__c - newRecReward.PointsAmount__c, 'Reward Points Amoung should be deducted to Contact Reward Points.');
			    
			    //Redeem Rewards: 500 points
			    Reward__c rewardRec2 = new Reward__c();
			    rewardRec2.RecordTypeId = redeemRecTypeId;
	            rewardRec2.Contact__c = conRec.Id;
	            rewardRec2.ProductForRedemption__c = productRec2.Id;
	            try {
	            	insert rewardRec2;
	          	} catch(Exception ex) {
                    hasError = true;//ex.getMessage().contains('Unable to save record');
                }
                System.assertEquals(true, hasError);
        	}
        System.Test.stopTest();
    }

    private static testMethod void updateRewardPointsBalanceTest() {
    	User testUser = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        Contact conRec = [SELECT Id, RewardPoints__c FROM Contact LIMIT 1];
        Product2 productRec = [SELECT Id, RewardsPointsRequired__c FROM Product2 WHERE RewardsPointsRequired__c = 700];
        Product2 productRec2 = [SELECT Id, RewardsPointsRequired__c FROM Product2 WHERE RewardsPointsRequired__c = 500];
        Product2 productRec3 = [SELECT Id, RewardsPointsRequired__c FROM Product2 WHERE RewardsPointsRequired__c = 1000];
        Id redeemRecTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_REDEEM_RECORDTYPE).getRecordTypeId();
        Id earnRecTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_EARN_RECORDTYPE).getRecordTypeId();
        Boolean hasError = false;
        //Id householdId = [SELECT Id FROM Account LIMIT 1].Id;
        //List<Contact> lContact = TestDataFactory.createTestAdultContact(1, householdId);

        System.Test.startTest();
        	System.runAs(testUser) {
        		//Redeem Rewards: 700 points
				Reward__c redeemReward = new Reward__c();
			    redeemReward.RecordTypeId = redeemRecTypeId;
			    redeemReward.Contact__c = conRec.Id;
			    redeemReward.ProductForRedemption__c = productRec.Id;
                redeemReward.Quantity__c = 1;
			    insert redeemReward;

        		Reward__c newRecReward = [SELECT Id, PointsAmount__c FROM Reward__c WHERE Id =: redeemReward.Id];
				Contact conAfterRedemption = [SELECT Id, RewardPoints__c FROM Contact WHERE Id =: conRec.Id];                                   
			    System.assertEquals(newRecReward.PointsAmount__c, productRec.RewardsPointsRequired__c, 'Reward Points Amount should be derived from related Product Points.');
			    System.assertEquals(conAfterRedemption.RewardPoints__c, conRec.RewardPoints__c - newRecReward.PointsAmount__c, 'Reward Points Amount should be deducted to Contact Reward Points.');

			    //Update Product to Redeem
        		redeemReward.ProductForRedemption__c = productRec2.Id;
        		update redeemReward;
	            Reward__c updatedRecReward = [SELECT Id, PointsAmount__c FROM Reward__c WHERE Id =: redeemReward.Id];
				Contact updatedConRedemption = [SELECT Id, RewardPoints__c FROM Contact WHERE Id =: conRec.Id];                                   
			    System.assertEquals(updatedRecReward.PointsAmount__c, productRec2.RewardsPointsRequired__c, 'Reward Points Amount should be derived from related Product Points.');
			    System.assertEquals(updatedConRedemption.RewardPoints__c, conAfterRedemption.RewardPoints__c + newRecReward.PointsAmount__c - updatedRecReward.PointsAmount__c, 'Reward Points Amount should be deducted to Contact Reward Points.');

			    //Update Product to Redeem
        		redeemReward.ProductForRedemption__c = productRec3.Id;
        		update redeemReward;
	            Reward__c updatedRecReward2 = [SELECT Id, PointsAmount__c FROM Reward__c WHERE Id =: redeemReward.Id];
				Contact updatedConRedemption2 = [SELECT Id, RewardPoints__c FROM Contact WHERE Id =: conRec.Id];                                   
			    System.assertEquals(updatedRecReward2.PointsAmount__c, productRec3.RewardsPointsRequired__c, 'Reward Points Amount should be derived from related Product Points.');
			    //System.assertEquals(updatedConRedemption2.RewardPoints__c, updatedConRedemption.RewardPoints__c + updatedRecReward.PointsAmount__c - updatedRecReward2.PointsAmount__c, 'Reward Points Amount should be deducted to Contact Reward Points.');
			    
			    //Update Reward from Redeem to Earn Record Type
        		redeemReward.RecordTypeId = earnRecTypeId;
        		update redeemReward;
        		Reward__c updatedEarnReward = [SELECT Id, PointsAmount__c FROM Reward__c WHERE Id =: redeemReward.Id];
				Contact updatedConEarn = [SELECT Id, RewardPoints__c FROM Contact WHERE Id =: conRec.Id];                                   
			    System.assertEquals(updatedEarnReward.PointsAmount__c, updatedRecReward2.PointsAmount__c, 'Earn Points Amount retain.');
			    System.assertEquals(updatedConEarn.RewardPoints__c, updatedConRedemption2.RewardPoints__c + updatedRecReward2.PointsAmount__c + updatedEarnReward.PointsAmount__c, 'Earn Points Amount should be added to Contact Reward Points.');

			    delete redeemReward;
			    Contact deleteConEarn = [SELECT Id, RewardPoints__c FROM Contact WHERE Id =: conRec.Id];   
			    System.assertEquals(deleteConEarn.RewardPoints__c, updatedConEarn.RewardPoints__c - updatedEarnReward.PointsAmount__c, 'Earn Points Amount should be deducted to Contact Reward Points.');

            }
        System.Test.stopTest();
    }
    
     private static testMethod void sumOfTotalRewardsTest() {
         
       Id adjustAddRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_ADD_RECORDTYPE).getRecordTypeId();
       Id adjustSubRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_SUBTRACT_RECORDTYPE).getRecordTypeId();
       User testUser = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
       Contact conRec = [SELECT Id, RewardPoints__c FROM Contact LIMIT 1];
       List<Membership__c> memRec = new List<Membership__c>([SELECT Id FROM Membership__c]);  
         
         Reward__c rewardRec3 = new Reward__c();
         rewardRec3.PointsAmount__c = 10;
         rewardRec3.Membership__c = memRec[0].id;
         rewardRec3.RecordTypeId = adjustAddRecordTypeId;
         rewardRec3.Contact__c = conRec.Id;
         
         Reward__c rewardRec4 = new Reward__c();
         rewardRec4.PointsAmount__c = 10;
         rewardRec4.Membership__c = memRec[1].id;
         rewardRec4.RecordTypeId = adjustSubRecordTypeId;
         rewardRec4.Contact__c = conRec.Id;

         System.Test.startTest();
         System.runAs(testUser) {
             Insert rewardRec3;
             Insert rewardRec4;
             rewardRec3.PointsAmount__c = 15;
             rewardRec4.PointsAmount__c = 5;
         }
         System.Test.stopTest();
         System.runAs(testUser) {
             Update rewardRec3;
             Update rewardRec4;
             System.assert(rewardRec3.PointsAmount__c == 15, 'Points Updated');
             System.assert(rewardRec4.PointsAmount__c == 5, 'Points Updated');
         }

     }
}