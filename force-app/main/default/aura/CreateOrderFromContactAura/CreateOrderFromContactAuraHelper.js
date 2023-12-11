({
    getMarketVal : function(component, helper) {
		var action = component.get("c.getMarketVal");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.marketList", result.marketValues);
                component.find("mainMarket").set("v.value", 'SG');
                component.find("endMarket").set("v.value", 'SG');
            } 
        });
        $A.enqueueAction(action);
    },
    
	getContacts : function(component, helper) {
        var mainAge = component.get("v.mainAge") == undefined || component.get("v.mainAge") == null || component.get("v.mainAge") == '' ? null : component.get("v.mainAge");
        var endAge = component.get("v.endAge") == undefined || component.get("v.endAge") == null || component.get("v.endAge") == '' ? null : component.get("v.endAge");
        var campObj = JSON.parse(JSON.stringify(component.get("v.campaign")));
        var campaignId = campObj.length == 0 ? '' : campObj[0];
        
		var action = component.get("c.pageOnInit");
        action.setParams({
            'brName' : component.get("v.brName"),
            'mainAge' : mainAge,
            'mainMarket' : component.find("mainMarket").get("v.value"),
            'endAge' : endAge,
            'endMarket' : component.find("endMarket").get("v.value"),
            'campId' : campaignId
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.contactList", result.contactList);
                component.set("v.marketList", result.marketValues);
            } 
        });
        $A.enqueueAction(action);
    },
    
    getFilteredContacts : function(component, helper) {
        
        var mainAge = component.get("v.mainAge") == undefined || component.get("v.mainAge") == null || component.get("v.mainAge") == '' ? null : component.get("v.mainAge");
        var endAge = component.get("v.endAge") == undefined || component.get("v.endAge") == null || component.get("v.endAge") == '' ? null : component.get("v.endAge");
        var campObj = JSON.parse(JSON.stringify(component.get("v.campaign")));
        var campaignId = campObj.length == 0 ? '' : campObj[0];
        
        var action = component.get("c.getContacts");
        action.setParams({
            'brName' : component.get("v.brName"),
            'mainAge' : mainAge,
            'mainMarket' : component.find("mainMarket").get("v.value"),
            'endAge' : endAge,
            'endMarket' : component.find("endMarket").get("v.value"),
            'campId' : campaignId,
            'crName' : component.get("v.crName"),
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if (result.length == 0) {
                    component.set("v.tableMsg", "No Data Found.");
                    $A.util.removeClass(component.find("pageMsg"), "slds-hide");
                    $A.util.addClass(component.find("contactTable"), "slds-hide");
                }
                else if (result.length  > 1000) {
                    component.set("v.tableMsg", "Too many records returned. Please add another filter.");
                    $A.util.removeClass(component.find("pageMsg"), "slds-hide");
                    $A.util.addClass(component.find("contactTable"), "slds-hide");
                }
                else {
                    component.set("v.contactList", result);
                    component.set("v.maxRowSelect", result.length);
                    $A.util.removeClass(component.find("contactTable"), "slds-hide");
                    $A.util.addClass(component.find("pageMsg"), "slds-hide");
                }
            }
            else {
                component.set("v.tableMsg", "There is a problem with the retrieved data. Please try again or try contacting your admin.");
                $A.util.removeClass(component.find("pageMsg"), "slds-hide");
                $A.util.addClass(component.find("contactTable"), "slds-hide");
            }
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },
    
    saveOrder : function(component, orderFields, conMap) {
        var action = component.get("c.createOrder");
        console.log(conMap);
        action.setParams({
            'orderVal' : orderFields,
            'conObj' : conMap
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.newOrder", false);
                component.set("v.orderHeader", 'ORDER PRODUCT CREATION');
                component.set("v.selectedRows", result);
            } 
            else {
                var errors = response.getError();
                var errormsg;
                if (errors && errors[0] && errors[0].message) {
                    errormsg = errors[0].message;
                } 
                else if (errors && errors[0] && errors[0].fieldErrors) {
                    for(var fieldError in errors[0].fieldErrors) {
                        var thisFieldError = errors[0].fieldErrors[fieldError];
                        for(var j=0; j < thisFieldError.length; j++) {
                            errormsg = thisFieldError[j].message;
                        }
                    }
                }
                else {
                    errormsg = 'Error with data retrieval. Please contact admin.';
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errormsg
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    saveItem : function(component, orderFields, conMap) {
        var action = component.get("c.createOrderProd");
        console.log(conMap);
        action.setParams({
            'orderProdVal' : orderFields,
            'conObj' : conMap
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.newItem", false);
            }
            else {
                var errors = response.getError();
                var errormsg;
                if (errors && errors[0] && errors[0].message) {
                    errormsg = errors[0].message;
                } 
                else if (errors && errors[0] && errors[0].fieldErrors) {
                    for(var fieldError in errors[0].fieldErrors) {
                        var thisFieldError = errors[0].fieldErrors[fieldError];
                        for(var j=0; j < thisFieldError.length; j++) {
                            errormsg = thisFieldError[j].message;
                        }
                    }
                }
                else {
                    errormsg = 'Error with data retrieval. Please contact admin.';
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errormsg
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
})