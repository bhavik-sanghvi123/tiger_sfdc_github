({
    getDetails : function(component, event, helper, recordId, sObjectName) {
    	var action = component.get("c.getCaseDetails");

        action.setParams({
            'recordId': recordId,
            'sObjectName': sObjectName
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.openFeebackForm", true);
                
                if(sObjectName == 'Case') {
                    component.set("v.contactId", result.ContactId);
                    component.set("v.householdId", result.AccountId);
                    component.set("v.parentCaseId", result.Id);
                }
                else if(sObjectName == 'Contact') {
                    component.set("v.contactId", result.Id);
                    component.set("v.householdId", result.AccountId);
                }
            }
        });
        
        $A.enqueueAction(action);
	},
    
    getRecordTypeId : function(component, event, helper) {
    	var action = component.get("c.getRecordTypeId");
		var recTypeName = "Feedback";
        
        action.setParams({
            'recTypeName': recTypeName
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS"){
                component.set("v.recordTypeId", result);
            }
        });
        
        $A.enqueueAction(action);
	},
    
    saveRecord : function(component, event, helper) {
        var action = component.get("c.saveCaseRecord");
        var caseFeedbackParams = this.getCaseFeedbackParams(component, event, helper);
        var jsonParams = JSON.stringify(caseFeedbackParams); 
        var caseType = "Feedback"
        
        action.setParams({
            'params': jsonParams,
            'caseType' : caseType
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.caseFeedbackId", result);
                
                component.find('notifLib').showToast({
                    "title": "Success!",
                    "message": "Feedback has been saved successfully.",
                    "variant": "success"
                });     
                
                component.set("v.openFeebackForm", false);
                $A.get("e.force:refreshView").fire();
                var sObjectEvent3 = $A.get("e.force:navigateToSObject");
                sObjectEvent3.setParams({
                    "recordId": result,
                    "slideDevName": "detail",
                });
                sObjectEvent3.fire();
            }
            else {
                var errors = response.getError();
                component.set("v.disabled", false);
                component.set("v.systemErrorMessage", errors[0].message);
                
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": errors[0].message,
                    "variant": "error"
                });
            }
        });
        
       	$A.enqueueAction(action);
    },
    
    getCaseFeedbackParams : function(component, event, helper) {
        var fbResolved = component.find("fbResolved").get("v.value");
        var fbFollowUpCall = component.find("fbFollowUpCall").get("v.value");
        var fbProductReplacement = component.find("fbProductReplacement").get("v.value");
        var fbCustomerCertification = component.find("fbCustomerCertification").get("v.value");
        var fbFileToTrackwise = component.find("fbFileToTrackwise").get("v.value");
        var fbSocialCase = component.find("fbSocialCase").get("v.value");
        var fbSampleAvailability = component.find("fbSampleAvailability").get("v.value");
        var fbResponseLetterisRequired = component.find("fbResponseLetterisRequired").get("v.value");
        
		return {
            'caseRecordType': component.get("v.recordTypeId"),
            'caseContactId': component.find("fbContactId").get("v.value"),
            'caseClassification': component.find("fbClassification").get("v.value"),	
            'caseStatus': component.find("fbStatus").get("v.value"),
            'caseAccountId': component.find("fbAccountId").get("v.value"),
            'casePriority': component.find("fbPriority").get("v.value"),
            'caseSubClassification': component.find("fbSubClassification").get("v.value"),
            'caseOrigin': component.find("fbOrigin").get("v.value"),
            'caseSubject': component.find("fbSubject").get("v.value"),
            'caseDescription': component.find("fbDescription").get("v.value"),
            'caseOrder': component.find("fbOrder").get("v.value"),
            'caseParentId': component.find("fbParentId").get("v.value"),
            'caseEscalatedTo': component.find("fbEscalatedTo").get("v.value"),
            'caseProduct': component.find("fbProduct").get("v.value"),
            'caseRetention': component.find("fbRetention").get("v.value"),
            'caseProductReplacement': fbProductReplacement == null ? false : fbProductReplacement,
            'caseCustomerCertification': fbCustomerCertification == null ? false : fbCustomerCertification,
            'caseProductReplacementStatus': component.find("fbProductReplacementStatus").get("v.value"),
            'caseStoreWherePurchased': component.find("fbStoreWherePurchased").get("v.value"),
            'caseBatchNumber': component.find("fbBatchNumber").get("v.value"),
            'caseProductPackageSize': component.find("fbProductPackageSize").get("v.value"),
            'caseManufacturingDate': component.find("fbManufacturingDate").get("v.value"),
            'caseDatePurchased': component.find("fbDatePurchased").get("v.value"),
            'caseFileToTrackwise': fbFileToTrackwise == null ? false : fbFileToTrackwise,
            'caseReplacementNotes': component.find("fbReplacementNotes").get("v.value"),
            'caseVariant': component.find("fbVariant").get("v.value"),
            'caseLotNumber': component.find("fbLotNumber").get("v.value"),
            'caseExpiryDate': component.find("fbExpiryDate").get("v.value"),
            'caseDateOpenedUsed': component.find("fbDateOpenedUsed").get("v.value"),
            'caseResolutionNotes': component.find("fbResolutionNotes").get("v.value"),
            'caseReopenCount': component.find("fbReopenCount").get("v.value"),
            'caseReopenNotes': component.find("fbReopenNotes").get("v.value"),
            'caseResolved': fbResolved == null ? false : fbResolved,
            'caseFollowUpCall': fbFollowUpCall == null ? false : fbFollowUpCall,
            'casePreferredDateTime': component.find("fbPreferredDateTime").get("v.value"),
            'caseReasonForCallback': component.find("fbReasonForCallback").get("v.value"),
            'caseWebEmail': component.find("fbWebEmail").get("v.value"),
            'caseSocialCase': fbSocialCase == null ? false : fbSocialCase,
            'caseReplacementProduct': component.find("fbReplacementProduct").get("v.value"),
            'caseSourceCreatedDate': component.find("fbSourceCreatedDate").get("v.value"),
            'caseCaseRegarding': component.find("fbCaseRegarding").get("v.value"),
            'caseReplyVia': component.find("fbReplyVia").get("v.value"),
            'caseEnquirerType': component.find("fbEnquirerType").get("v.value"),
            'caseComplexity': component.find("fbComplexity").get("v.value"),
            'caseReviewedBy': component.find("fbReviewedBy").get("v.value"),
            'caseReviewedDate': component.find("fbReviewedDate").get("v.value"),
            'caseAbbottAwarenessDate': component.find("fbAbbottAwarenessDate").get("v.value"),
            'caseDateofPackaging': component.find("fbDateofPackaging").get("v.value"),
            'caseTimeCode': component.find("fbTimeCode").get("v.value"),
            'caseDateofIncident': component.find("fbDateofIncident").get("v.value"),
            'casePackCondition': component.find("fbPackCondition").get("v.value"),
            'caseTrackwiseID': component.find("fbTrackwiseID").get("v.value"),
            'caseRecommendedBy': component.find("fbRecommendedBy").get("v.value"),
            'caseAdditionalObservation': component.find("fbAdditionalObservation").get("v.value"),
            'caseSampleAvailability': fbSampleAvailability == null ? false : fbSampleAvailability,
            'caseResponseLetterisRequired': fbResponseLetterisRequired == null ? false : fbResponseLetterisRequired,
            'caseUsageDetails': component.find("fbUsageDetails").get("v.value"),
            'caseNutritionHistory': component.find("fbNutritionHistory").get("v.value"),
            'caseLevelofEscalation': component.find("fbLevelofEscalation").get("v.value"),
            'caseReminderStatus': component.find("fbReminderStatus").get("v.value"),
            'caseState': component.find("fbState").get("v.value"),
            'caseQuantity': component.find("fbQuantity").get("v.value"),
            'caseProductReplacementDeliveredDate': component.find("fbProductReplacementDeliveredDate").get("v.value"),
        };
    },
})