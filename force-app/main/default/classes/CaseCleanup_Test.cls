// for deletion

//@isTest
public class CaseCleanup_Test {} /*
    
    @testsetup
    static void setup() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
    	User datamigration = TestDataFactory.createUser('System Administrator', 'datami' , 'PH');
		datamigration.username = 'datamigration@tigerani.abbott.comtest';
        insert datamigration;
        
        System.runAs(sysad) {
			
	        Campaign camp = TestDataFactory.createCampaign('Test Campaign 1', 'Ensure', 'PH');
			insert camp;

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
			
			List<ChannelResponse__c> crList = new List<ChannelResponse__c>();
			crList.add(new ChannelResponse__c(Channel__c = lChannel[0].Id,
			                                BrandRelationship__c = lBrand[0].Id,
			                                RegistrationDate__c = Date.today()));
			crList.add(new ChannelResponse__c(Channel__c = lChannel[0].Id,
			                                BrandRelationship__c = lBrand[0].Id,
			                                RegistrationDate__c = Date.today().addDays(1)));
			Insert crList;
			
			
		    Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
			
			Case ca1 = new Case();
            ca1.RecordtypeId = callRTId;
            ca1.ContactId = lContact[0].Id;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId = lAccount[0].Id;
            ca1.CallRegarding__c = lContact[0].Id;
			ca1.Campaign__c = camp.Id;
            insert ca1;
			
			crList = new List<ChannelResponse__c>();
			crList.add(new ChannelResponse__c(Channel__c = lChannel[0].Id,
			                                BrandRelationship__c = lBrand[0].Id,
			                                RegistrationDate__c = Date.today().addDays(2)));
			crList.add(new ChannelResponse__c(Channel__c = lChannel[0].Id,
			                                BrandRelationship__c = lBrand[0].Id,
			                                RegistrationDate__c = Date.today().addDays(3)));
			Insert crList;
		    
		}
    }
    
    static testMethod void test1(){
        
		Test.startTest();
		    Database.executeBatch(new CaseCleanUp());
		Test.stopTest();
			
    }
	
	static testMethod void test2(){
		Test.startTest();
			DateTime dt = Datetime.now().addHours(-3);
			DateTime dt2 = Datetime.now();
			DateTime dt3 = Datetime.now().addHours(1);

			CaseCleanup cc = new CaseCleanup();
			cc.getNearestDate(dt2, null, dt3);
			cc.getNearestDate(dt2, dt, null);
			cc.getNearestDate(dt2, dt, dt3);
			cc.getNearestDate(dt2, dt3, dt);

			dt3 = dt3.addDays(3);
			cc.getNearestDate(dt2, dt, dt3);
		Test.stopTest();
	}
    
    
}*/