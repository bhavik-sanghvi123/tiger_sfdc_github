@isTest
public class ExportCallBatch_Test {

    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        sysad.FirstName = 'Data';
        sysad.LastName = 'Migration';
        insert sysad;

        System.runAs(sysad) {
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
            List<Account> accList = TestDataFactory.createTestHousehold(1);
            List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);

            //Create Address
            List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
            List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
            List<Address__c> lAddress = TestDataFactory.createTestDefaultAddress(1, conList.get(0).Id, lRegion.get(0).Id, lCity.get(0).Id);
            Test.setCreatedDate(lAddress[0].Id, Date.TODAY());

            Affiliate_Value__c af1 = new Affiliate_Value__c();
            af1.Name = 'Success Test';
            af1.AffiliateValue__c = 'Success Test';
            af1.Market__c = 'PH';
            af1.Active__c = true;
            insert af1;
            
            Id callRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
            Case ca1 = new Case();
            ca1.RecordtypeId = callRecordType;
            ca1.ContactId = conList[0].Id;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'Completed';
            ca1.AccountId = accList[0].Id;
            ca1.CallRegarding__c = conList[0].Id;
            ca1.CallOutcome__c = 'Successful';
            ca1.SuccessfulReason__c = af1.Id;
            
            insert ca1;

            List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, conList[0].Id, lProduct[0].Id);
            List<ChannelResponse__c> crList = new List<ChannelResponse__c>();
            crList.add(new ChannelResponse__c(Channel__c = lChannel[0].Id,
                                            BrandRelationship__c = lBrand[0].Id,
                                            RegistrationDate__c = Date.today().addDays(1)));
            Insert crList;
        }
    }

    static testMethod void test1(){
        Test.startTest();
            Database.executeBatch(new ExportCallBatch2('VN'),1);
        Test.stopTest();
    }
    
    static testMethod void test2(){
        Test.startTest();

            String cronStr = '0 0 0 3 9 ? 2050';
            String jobId2 = System.schedule('ExportCallBatch_Sched_VN_test', cronStr, new ExportCallBatch_Sched_VN());

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId2];

            // Verify the expressions are the same
            System.assertEquals(cronStr, ct.CronExpression);

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
    
}