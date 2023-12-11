({
	doInit : function(component, event, helper) {
        var action = component.get("c.fetchUserDetails");
        var getToken = component.get("c.getExperianToken");
        var sObjectName = component.get("v.sObjectName");
        var recordId = component.get("v.recordId");

        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.userMarket", result.Market__c);
                
                if(result.Market__c == "SG") {
                    helper.getSingaporeCity(component, event, helper);
                }
            } 
        });
        
        $A.enqueueAction(action);
        
        component.set("v.addressId", recordId);
        helper.identifyRecordAccess(component, event, helper, recordId);
        helper.retrieveAddressDetails(component, event, helper, recordId);

        getToken.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
			
            if(state === "SUCCESS"){
                if(result != null && result != '') {
                	component.set("v.isTokenAvailable", true);
                } else {
                    component.set("v.isTokenAvailable", false);
                }
            } 
        });
        
        $A.enqueueAction(getToken);
	},

	cancelCreation : function(component, event, helper) {
        if (confirm('Are you sure you want to Cancel?')) {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId}); 
            })
        }
	},
	
	saveAddress : function(component, event, helper) {
        event.preventDefault(); // stop form submission
        
        var userMarket = component.get("v.userMarket");
        var street1Value = component.find("addressStreet1").get("v.value");
        var invalidPostalCode = component.get("v.invalidPostalCode");
        var invalidUnitNo = component.get("v.invalidUnitNo");
        var message;
        var cityValue;
        var stateValue;
        var suburbTownValue;
        var regionValue;
        var districtValue;
        var subDistrictValue;
        var wardValue;
        var isError = false;
        
        if(invalidPostalCode) {
            isError = true;
            message = "Invalid Postal Code!";
            helper.showToast(component, event, helper, message);
        }
        
        if(invalidUnitNo) {
            isError = true;
            message = "Invalid Unit Number!";
            helper.showToast(component, event, helper, message);
        }
        
        if(street1Value == null || street1Value == '') {
            isError = true;
            message = "Street1 must be completed."
            helper.showToast(component, event, helper, message);
        }
            
        if(userMarket != "ANZ") {

            if(userMarket == "ID") {
                cityValue = component.find("addressCity2").get("v.value");
            } else {
                cityValue = component.find("addressCity").get("v.value");
            }
            
            if(cityValue == null || cityValue == '') {
                isError = true;
                message = "City must be completed."
                helper.showToast(component, event, helper, message);
            }
        }
        
        if(userMarket == "ANZ") {
            stateValue = component.find("addressState").get("v.value");
            suburbTownValue = component.find("addressSuburbTown").get("v.value");
            
            if(stateValue == null || stateValue == '' || suburbTownValue == null || suburbTownValue == '') {
                isError = true;
                message = "These required fields must be completed: State, Suburb/Town"
                helper.showToast(component, event, helper, message);
            }
        }
        
        if(userMarket == "IN") {
            stateValue = component.find("addressState").get("v.value");
            
            if(stateValue == null || stateValue == '') {
                isError = true;
                message = "State must be completed."
                helper.showToast(component, event, helper, message);
            }
        }
        
        if(userMarket == "ID") {
            regionValue = component.find("addressRegion").get("v.value");
            districtValue = component.find("addressDistrict").get("v.value");
            subDistrictValue = component.find("addressSubDistrict").get("v.value");
            wardValue = component.find("addressWard").get("v.value");
            
            if(regionValue == null || regionValue == '') {
                isError = true;
                message = "Region must be completed."
                helper.showToast(component, event, helper, message);
            }
            
            if(districtValue == null || districtValue == '') {
                isError = true;
                message = "District must be completed."
                helper.showToast(component, event, helper, message);
            }
            
            if(subDistrictValue == null || subDistrictValue == '') {
                isError = true;
                message = "Sub-District must be completed."
                helper.showToast(component, event, helper, message);
            }
            
            if(wardValue == null || wardValue == '') {
                isError = true;
                message = "Postal Code must be completed."
                helper.showToast(component, event, helper, message);
            }
        }
        
        if(!isError) {
            var fields = event.getParam("fields");
            fields["District__c"] = component.get('v.districtValue');
            fields["SubDistrict__c"] = component.get('v.subDistrictValue');
            fields["Ward2__c"] = component.get('v.wardValue');
            fields["AddressValidationStatus__c"] = component.get('v.addressValidationStatus');
			
            if(userMarket == "ID") {
                fields["City2__c"] = component.get('v.cityValue');
            }
            component.find("addressForm").submit(fields);
        }
	},
    
    handleError : function(component, event) {
        var errors = event.getParam('detail');
    },
    
    handleSuccess : function(component, event) {
        component.find('notifLib').showToast({
            "title": "Success!",
            "message": "Address has been successfully created!",
            "variant": "success"
        });
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId}); 
        })
    },
    
    postalCodeKeyPressController : function(component, event, helper) {

        // run for SG only
        var userMarket = component.get("v.userMarket");
        var isTokenAvailable = component.get("v.isTokenAvailable");
        if(!(userMarket == "SG" && isTokenAvailable)) {
            return;
        }

        component.set("v.addressValidationStatus", "Pending");
        var searchKey = component.find("addressPostalCode2").get("v.value");
        var unitNumber = component.find("addressUnitNo").get("v.value");
        var postalCodeFormat = new RegExp("\\d\\d\\d\\d\\d\\d");
        var message;
        
        if(searchKey.length == 6){
            if(!postalCodeFormat.test(searchKey)) {
                component.set("v.invalidPostalCode", true);
                message = "Invalid Postal Code!";
                helper.showToast(component, event, helper, message);            
            } else {
                component.find("addressStreet1").set("v.value", null);
                component.find("addressBuilding").set("v.value", null);
                component.find("addressStateProvince").set("v.value", null);
                helper.experianCallout(component, event, helper, searchKey, unitNumber);
            }
        } 
        else if(searchKey.length > 6){
            component.set("v.invalidPostalCode", true);
            message = "Invalid Postal Code!";
            helper.showToast(component, event, helper, message); 
        }
        else if(searchKey.length == 0) {
            component.set("v.invalidPostalCode", false);     
		}
	},
    
    unitNoKeyPressController : function(component, event, helper) {

        // run for SG only
        var userMarket = component.get("v.userMarket");
        var isTokenAvailable = component.get("v.isTokenAvailable");
        if(!(userMarket == "SG" && isTokenAvailable)) {
            return;
        }

        var searchKey = component.find("addressPostalCode2").get("v.value");
        var unitNumber = component.find("addressUnitNo").get("v.value");
        var unitNumber5CharFormat = new RegExp("\\d\\d[-]\\d\\d|\\d\\d[-]\\d[A-Z]");
        var unitNumber6CharFormat = new RegExp("\\d\\d[-]\\d\\d\\d|\\d\\d[-]\\d\\d[A-Z]");
        var message = "Invalid Unit Number!";
        
        if((unitNumber.length == 5 && !unitNumber5CharFormat.test(unitNumber)) || (unitNumber.length == 6 && !unitNumber6CharFormat.test(unitNumber)) || unitNumber.length > 6){
            component.set("v.invalidUnitNo", true);
            helper.showToast(component, event, helper, message);
        }
		else if((unitNumber.length == 5 || unitNumber.length == 6) && searchKey != null && searchKey != "") {
            helper.experianCallout(component, event, helper, searchKey, unitNumber);
        }
        else if(unitNumber.length == 0) {
            component.set("v.invalidUnitNo", false);     
		}
	},
    
    stateChange : function(component, event, helper) {
        var userMarket = component.get("v.userMarket");
        
        if(event.getSource().getLocalId() == 'addressCity' && event.getSource().get("v.value") != '') {
            component.set('v.disabledDistrict', false);
            component.set('v.cityValue', event.getSource().get("v.value"));
        }
        else if (event.getSource().getLocalId() == 'addressCity'){
            component.find("addressDistrict").clearValue();           
            component.find("addressSubDistrict").clearValue();      
            component.find("addressWard").clearValue();
            component.set('v.disabledDistrict', true);
        }
        else if (event.getSource().getLocalId() == 'addressRegion'){
            console.log("usermarket: " + userMarket);
            if(userMarket == "ID") {
                component.set('v.disabledCity2', event.getSource().get("v.value") == "");
                component.find("addressCity2").clearValue();
            }
            component.set("v.regionValue", event.getSource().get("v.value")); 
            component.find("addressDistrict").clearValue();
        }
    },
    
    handleSelectedAddress : function(component, event, helper) {
		var selectedRecordGetFromEvent = event.getParam("addressObj");
        var userMarket = component.get("v.userMarket");
        
        console.log('handleSelectedAddress: ' + selectedRecordGetFromEvent.name);
		if (selectedRecordGetFromEvent) {	
            if (selectedRecordGetFromEvent.name == 'City' && selectedRecordGetFromEvent.value != '') {
                component.set('v.disabledDistrict', selectedRecordGetFromEvent.value == '');
                component.set('v.cityValue', selectedRecordGetFromEvent.value);
            } else if (selectedRecordGetFromEvent.name == 'City'){
                component.set('v.cityValue', selectedRecordGetFromEvent.value);
                component.set('v.disabledDistrict', selectedRecordGetFromEvent.value == '');
                component.find("addressDistrict").clearValue();
            }

            if (selectedRecordGetFromEvent.name == 'District') {
                component.set('v.districtValue', selectedRecordGetFromEvent.value);
                component.find("addressSubDistrict").clearValue();      
                component.find("addressWard").clearValue();      
                component.set('v.disabledWard', selectedRecordGetFromEvent.value == '');
                component.set('v.disabledSubDistrict', selectedRecordGetFromEvent.value == '');
            }

            if (selectedRecordGetFromEvent.name == 'Sub-District'){
                component.set('v.subDistrictValue', selectedRecordGetFromEvent.value);
            }

            if (userMarket != "ID" && selectedRecordGetFromEvent.name == 'Ward'){
                component.set('v.wardValue', selectedRecordGetFromEvent.value);
            } else if (selectedRecordGetFromEvent.name == 'Postal Code') {
                component.set('v.wardValue', selectedRecordGetFromEvent.value);
            }
		}
	},
    
	handleLoad : function(component, event) {
        var userMarket = component.get("v.userMarket");
        
        if(userMarket != "ANZ") {
            var addressCity = userMarket == "ID" ? "addressCity2" : "addressCity";
            
            if (!$A.util.isEmpty(component.find(addressCity).get("v.value"))) {
                component.set("v.cityValue", component.find(addressCity).get("v.value"));
                if(userMarket != "ID"){
                    component.set('v.disabledDistrict', false);
                }
            }
        }
    },
})