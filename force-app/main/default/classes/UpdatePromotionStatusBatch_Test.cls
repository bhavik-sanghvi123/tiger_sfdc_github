@isTest
public class UpdatePromotionStatusBatch_Test {

    @testsetup
    static void setupData() {
    
    	List<Promotion__c> promList = new List<Promotion__c>();

    	//Create a Planned Campaign
    	Promotion__c prom1 = new Promotion__c();
    	prom1.Name = 'Test Promotion - A';
    	prom1.Status__c = 'Planned';
    	prom1.StartDate__c = Date.today();
    	prom1.EndDate__c = Date.today().addDays(7);
        prom1.Market__c = 'VN';
    	promList.add(prom1);

    	//Create a In Progress Campaign
    	Promotion__c prom2 = new Promotion__c();
    	prom2.Name = 'Test Promotion - B';
    	prom2.Status__c = 'In Progress';
    	prom2.StartDate__c = Date.today().addDays(-7);
    	prom2.EndDate__c = Date.today();
        prom2.Market__c = 'VN';
    	promList.add(prom2);
    	
    	insert promList;
    }

    public static testMethod  void testUpdate() {
    	System.Test.startTest();
    		UpdatePromotionStatusBatch ucs = new UpdatePromotionStatusBatch();
    		Database.executeBatch(ucs, 200);

    		UpdatePromotionStatusSchedule job = new UpdatePromotionStatusSchedule();
    		String sch = '0 0 23 * * ?'; 
    		system.schedule('Test Promotion Status Batch Job', sch, job);
    		
    	System.Test.stopTest();

    	List<Promotion__c> inProgressPromotionList = [SELECT Id FROM Promotion__c WHERE Status__c = 'In Progress'];
    	List<Promotion__c> completedPromotionList = [SELECT Id FROM Promotion__c WHERE Status__c = 'Completed'];

    	System.assertEquals(1, inProgressPromotionList.size(), 'Promotion with Planned Status should be updated to In Progress.');
    	System.assertEquals(1, completedPromotionList.size(), 'Promotion with In Progress Status should be updated to Completed.');

   	}
    
}