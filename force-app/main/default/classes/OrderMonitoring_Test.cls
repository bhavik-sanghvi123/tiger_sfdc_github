@isTest
public class OrderMonitoring_Test {

    @testsetup
    static void setupData() {
    	User sysad = new User();
        sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        sysad.FirstName = 'Data';
        sysad.LastName = 'Migration';
        sysad.UserName = 'datamigration@tigerani.abbott.comtest';
        insert sysad;
        
        System.runAs(sysad) {    

			List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);           

			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProduct.get(0).Id);

			PricebookEntry entry = TestDataFactory.createPricebookEntry();
			Insert entry;

			List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
			Insert lOrder;

			OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
			insert item;
            
		    Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
			
	        Campaign camp = TestDataFactory.createCampaign('New User Call 1', 'Ensure', 'PH');
			insert camp;
			Case ca1 = new Case();
            ca1.RecordtypeId = callRTId;
            ca1.ContactId = lContact[0].Id;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId = lAccount[0].Id;
            ca1.CallRegarding__c = lContact[0].Id;
			ca1.Campaign__c = camp.Id;
            insert ca1;

            lOrder[0].Status = 'Cancelled - Abandoned';
            update lOrder;
    	}
    }

    static testMethod void test1(){
        Test.startTest();
            Set<Id> contactIds = new Set<Id>();
            for(Contact c: [SELECT id FROM Contact]){
                contactIds.add(c.Id);
            }

            OrderMonitoring om = new OrderMonitoring();
            Database.executebatch(om);
            //om.process(contactIds);

        Test.stopTest();
    }

    
	static testMethod void test_scheduler() {
		// Implement test code
		OrderMonitoring_Sched job = new OrderMonitoring_Sched();
		String sch = '0 0 23 * * ?'; 
		Id scID = System.schedule('Test OrderMonitoring_Sched', sch, job);

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