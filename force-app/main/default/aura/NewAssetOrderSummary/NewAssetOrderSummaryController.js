({
    doInit : function(component, event, helper) {
        console.log("initializing order summary page");
        var caseId = component.get("v.caseId");
        var paymentValue = component.get("v.paymentValue");
        var orderTypeValue = component.get("v.orderTypeValue");
        var finalGrandTotal = component.get("v.finalGrandTotal");
        component.set("v.finalGrandTotalSummary", finalGrandTotal);
        
        var action = component.get("c.getLoginUserDetails");
        var getToken = component.get("c.getExperianToken");
        var getDefaultValues = component.get("c.getCaseDetails");
        helper.retrievePicklistValue(component);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.userMarket", result.Market__c);
                helper.retrieveMarketAndAddress(component);
            } 
        });
        
        $A.enqueueAction(action);
        
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
        
        if(caseId != "" && caseId != null){
            getDefaultValues.setParams({            
                caseId : caseId,
            });
            
            getDefaultValues.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                
                if(state === "SUCCESS"){
                    component.find("orderCampaign").set("v.value", result.RelatedCampaign__c);
                    component.find("orderChannel").set("v.value", result.RelatedCampaign__r.Channel__c);
                } 
            });
            
            $A.enqueueAction(getDefaultValues);
        }
        
        helper.getHouseholdAddress(component, event, helper, component.get("v.householdId"));
        
        var orderItemList = component.get("v.orderItemList");
        component.set("v.pricebookId", orderItemList[0].oPricebook);
    },
    
    saveDetails : function(component, event, helper) {
        console.log("saving record...");
        if(component.get("v.isAsset")){          
            
            if(component.get("v.isReplacement")){
                helper.createAssetRelationship(component, event, helper);
            }
            else{
                
            component.set("v.selectedAddress", component.get("v.householdAddress"));
                helper.executeSaveDetails(component, true);
            }
        }
        else{
            
            var selectedRecord  = component.get('v.selectedAddress');
            var invalidPostalCode = component.get("v.invalidPostalCode");
            var invalidUnitNo = component.get("v.invalidUnitNo");
            
            if(invalidPostalCode) {
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": "Invalid Postal Code!",
                    "variant": "error"
                }); 
            }
            
            else if(invalidUnitNo) {
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": "Invalid Unit Number!",
                    "variant": "error"
                }); 
            }
            
                else if (helper.checkRequireField(component) == false) {
                    component.find('notifLib').showToast({
                        "title": "Order Creation!",
                        "message": 'Please populate all the required field',
                        "variant": "error"
                    }); 
                }  
            
                    else if (helper.checkUpdatehasChanges(component, event, helper, selectedRecord)) {
                        var r = confirm("You have update an existing address. Are you sure you want to apply the changes?");
                        if (r) {						
                            helper.executeSaveDetails(component, true);
                        }
                    } 
            
                        else if (!selectedRecord.Id) {					
                            helper.executeSaveDetails(component, true);
                        } else {
                            helper.executeSaveDetails(component, false);
                        }   
        }
    },
    
    showAddress : function(component, event, helper) {
        component.set('v.showAddressCreation', true);		
    },
    
    handleSelectedAddress : function(component, event, helper) {
        var userMarket = component.get("v.userMarket");
        var selectedRecordGetFromEvent = event.getParam("saveAddress");
        if (selectedRecordGetFromEvent) {		
            helper.refreshLookupAddress(component);
            
            var childCmp = component.find("addressLookup");           
            childCmp.prepopulateMethod(event.getParam("addressObj"));
            
            if(userMarket == "SG"){
                component.find("PostalCode2__c").set("v.value", event.getParam("addressObj").PostalCode__c);
            }    
        }
        component.set('v.showAddressCreation', false);
    },
    
    showModalforCancelButton : function(component, event, helper) {
        var compEvent = component.getEvent("cancelSummaryEvent");
        compEvent.setParams({"cancelOrder" : true });  
        compEvent.fire();
    },
    
    backToPreviousPage : function(component, event, helper) {
        var compEvent = component.getEvent("cancelSummaryEvent");
        compEvent.setParams({"cancelOrder" : false });  
        compEvent.fire();
    },
    
    handleSuccess: function(component, event, helper) {
        var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
        console.log('onsuccess: ', updatedRecord.response.id);
        component.set('v.addressId', updatedRecord.response.id);
        helper.executeSaveDetails(component);
    },
    
    handleError : function(component, event) {
        var err = JSON.parse(JSON.stringify(event.getParam('error')));
        console.log(err.message);
    },
    
    handleLoad : function(component, event) {
        var userMarket = component.get("v.userMarket");
        
        if(userMarket != "ANZ") {
            var addressCity = userMarket == "ID" ? "addressCity2" : "City2__c";
            
            if (!$A.util.isEmpty(component.find(addressCity).get("v.value"))) {
                component.set("v.cityValue", component.find(addressCity).get("v.value"));
                if(userMarket != "ID"){
                    component.set('v.disabledDistrict', false);
                }
            }
        }
    },
    
    refreshForm : function(component, event, helper) {
        component.set('v.refreshEditForm', false);
        helper.refreshLookupAddress(component);
        
        window.setTimeout(
            $A.getCallback(function() {
                component.set('v.refreshEditForm', true);
                //set the default country
                var marketField = component.get("v.marketField");
                component.find("countryField").set("v.value", marketField);
            }), 200
        );
    },
    
    handleOptionSelected: function (component, event, helper) {
        // Get the string of the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");
        component.set('v.countryValue', selectedOptionValue);        
    },
    
    postalCodeKeyPressController : function(component, event, helper) {
        var searchKey = component.get("v.searchKeyWord");
        var unitNumber = component.get("v.unitNumber");
        var postalCodeFormat = new RegExp("\\d\\d\\d\\d\\d\\d");
        
        if(searchKey.length == 6 && searchKey.length > 0){
            if(!postalCodeFormat.test(searchKey)) {
                component.set("v.invalidPostalCode", true);
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": "Invalid Postal Code!",
                    "variant": "error"
                });          
            } else {
                component.find("Street1__c").set("v.value", null);
                component.find("Building__c").set("v.value", null);
                component.find("StateProvince__c").set("v.value", null);
                helper.experianCallout(component, event, helper, searchKey, unitNumber);
            }
        } 
        else if (searchKey.length > 0 && searchKey.length < 6){
            component.set("v.invalidPostalCode", true);
            component.find('notifLib').showToast({
                "title": "Error!",
                "message": "Invalid Postal Code!",
                "variant": "error"
            });
        }
            else if(searchKey.length == 0) {
                component.set("v.invalidPostalCode", false);
            }
    },
    
    unitNoKeyPressController : function(component, event, helper) {
        console.log("unit no. is updated");
        var searchKey = component.get("v.searchKeyWord");
        var unitNumber = component.get("v.unitNumber");
        var unitNumber5CharFormat = new RegExp("\\d\\d[-]\\d\\d|\\d\\d[-]\\d[A-Z]");
        var unitNumber6CharFormat = new RegExp("\\d\\d[-]\\d\\d\\d|\\d\\d[-]\\d\\d[A-Z]");
        var unitNumber7CharFormat = new RegExp("\\d\\d[-]\\d\\d\\d\\d|\\d\\d[-]\\d\\d[A-Z][A-Z]|\\d\\d[-]\\d\\d\\d[A-Z]");
        
        if((unitNumber.length == 5 && !unitNumber5CharFormat.test(unitNumber)) || (unitNumber.length == 6 && !unitNumber6CharFormat.test(unitNumber)) 
           || (unitNumber.length == 7 && !unitNumber7CharFormat.test(unitNumber)) || unitNumber.length > 7){
            component.set("v.invalidUnitNo", true);
            component.find('notifLib').showToast({
                "title": "Error!",
                "message": "Invalid Unit Number!",
                "variant": "error"
            });
        }
        else if((unitNumber.length == 5 || unitNumber.length == 6 || unitNumber.length == 7) && searchKey != null && searchKey != "") {
            console.log("experian callout with unit number");
            helper.experianCallout(component, event, helper, searchKey, unitNumber);
        }
            else if (unitNumber.length == 0){
                component.set("v.invalidUnitNo", false);
            }
    },
    
    stateChange  : function(component, event, helper) {
        var userMarket = component.get("v.userMarket");
        
        if(event.getSource().getLocalId() == 'City2__c' && event.getSource().get("v.value") != '') {
            component.set('v.disabledDistrict', false);
            component.set('v.cityValue', event.getSource().get("v.value"));
        }
        else if (event.getSource().getLocalId() == 'City2__c'){
            component.find("addressDistrict").clearValue();           
            component.find("addressSubDistrict").clearValue();      
            component.find("addressWard").clearValue();
            component.set('v.disabledDistrict', true);
        }
            else if (event.getSource().getLocalId() == 'Region__c'){
                if(userMarket == "ID") {
                    component.find("addressCity2").clearValue();
                    component.set('v.disabledCity2', event.getSource().get("v.value") == "");
                }
                component.set("v.regionValue", event.getSource().get("v.value")); 
                component.find("addressDistrict").clearValue();
            }
        
        // TKT-002676: auto update state/province for mm cities
        var cityId = component.find("City2__c").get("v.value");
        if(userMarket == "PH") {
            helper.getMetroManilaCity(component, event, helper,cityId);
        }
    },
    
    handleLookupAddress : function(component, event, helper) {
        var selectedRecordGetFromEvent = event.getParam("addressObj");
        var regionValue = component.get("v.regionValue");
        var userMarket = component.get("v.userMarket");
        
        console.log('handleLookupAddress: ' + selectedRecordGetFromEvent.name);
        if (selectedRecordGetFromEvent) {
            if (selectedRecordGetFromEvent.name == 'City' && selectedRecordGetFromEvent.value != '') {
                component.set('v.disabledDistrict', selectedRecordGetFromEvent.value == '');
                component.set('v.cityValue', selectedRecordGetFromEvent.value);
            } else if (selectedRecordGetFromEvent.name == 'City'){
                component.set('v.cityValue', selectedRecordGetFromEvent.value);
                component.set('v.disabledDistrict', selectedRecordGetFromEvent.value == '');
                component.find("addressDistrict").clearValue();
                if(regionValue != '' && regionValue != null) {
                    component.set('v.disabledCity2', false);
                }
            }
            
            if (selectedRecordGetFromEvent.name == 'District' && selectedRecordGetFromEvent.value != '') {
                component.set('v.disabledWard', false);
                component.set('v.disabledSubDistrict', false);
                component.set('v.districtValue', selectedRecordGetFromEvent.value);
            } else  if (selectedRecordGetFromEvent.name == 'District') {
                component.set('v.districtValue', '');
                component.find("addressSubDistrict").clearValue();      
                component.find("addressWard").clearValue();      
                component.set('v.disabledWard', true);
                component.set('v.disabledSubDistrict', true);
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
    
    campaignSelected : function(component, event, helper) {
        var campaignId = component.find("orderCampaign").get("v.value");
        
        if(campaignId != ""){
            helper.populateChannelField(component, event, helper, campaignId);
        } else {
            component.find("orderChannel").set("v.value", "");
        }
    }, 
    
    
})