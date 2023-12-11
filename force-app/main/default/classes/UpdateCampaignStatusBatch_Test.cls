@isTest 
public class UpdateCampaignStatusBatch_Test{

    @testsetup
    static void setupData() {
    
    	List<Campaign> campList = new List<Campaign>();

    	//Create a Planned Campaign
    	Campaign camp1 = new Campaign();
    	camp1.Name = CommonConstant.TESTCAMPAIGN;
    	camp1.Status = CommonConstant.PLANNED;
    	camp1.StartDate = Date.today();
    	camp1.EndDate = Date.today().addDays(7);
    	camp1.ApprovalStatus__c = CommonConstant.APPROVED;
        camp1.Market__c = CommonConstant.MARKET_VN;
        camp1.Objective__c = CommonConstant.MARKET_VN;
    	campList.add(camp1);

    	//Create a In Progress Campaign
    	Campaign camp2 = new Campaign();
    	camp2.Name = CommonConstant.TESTCAMPAIGN2;
    	camp2.Status = CommonConstant.IN_PROGRESS;
    	camp2.StartDate = Date.today().addDays(-7);
    	camp2.EndDate = Date.today();
        camp2.Market__c = CommonConstant.MARKET_VN;
        camp2.Objective__c = CommonConstant.MARKET_VN;
    	campList.add(camp2);
    	
    	insert campList;
    }

    public static testMethod  void testUpdate() {
    	System.Test.startTest();
    		UpdateCampaignStatusBatch ucs = new UpdateCampaignStatusBatch();
    		Database.executeBatch(ucs, 200);

    		UpdateCampaignStatusSchedule job = new UpdateCampaignStatusSchedule();
    		String sch = '0 0 23 * * ?'; 
    		system.schedule('Test Campaign Status Batch Job', sch, job);
    		
    	System.Test.stopTest();

    	List<Campaign> inProgressCampaignList = [SELECT Id FROM Campaign WHERE Status = 'In Progress'];
    	List<Campaign> completedCampaignList = [SELECT Id FROM Campaign WHERE Status = 'Completed'];

    	System.assertEquals(1, inProgressCampaignList.size(), 'Campaign with Planned Status should be updated to In Progress.');
    	System.assertEquals(1, completedCampaignList.size(), 'Campaign with In Progress Status should be updated to Completed.');

   	}
}