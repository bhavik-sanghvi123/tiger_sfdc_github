({
    doInit : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var action = component.get("c.fetchUser");
        var action2 = component.get("c.getLoginUserDetails");
        
        if(sObjectName == "Case") {
            var caseRecordId = component.get("v.recordId");
            helper.getRecordType(component, event, helper, caseRecordId);
        }
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS")
            {
                if(result === "ASEAPAC") {
                    component.set("v.isPageAccessible", false);
                } else{
                    component.set("v.isPageAccessible", true);
                }
            }
        });
        $A.enqueueAction(action);
        
        action2.setCallback(this, function(response) {
            var state2 = response.getState();
            var result2 = response.getReturnValue();
            
            if(state2 === "SUCCESS"){
                component.set("v.userMarket", result2.Market__c);
                if(result2.Market__c === "MY"
                  	|| result2.Market__c === "IN"
                  	|| result2.Market__c === "VN"
                    || result2.Market__c === "ID"
                  	|| result2.Market__c === "TH") {
                	component.set("v.showCallScript", true);
                }
                if(result2.Market__c === "TW") {
                    var caseRecordId = component.get("v.recordId");
                    helper.retrieveCaseDetails(component, event, helper, caseRecordId);
                }
            } 
        });
        
        $A.enqueueAction(action2); 
    },
    
    createOrder : function(component, event, helper) {
        var accessPage = component.get("v.isPageAccessible");
        if(accessPage === false) {
            component.find('notifLib').showToast({
                "title": "Error!",
                "message": "ASEAPAC users doesn't has privilege to create order details. Please contact System Administrator for any inquiry.",
                "variant": "error"
            });
        } else {
            var sObjectName = component.get("v.sObjectName");
            var userMarket = component.get("v.userMarket");
            var action = component.get("c.createNewOrder");
            var caseId;
            var contactId;
            var orderId;
           
            if(sObjectName === "Case") {
                caseId = component.get("v.recordId");
            }
            else if(sObjectName === "Contact") {
                contactId = component.get("v.recordId");
            }
            
            action.setParams({
                caseId : caseId,
                contactId : contactId,
                sObjectName : sObjectName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                
                if(state === "SUCCESS")
                {
                    component.set("v.orderID", result);
                    orderId = result;
                    
                    helper.processOrderRecord(component, event, helper, orderId, caseId, contactId, sObjectName, userMarket);
                }
            });
            $A.enqueueAction(action);
    	}
    },
    
    createContact : function(component, event, helper) {
        var caseRecordId = component.get("v.recordId");
        helper.checkContactAndHouseholdField(component, event, helper, caseRecordId);
    },
    
    startCallScript : function(component, event, helper) {
        var caseId = component.get("v.recordId");
        var userMarket = component.get("v.userMarket");
        var action = component.get("c.getCaseDetails");
        
        action.setParams({
            caseId : caseId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") {
                
                if(userMarket == "IN") {
                    var nutritionalHistoryId = result.MedicalDiagnosis__c;
                    var relatedBRId = result.RelatedBrandRelationship__c;
                    
                    component.set("v.nutritionalHistoryId", nutritionalHistoryId);
    
                    if(relatedBRId == '' || relatedBRId == null) {
                        component.find('notifLib').showToast({
                            "title": "Error!",
                            "message": "Related Brand Relationship should be populated in order to proceed.",
                            "variant": "error"
                        });
                    } else {
                        var keyBrand = result.RelatedBrandRelationship__r.BrandRelationship__r.KeyBrand__c;
                        var prodFamily = result.RelatedBrandRelationship__r.BrandRelationship__r.Family;
                        var pass = true;
                        
                        if(nutritionalHistoryId != '' && nutritionalHistoryId != null) {
                            var refNumber = result.MedicalDiagnosis__r.Name;
                            component.find('notifLib').showToast({
                                "title": "Error!",
                                "message": "There is already a Nutritional History record related to this call (Ref# " + refNumber + "). Please remove it before proceeding.",
                                "variant": "error"
                            });  
                            
                        } else {
                            if(keyBrand == 'Pediasure' && prodFamily == 'Pediatric') {
                                helper.callFlow(component, event, helper, caseId, userMarket);
                            }
                            
                            else if((keyBrand == 'Ensure' || keyBrand == 'Ensure Diabetes Care') && prodFamily == 'Adult') {
                                helper.callFlow(component, event, helper, caseId, userMarket);
                            } 
                            
                            else {
                                 component.find('notifLib').showToast({
                                    "title": "Error!",
                                     "message": "Related Brand Relationship must satisfy any of the following criteria in order to proceed. " +
                                     "\n \t - Brand Relationship Type is Adult and Key Brand is Ensure " +
                                     "\n \t - Brand Relationship Type is Adult and Key Brand is Ensure Diabetes Care " +
                                     "\n \t - Brand Relationship Type is Pediatric and Key Brand is Pediasure",
                                    "variant": "error"
                                });   
                            }
                        }
                    }
                }
                
                else if(userMarket == "MY") {
                    var channelResponseId = (result.RelatedChannelResponse__c == undefined ? null : result.RelatedChannelResponse__c);                    
                    
                    if(channelResponseId == null) {
                        component.find('notifLib').showToast({
                            "title": "Error!",
                            "message": "Related Channel Response should be populated in order to proceed.",
                            "variant": "error"
                        });
                    } 
                    
                    else {
                        helper.callFlow(component, event, helper, caseId, userMarket);
                    }
                }
                
                else if(userMarket == "ID") {
                    var channelResponseId = (result.RelatedChannelResponse__c == undefined ? null : result.RelatedChannelResponse__c);                    
                    
                    if(channelResponseId == null) {
                        component.find('notifLib').showToast({
                            "title": "Error!",
                            "message": "Related Channel Response should be populated in order to proceed.",
                            "variant": "error"
                        });
                    } 
                    
                    else {
                        helper.callFlow(component, event, helper, caseId, userMarket);
                    }
                }
                
                else if(userMarket == "VN") {
                    var channelResponseId = (result.RelatedChannelResponse__c == undefined ? null : result.RelatedChannelResponse__c);                    
                    
                    if(channelResponseId == null) {
                        component.find('notifLib').showToast({
                            "title": "Error!",
                            "message": "Related Channel Response should be populated in order to proceed.",
                            "variant": "error"
                        });
                    } 
                    
                    else {
                        helper.callFlow(component, event, helper, caseId, userMarket);
                    }
                }
                
                else if(userMarket == "TH") {
                    var channelResponseId = (result.RelatedChannelResponse__c == undefined ? null : result.RelatedChannelResponse__c);                  
                    var brandRelationshipId = (result.RelatedBrandRelationship__c == undefined ? null : result.RelatedBrandRelationship__c);
                    
                    if(channelResponseId == null || brandRelationshipId == null) {
                        component.find('notifLib').showToast({
                            "title": "Error!",
                            "message": "Both Related Channel Response and Related Brand Relationship should be populated in order to proceed.",
                            "variant": "error"
                        });
                    } 
                    
                    else {
                        helper.callFlow(component, event, helper, caseId, userMarket);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})