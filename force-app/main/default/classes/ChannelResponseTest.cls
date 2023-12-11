@isTest
public class ChannelResponseTest {
    //Change this value to test other countries
    static String country = CommonConstant.MARKET_TW;
	
    @testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , country);
        insert sysad;
        
        System.runAs(sysad) {
	    	List<Channel__c> lChannel = TestDataFactory.createTestChannel(1, country);
			List<Account> lAccount = TestDataFactory.createTestHousehold(1, country);
			List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
	        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1, country);
	        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1, country);
	        List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, lContact.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
	        PricebookEntry entry = TestDataFactory.createPricebookEntry(country);
			Insert entry;
			List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, lContact.get(0).Id, entry.Product2Id);
			Test.getEventBus().deliver();
		}
    }
    
  	@isTest
    static void testInsertCR(){
        Test.enableChangeDataCapture();
        User sysad = [SELECT Id FROM User WHERE Username = 'tstSysAd@test.com' LIMIT 1];
        System.runAs(sysad) {
            Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
            BrandRelationship__c br = [SELECT Id, PrimaryContact__c FROM BrandRelationship__c LIMIT 1];
            Channel__c chan = [SELECT Id FROM Channel__c LIMIT 1];
            Address__c address = [SELECT Id FROM Address__c LIMIT 1];
            Test.startTest();
            TestDataFactory.createTestChannelResponseMultiple(100, br, chan, address, prod, true, 'Pending');
            System.debug('CPU TIME 1: '+Limits.getCPUTime());
            Test.getEventBus().deliver();
            System.debug('CPU TIME 2: '+Limits.getCPUTime());
        	Test.stopTest();
        }
    }
    
    @isTest
    static void testUpdateCR(){
        Test.enableChangeDataCapture();
        User sysad = [SELECT Id FROM User WHERE Username = 'tstSysAd@test.com' LIMIT 1];
        List<ChannelResponse__c> crList = new List<ChannelResponse__c>();
        System.runAs(sysad) {
            Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
            BrandRelationship__c br = [SELECT Id, PrimaryContact__c FROM BrandRelationship__c LIMIT 1];
            Channel__c chan = [SELECT Id FROM Channel__c LIMIT 1];
            Address__c address = [SELECT Id FROM Address__c LIMIT 1];
            crList = TestDataFactory.createTestChannelResponseMultiple(100, br, chan, address, prod, true, '');
            Test.getEventBus().deliver();
            
            Test.startTest();
            List<ChannelResponse__c> crUpdateList = new List<ChannelResponse__c>();
            for(ChannelResponse__c cr : crList){
                System.debug(cr);
                cr.OrderCreationStatus__c = 'Pending';
                cr.RegistrationDate__c = Date.today();
                crUpdateList.add(cr);
            }
            update crUpdateList;
            System.debug('CPU TIME 1: '+Limits.getCPUTime());
            Test.getEventBus().deliver();
            System.debug('CPU TIME 2: '+Limits.getCPUTime());
            Test.stopTest();
            for(ChannelResponse__c cr : [SELECT Id, RegistrationDate__c, IsSample_Requested__c, DeliveryAddress__c, ProductSampleRequested__c, OrderCreationStatus__c FROM ChannelResponse__c]){
                System.debug(cr);
            }
        }
    }
}