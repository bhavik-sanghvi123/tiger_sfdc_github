({
	executeSaveDetails : function(component, createAddress) {
		var action = component.get("c.submitAssetOrder");
        var self = this;
       	var orderlist = self.convertOrderlistToSalesforce(component, component.get('v.orderItemList'));
       
       	action.setParams({            
            orderParameter : self.createParameter(component, createAddress),
            orderItemList : orderlist,
            isAsset : component.get('v.isAsset')
        });

        action.setCallback(this, function(action){
            var recordId = component.get('v.orderId');
            var workspaceAPI = component.find("workspace");
            var state = action.getState();
            var focusedTabId = "";
            
            if(state == 'SUCCESS') {            
				component.find('notifLib').showToast({
                    "title": "Order Creation!",
                    "message": "The order has been submitted.",
                    "variant": "success"
                });     
                
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    focusedTabId = response.tabId;
                    
                    if(focusedTabId != "") {
                        workspaceAPI.closeTab({tabId: focusedTabId});
                        workspaceAPI.openTab({
                            url: '#/sObject/' + recordId + '/view',
                            focus: true
                        }).then(function(response) {
                            workspaceAPI.focusTab({tabId : response});
                        })
                    }
                })
                
                if(focusedTabId == "" || focusedTabId == null) {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "Order"
                    });
                    navEvt.fire();
                }
            } else {
                component.find('notifLib').showToast({
                    "title": "Order Creation!",
                    "message": action.getError()[0].message,
                    "variant": "error"
                });  
			}
        }); 
        $A.enqueueAction(action);
	},
    
    retrieveDefaultAddress : function(component) { 
        var action = component.get("c.getDefaultAddress");
        var action2 = component.get("c.getAffiliateSingaporeCity");
        var userMarket = component.get("v.userMarket");
        var self = this;
        
        action.setParams({            
            contactId : component.get('v.contactId')
        });

        action.setCallback(this, function(action){          
            var state = action.getState();
            if(state == 'SUCCESS') {            
                var result = action.getReturnValue();
                
                if (result && result.length != 0) {
                    var childCmp = component.find("addressLookup");
                    childCmp.prepopulateMethod(result[0]);
                        
                    if(userMarket == "SG") {
                        component.find("PostalCode2__c").set("v.value", result[0].PostalCode__c);
                        component.find("addressUnitNo").set("v.value", result[0].UnitNumber__c);
                    }
                    else if(userMarket == "ID") {
                        component.find("addressCity2").set("v.value", result[0].City2__c);
                    }
                }
                else{
                    var marketField = component.get("v.marketField");
                    component.find("countryField").set("v.value", marketField);
                    
                    if(userMarket == "SG") {
                        action2.setCallback(this, function(response) {
                            var state = response.getState();
                            var result = response.getReturnValue();
                            
                            if(state === "SUCCESS"){
                                component.find("City2__c").set("v.value", result);
                            } 
                        });
                        
                        $A.enqueueAction(action2);    	
               		}
                }

            } else {
                alert(action.getError()[0].message);
            }
        }); 
        $A.enqueueAction(action);
    },
    
    retrieveMarketAndAddress : function(component) {
        var self = this;
        //var market = component.get("v.marketField");
        var action2 = component.get("c.getMarket");
       
        action2.setParams({            
            contactId : component.get('v.contactId')
        });
        
        action2.setCallback(this, function(action){          
            var state2 = action2.getState();
            if(state2 == 'SUCCESS') {        
                var result2 = action2.getReturnValue();
                component.set("v.marketField", result2);
                this.retrieveDefaultAddress(component);
            } 
        }); 
        $A.enqueueAction(action2);
    },
    
    retrievePicklistValue : function(component) {
        var action = component.get("c.getPickListValuesIntoList");
        var self = this;
        action.setCallback(this, function(action){          
            var state = action.getState();
            if(state == 'SUCCESS') {            
                var result = action.getReturnValue();          
                var items = [];
                for (var i = 0; i < result.length; i++) {
                    var item = {
                        "label": result[i],
                        "value": result[i],
                    };
                    items.push(item);
                }
                
                component.set('v.countryPicklist', items);
               
            } else {
                alert(action.getError()[0].message);
            }
        }); 
        $A.enqueueAction(action);
    },
    
    convertOrderlistToSalesforce : function(component, orderList) {
        var paymentValue = component.get("v.paymentValue");
        var totalGST = 0; 
        var result = [];
        
        if (orderList && orderList.length != 0) {            
            for(var i=0; i < orderList.length; i++) {
                var order = {};
                var currentOrder = orderList[i];
                order.OrderId = component.get('v.orderId');
                order.Product2Id = currentOrder.oProductId;
                order.Quantity = currentOrder.oQuantity;
                order.UnitPrice = currentOrder.oUnitPrice + (10);
                order.OrderedFor__c = currentOrder.oOrderedForId;
                order.Category__c = currentOrder.Category__c;    
                order.PromotionItem__c = currentOrder.oPromotionItemId;
                order.DiscountAmount__c = currentOrder.oDiscountAmount;
                order.GST__c = currentOrder.oGSTValue;
                order.Channel__c = currentOrder.oChannelId;
                order.Asset__c = currentOrder.oAssetId;
                order.CurrencyIsoCode = currentOrder.oCurrency;
                order.Allocated_Quantity__c = currentOrder.oOrderQuantity;
                result.push(order);
            }
        }
        return result;
    },
    
    createParameter : function(component, createAddress) {
        var selectedAddress = component.get('v.selectedAddress');
        var result = {
            orderId : component.get('v.orderId'),
            paymentMethod : component.get("v.paymentValue"),
            deliveryAddress : selectedAddress.Id ? selectedAddress.Id : component.get('v.addressId'),
            campaign : component.find("orderCampaign").get("v.value"),
            channel : component.find("orderChannel").get("v.value"),
            notes : component.get('v.orderNotesValue'),
            deliveryDate : component.get('v.orderDeliveryDate'),
            deliveryTime : component.get('v.orderDeliveryTime'),
            pricebook : component.get('v.pricebookId'),
            totalDiscount : component.get('v.finalDiscountAmount'),
            totalGST : component.get('v.finalGSTAmount'),
            updateAddress : createAddress,
            addressRec : createAddress ? this.createAddressRecord(component, selectedAddress) : { 'sobjectType' : 'Address__c'  }
        };
        return  JSON.stringify(result);
    },
    
    createAddressRecord : function(component, selectedAddress) {
        var userMarket = component.get("v.userMarket");
        
        var result = {
            Street1__c : component.find('Street1__c').get("v.value"),
            DefaultAddress__c : component.find('DefaultAddress__c').get("v.value") ,
            Street2__c : component.find('Street2__c').get("v.value"),
            UnitNumber__c : userMarket == "SG" ? component.find('addressUnitNo').get("v.value") : "",
            Region__c : userMarket != "ANZ" ? component.find('Region__c').get("v.value") : "",
            City2__c: userMarket != "ANZ" ?  userMarket == "ID" ? component.find("addressCity2").get("v.value") : component.find('City2__c').get("v.value") : "",
            District__c : userMarket != "ANZ" && userMarket != "IN" ? component.get("v.districtValue") : "",
            Street1__c : component.find('Street1__c').get("v.value"),
            StateProvince__c : userMarket != "ANZ" && userMarket != "IN" && userMarket != "ID" ? component.find('StateProvince__c').get("v.value") : "",
            Ward2__c : userMarket != "ANZ" && userMarket != "IN" ? component.get("v.wardValue") : "",
            PostalCode__c : userMarket == "SG" ? component.find('PostalCode2__c').get("v.value") : userMarket != "ID" ? component.find("PostalCode__c").get("v.value") : "",
            Country__c : component.get('v.selectedAddress.Country__c'),
            ParentHousehold__c : component.get('v.householdId'),
            SubDistrict__c : userMarket != "ANZ" && userMarket != "IN" ? component.get("v.subDistrictValue") : "",
            Building__c : userMarket != "ANZ" && userMarket != "ID" ? component.find('Building__c').get("v.value") : "",
            VillageNo__c : userMarket != "ANZ" && userMarket != "IN" && userMarket != "ID" ? component.find('VillageNo__c').get("v.value") : "",
            VillageName__c : userMarket != "ANZ" && userMarket != "IN" && userMarket != "ID" ? component.find('VillageName__c').get("v.value") : "",
            Road__c : userMarket != "ANZ" && userMarket != "IN" && userMarket != "ID" ? component.find('Road__c').get("v.value") : "",
            ParentContact__c : component.find('ParentContact__c').get("v.value") ? component.find('ParentContact__c').get("v.value") : component.get('v.contactId'),
            AddressValidationStatus__c : component.get("v.addressValidationStatus"),
            State__c : userMarket == "ANZ" || userMarket == "IN"? component.find('State__c').get("v.value") : "",
            SuburbTown__c : userMarket == "ANZ" ? component.find('SuburbTown__c').get("v.value") : "",
        };
        
        console.log("writing create address result");
        if ( selectedAddress.Id ) {
            result.Id = selectedAddress.Id
        } 
        return result;
    },
    
    checkUpdatehasChanges : function(component, event, helper, selectedRecord) {
        var userMarket = component.get("v.userMarket");
        var hasChanges = false;        
        
        if (selectedRecord && selectedRecord.Id) {
            //raustr - 8.9.19: added condition because of the new lookup
            var ward = selectedRecord.Ward2__c ? selectedRecord.Ward2__c : '';
            var district = selectedRecord.District__c ? selectedRecord.District__c : '';
            var subDistrict = selectedRecord.SubDistrict__c ? selectedRecord.SubDistrict__c : '';
            var city = selectedRecord.City2__c ? selectedRecord.City2__c : '';
            //check for any changes of the value
            if (component.find('Street1__c').get("v.value") != selectedRecord.Street1__c) {
                hasChanges = true;
            }
            else if (component.find('DefaultAddress__c').get("v.value") != selectedRecord.DefaultAddress__c) {
                hasChanges = true;
            }
            else if (component.find('Street2__c').get("v.value") != selectedRecord.Street2__c) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && (component.find('Region__c').get("v.value") != selectedRecord.Region__c)) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && userMarket != 'ID' && (component.find('City2__c').get("v.value") != selectedRecord.City2__c)) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && userMarket != 'IN' && component.get("v.districtValue") != district) {
                hasChanges = true;
            }
            else if (component.find('Street1__c').get("v.value") != selectedRecord.Street1__c) {
                hasChanges = true;
            }
            else if (userMarket != 'ID' && userMarket != "ANZ" && userMarket != 'IN' && component.find('StateProvince__c').get("v.value") != selectedRecord.StateProvince__c) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && userMarket != 'IN' && component.get("v.wardValue") != ward) {
                hasChanges = true;
            }
            else if (userMarket == 'ID' && component.get("v.cityValue") != city) {
                hasChanges = true;
            }
            else if (userMarket != 'SG' && userMarket != 'ID' && component.find('PostalCode__c').get("v.value") != selectedRecord.PostalCode__c) {
                hasChanges = true;
            }
            else if (userMarket == 'SG' && component.find('PostalCode2__c').get("v.value") != selectedRecord.PostalCode__c) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && userMarket != 'IN' && component.get("v.subDistrictValue") != subDistrict) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && userMarket != 'ID' && component.find('Building__c').get("v.value") != selectedRecord.Building__c) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && userMarket != 'IN' && userMarket != 'ID' && component.find('VillageNo__c').get("v.value") != selectedRecord.VillageNo__c) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && userMarket != 'IN' && userMarket != 'ID' && component.find('VillageName__c').get("v.value") != selectedRecord.VillageName__c) {
                hasChanges = true;
            }
            else if (userMarket != "ANZ" && userMarket != 'IN' && userMarket != 'ID' &&  component.find('Road__c').get("v.value") != selectedRecord.Road__c) {
                hasChanges = true;
            }
            else if (userMarket == "ANZ" && userMarket == 'IN' && (component.find('State__c').get("v.value") != selectedRecord.State__c)) {
                hasChanges = true;
            }
            else if (userMarket == "ANZ" && (component.find('SuburbTown__c').get("v.value") != selectedRecord.SuburbTown__c)) {
                hasChanges = true;
            }
        }
        return  hasChanges;
    },
    
    checkRequireField : function(component) {
        var userMarket = component.get("v.userMarket");
        var isValid = true;
        
        if (!component.find('Street1__c').get("v.value") || component.find('Street1__c').get("v.value") == '') {
            isValid = false;
        }

        if (userMarket != "ANZ" && userMarket != "ID" && (!component.find('City2__c').get("v.value") || component.find('City2__c').get("v.value") == '')) {
            isValid = false;
        }
        
        if (userMarket == "ID" && (!component.find('addressCity2').get("v.value") || component.find('addressCity2').get("v.value") == '')) {
            isValid = false;
        }

        if (!component.get('v.selectedAddress.Country__c') || component.get('v.selectedAddress.Country__c') == '') {
            isValid = false;
        }
        
        if (userMarket == "ANZ" && (component.find('State__c').get("v.value") == null || component.find('State__c').get("v.value") == '')) {
            isValid = false;
        }
        
        if (userMarket == "ANZ" && (component.find('SuburbTown__c').get("v.value") == null || component.find('SuburbTown__c').get("v.value") == '')) {
            isValid = false;
        }
        
        if ((userMarket == "ANZ" || userMarket == "IN")   && (component.find('State__c').get("v.value") == null || component.find('State__c').get("v.value") == '')) {
            isValid = false;
        }
        
        if (userMarket == "ID" && (component.find('Region__c').get("v.value") == null || component.find('Region__c').get("v.value") == '')) {
            isValid = false;
        }
        
        if (userMarket == "ID" && (component.find('addressDistrict').get("v.value") == null || component.find('addressDistrict').get("v.value") == '')) {
            isValid = false;
        }
        
        if (userMarket == "ID" && (component.find('addressSubDistrict').get("v.value") == null || component.find('addressSubDistrict').get("v.value") == '')) {
            isValid = false;
        }
        
        if (userMarket == "ID" && (component.find('addressWard').get("v.value") == null || component.find('addressWard').get("v.value") == '')) {
            isValid = false;
        }
        
        return isValid;
    },
    
    experianCallout : function(component, event, helper, searchKey, unitNumber) {
        console.log(searchKey + " " + unitNumber);
        console.log("experian callout");
        component.set("v.callingExperianAPI", true);
        var state = null;
        var result = null;
        
        var action = component.get("c.getAddressDetails");
        action.setParams({
            'postalCode' : searchKey,
            'unitNumber' : unitNumber,
        })
        
        action.setCallback(this, function(response) {
            setTimeout( function() {
                state = response.getState();
                result = response.getReturnValue();
                
                if(state === "SUCCESS"){
                    component.set("v.experianAddress", result);
                    component.set("v.callingExperianAPI", false);
                    
                    if(unitNumber != null && unitNumber != "") {
                        if(result.expPostCode != null) {
                            component.set("v.invalidUnitNo", false);
                            component.set("v.invalidPostalCode", false);
                            component.find("PostalCode2__c").set("v.value", result.expPostCode);
                            component.set("v.addressValidationStatus", "Valid Address");
                            
                            if(result.expStreet1 != null) {
                                component.find("Street1__c").set("v.value", result.expStreet1);
                            }
                            if(result.expBuilding != null) {
                                component.find("Building__c").set("v.value", result.expBuilding);
                            }
                            if(result.expState != null) {
                                component.find("StateProvince__c").set("v.value", result.expState);
                            }
                            //this.processExperianResult(component, event, helper, result);
                        } else {
                            component.set("v.invalidUnitNo", true);
                        }
                    } else {
                        if(result.expPostCode != null) {
                            component.set("v.invalidPostalCode", false);
                            component.find("PostalCode2__c").set("v.value", result.expPostCode);
                            component.set("v.addressValidationStatus", "Valid Address");
                            
                            if(result.expStreet1 != null) {
                                component.find("Street1__c").set("v.value", result.expStreet1);
                            }
                            if(result.expBuilding != null) {
                                component.find("Building__c").set("v.value", result.expBuilding);
                            }
                            if(result.expState != null) {
                                component.find("StateProvince__c").set("v.value", result.expState);
                            }
                            //this.processExperianResult(component, event, helper, result);
                        } else {
                            component.set("v.invalidPostalCode", true);
                        }
                    }
                }
            }, 250);
        });
        
        $A.enqueueAction(action);
	},
    
    refreshLookupAddress : function(component) {
        component.set('v.disabledWard', true);
        component.set('v.disabledSubDistrict', true);
        component.set('v.disabledDistrict', true);
        component.set('v.districtValue', '');
        component.set('v.subDistrictValue', '');
        component.set('v.wardValue', '');
        component.set('v.unitNumber', '');
        component.set('v.searchKeyWord', '');
    },
    
    // TKT-002676: Auto-populate Province field when City is within Metro Manila
	getMetroManilaCity : function(component, event, helper, cityId) {
        var action = component.get("c.getAffiliateCityName");
        action.setParams({
            'cityId' : cityId,
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS" && result != null){
                component.find("StateProvince__c").set("v.value", result);
            } 
        });
                    
        $A.enqueueAction(action);    	
	},
    
    populateChannelField : function(component, event, helper, campaignId) {
        var action = component.get("c.getChannelRecord");
        
        action.setParams({
            'campaignId' : campaignId,
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.find("orderChannel").set("v.value", result);
            } 
        });
                    
        $A.enqueueAction(action);    	
	},
    
    getHouseholdAddress : function(component, event, helper, householdId){
        var action = component.get("c.getHouseholdAddressRecord");
        
        action.setParams({
            'householdId' : householdId
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.householdAddress", result);
            } 
        });
        
        $A.enqueueAction(action);   
        
    },
    createAssetRelationship : function (component, event, helper){
         var action = component.get("c.createAssetRelationship");
        
		var orderList = component.get("v.orderItemList")
        action.setParams({
            'assetId': component.get("v.assetId"),
            'newAssetId' : orderList[0].oAssetId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS"){
                 component.find('notifLib').showToast({
                    "title": "Asset Replacement!",
                    "message": "The asset replacement has been submitted.",
                    "variant": "success"
                });  
                
            this.executeSaveDetails(component, true);
            }
            else{
                component.find('notifLib').showToast({
                    "title": "Asset Replacement!",
                    "message": "The new asset must not be the same as the old asset",
                    "variant": "error"
                }); 
            }
        });
        
        $A.enqueueAction(action);
	}
    
})