@isTest 
public class DeactivateRewardsBatchTest{

    @testsetup
    static void setupData() {
    
      //Create Household record
      List<Account> lAccount = TestDataFactory.createTestHousehold(1);

      //Create Adult Contact record
      List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);

      //Create Earn Reward Record
      List<Reward__c> lReward = TestDataFactory.createReward(1, lContact.get(0).Id, Date.today().addDays(-1000));
      update lReward[0];
    }

    public static testMethod  void testUpdate() {
      System.Test.startTest();
        DeactivateRewardsBatch dr = new DeactivateRewardsBatch();
        Database.executeBatch(dr, 200);

        DeactivateRewardsSchedule job = new DeactivateRewardsSchedule();
        String day = String.valueOf(Datetime.now().day());
        String month = String.valueOf(Datetime.now().month());

        //String sch = '0 0 0' + ' ' + day + ' ' + month + ' ? 2060';
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Deactivate Reards Batch Job', sch, job);
      System.Test.stopTest();

      List<Reward__c> inActiveRewardsList = [SELECT Id, Active__c FROM Reward__c WHERE Active__c = FALSE];
      System.assertEquals(1, inActiveRewardsList.size(), 'Reward should be deactivated.');

     }
}