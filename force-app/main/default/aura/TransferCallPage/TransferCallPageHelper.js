({
	getUserMarket: function(component, event, helper) {
		var action = component.get("c.fetchUserMarket");
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if (state === "SUCCESS") {
                component.set("v.userMarket", result); 
            }
        });
        $A.enqueueAction(action);
	},
    
    getRelatedContactDetails: function(component, event, helper, caseId) {
		var action = component.get("c.fetchContact");
        
        action.setParams({            
            'caseId': caseId
        });
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if (state === "SUCCESS") {
                component.set("v.caseRec", result)
                component.set("v.contactId", result.ContactId);
                component.set("v.contactLanguage", result.Contact.PreferredLanguage__r.Name);
                
                var contactLanguage = component.get("v.contactLanguage");
                if(contactLanguage != null && contactLanguage != "") {
                    component.set("v.isLanguageDefined", true);
                } else {
                    component.set("v.isLanguageDefined", false);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
     getPrefferedLanguageDetails: function(component, event, helper, affiliateId) {
		var action = component.get("c.fetchLanguage");
        
        action.setParams({            
            'affiliateId': affiliateId
        });
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if (state === "SUCCESS") {
                component.set("v.contactLanguage", result)
            }
        });
        $A.enqueueAction(action);
    },
    
    transferCalltoAgent: function(component, event, helper, caseId, ownerId, callBackReason, contactId, contactLanguage) {
        var action = component.get("c.transferCall");
        console.log("Saving case record...");
        
        action.setParams({            
            'caseId': caseId,
            'ownerId': ownerId,
            'reason': callBackReason,
            'contactId': contactId,
            'contactLanguage': contactLanguage
        });
		
        action.setCallback(this, function(action){
            var state = action.getState();
            
            if(state === "SUCCESS") {            
                window.location.reload();
				component.find('notifLib').showToast({
                    "title": "Success!",
                    "message": "Call has been transfered to another agent.",
                    "variant": "success"
                });     
				component.set("v.openTransferCallForm", false);
            } else {
                component.find('notifLib').showToast({
                    "title": "Failed!",
                    "message": action.getError()[0].message,
                    "variant": "error"
                });  
			}
        });
        
        $A.enqueueAction(action);
    }
})