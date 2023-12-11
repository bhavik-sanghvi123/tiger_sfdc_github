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
                component.set("v.openInquiryForm", true);
                
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
		var recTypeName = "Inquiry";
        
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
        var caseInquiryParams = this.getCaseInquiryParams(component, event, helper);
        var jsonParams = JSON.stringify(caseInquiryParams); 
        var caseType = "Inquiry"
        
        action.setParams({
            'params': jsonParams,
            'caseType' : caseType
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.caseInquiryId", result);
                
                component.find('notifLib').showToast({
                    "title": "Success!",
                    "message": "Inquiry has been Saved successfully.",
                    "variant": "success"
                });     
                
                component.set("v.openInquiryForm", false);
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
    
    getCaseInquiryParams : function(component, event, helper) {
        var inquiryResolved = component.find("inquiryResolved").get("v.value");
        var inquiryFollowUpCall = component.find("inquiryFollowUpCall").get("v.value");
        var inquirySocialCase = component.find("inquirySocialCase").get("v.value");
        
		return {
            'caseRecordType': component.get("v.recordTypeId"),
            'caseContactId': component.find("inquiryContactId").get("v.value"),
            'caseClassification': component.find("inquiryClassification").get("v.value"),	
            'caseStatus': component.find("inquiryStatus").get("v.value"),
            'caseAccountId': component.find("inquiryAccountId").get("v.value"),
            'casePriority': component.find("inquiryPriority").get("v.value"),
            'caseSubClassification': component.find("inquirySubClassification").get("v.value"),
            'caseSocialCase': inquirySocialCase == null ? false : inquirySocialCase,
            'caseOrigin': component.find("inquiryOrigin").get("v.value"),
            'caseSubject': component.find("inquirySubject").get("v.value"),
            'caseDescription': component.find("inquiryDescription").get("v.value"),
            'caseOrder': component.find("inquiryOrder").get("v.value"),
            'caseParentId': component.find("inquiryParentId").get("v.value"),
            'caseResolutionNotes': component.find("inquiryResolutionNotes").get("v.value"),
            'caseProduct': component.find("inquiryProduct").get("v.value"),
            'caseEscalatedTo': component.find("inquiryEscalatedTo").get("v.value"),
            'caseBatchNumber': component.find("inquiryBatchNumber").get("v.value"),
            'caseEndUserName': component.find("inquiryEndUserName").get("v.value"),
            'caseCurrentBrandUsed': component.find("inquiryCurrentBrandUsed").get("v.value"),
            'caseConsumption': component.find("inquiryConsumption").get("v.value"),
            'caseCaregiverName': component.find("inquiryCaregiverName").get("v.value"),
            'casePackageSize': component.find("inquiryPackageSize").get("v.value"),
            'caseReopenCount': component.find("inquiryReopenCount").get("v.value"),
            'caseResolved': inquiryResolved == null ? false : inquiryResolved,
            'caseReopenNotes': component.find("inquiryReopenNotes").get("v.value"),
            'caseLoyaltyCardNumber': component.find("inquiryLoyaltyCardNumber").get("v.value"),
            'caseFollowUpCall': inquiryFollowUpCall == null ? false : inquiryFollowUpCall,
            'casePreferredDateTime': component.find("inquiryPreferredDateTime").get("v.value"),
            'caseReasonForCallback': component.find("inquiryReasonForCallback").get("v.value"),
            'caseSourceCreatedDate': component.find("inquirySourceCreatedDate").get("v.value"),
            'caseWebEmail': component.find("inquiryWebEmail").get("v.value"),
            'caseCaseRegarding': component.find("inquiryCaseRegarding").get("v.value"),
            'caseReplyVia': component.find("inquiryReplyVia").get("v.value"),
            'caseEnquirerType': component.find("inquiryEnquirerType").get("v.value"),
            'caseComplexity': component.find("inquiryComplexity").get("v.value"),
            'caseReviewedBy': component.find("inquiryReviewedBy").get("v.value"),
            'caseReviewedDate': component.find("inquiryReviewedDate").get("v.value"),
            'caseNutritionHistory': component.find("inquiryNutritionHistory").get("v.value"),
            'caseReminderStatus': component.find("inquiryReminderStatus").get("v.value"),
        };
    },
})