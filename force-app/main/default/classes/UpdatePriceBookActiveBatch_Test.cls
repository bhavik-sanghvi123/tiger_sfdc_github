@isTest
public class UpdatePriceBookActiveBatch_Test {

    @testsetup
    static void setupData() {
    
    	List<Pricebook2> promList = new List<Pricebook2>();

    	//Create a Planned Campaign
    	Pricebook2 prom1 = new Pricebook2();
    	prom1.Name = CommonConstant.TESTPRICEBOOK;
    	prom1.StartDate__c = Date.today();
    	prom1.EndDate__c = Date.today().addDays(7);
        prom1.Market__c = CommonConstant.MARKET_VN;
    	promList.add(prom1);

    	//Create a In Progress Campaign
    	Pricebook2 prom2 = new Pricebook2();
    	prom2.Name = CommonConstant.TESTPRICEBOOK2;
    	prom2.StartDate__c = Date.today().addDays(-7);
    	prom2.EndDate__c = Date.today();
        prom2.Market__c = CommonConstant.MARKET_VN;
    	promList.add(prom2);
    	
    	insert promList;
    }

    public static testMethod  void testUpdate() {
    	System.Test.startTest();
    		UpdatePriceBookActiveBatch ucs = new UpdatePriceBookActiveBatch();
    		Database.executeBatch(ucs, 200);

    		UpdatePriceBookActiveSchedule job = new UpdatePriceBookActiveSchedule();
    		String sch = '0 0 23 * * ?'; 
    		system.schedule('Test PriceBook Active Status Batch Job', sch, job);
    		
    	System.Test.stopTest();
        
    	List<Pricebook2> activePricebookList = [SELECT Id FROM Pricebook2 WHERE StartDate__c =:  date.today()];
    	List<Pricebook2> inactivePriceBookList = [SELECT Id FROM Pricebook2 WHERE EndDate__c =:  date.today()];


   	}
    
}