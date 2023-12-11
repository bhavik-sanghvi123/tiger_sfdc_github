({    
    processOrderRecord : function(component, event, helper, orderId, caseId, contactId, sObjectName, userMarket) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:newOrderButton",
            componentAttributes: {
                orderId : orderId,
                caseId : caseId,
                contactId: contactId,
                sObjectName : sObjectName,
                userMarket : userMarket
            }
        });
        evt.fire();
	},
    
    getRecordType : function(component, event, helper, caseRecordId) {
    	var action = component.get("c.getCaseRecordTypeName")
        
        action.setParams({
            'caseId': caseRecordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS")
            {
                component.set("v.caseRecordType", result);
            }
        });
        $A.enqueueAction(action);
	},
    
    checkContactAndHouseholdField : function(component, event, helper, caseRecordId) {
    	var action = component.get("c.checkContactAndHousehold")
        
        action.setParams({
            'caseId': caseRecordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS")
            {
                component.set("v.isAllowed", result)
        
                if(result === "false") {
                    component.find('notifLib').showToast({
                        "title": "Error!",
                        "message": 'Please clear out the values at Contact Name and Household before proceed with Main Contact creation.',
                        "variant": "error"
                    }); 
                } else {
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:HouseholdAndContactCreationPage",
                        componentAttributes :{
                            sObjectName : "Case",
                            caseId : caseRecordId,
                        }
                    });
                   
                    evt.fire();   
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    callFlow : function(component, event, helper, caseId, userMarket) {
        var evt = $A.get("e.force:navigateToComponent");
        
        evt.setParams({
            componentDef : "c:StartCallScript",
            componentAttributes: {
                caseId : caseId,
                userMarket : userMarket,
            }
        });
        evt.fire();
    },
    
    retrieveCaseDetails : function(component, event, helper, caseRecordId) {
    	var action = component.get("c.getCaseDetails");
        action.setParams({
            caseId : caseRecordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") {
                var blacklistedStatus = result.Contact.BlacklistedStatus__c;
                if(!$A.util.isUndefinedOrNull(blacklistedStatus) && blacklistedStatus != '') {
                    if(blacklistedStatus.includes('Red_Icon')) {
                        component.set("v.blacklistedStatus", true);
                    }
                } else {
                    component.set("v.blacklistedStatus", false);
                }
            }
        });
                           
        $A.enqueueAction(action);
	},
})