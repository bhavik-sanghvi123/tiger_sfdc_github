/*
* @author        Rey Austral
* @date          3.13.2019
* @description   Test class for BrandRelationshipTriggerHandler
* @revision(s) 
*/
@isTest
private class BrandRelationshipTriggerHandlerTest {
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
    
    @isTest
    static void test_CreationOfBrand() {
		Test.enableChangeDataCapture();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
        lProduct[0].Name = 'ProductName - 2';
        update lProduct;
        
        BrandRelationship__c brand = new BrandRelationship__c();                
        brand.Type__c = 'Lead';
        brand.Status__c = 'Contacted';            
        brand.BrandRelationship__c = lProduct[0].Id;
        brand.User__c =  [Select Id from Contact Limit 1].Id;
        brand.PrimaryContact__c = [Select Id from Contact Limit 1].Id;   
        brand.Active__c = true;   
        
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {   
            insert brand;
			Test.getEventBus().deliver();
            Contact updatedContact = [Select MCEnsureEndUser__c  From Contact Limit 1];
            
            System.assertEquals(true, updatedContact.MCEnsureEndUser__c);
            brand.Active__c = false;
            update brand;
			Test.getEventBus().deliver();
            
            delete brand;
			Test.getEventBus().deliver();
            updatedContact = [Select MCEnsureEndUser__c,MCEnsureMainContact__c  From Contact Limit 1];
            //should still be true because there is still existing brand with the same keybrand for the contact
            System.assertEquals(true, updatedContact.MCEnsureEndUser__c);
            System.assertEquals(true, updatedContact.MCEnsureMainContact__c);
        }
    }

    
    
    @isTest
    static void test_CreationOfBrand2() {
		Test.enableChangeDataCapture();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
        lProduct[0].Name = 'ProductName - 2';
        update lProduct;

        List<Contact> conList = [Select Id from Contact Limit 2];
        
        BrandRelationship__c brand = new BrandRelationship__c();                
        brand.Type__c = 'Lead';
        brand.Status__c = 'Contacted';            
        brand.BrandRelationship__c = lProduct[0].Id;
        brand.User__c =  conList[0].Id;
        brand.PrimaryContact__c = conList[1].Id;   
        brand.Active__c = true;   
        
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {   
            insert brand;
			Test.getEventBus().deliver();
            Contact updatedContact = [Select MCEnsureEndUser__c  From Contact Limit 1];
            
            System.assertEquals(true, updatedContact.MCEnsureEndUser__c);
            brand.Active__c = false;
            update brand;
			Test.getEventBus().deliver();
            
            delete brand;
			Test.getEventBus().deliver();
            updatedContact = [Select MCEnsureEndUser__c,MCEnsureMainContact__c  From Contact Limit 1];
            //should still be true because there is still existing brand with the same keybrand for the contact
            System.assertEquals(true, updatedContact.MCEnsureEndUser__c);
            //System.assertEquals(true, updatedContact.MCEnsureMainContact__c);
        }
    }


    @isTest
    static void test_CreationOfBrandOthers() {
		Test.enableChangeDataCapture();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
        lProduct[0].Name = 'ProductName - 2';
        lProduct[0].Keybrand__c = CommonConstant.PRODUCT_KEYBRAND_OTHERS;
        update lProduct;
        
        BrandRelationship__c brand = new BrandRelationship__c();                
        brand.Type__c = 'Lead';
        brand.Status__c = 'Contacted';            
        brand.BrandRelationship__c = lProduct[0].Id;
        brand.User__c =  [Select Id from Contact Limit 1].Id;
        brand.PrimaryContact__c = [Select Id from Contact Limit 1].Id;   
        brand.Active__c = true;   
        
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {   
            insert brand;
			Test.getEventBus().deliver();
            Contact updatedContact = [Select MCOthersEndUser__c,MCOthersMainContact__c  From Contact Limit 1];
            
            System.assertEquals(true, updatedContact.MCOthersEndUser__c);				
            System.assertEquals(true, updatedContact.MCOthersMainContact__c);
        }
    }
    
    @isTest
    static void test_CreationOfBrandGrow() {
		Test.enableChangeDataCapture();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
        lProduct[0].Name = 'ProductName - 2';
        lProduct[0].Keybrand__c = CommonConstant.PRODUCT_KEYBRAND_GROW;
        update lProduct;
        
        BrandRelationship__c brand = new BrandRelationship__c();                
        brand.Type__c = 'Lead';
        brand.Status__c = 'Contacted';            
        brand.BrandRelationship__c = lProduct[0].Id;
        brand.User__c =  [Select Id from Contact Limit 1].Id;
        brand.PrimaryContact__c = [Select Id from Contact Limit 1].Id;   
        brand.Active__c = true;   
        
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {   
            insert brand;
			Test.getEventBus().deliver();
            Contact updatedContact = [Select MCGrowEndUser__c,MCGrowMainContact__c  From Contact Limit 1];
            
            System.assertEquals(true, updatedContact.MCGrowEndUser__c);				
            System.assertEquals(true, updatedContact.MCGrowMainContact__c);
        }
    }
    
    @isTest
    static void test_CreationOfBrandDifferentUser() {
		Test.enableChangeDataCapture();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
        lProduct[0].Name = 'ProductName - 2';
        update lProduct;
        
        //reset the contact values
        List<Contact> contactList =  [Select Id,MCEnsureEndUser__c,MCEnsureMainContact__c from Contact];
        contactList.get(0).MCEnsureEndUser__c = false;
        contactList.get(0).MCEnsureMainContact__c = false;
        Update contactList;
        
        BrandRelationship__c brand = new BrandRelationship__c();                
        brand.Type__c = 'Lead';
        brand.Status__c = 'Contacted';            
        brand.BrandRelationship__c = lProduct[0].Id;
        brand.User__c =  contactList.get(0).Id;
        brand.PrimaryContact__c = contactList.get(1).Id;   
        brand.Active__c = true;   
        
        
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {   
            insert brand;
			Test.getEventBus().deliver();
            
            Contact updatedContact = [Select MCEnsureEndUser__c,MCEnsureMainContact__c  From Contact Where Id =: contactList.get(0).Id];				
            System.assertEquals(true, updatedContact.MCEnsureEndUser__c);
            //System.assertEquals(false, updatedContact.MCEnsureMainContact__c);
            //Ln18 BR Main Contact, End User = contactList.get(0).Id, values will return True
            
            updatedContact = [Select MCEnsureEndUser__c,MCEnsureMainContact__c  From Contact Where Id =: contactList.get(1).Id];				
            System.assertEquals(false, updatedContact.MCEnsureEndUser__c);
            System.assertEquals(true, updatedContact.MCEnsureMainContact__c);
        }
    }
    
    @isTest
    static void test_BrandSwitch() {
		Test.enableChangeDataCapture();
        List<Contact> contactList =  [Select Id, UserLatestBrandSwitch__c from Contact limit 1];
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {
            
            Product2 prod = new Product2();          
            //add new required field in here
            prod.Name = 'ProductName - 1';           
            prod.AvailableBrandRelationship__c = true;
            prod.AvailableForCurrentAndPreviousBrand__c = true;
            prod.Market__c = 'PH';
            prod.Keybrand__c = 'Ensure';
            prod.IsActive = true;
            prod.ProductCode = '1123455';
            insert prod;
            
            BrandRelationship__c brand = new BrandRelationship__c();              
            brand.Type__c = 'User';
            brand.Status__c = 'New';            
            brand.BrandRelationship__c = prod.Id;
            brand.User__c =  contactList.get(0).Id;
            brand.PrimaryContact__c = contactList.get(0).Id;   
            brand.Active__c = true;
            insert brand;
			Test.getEventBus().deliver();	
            
            BrandRelationship__c brand2 = [select Id, CurrentBrand__c from BrandRelationship__c where Id = :brand.Id];
            brand2.CurrentBrand__c = prod.Id;
            update brand2;
			Test.getEventBus().deliver();		
            
            Contact con1 = [Select Id, UserLatestBrandSwitch__c From Contact Where Id =: contactList.get(0).Id];
            BrandRelationship__c brand3 = [select Id, BrandSwitchDate__c from BrandRelationship__c where Id = :brand.Id];
            
            System.assertEquals(brand3.Id, con1.UserLatestBrandSwitch__c);
            System.assertEquals(true, brand3.BrandSwitchDate__c != null);
        }
    }

    @isTest
    static void test_utility() {
        Contact con = new Contact();

        BrandRelationshipTriggerHandler brHandler = new BrandRelationshipTriggerHandler();

        System.assert(brHandler.updateEndUserMarketField(con, CommonConstant.PRODUCT_KEYBRAND_SIMILAC, true).MCSimilacEndUser__c);
        System.assert(brHandler.updateEndUserMarketField(con, CommonConstant.PRODUCT_KEYBRAND_GROW, true).MCGrowEndUser__c);
        System.assert(brHandler.updateEndUserMarketField(con, CommonConstant.PRODUCT_KEYBRAND_PEDIASURE, true).MCPediasureEndUser__c);
        System.assert(brHandler.updateEndUserMarketField(con, CommonConstant.PRODUCT_KEYBRAND_ENSURE, true).MCEnsureEndUser__c);
        System.assert(brHandler.updateEndUserMarketField(con, CommonConstant.PRODUCT_KEYBRAND_GLUCERNA, true).MCGlucernaEndUser__c);
        System.assert(brHandler.updateEndUserMarketField(con, CommonConstant.PRODUCT_KEYBRAND_OTHERS, true).MCOthersEndUser__c);
        System.assert(brHandler.updateEndUserMarketField(con, CommonConstant.PRODUCT_KEYBRAND_SIMILACMOM, true).MCSimilacMomEndUser__c);

        System.assert(brHandler.updatePrimaryContactMarketField(con, CommonConstant.PRODUCT_KEYBRAND_SIMILAC, true).MCSimilacMainContact__c);
        System.assert(brHandler.updatePrimaryContactMarketField(con, CommonConstant.PRODUCT_KEYBRAND_GROW, true).MCGrowMainContact__c);
        System.assert(brHandler.updatePrimaryContactMarketField(con, CommonConstant.PRODUCT_KEYBRAND_PEDIASURE, true).MCPediasureMainContact__c);
        System.assert(brHandler.updatePrimaryContactMarketField(con, CommonConstant.PRODUCT_KEYBRAND_ENSURE, true).MCEnsureMainContact__c);
        System.assert(brHandler.updatePrimaryContactMarketField(con, CommonConstant.PRODUCT_KEYBRAND_GLUCERNA, true).MCGlucernaMainContact__c);
        System.assert(brHandler.updatePrimaryContactMarketField(con, CommonConstant.PRODUCT_KEYBRAND_OTHERS, true).MCOthersMainContact__c);
        System.assert(brHandler.updatePrimaryContactMarketField(con, CommonConstant.PRODUCT_KEYBRAND_SIMILACMOM, true).MCSimilacMomMainContact__c);
    }
    
    @isTest
    static void test_updateChildEndUserCount_Insert() {
		Test.enableChangeDataCapture();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
        lProduct[0].Name = 'ProductName - 2';
        update lProduct;

        Contact conAdult = [Select Id from Contact WHERE RecordType.Name = 'Adult' Limit 1][0];
		Contact conChild = [Select Id from Contact WHERE RecordType.Name = 'Child' LIMIT 1][0];		
        
        BrandRelationship__c brand = new BrandRelationship__c();                
        brand.Type__c = 'Lead';
        brand.Status__c = 'Contacted';            
        brand.BrandRelationship__c = lProduct[0].Id;
        brand.User__c =  conChild.Id;
        brand.PrimaryContact__c = conAdult.Id;   
        brand.Active__c = true;   
        
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        System.runAs(sysad) {   
            insert brand;
			Test.getEventBus().deliver();
            Contact conCheck = [SELECT Brand_Relationship_EndUser_Child_Count__c FROM Contact WHERE Id =: conChild.id];
            System.assertEquals(conCheck.Brand_Relationship_EndUser_Child_Count__c, 1);
        }
    }
    
    @isTest
    static void test_updateChildEndUserCount_Update() {
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
			Test.getEventBus().deliver();
            Contact conCheck = [SELECT Brand_Relationship_EndUser_Child_Count__c FROM Contact WHERE Id =: conChild.id];
            System.assertEquals(conCheck.Brand_Relationship_EndUser_Child_Count__c, 2);
            
            BrandRelationship__c brandUpdate = new BrandRelationship__c();     
            brandUpdate.Id = brand1.Id;
            brandUpdate.User__c = conAdult.Id;
            update brandUpdate;
            Contact conCheck1 = [SELECT Brand_Relationship_EndUser_Child_Count__c FROM Contact WHERE Id =: conChild.id];
            System.assertEquals(conCheck1.Brand_Relationship_EndUser_Child_Count__c, 1);
        }
    }
    
    @isTest
    static void test_updateChildEndUserCount_Delete() {
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
			Test.getEventBus().deliver();
            Contact conCheck = [SELECT Brand_Relationship_EndUser_Child_Count__c FROM Contact WHERE Id =: conChild.id];
            System.assertEquals(conCheck.Brand_Relationship_EndUser_Child_Count__c, 2);
            
            BrandRelationship__c brandDelete = new BrandRelationship__c();     
            brandDelete.Id = brand2.Id;
            delete brandDelete;
            Contact conCheck1 = [SELECT Brand_Relationship_EndUser_Child_Count__c FROM Contact WHERE Id =: conChild.id];
            System.assertEquals(conCheck1.Brand_Relationship_EndUser_Child_Count__c, 1);
        }
    }
}