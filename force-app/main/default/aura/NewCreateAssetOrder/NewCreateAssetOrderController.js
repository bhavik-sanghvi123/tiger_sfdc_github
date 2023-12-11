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
            } 
        });
        
        $A.enqueueAction(action2); 
    },
    
    createOrder : function(component, event, helper) {
        var accessPage = component.get("v.isPageAccessible");
        var isReplacement = component.get("v.isReplacement");
        if(accessPage === false) {
            component.find('notifLib').showToast({
                "title": "Error!",
                "message": "ASEAPAC users doesn't has privilege to create order details. Please contact System Administrator for any inquiry.",
                "variant": "error"
            });
        } else {
            var sObjectName = component.get("v.sObjectName");
            var userMarket = component.get("v.userMarket");
            var action = component.get("c.createAssetOrder");
            var caseId;
            var contactId;
            var assetId;
            var orderId;
            if(sObjectName === "Asset" || sObjectName === "Account") {
                assetId = component.get("v.recordId");
            }
            
            
            action.setParams({
                caseId : caseId,
                contactId : contactId,
                assetId : assetId,
                sObjectName : sObjectName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                
                if(state === "SUCCESS")
                {
                    component.set("v.orderID", result);
                    orderId = result;
                    helper.processOrderRecord(component, event, helper, orderId, caseId, contactId,assetId, sObjectName, userMarket, isReplacement);
                }
                else{
                    component.find('notifLib').showToast({
                        "title": "Household Error!",
                        "message": 'The household record must have an associated primary contact',
                        "variant": "error"
                    }); 
                }
            });
            $A.enqueueAction(action);
    	}
       
    },
    
    createReplacementOrder : function(component, event, helper) {
        component.set("v.isReplacement", true);
        var accessPage = component.get("v.isPageAccessible");
        var isReplacement = component.get("v.isReplacement");
        if(accessPage === false) {
            component.find('notifLib').showToast({
                "title": "Error!",
                "message": "ASEAPAC users doesn't has privilege to create order details. Please contact System Administrator for any inquiry.",
                "variant": "error"
            });
        } else {
            var sObjectName = component.get("v.sObjectName");
            var userMarket = component.get("v.userMarket");
            var action = component.get("c.createAssetOrder");
            var caseId;
            var contactId;
            var assetId;
            var orderId;
           
            if(sObjectName === "Case") {
                caseId = component.get("v.recordId");
            }
            else if(sObjectName === "Contact") {
                contactId = component.get("v.contactID");
            }
            else if(sObjectName === "Asset") {
                assetId = component.get("v.recordId");
            }
            
            
            action.setParams({
                caseId : caseId,
                contactId : contactId,
                assetId : assetId,
                sObjectName : sObjectName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                
                if(state === "SUCCESS")
                {
                    component.set("v.orderID", result);
                    orderId = result;
                    
                    helper.processOrderRecord(component, event, helper, orderId, caseId, contactId,assetId, sObjectName, userMarket, isReplacement);
                }
                else{
                    component.find('notifLib').showToast({
                        "title": "Asset Error!",
                        "message": 'The asset record must have household and contact records',
                        "variant": "error"
                    }); 
                }
            });
            $A.enqueueAction(action);
    	}
       
    },
    
    createContact : function(component, event, helper) {
        var caseRecordId = component.get("v.recordId");
        helper.checkContactAndHouseholdField(component, event, helper, caseRecordId);
    }

})