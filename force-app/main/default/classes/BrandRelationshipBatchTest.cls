// @isTest for deletion
public class BrandRelationshipBatchTest {} /*
	@testsetup
    static void setupData() {
    	
    	User sysad = new User();
    	
        sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');      
        insert sysad;
    	

        System.runAs(sysad) {	  
	    	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            lProduct.get(0).Market__c = 'VN';
            update lProduct;

			List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            lAccount.get(0).Market__c = 'VN';
            Update lAccount;

			List<Contact> lContact = TestDataFactory.createTestAdultContact(2, lAccount.get(0).Id);		
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, lProduct.get(0).Id);	
		}
    }

	@isTest
	static void test_CreationOfBrand() {
		
		
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {   
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            lProduct[0].Name = 'ProductName - 2';
            lProduct[0].Market__c = 'VN';
            update lProduct;

            BrandRelationship__c brand = new BrandRelationship__c();                
            brand.Type__c = 'Lead';
            brand.Status__c = 'Contacted';            
            brand.BrandRelationship__c = lProduct[0].Id;
            brand.User__c =  [Select Id from Contact Limit 1].Id;
            brand.PrimaryContact__c = [Select Id from Contact order by Name desc Limit 1].Id;   
            brand.Active__c = true;   

			insert brand;			
			//Test.setCreatedDate(brand.Id, DateTime.newInstance(2019,06,29));
			Test.setCreatedDate(brand.Id, DateTime.now());

			test.StartTest();

				BrandRelationshipBatch umd = new BrandRelationshipBatch();
            	Database.executeBatch(umd, 200);


			test.StopTest();

			Contact updatedContact = [Select MCEnsureEndUser__c, MCEnsureMainContact__c  From Contact where id =: brand.PrimaryContact__c];
			System.assertEquals(true, updatedContact.MCEnsureMainContact__c);
			
			updatedContact = [Select MCEnsureEndUser__c,MCEnsureMainContact__c  From Contact Limit 1];
			//should still be true because there is still existing brand with the same keybrand for the contact
			System.assertEquals(true, updatedContact.MCEnsureEndUser__c);
			
		}
	}

	@isTest
	static void test_CreationOfBrandOthers() {
		
		
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {   
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            lProduct[0].Name = 'ProductName - 2';
            lProduct[0].Keybrand__c = CommonConstant.PRODUCT_KEYBRAND_OTHERS;
            lProduct[0].Market__c = 'VN';
            update lProduct;


            BrandRelationship__c brand = new BrandRelationship__c();                
            brand.Type__c = 'Lead';
            brand.Status__c = 'Contacted';            
            brand.BrandRelationship__c = lProduct[0].Id;
            brand.User__c =  [Select Id from Contact Limit 1].Id;
            brand.PrimaryContact__c = [Select Id from Contact Limit 1].Id;   
            brand.Active__c = true;   

			insert brand;
				//Test.setCreatedDate(brand.Id, DateTime.newInstance(2019,06,29));
				Test.setCreatedDate(brand.Id, DateTime.now());

			test.StartTest();
				
				BrandRelationshipBatch umd = new BrandRelationshipBatch();
            	Database.executeBatch(umd, 200);

				
			test.StopTest();

			Contact updatedContact = [Select MCOthersEndUser__c,MCOthersMainContact__c  From Contact Limit 1];

			System.assertEquals(true, updatedContact.MCOthersEndUser__c);				
			System.assertEquals(true, updatedContact.MCOthersMainContact__c);
		}
	}

	@isTest
	static void test_CreationOfBrandGrow() {
		
		
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {   
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            lProduct[0].Name = 'ProductName - 2';
            lProduct[0].Keybrand__c = CommonConstant.PRODUCT_KEYBRAND_GROW;
            lProduct[0].Market__c = 'VN';
            update lProduct;

            BrandRelationship__c brand = new BrandRelationship__c();                
            brand.Type__c = 'Lead';
            brand.Status__c = 'Contacted';            
            brand.BrandRelationship__c = lProduct[0].Id;
            brand.User__c =  [Select Id from Contact Limit 1].Id;
            brand.PrimaryContact__c = [Select Id from Contact Limit 1].Id;   
            brand.Active__c = true;   
			insert brand;
				//Test.setCreatedDate(brand.Id, DateTime.newInstance(2019,06,29));
				Test.setCreatedDate(brand.Id, DateTime.now());
			test.StartTest();
				
				BrandRelationshipBatch umd = new BrandRelationshipBatch();
            	Database.executeBatch(umd, 200);

				
			test.StopTest();

			Contact updatedContact = [Select MCGrowEndUser__c,MCGrowMainContact__c  From Contact Limit 1];

			System.assertEquals(true, updatedContact.MCGrowEndUser__c);				
			System.assertEquals(true, updatedContact.MCGrowMainContact__c);
		}
	}
	
}*/