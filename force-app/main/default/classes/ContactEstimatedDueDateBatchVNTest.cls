@isTest
private class ContactEstimatedDueDateBatchVNTest {
  @testsetup
    static void setupData() {
      User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
        System.runAs(sysad) {        
            List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
            List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            List<BrandRelationship__c> lBrandRelationship = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProduct.get(0).Id);
        }
    }

  @isTest static void test_creationRecordBatch() {
    Account acc = [Select Id,Market__c from Account Limit 1];
    acc.Market__c = 'VN';
    update acc;
      
    Contact con = [Select Id,EstimatedDueDate__c,WeeksOfPregnancy__c from Contact Limit 1];
    con.EstimatedDueDate__c = Date.today().addMonths(-10);
    Update con;
    con = [Select Id,EstimatedDueDate__c,WeeksOfPregnancy__c, market__c from Contact Limit 1];
   
    BrandRelationship__c br = [SELECT Id, LatestMilestone__c, MilestoneStatus__c FROM BrandRelationship__c Limit 1];
    br.User__c = con.Id;
    br.LatestMilestone__c = '40 Weeks';
    Update br;  

    System.Test.startTest();
        ContactEstimatedDueDateBatch_VN ucs = new ContactEstimatedDueDateBatch_VN();
        Database.executeBatch(ucs, 200);
    System.Test.stopTest();
      
    con = [Select Id,EstimatedDueDate__c,WeeksOfPregnancy__c, market__c from Contact Limit 1];
    //Estimated Due Date should reset
    System.assertEquals(con.EstimatedDueDate__c, null);      
  
	
  }
    
  @isTest static void test_scheduler() {
    // Implement test code
    ContactEstimatedDueDate_VN_Sched job = new   ContactEstimatedDueDate_VN_Sched();
    String sch = '0 0 23 * * ?'; 
    Id scID = System.schedule('Test Cost Estimate Batch Job VN', sch, job);

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