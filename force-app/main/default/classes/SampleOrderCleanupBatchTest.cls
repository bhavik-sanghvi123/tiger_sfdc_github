// @isTest for deletion
public class SampleOrderCleanupBatchTest {} /*
    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
            List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
            
            //Create Region
            List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
            //Create City
            List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
            List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, lContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
            PricebookEntry entry = TestDataFactory.createPricebookEntry();
            Insert entry;
            List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, entry.Product2Id);
            
            ChannelResponse__c ch = new ChannelResponse__c();
            ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
            ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
            ch.RegistrationDate__c = Date.today();
            ch.IsSample_Requested__c = true;
            ch.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_SUCCESSFUL;
            ch.DeliveryAddress__c =  [Select Id from Address__c Limit 1].Id;
            ch.ProductSampleRequested__c = [Select Id from Product2 where Name = 'Test Product'].Id;
            
            insert ch;
            
            ch = new ChannelResponse__c();
            ch.BrandRelationship__c = [Select Id from BrandRelationship__c Limit 1].Id;
            ch.Channel__c = [Select Id From Channel__c Limit 1].Id;
            ch.RegistrationDate__c = Date.today();
            ch.IsSample_Requested__c = true;
            ch.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_SUCCESSFUL;
            ch.DeliveryAddress__c =  [Select Id from Address__c Limit 1].Id;
            ch.ProductSampleRequested__c = [Select Id from Product2 where Name = 'Test Product'].Id;
            
            insert ch;
        }
    }
    
    public static testMethod  void executeBatch() {
        User sysad = [Select Id From User where LastName = 'tstSysAd'];
        List<ChannelResponse__c> chList = [Select id from ChannelResponse__c];
        System.assertEquals(2, chList.size());
        Test.startTest();
        System.runAs(sysad) {
            
            SampleOrderCleanupBatch psob = new SampleOrderCleanupBatch();
            Database.executeBatch(psob, 200);
            
            
        }
        Test.stopTest();  
        chList = [Select id from ChannelResponse__c];
        System.assertEquals(1, chList.size());
    }
} */