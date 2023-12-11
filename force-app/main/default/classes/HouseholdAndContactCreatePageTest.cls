@isTest 
public class HouseholdAndContactCreatePageTest{

    @testsetup
    static void setupData() {
        Id phRoleId = [SELECT Id FROM UserRole WHERE Name = 'ANI - Philippines'].Id;
        User testUser = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        testUser.UserRoleId = phRoleId;
        insert testUser;
        
        System.runAs(testUser){
            List<Product2> testProductList = TestDataFactory.createTestBrandProduct(1);
            testProductList[0].ProductHierarchyLevel__c = 'Brand';
            update testProductList[0];
        }
    }

    private static testMethod void fetchUserTest() {
        String aseapacRole = 'ANI - ASEAPAC';
        User testUser = [SELECT Id FROM User LIMIT 1];

        System.Test.startTest();
            User result = HouseholdAndContactCreatePage_CC.fetchUser();   
        System.Test.stopTest();

        System.assertNotEquals(aseapacRole, result.UserRole.Name, 'Current user does not have ANI - ASEAPAC Role.');
    }

    private static testMethod void getRelationshipTypePicklistValuesTest() {
        String fieldName = 'Salutation';
        sObject sObj = Schema.getGlobalDescribe().get('Contact').newSObject();

        System.Test.startTest();
            List<String> result = HouseholdAndContactCreatePage_CC.getRelationshipTypePicklistValues(sObj, fieldName);  
        System.Test.stopTest();

        System.assert(result.size() > 0, 'Should return all Salutation picklist values.');
    }
    
    private static testMethod void getProductHeirarchyLevel(){
        Product2 testProduct = [SELECT ID,ProductHierarchyLevel__c FROM Product2 Where ProductHierarchyLevel__c = 'Brand'];
        Test.startTest();
        boolean isBrand = HouseholdAndContactCreatePage_CC.getProductHierarchyLevel(testProduct.Id);
        Test.stopTest();
        
        System.assertEquals(isBrand, true, 'Should Return True');
        
    }

    private static testMethod void saveRecordsViaWizard() {
        User sysAd = [Select Id From User LIMIT 1];
        List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
        
        //create City
        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
        
        //Contact creation in the wizard
        conHolderObj mainContact = new conHolderObj();
        mainContact.primarySalutation = 'Mr.';
        mainContact.primaryFirstName = 'User01';
        mainContact.primaryLastName = 'Test';
        mainContact.primaryTagging = TRUE;
        mainContact.primaryMobilePhone = '76435742';
        mainContact.primaryMasterOptOut = FALSE;
        mainContact.primaryEmailOptOut = FALSE;
        mainContact.primaryDoNotCall = FALSE;
        mainContact.primarySMSOptOut = FALSE;
        mainContact.primaryDataShareOptOut = FALSE;
        mainContact.primaryVerified = FALSE;
        mainContact.primaryWhatsAppOptOut = FALSE;
        String mainContactParams = JSON.serialize(mainContact);

        //Address creation in wizard
        addressHolderObj address = new addressHolderObj();
        address.addressStreet1 = '34th';
        address.addressCity = lCity.get(0).Id;
        address.addressCountry = 'Philippines';
        address.addressDefaultAddress = FALSE;
        String addressParams = JSON.serialize(address);

        //Adult Secondary Contact creation in wizard
        adultHolderObj adultContact = new adultHolderObj();
        adultContact.adultSalutation = 'Mr.';
        adultContact.adultFirstName = 'User02';
        adultContact.adultLastName = 'Test';
        adultContact.adultMasterOptOut = FALSE;
        adultContact.adultEmailOptOut = FALSE;
        adultContact.adultDoNotCall = FALSE;
        adultContact.adultSMSOptOut = FALSE;
        adultContact.adultDataShareOptOut = FALSE;
        adultContact.adultSecondaryVerified = FALSE;
        String adultContactParams = JSON.serialize(adultContact);

        //Child Secondary contact creation in wizard
        childHolderObj childContact = new childHolderObj();
        childContact.childSalutation = 'Mr.';
        childContact.childFirstName = 'User03';
        childContact.childLastName = 'Test';
        childContact.childMasterOptOut = FALSE;
        childContact.childEmailOptOut = FALSE;
        childContact.childDoNotCall = FALSE;
        childContact.childSMSOptOut = FALSE;
        childContact.childDataShareOptOut = FALSE;
        childContact.childVerified = FALSE;
        childContact.childMilkCodeRestriction = FALSE;
        String childContactParams = JSON.serialize(childContact);

        //Brand Relationship creation in wizard
        brHolderObject br = new brHolderObject();
        br.brType = 'Lead';
        br.brStatus = 'Uncontacted';
        br.brBrandOptOut = FALSE;
        br.brWinBack = FALSE;
        br.brProductBenefitsExplained = FALSE;
        br.brCareGiver = FALSE;
        br.brGiftGiver = FALSE;
        br.brEndUser = FALSE;
        String brParams = JSON.serialize(br);

        //Channel Response creation in wizard
        crHolderObject cr = new crHolderObject();
        cr.crChannel = lChannel[0].Id;
        cr.crSampleRequested = FALSE;
        cr.crRegistrationDate = System.Today();
        cr.crSampleGivenOnGround = FALSE;
        cr.crGrowthGuideAppSubmitted = FALSE;
        String crParams = JSON.serialize(cr);
        
        //Case Creation in Wizard
        
        caseHolderObject caseRecord = new caseHolderObject();
        caseRecord.caseStatus = 'New';
        caseRecord.caseOrigin = 'Inbound Call';
        caseRecord.caseCustomerCertification = false;
        caseRecord.caseFileToTrackwise = false;
        caseRecord.caseFollowUpCall = false;
        caseRecord.caseProductReplacement = false;
        caseRecord.caseResolved = false;
        caseRecord.caseSocialCase = false;
        caseRecord.caseResponseLetterisRequired = false;
        caseRecord.caseSampleAvailability = false;
        String caseParams = JSON.serialize(caseRecord);


        System.Test.startTest();
            System.runAs(sysAd) {
                String mainContactResult = HouseholdAndContactCreatePage_CC.savePrimaryContactAndHousehold(mainContactParams, null);
                Id mainContactId = [SELECT Id FROM Contact WHERE FirstName = 'User01' LIMIT 1].Id;
                String addressResult = HouseholdAndContactCreatePage_CC.saveAddress(addressParams, mainContactId);
                String adultResult = HouseholdAndContactCreatePage_CC.saveAdditionalContact(adultContactParams, mainContactId, true, false);
                Id adultContactId = [SELECT Id FROM Contact WHERE FirstName = 'User02' LIMIT 1].Id;             
                String childResult = HouseholdAndContactCreatePage_CC.saveAdditionalContact(childContactParams, mainContactId, false, true);                
                String brResult = HouseholdAndContactCreatePage_CC.saveBrandRelationship(brParams, mainContactId, adultContactId, false, true, false, null);
                Id brId = [SELECT Id FROM BrandRelationship__c LIMIT 1].Id; 
                String crResult = HouseholdAndContactCreatePage_CC.saveChannelResponse(crParams, brId);
                String caseResultfb = HouseholdAndContactCreatePage_CC.saveCaseRecord(caseParams,mainContactId,null,'Feedback');
                String caseResultInquiry = HouseholdAndContactCreatePage_CC.saveCaseRecord(caseParams,mainContactId,null,'Inquiry');
                
                System.assertNotEquals(null, mainContactResult, 'Main Contact should be created');
                System.assertNotEquals(null, addressResult, 'Address should be created and linked to the Main Contact');
                System.assertNotEquals(null, adultResult, 'Secondary(Adult) Contact should be created and linked to the Main Contact');
                System.assertNotEquals(null, childResult, 'Secondary(Child) Contact should be created and linked to the Main Contact');
                System.assertNotEquals(null, brResult, 'Brand Relationship should be created and linked to the Main Contact');
                System.assertNotEquals(null, crResult, 'Channel Response should be created and linked to the Brand Relationship');
                System.assertNotEquals(null, caseResultfb, 'Case Feedback should be created and linked to the Main Contact');
                System.assertNotEquals(null, caseResultInquiry, 'Case Inquiry should be created and linked to the Main Contact');
            }
        System.Test.stopTest();

    }

    private static testMethod void updateCaseRecordTest() {
        List<Account> accountList = TestDataFactory.createTestHousehold(1);
        List<Contact> contactList = TestDataFactory.createTestAdultContact(1, accountList.get(0).Id);
        Case caseRec = TestDataFactory.createCaseCall(accountList.get(0).Id, contactList.get(0).Id);
        caseRec.AbbottAwarenessDate__c = Date.Today().addDays(-1);
        update caseRec;

        System.Test.startTest();
            HouseholdAndContactCreatePage_CC.updateCaseRecord(caseRec.Id, contactList.get(0).Id);
        System.Test.stopTest();

        Case updatedCaseRec = [Select Id, ContactId, AccountId FROM Case LIMIT 1];
        System.assertNotEquals(null, updatedCaseRec.ContactId, 'Case Contact Name should be populated');
        System.assertNotEquals(null, updatedCaseRec.AccountId, 'Case Household should be populated');
    }
    
    private static testMethod void getProductDetailsTest() {
        Id productRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(CommonConstant.PRODUCT_PRODUCT_RECORDTYPE).getRecordTypeId();
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
        lProduct[0].RecordTypeId = productRecTypeId;
        lProduct[0].CompetitorProduct__c = true;
        update lProduct[0];

        System.Test.startTest();
            String competitorProduct = HouseholdAndContactCreatePage_CC.getProductDetails(lProduct.get(0).Id);
        System.Test.stopTest();

        System.assertEquals('true', competitorProduct, 'Product is a Competitor');
    }
    
    private static testMethod void getExperianTokenTest() {
        System.Test.startTest();
        String token = HouseholdAndContactCreatePage_CC.getExperianToken();
        System.Test.stopTest();
        
        System.assertNotEquals(null, token, 'Experian token should be returned');
    }
    
    private static testMethod void getAffiliateSingaporeCityTest() {
        User testUser = [Select Id, Market__c, UserRoleId From User where LastName = 'tstSysAd'];
        String sgId;
        
        System.runAs(testUser) {
            List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
            lCity[0].Name = 'Singapore';
            lCity[0].Market__c = 'SG';
            update lCity[0];
            
            System.Test.startTest();
            sgId = HouseholdAndContactCreatePage_CC.getAffiliateSingaporeCity();
            System.Test.stopTest();
        }
        
        System.assertNotEquals(null, sgId, 'Singapore Affiliate City Id should be returned');
    }

    class conHolderObj {
        String primarySalutation;
        String primaryFirstName;
        String primaryLastName;
        Boolean primaryTagging;
        String primaryMobilePhone;
        Boolean primaryMasterOptOut;
        Boolean primaryEmailOptOut;
        Boolean primaryDoNotCall;
        Boolean primarySMSOptOut;
        Boolean primaryDataShareOptOut;
        Boolean primaryVerified;
        Boolean primaryWhatsAppOptOut;
    }

    class addressHolderObj {
        String addressStreet1;
        String addressCity;
        String addressCountry;
        Boolean addressDefaultAddress;
    }

    class adultHolderObj {
        String adultSalutation;
        String adultFirstName;
        String adultLastName;
        String adultMobilePhone;
        Boolean adultMasterOptOut;
        Boolean adultEmailOptOut;
        Boolean adultDoNotCall;
        Boolean adultSMSOptOut;
        Boolean adultDataShareOptOut;
        Boolean adultSecondaryVerified;
    }

    class childHolderObj {
        String childSalutation;
        String childFirstName;
        String childLastName;
        Boolean childMasterOptOut;
        Boolean childEmailOptOut;
        Boolean childDoNotCall;
        Boolean childSMSOptOut;
        Boolean childDataShareOptOut;
        Boolean childVerified;
        Boolean childMilkCodeRestriction;
    }

    class brHolderObject {
        String brType;
        String brStatus;    
        Boolean brBrandOptOut;
        Boolean brWinBack;
        Boolean brProductBenefitsExplained;
        Boolean brCareGiver;
        Boolean brGiftGiver;
        Boolean brEndUser;
    }

    class crHolderObject {
        String crChannel;
        Boolean crSampleRequested;
        Datetime crRegistrationDate;
        Boolean crSampleGivenOnGround;
        Boolean crGrowthGuideAppSubmitted;
    }
    
    class caseHolderObject{
        String caseStatus;
        String caseOrigin;
        boolean caseCustomerCertification;
        boolean caseFileToTrackwise;
        boolean caseFollowUpCall;
        boolean caseProductReplacement;
        boolean caseResolved;
        boolean caseSocialCase;
        boolean caseResponseLetterisRequired;
        boolean caseSampleAvailability;
    }
}