({
    acceptWork: function(component, event, helper) {
        //update Call Accepted to TRUE
        var recordId = component.get("v.recordId");
        var action = component.get("c.acceptCall");
        
        action.setParams({
            'caseId' : recordId
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){
            	var resp = response.getReturnValue();
                /*
                1 - Success
                2 - Case owned by other agent
                3 - Call already accepted
                */
                if(resp == "1"){
                    component.find('notifLib').showToast({
                        "title": "Success!",
                        "message": "Call Accepted",
                        "variant": "success"
                    });
                    $A.get("e.force:refreshView").fire();
                } else if(resp == "2"){
                    component.find('notifLib').showToast({
                        "title": "Error",
                        "message": "Call can only be accepted by the case owner",
                        "variant": "error"
                    });
                } else {
                    component.find('notifLib').showToast({
                        "title": "Info",
                        "message": "Call has already been accepted",
                        "variant": "info"
                    });
                }
            } else {
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": "Call not accepted",
                    "variant": "error"
                });
                console.log('there was a problem: ' + response.getError());
            }
        });
		
        $A.enqueueAction(action);
        /*
        var omniAPI = component.find("omniToolkit");
        var recId = component.get("v.recordId");
        var recId15 = recId.substring(0, 15);
        var workToAccept;
        var errMessage = "You are unable to accept this call due to one of the following reasons:\n- Agent should be on Console\n- Agent should be Online in Omni-Channel\n- Call record should be in the Agent's current Omni-Channel (temporary assignment)\n- Call is already accepted";
        
        omniAPI.getAgentWorks().then(function(result) {
            var works = JSON.parse(result.works);
            
            for(var i = 0; i < works.length; i++) {
                var work = works[i];
                if(work.workItemId == recId15) {
                    workToAccept = work.workId;
                    break;
                }
            }
            
            if(workToAccept != undefined && workToAccept != null) {
                omniAPI.acceptAgentWork({workId: work.workId}).then(function(res) {
                    if (res) {
                        console.log("Accepted work successfully");
                    } else {
                        console.log("Accept work failed");
                    }
                }).catch(function(error) {
                    console.log(error);
                    if(error.includes("engaged")) {
                        component.find('notifLib').showToast({
                            "title": "Error",
                            "message": errMessage,
                            "variant": "error"
                        });
                    } else {
                        component.find('notifLib').showToast({
                            "title": "Error",
                            "message": error,
                            "variant": "error"
                        }); 
                    }
                });
            } else {
                component.find('notifLib').showToast({
                    "title": "Error",
                    "message": errMessage,
                    "variant": "error"
                }); 
            }
        }).catch(function(error) {
            console.log(error);
            if(error.includes("Omni-Channel is not available")) {
                component.find('notifLib').showToast({
                    "title": "Error",
                    "message": errMessage,
                    "variant": "error"
                });
            } else {
                component.find('notifLib').showToast({
                    "title": "Error",
                    "message": error,
                    "variant": "error"
                }); 
            }
        });*/
    }
})