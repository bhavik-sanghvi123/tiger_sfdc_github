@isTest
public class UpdateChildEndUserCountBatchTest {
    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {	  
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            List<Contact> lContact = TestDataFactory.createTestAdultContact(2, lAccount.get(0).Id);		
            List<Contact> lContactChild = TestDataFactory.createTestChildContact(1, lAccount.get(0).Id);		
            List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProduct.get(0).Id);	
        }
    }
    
    static testmethod void test_UpdateChildEndUserCountBatch() {
        Test.enableChangeDataCapture();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(2);
        lProduct[0].Name = 'ProductName - 2';
        lProduct[1].Name = 'ProductName - 3';
        update lProduct;
        
        Contact conAdult = [Select Id from Contact WHERE RecordType.Name = 'Adult' Limit 1][0];
        Contact conChild = [Select Id from Contact WHERE RecordType.Name = 'Child' LIMIT 1][0];		
        
        BrandRelationship__c brand1 = new BrandRelationship__c();                
        brand1.Type__c = 'Lead';
        brand1.Status__c = 'Contacted';            
        brand1.BrandRelationship__c = lProduct[0].Id;
        brand1.User__c =  conChild.Id;
        brand1.PrimaryContact__c = conAdult.Id;   
        brand1.Active__c = true;   
        
        BrandRelationship__c brand2 = new BrandRelationship__c();                
        brand2.Type__c = 'Lead';
        brand2.Status__c = 'Contacted';            
        brand2.BrandRelationship__c = lProduct[1].Id;
        brand2.User__c =  conChild.Id;
        brand2.PrimaryContact__c = conAdult.Id;   
        brand2.Active__c = true;   
        List<BrandRelationship__c> brandInsertList = new List<BrandRelationship__c>{brand1, brand2};
            
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {   
            insert brandInsertList;
            Contact conCheck = [SELECT Brand_Relationship_EndUser_Child_Count__c FROM Contact WHERE Id =: conChild.id];
            System.assertEquals(conCheck.Brand_Relationship_EndUser_Child_Count__c, 0);
            
            Test.startTest();
            UpdateChildEndUserCountBatch batch = new UpdateChildEndUserCountBatch('PH', 0, 60); 
            System.schedule('jobName', '0 5 * * * ?', batch);
            Database.executebatch(batch, 50);
            Test.stopTest();
            
            Contact conCheck1 = [SELECT Brand_Relationship_EndUser_Child_Count__c FROM Contact WHERE Id =: conChild.id];
            System.assertEquals(conCheck1.Brand_Relationship_EndUser_Child_Count__c, 2);
        }
    }
}