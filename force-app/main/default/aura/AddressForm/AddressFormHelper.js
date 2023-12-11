({
    experianCallout : function(component, event, helper, searchKey, unitNumber) {
        var action = component.get("c.getAddressDetails");
        action.setParams({
            'postalCode' : searchKey,
            'unitNumber' : unitNumber,
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();

            //var message = 'unitno: ' + unitNumber + '=== result ' + result.expSubBuilding + '|' + 'post code: ' + searchKey + '=== result: ' + result.expPostCode;
            //this.showToast(component, event, helper, message);
            
            if(state === "SUCCESS"){
                if(unitNumber != null && unitNumber != "") {
                    if((result.expSubBuilding != unitNumber) || (result.expPostCode != searchKey)) {
                    //if(result.expPostCode == null) {
                        component.set("v.invalidUnitNo", true);
                    } else {
                        component.set("v.invalidUnitNo", false);
                        this.processExperianResult(component, event, helper, result);
                    }
                } else {
                    if(result.expPostCode != null) {
                        this.processExperianResult(component, event, helper, result);
                    } else {
                        component.set("v.invalidPostalCode", true);
                    }
                }
            }
        });
        
        $A.enqueueAction(action);
	},
    
    processExperianResult: function(component, event, helper, result) {
        if(result.expPostCode != null) {
            component.set("v.invalidPostalCode", false);
            component.set("v.experianAddress", result);
            component.find("addressPostalCode2").set("v.value", result.expPostCode);
            component.set("v.addressValidationStatus", "Valid Address");
            
            if(result.expStreet1 != null) {
                component.find("addressStreet1").set("v.value", result.expStreet1);
            }
            if(result.expBuilding != null) {
                component.find("addressBuilding").set("v.value", result.expBuilding);
            }
            if(result.expState != null) {
                component.find("addressStateProvince").set("v.value", result.expState);
            }
        }
    },
    
    identifyRecordAccess : function(component, event, helper, addressId) {
        var action = component.get("c.getRecordAccess");
        
        action.setParams({
            'addressId' : addressId,
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();

            if(state === "SUCCESS"){
                if(result == true) {
                    component.set("v.hasRecordAccess", true);
                } else {
                    component.set("v.hasRecordAccess", false);
                }
            } 
        });
        
        $A.enqueueAction(action); 	
	},
    
    showToast : function(component, event, helper, message) {
        component.find('notifLib').showToast({
            "title": "Error!",
            "message": message,
            "variant": "error"
        });
	},
    
    getSingaporeCity : function(component, event, helper) {
        var action = component.get("c.getAffiliateSingaporeCity");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.find("addressCity").set("v.value", result);
            } 
        });
        
        $A.enqueueAction(action);    	
	},
    
    retrieveAddressDetails : function(component, event, helper, recordId) {
        var action = component.get("c.getAddressRecordDetails");
        
        action.setParams({
            'addressId' : recordId,
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.selectedAddress", result);
                component.find("addressCity2").set("v.value", result.City2__c);
            } 
        });
                    
        $A.enqueueAction(action);    	
	}
})