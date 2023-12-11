@isTest
public class AcceptAgentWorkController_Test {

    @testsetup
    static void setupData() {
    	UserRole uRole = [SELECT Id FROM UserRole WHERE Name =: 'ANI - Philippines'];
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        sysad.UserRoleId = uRole.Id;
        insert sysad;
        
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
            ca1.Market__c = 'PH';
            insert ca1;
        }
    }
    
    static testmethod void test1(){
    
        Case c = [SELECT Owner.Username FROM Case LIMIT 1];
        User sysad = [SELECT Id FROM User WHERE Username =: c.Owner.Username];
        
        User sysad2 = TestDataFactory.createUser('System Administrator', 'tsysAd2' , 'PH');
        sysad2.username = 'datamigration@tigerani.abbott.comtest2';
        insert sysad2;
        
        
        Test.startTest();

            //user can accept owned calls only
            System.runAs(sysad2){
                System.assertEquals('2', AcceptAgentWorkController.acceptCall(c.Id));
            }
            
            System.runAs(sysad){
            
                //success
                System.assertEquals('1', AcceptAgentWorkController.acceptCall(c.Id));
    
                //call already accepted
                System.assertEquals('3', AcceptAgentWorkController.acceptCall(c.Id));
            }
        Test.stopTest();
    }
}