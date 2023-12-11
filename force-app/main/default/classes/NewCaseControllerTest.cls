@isTest 
public class NewCaseControllerTest{

    @testsetup
    static void setupData() {
        List<Account> accountList = TestDataFactory.createTestHousehold(1);
        List<Contact> contactList = TestDataFactory.createTestAdultContact(1, accountList.get(0).Id);
        Case caseRec = TestDataFactory.createCaseCall(accountList.get(0).Id, contactList.get(0).Id);     
    }

    private static testMethod void getCaseDetailsTest() {
        Id callId = [SELECT Id FROM Case LIMIT 1].Id;
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        String objName = 'Case';

        System.Test.startTest();
            sObject caseRecord = NewCaseController.getCaseDetails(callId, objName);   
        System.Test.stopTest();

        System.assertNotEquals(caseRecord, null, 'Call record details should be returned.');
    }

    private static testMethod void getRecordTypeTest() {
        System.Test.startTest();
            Id caseRecTypeId = NewCaseController.getRecordTypeId(CommonConstant.CASE_INQUIRY_RECORDTYPE);   
        System.Test.stopTest();

        System.assertNotEquals(null, caseRecTypeId, 'Case Inquiry record type ID must be returned.');
    }

    private static testMethod void saveCaseRecordTest() {
        Id callId = [SELECT Id FROM Case LIMIT 1].Id;
        Id conId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id householdId = [SELECT Id FROM Account LIMIT 1].Id;
        Id caseInquiryRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_INQUIRY_RECORDTYPE).getRecordTypeId();
        Id caseFeedbackRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();

        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
        
        //Case Inquiry creation in the wizard
        caseHolderObj caseInquiry = new caseHolderObj();
        caseInquiry.caseContactId = conId;
        caseInquiry.caseRecordType = caseInquiryRecTypeId;
        caseInquiry.caseAccountId = householdId;
        caseInquiry.casePriority = 'Medium';
        caseInquiry.caseOrigin = 'Inbound Call';
        caseInquiry.caseSubject = 'Test Case Inquiry Record';
        caseInquiry.caseParentId = callId;
        caseInquiry.caseResolved = FALSE;
        caseInquiry.caseFollowUpCall = FALSE;
        caseInquiry.caseSocialCase = FALSE;
        caseInquiry.caseSampleAvailability = FALSE;
        caseInquiry.caseResponseLetterisRequired = FALSE;
        caseInquiry.caseAbbottAwarenessDate = Date.today().addDays(-2);
        String mainCaseInquiryParams = JSON.serialize(caseInquiry);

        //Case Feedback creation in the wizard
        caseHolderObj caseFeedback = new caseHolderObj();
        caseFeedback.caseContactId = conId;
        caseFeedback.caseRecordType = caseFeedbackRecTypeId;
        caseFeedback.caseAccountId = householdId;
        caseFeedback.casePriority = 'Medium';
        caseFeedback.caseOrigin = 'Inbound Call';
        caseFeedback.caseSubject = 'Test Case Feedback Record';
        caseFeedback.caseParentId = callId;
        caseFeedback.caseResolved = FALSE;
        caseFeedback.caseFollowUpCall = FALSE;
        caseFeedback.caseFileToTrackwise = FALSE;
        caseFeedback.caseProductReplacement = FALSE;
        caseFeedback.caseCustomerCertification = FALSE;
        caseFeedback.caseSocialCase = FALSE;
        caseFeedback.caseSampleAvailability = FALSE;
        caseFeedback.caseResponseLetterisRequired = FALSE;
        caseFeedback.caseAbbottAwarenessDate = Date.today().addDays(-2);
        String mainCaseFeedbackParams = JSON.serialize(caseFeedback);

        System.Test.startTest();
        	String caseInquiryResult = NewCaseController.saveCaseRecord(mainCaseInquiryParams, CommonConstant.CASE_INQUIRY_RECORDTYPE);
        	String caseFeedbackResult = NewCaseController.saveCaseRecord(mainCaseFeedbackParams, CommonConstant.CASE_FEEDBACK_RECORDTYPE);
        	System.assertNotEquals(null, caseInquiryResult, 'A Case Inquiry should be created.');
            System.assertNotEquals(null, caseFeedbackResult, 'A Case Feedback should be created.');
        System.Test.stopTest();
    }

    class caseHolderObj {
        Id caseContactId;
        Id caseRecordType;
        Id caseAccountId;
        String caseStatus;
        String casePriority;
        String caseOrigin;
        String caseSubject;
        Id caseParentId;
        Boolean caseResolved;
        Boolean caseFollowUpCall;
        Boolean caseFileToTrackwise;
        Boolean caseProductReplacement;
        Boolean caseCustomerCertification;
        Boolean caseSocialCase;
        Boolean caseSampleAvailability;
        Boolean caseResponseLetterisRequired;
        Date caseAbbottAwarenessDate
;
    }
}