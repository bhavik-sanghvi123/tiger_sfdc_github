({
    doInit : function(component, event, helper) {
        var caseId = component.get("v.recordId");
        var action = component.get("c.isSocial");
        
        action.setParams({
            caseId : caseId,
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") {
                component.set("v.isSocial", result);
            }
        });
        $A.enqueueAction(action);
    },
    
	acceptCase : function(component, event, helper) {
        var caseId = component.get("v.recordId");
        var action = component.get("c.acceptSocialCase");
        
        action.setParams({
            caseId : caseId,
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") {
                if(result.indexOf("case accepted") > -1) {
                    $A.get('e.force:refreshView').fire();
                } else {
                    component.find('notifLib').showToast({
                        "title": "Error",
                        "message": result,
                        "variant": "error"
                    });
                }
            } else if(state === "ERROR") {
                var errMsg = '';
                var errors = response.getError();
                if (errors) {
                    for(var i=0; i < errors.length; i++) {
                        for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                            errMsg += (errMsg.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                        }
                        if(errors[i].fieldErrors) {
                            for(var fieldError in errors[i].fieldErrors) {
                                var thisFieldError = errors[i].fieldErrors[fieldError];
                                for(var j=0; j < thisFieldError.length; j++) {
                                    errMsg += (errMsg.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }
                        if(errors[i].message) {
                            errMsg += (errMsg.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                }
                
                component.find('notifLib').showToast({
                    "title": "Error",
                    "message": errMsg,
                    "variant": "error"
                });
            }
        });
        $A.enqueueAction(action);
	}
})