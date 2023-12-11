public class NewCaseController{
    
    @AuraEnabled
    public static sObject getCaseDetails(String recordId, String sObjectName) {    
        sObject record;
        
        if(sObjectName == 'Case') {
	        record = [SELECT Id, ContactId, AccountId FROM Case WHERE Id =: recordId];
        } 
        else if(sObjectName == 'Contact') {
            record = [SELECT Id, AccountId FROM Contact WHERE Id =: recordId];
        }
        return record;      
    }

    @AuraEnabled
    public static Id getRecordTypeId(String recTypeName) {    
        
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
        return caseRecTypeId;
    }

    /**
    * This method is responsible for creating the Case Inquiry related to the call record
    * RecordType is Inquiry
    **/
    @AuraEnabled
    public static String saveCaseRecord(String params, String caseType) 
    {        
        CommonObjectWrapper.cls_Case caseWrapper = (CommonObjectWrapper.cls_Case)JSON.deserialize(params, CommonObjectWrapper.cls_Case.class);
        
        Case caseRecord = new Case();
        
        if (caseWrapper != null){
            caseRecord.ContactId = caseWrapper.caseContactId;
            caseRecord.RecordTypeId = caseWrapper.caseRecordType;
            caseRecord.Classification__c = caseWrapper.caseClassification;
            caseRecord.Status = caseWrapper.caseStatus;
            caseRecord.AccountId = caseWrapper.caseAccountId;
            caseRecord.Priority = caseWrapper.casePriority;
            caseRecord.SubClassification__c = caseWrapper.caseSubClassification;
            caseRecord.IsSocialCase__c = caseWrapper.caseSocialCase;
            caseRecord.Origin = caseWrapper.caseOrigin;
            caseRecord.Subject = caseWrapper.caseSubject;
            caseRecord.Description = caseWrapper.caseDescription;
            caseRecord.Order__c = caseWrapper.caseOrder;
            caseRecord.ParentId = caseWrapper.caseParentId;
            caseRecord.EscalatedTo__c = caseWrapper.caseEscalatedTo;
            caseRecord.Product__c = caseWrapper.caseProduct;
            caseRecord.BatchNumber__c = caseWrapper.caseBatchNumber;
            caseRecord.ProductPackageSize__c = caseWrapper.casePackageSize;
            caseRecord.ResolutionNotes__c= caseWrapper.caseResolutionNotes;
            caseRecord.ReopenCount__c = caseWrapper.caseReopenCount;
            caseRecord.ReopenNotes__c = caseWrapper.caseReopenNotes;
            caseRecord.ResolvedUponOpening__c = caseWrapper.caseResolved;
            caseRecord.FollowUpCallRequired__c = caseWrapper.caseFollowUpCall;
            caseRecord.PreferredDateTimeofCallback__c = caseWrapper.casePreferredDateTime;
            caseRecord.ReasonofRequestforCallback__c = caseWrapper.caseReasonForCallback;
            caseRecord.SuppliedEmail = caseWrapper.caseWebEmail;
            caseRecord.SourceCreatedDate__c = caseWrapper.caseSourceCreatedDate;
            caseRecord.CaseRegarding__c = caseWrapper.caseCaseRegarding;
            caseRecord.ReplyVia__c = caseWrapper.caseReplyVia;
            caseRecord.EnquirerType__c = caseWrapper.caseEnquirerType;
            caseRecord.Complexity__c = caseWrapper.caseComplexity;
            caseRecord.ReviewedBy__c = caseWrapper.caseReviewedBy;
            caseRecord.ReviewedDate__c = caseWrapper.caseReviewedDate;
            caseRecord.MedicalDiagnosis__c = caseWrapper.caseNutritionHistory;
            caseRecord.ReminderStatus__c = caseWrapper.caseReminderStatus;

            if(caseType == CommonConstant.CASE_INQUIRY_RECORDTYPE) {
                caseRecord.EndUserName__c = caseWrapper.caseEndUserName;
                caseRecord.CurrentBrandUsed__c = caseWrapper.caseCurrentBrandUsed;
                caseRecord.ConsumptionperMonthNoofCans__c = caseWrapper.caseConsumption;
                caseRecord.CaregiverName__c = caseWrapper.caseCaregiverName;
                caseRecord.LoyaltyCardNumber__c = caseWrapper.caseLoyaltyCardNumber;
            }
            
            else if(caseType == CommonConstant.CASE_FEEDBACK_RECORDTYPE) {
                caseRecord.Retention__c = caseWrapper.caseRetention;
                caseRecord.ProductReplacementRequired__c = caseWrapper.caseProductReplacement;
                caseRecord.CustomerCertificationAttached__c = caseWrapper.caseCustomerCertification;
                caseRecord.ProductReplacementStatus__c = caseWrapper.caseProductReplacementStatus;
                caseRecord.StoreWherePurchased__c = caseWrapper.caseStoreWherePurchased;
                caseRecord.ManufacturingDate__c = caseWrapper.caseManufacturingDate;
                caseRecord.DatePurchased__c = caseWrapper.caseDatePurchased;
                caseRecord.FiletoTrackwise__c = caseWrapper.caseFileToTrackwise;
                caseRecord.Variant__c = caseWrapper.caseVariant;
                caseRecord.LotNumber__c = caseWrapper.caseLotNumber;
                caseRecord.ExpiryDate__c = caseWrapper.caseExpiryDate;
                caseRecord.DateOpenedUsed__c = caseWrapper.caseDateOpenedUsed;
                caseRecord.ReplacementProduct__c = caseWrapper.caseReplacementProduct;
                caseRecord.AbbottAwarenessDate__c = caseWrapper.caseAbbottAwarenessDate;
                caseRecord.DateofPackaging__c = caseWrapper.caseDateofPackaging;
                caseRecord.TimeCode__c = caseWrapper.caseTimeCode;
                caseRecord.DateofIncident__c = caseWrapper.caseDateofIncident;
                caseRecord.PackCondition__c = caseWrapper.casePackCondition;
                caseRecord.TrackwiseID__c = caseWrapper.caseTrackwiseID;
                caseRecord.RecommendedBy__c = caseWrapper.caseRecommendedBy;
                caseRecord.AdditionalObservation__c = caseWrapper.caseAdditionalObservation;
                caseRecord.SampleAvailability__c = caseWrapper.caseSampleAvailability;
                caseRecord.ResponseLetterisRequired__c = caseWrapper.caseResponseLetterisRequired;
                caseRecord.UsageDetails__c = caseWrapper.caseUsageDetails;
                caseRecord.LevelofEscalation__c = caseWrapper.caseLevelofEscalation;
                caseRecord.State__c = caseWrapper.caseState;
                caseRecord.Quantity__c = caseWrapper.caseQuantity;
                caseRecord.ProductReplacementDeliveredDate__c = caseWrapper.caseProductReplacementDeliveredDate;
            }
        }

        try {
            insert caseRecord;
        } 
        catch (DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }

        return caseRecord.Id;
    }
}