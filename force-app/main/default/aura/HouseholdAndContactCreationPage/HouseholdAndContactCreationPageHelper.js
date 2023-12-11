({
    saveHouseholdAndPrimary : function(component, event, helper, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse,isFeedback, isInquiry, ifNoCase) {
        var action = component.get("c.savePrimaryContactAndHousehold"); 
        var contactParams = this.getContactParameters(component, event, helper);
        console.log('Contact Parameters: ' + contactParams);
        var jsonParams = JSON.stringify(contactParams); 
        
        //Setting the Apex Parameter
        action.setParams({
            'params': jsonParams,
        	'accountId': accountId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            var secondaryContactId;
            
            if(state === "SUCCESS"){
                if(result == "isError") {
                    var message = "A duplicate Contact exists.";
                    this.showToast(component, event, helper, message);
                    component.set("v.invalidUser", false);
                } 
                else {
                    component.set("v.primaryContactId", result);
                    component.set("v.systemErrorMessage", "");
                    
                    if(isAdult || isChild) {
                        this.saveSecondaryContact(component, event, helper, isAdult, isChild, noSecondaryContact, mapToPrimaryContact, mapToSecondaryContact, isCreateBrandRelationship, isCreateChannelResponse);
                    }
                    
                    if(isCreateAddress) {
                        this.saveContactAddress(component, event, helper, isCreateAddress);
                    }
                    
                    if(mapToPrimaryContact || noSecondaryContact) {
                        this.saveContactBrandRelationship(component, event, helper, noSecondaryContact, mapToPrimaryContact, mapToSecondaryContact, secondaryContactId, isCreateBrandRelationship, isCreateChannelResponse);
                    }

                    if(!ifNoCase){
                        this.saveCaseRecord(component,event,helper,isFeedback,isInquiry,ifNoCase)
                    }
            	}
            }
            else {
                var errors = response.getError();
                this.showToast(component, event, helper, errors[0].message);component.set("v.invalidUser", false);
                component.set("v.invalidUser", false);
            }
        });
        
       	$A.enqueueAction(action);
    },

    saveCaseRecord : function(component,event,helper,isFeedback, isInquiry, ifNoCase){

        var primaryContactId = component.get("v.primaryContactId");
        var accountId = component.get("v.accountId");
        var recordTypeName;
        var caseParams;

        if(isFeedback){
            recordTypeName = 'Feedback';
            caseParams = this.getCaseFeedbackParams(component, event, helper);
        }
        else if(isInquiry){
            recordTypeName = 'Inquiry';
            caseParams = this.getCaseInquiryParams(component, event, helper);
        }


        var jsonParams = JSON.stringify(caseParams);
        var action = component.get("c.saveCaseRecord");

        action.setParams({
            'params': jsonParams,
            'primaryContactId': primaryContactId,
            'accountId' : accountId,
            'recTypeName' : recordTypeName
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.createdCaseId", result);
                component.set("v.systemErrorMessage", "");
                this.viewCreatedRecords(component, event, helper);

            }
            else {
                var errors = response.getError();
                this.showToast(component, event, helper, errors[0].message);
                component.set("v.invalidUser", false);
            }
        });
        
       	$A.enqueueAction(action); 
        
        
    },

    savechildContact : function(component, event, helper, isAdult, isChild, isCreateBrandRelationship, isCreateChannelResponse) {
        //raustral - 2.21.2019, method for saving child record
        this.saveSecondaryContact(component, event, helper, isAdult, isChild, false, false, true, isCreateBrandRelationship, isCreateChannelResponse);        

    },
    
    saveContactAddress : function(component, event, helper, isCreateAddress) {
        var action = component.get("c.saveAddress"); 
        var addressParams = this.getAddressParameters(component, event, helper);
        var jsonParams = JSON.stringify(addressParams);
        var primaryContactId = component.get("v.primaryContactId");
		
        //Setting the Apex Parameter
        action.setParams({
            'params': jsonParams,
            'primaryContactId': primaryContactId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.addressId", result);
                component.set("v.systemErrorMessage", "");
            }
            else {
                var errors = response.getError();
                this.showToast(component, event, helper, errors[0].message);
                component.set("v.invalidUser", false);
            }
        });
        
       	$A.enqueueAction(action); 
    },
    
    saveSecondaryContact : function(component, event, helper, isAdult, isChild, noSecondaryContact, mapToPrimaryContact, mapToSecondaryContact, isCreateBrandRelationship, isCreateChannelResponse) {
        var action = component.get("c.saveAdditionalContact"); 
        var primaryContactId = component.get("v.primaryContactId");
        var contactParams;

        if(isAdult == true) {
        	contactParams = this.getAdultContactParameters(component, event, helper);
        } 
        else if(isChild == true) {
            contactParams = this.getChildContactParameters(component, event, helper);
        }

        var jsonParams = JSON.stringify(contactParams); 
        
        //Setting the Apex Parameter
        action.setParams({
            'params': jsonParams,
            'primaryContactId': primaryContactId,
            'isAdult': isAdult,
            'isChild': isChild});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            var secondaryContactId = result;
            
            if(state === "SUCCESS"){
                if(result == "isError") {
                    var message = "A duplicate Contact exists.";
                    this.showToast(component, event, helper, message);
                    component.set("v.invalidUser", false);
                } else {
                    console.log(response.getReturnValue());
                    component.set("v.additionalContactId", result);
                    component.set("v.systemErrorMessage", "");
					
                    if(mapToSecondaryContact && secondaryContactId != "isError") {
                        this.saveContactBrandRelationship(component, event, helper, noSecondaryContact, mapToPrimaryContact, mapToSecondaryContact, secondaryContactId, isCreateBrandRelationship, isCreateChannelResponse);
                    }
                }
            }
            else {
                var errors = response.getError();
                this.showToast(component, event, helper, errors[0].message);
                component.set("v.invalidUser", false);
            }
        });
        
       	$A.enqueueAction(action);
    },
    
    saveContactBrandRelationship : function(component, event, helper, noSecondaryContact, mapToPrimaryContact, mapToSecondaryContact, secondaryContactId, isCreateBrandRelationship, isCreateChannelResponse) {        
        if(isCreateBrandRelationship) {
            var action = component.get("c.saveBrandRelationship");
            var primaryContactId = component.get("v.primaryContactId");
            var brParams = this.getBrandRelationshipParameters(component, event, helper);
            var jsonParams = JSON.stringify(brParams);
            var additionalContactId = component.get("v.additionalContactId"); 
            var mainContactId = component.get("v.mainContactId");
            
            //Setting the Apex Parameter
            action.setParams({
                'params': jsonParams,
                'primaryContactId': primaryContactId,
                'additionalContactId': secondaryContactId,
                'noSecondaryContact': noSecondaryContact,
                'mapToPrimaryContact': mapToPrimaryContact,
                'mapToSecondaryContact': mapToSecondaryContact,
                'mainContactId': mainContactId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                
                if(state === "SUCCESS"){
                    component.set("v.brandRelationshipId", result);
                    component.set("v.systemErrorMessage", "");

                    if(isCreateChannelResponse) {
                        this.saveChannelResponse(component, event, helper, result);
                    } 
                    else {
                        this.viewCreatedRecords(component, event, helper);
                    }
                }
                else {
                    var errors = response.getError();
                    this.showToast(component, event, helper, errors[0].message);
                        component.set("v.invalidUser", false);
                    }
                });
                
                $A.enqueueAction(action);
        } 
        else if(!isCreateBrandRelationship) {
            this.viewCreatedRecords(component, event, helper);
        }
    },

    saveChannelResponse : function(component, event, helper, brandRelationshipId) { 
        var action = component.get("c.saveChannelResponse");
        var crParams = this.getChannelResponseParameters(component, event, helper);
        var jsonParams = JSON.stringify(crParams);
        var brandRelationshipId = component.get("v.brandRelationshipId"); 
        
        //Setting the Apex Parameter
        action.setParams({
            'params': jsonParams,
            'brandRelationshipId': brandRelationshipId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.channelResponseId", result);
                component.set("v.systemErrorMessage", "");
                this.viewCreatedRecords(component, event, helper);
            }
            else {
                var errors = response.getError();
                this.showToast(component, event, helper, errors[0].message);
                    component.set("v.invalidUser", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getProductHierarchyLevel : function(component, event, helper, productId){
        return new Promise(function (resolve,reject){
        var action = component.get("c.getProductHierarchyLevel");
        action.setParams({
            "productId" : productId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if(state === "SUCCESS"){
                    if(result == true){
                        component.set("v.caseProductIsBrand", true);
                    }
                    resolve('RESOLVE');
                }
                else if (response.getState() === "ERROR") {
                    console.log(response.getError());   
                    reject('REJECT');    
                }          
            });
            $A.enqueueAction(action);
        });
    },
    
    getPicklistValues : function(component, object, fieldAPI, uiId) {
		
        var action = component.get("c.getRelationshipTypePicklistValues");
		action.setParams({
            			"obj" : object,
            			"fld" : fieldAPI
        				});
        var opts = [];
        action.setCallback(this, function(response) {  

            if (response.getState() === "SUCCESS")  {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--None--",
                        value: "",
                        selected: "true"
                    });
                }
                
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(uiId).set("v.options", opts);
            } 
            else if (response.getState() === "ERROR") {
            	console.log(response.getError());       
            }           
        });
        $A.enqueueAction(action);
	},
    
    viewCreatedRecords : function(component, event, helper) {

            component.find('notifLib').showToast({
                "title": "Success!",
                "message": "Records are successfully created!",
                "variant": "success"
            });
                    
            var accountId = component.get("v.accountId");
            var primaryContactId = component.get("v.primaryContactId");        
            var mainContactId = component.get("v.mainContactId");
            var workspaceAPI = component.find("workspace");
            var caseId = component.get("v.caseId");
            
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
                
            }) 
            

            if(caseId != null && caseId != "") {

                var action = component.get("c.updateCaseRecord");
                action.setParams({
                            "caseRecordId" : caseId,
                            "conRecordId" : primaryContactId
                            });
                $A.enqueueAction(action);

                var sObjectEvent4 = $A.get("e.force:navigateToSObject");
                sObjectEvent4.setParams({
                    "recordId": caseId,
                    "slideDevName": "detail",
                });
                sObjectEvent4.fire();
            }

            else if(accountId != null) {
                var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": accountId,
                    "slideDevName": "detail",
                });
                sObjectEvent.fire();           
            }
            
            else if(primaryContactId != null && primaryContactId != "") {
                $A.get("e.force:refreshView").fire();
                var sObjectEvent2 = $A.get("e.force:navigateToSObject");
                sObjectEvent2.setParams({
                    "recordId": primaryContactId,
                    "slideDevName": "detail",
                });
                sObjectEvent2.fire();           
            }
            
            else if(mainContactId != null && mainContactId != "") {
                $A.get("e.force:refreshView").fire();
                var sObjectEvent3 = $A.get("e.force:navigateToSObject");
                sObjectEvent3.setParams({
                    "recordId": mainContactId,
                    "slideDevName": "detail",
                });
                sObjectEvent3.fire();           
            }
    },
    
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
                    //if(result.expPostCode == null) {
                    //result should match entered unit no and postal code
                    if((result.expSubBuilding != unitNumber) || (result.expPostCode != searchKey)) {
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
        component.set("v.invalidPostalCode", false);
        component.set("v.experianAddress", result);
        component.find("addressPostalCode").set("v.value", result.expPostCode);
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
    
    getMetroManilaCity : function(component, event, helper, cityId) {
        var action = component.get("c.getAffiliateCityName");
        action.setParams({
            'cityId' : cityId,
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS" && result != null){
                component.find("addressStateProvince").set("v.value", result);
            } 
        });
                    
        $A.enqueueAction(action);    	
	},
    
    showToast : function(component, event, helper, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error Message",
            "message": message,
        });
        toastEvent.fire();
	},
    
    promptDialogBox : function(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent, isFeedback, isInquiry, ifNoCase) {
        if (confirm(message)) {
            if(isChildCreation) {
                this.savechildContact(component, event, helper, isAdult, isChild, isCreateBrandRelationship, isCreateChannelResponse);
                component.set("v.isAdultWarning", false);
                component.set("v.isChildWarning", false);
            } else {
                if(isParent) {
                	component.set("v.isPrimaryWarning", false);    
                } else {
                    component.set("v.isAdultWarning", false);
                    component.set("v.isChildWarning", false);
                }
                
                var isPrimaryWarning = component.get("v.isPrimaryWarning");
                var isAdultWarning = component.get("v.isAdultWarning");
                var isChildWarning = component.get("v.isChildWarning");
                
                if(!isPrimaryWarning && !isAdultWarning && !isChildWarning) {
            		this.saveHouseholdAndPrimary(component, event, helper, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse,  isFeedback, isInquiry, ifNoCase);
                }
                
            }
        } else {
			component.set("v.invalidUser",false);
        }
	},

    getContactParameters : function(component, event, helper) {
        var userMarket = component.get("v.userMarket");
        var primaryMasterOptOut = component.find("primaryMasterOptOut").get("v.value");
        var primaryDoNotCall = component.find("primaryDoNotCall").get("v.value");
        var primaryEmailOptOut = component.find("primaryEmailOptOut").get("v.value");
        var primaryWhatsAppOptOut = component.find("primaryWhatsAppOptOut").get("v.value");
        var primarySMSOptOut = component.find("primarySMSOptOut").get("v.value");
        var primaryDataShareOptOut = component.find("primaryDataShareOptOut").get("v.value");
        var primaryVerified = component.find("primaryVerified").get("v.value");
        
		return {
            'primarySalutation': component.find("primarySalutation").get("v.value"),
            'primaryFirstName': component.find("primaryFirstName").get("v.value"),	
            'primaryMiddleName': component.find("primaryMiddleName").get("v.value"),
            'primaryLastName': component.find("primaryLastName").get("v.value"),
            'primarySuffix': component.find("primarySuffix").get("v.value"),
            'primaryBirthdate': component.find("primaryBirthdate").get("v.value"),
            'primaryProfession': component.find("primaryProfession").get("v.value"),
            'primaryEmail': component.find("primaryEmail").get("v.value"),
            'primaryHomePhone': component.find("primaryHomePhone").get("v.value"),
            'primaryGender': component.find("primaryGender").get("v.value"),
            'primaryEthnicity': component.find("primaryEthnicity").get("v.value"),
            'primaryLanguage': component.find("primaryLanguage").get("v.value"),
            'primaryAfterBirthCareCenter': component.find("primaryAfterBirthCareCenter").get("v.value"),
            'primaryEnrolledBy': component.find("primaryEnrolledBy").get("v.value"),
            'primaryMobilePhone': component.find("primaryMobilePhone").get("v.value"),
            'primaryPurchaseChannel': userMarket != "ANZ" ? component.find("primaryPurchaseChannel").get("v.value") : null,
            'primarySecondaryPurchaseChannel': userMarket != "ANZ" ? component.find("primarySecondaryPurchaseChannel").get("v.value") : null,
            'primaryMasterOptOut': primaryMasterOptOut == null ? false : primaryMasterOptOut,
            'primaryEmailOptOut': primaryEmailOptOut == null ? false : primaryEmailOptOut,
            'primaryWhatsAppOptOut': primaryWhatsAppOptOut == null ? false : primaryWhatsAppOptOut,
            'primaryDoNotCall': primaryDoNotCall == null ? false : primaryDoNotCall,
            'primarySMSOptOut': primarySMSOptOut == null ? false : primarySMSOptOut,
            'primaryDataShareOptOut': primaryDataShareOptOut == null ? false : primaryDataShareOptOut,
            'primaryPreferredPaymentMethod': userMarket != "ANZ" ? component.find("primaryPreferredPaymentMethod").get("v.value") : null,
            'primaryHeight': userMarket != "ANZ" ? component.find("primaryHeight").get("v.value") : null,
            'primaryEstimatedDueDate': userMarket != "ANZ" ? component.find("primaryEstimatedDueDate").get("v.value") : null,
            'primaryWeight': userMarket != "ANZ" ? component.find("primaryWeight").get("v.value"): null,
            'primaryCaloriesDay': userMarket != "ANZ" ? component.find("primaryCaloriesDay").get("v.value") : null,
            'primaryMembershipStartDate': userMarket != "ANZ" ? component.find("primaryMembershipStartDate").get("v.value") : null,
            'primaryTagging': component.find("primaryTagging").get("v.value"),
            'primaryPreferredContactTime' : component.find("primaryPreferredContactTime").get("v.value"),
            'primaryOtherPhone' : component.find("primaryOtherPhone").get("v.value"),
            'primaryOfficePhone' : component.find("primaryOfficePhone").get("v.value"),
            'primaryPreferredPhone' : component.find("primaryPreferredPhone").get("v.value"),
            'primaryVerified' : primaryVerified == null ? false : primaryVerified,
            'primaryCarerPhone' : component.find("primaryCarerPhone").get("v.value"),
            'primaryOccupation': component.find("primaryOccupation").get("v.value"),
            'primaryExternalLoyaltyID': userMarket != "ANZ" ? component.find("primaryExternalLoyaltyID").get("v.value") : null,
            'primarySourceCreatedDate': userMarket != "ANZ" ? component.find("primarySourceCreatedDate").get("v.value") : null,
            'primaryExternalReferenceNumber': userMarket != "ANZ" ? component.find("primaryExternalReferenceNumber").get("v.value") : null,
            'primaryConsumerResponse' : userMarket != "ANZ" ? component.find("primaryConsumerResponse").get("v.value") : null,
            'primaryEducationLevel' : component.find("primaryEducationLevel").get("v.value"),
            'primaryMonthlyExpense' : component.find("primaryMonthlyExpense").get("v.value"),
            'primaryFamilyDiabetesHistory' : userMarket != "ANZ" ? component.find("primaryFamilyDiabetesHistory").get("v.value") : null,
            'primaryLungDiseaseName' : userMarket != "ANZ" ? component.find("primaryLungDiseaseName").get("v.value") : null,
            'primaryRenalDiseaseType' : userMarket != "ANZ" ? component.find("primaryRenalDiseaseType").get("v.value") : null,
        };
    },
    
    getAddressParameters : function(component, event, helper) { 
        var userMarket = component.get("v.userMarket");
        
		return {
        	'addressStreet1': component.find("addressStreet1").get("v.value"),
            'addressStreet2': component.find("addressStreet2").get("v.value"),
            'addressCity': userMarket != "ANZ" ? userMarket == "ID" ? component.find("addressCity2").get("v.value") : component.find("addressCity").get("v.value") : null,	
            'addressStateProvince': (userMarket != "ANZ" && userMarket != "IN" && userMarket != "ID") ? component.find("addressStateProvince").get("v.value") : null,
            'addressPostalCode': userMarket != "ID" ? component.find("addressPostalCode").get("v.value") : null,
            'addressCountry': component.find("addressCountry").get("v.value"),
            'addressDefaultAddress': component.find("addressDefaultAddress").get("v.value"),	
            'addressType': component.find("addressType").get("v.value"),
            'addressRegion': userMarket != "ANZ" ? component.find("addressRegion").get("v.value") : null,
            'addressDistrict': (userMarket != "ANZ" && userMarket != "IN") ? component.find("addressDistrict").get("v.value"): null,
            'addressWard': (userMarket != "ANZ" && userMarket != "IN") ? component.find("addressWard").get("v.value"): null,
            'addressSubDistrict': (userMarket != "ANZ" && userMarket != "IN") ? component.find("addressSubDistrict").get("v.value"): null,
            'addressBuilding' : (userMarket != "ANZ" && userMarket != "ID")? component.find("addressBuilding").get("v.value") : null,
            'addressVillageNo' : (userMarket != "ANZ" && userMarket != "IN" && userMarket != "ID") ? component.find("addressVillageNo").get("v.value") : null,
            'addressVillageName' : (userMarket != "ANZ" && userMarket != "IN" && userMarket != "ID") ? component.find("addressVillageName").get("v.value") : null,
            'addressRoad' : (userMarket != "ANZ" && userMarket != "IN" && userMarket != "ID") ? component.find("addressRoad").get("v.value") : null,
            'addressValidationStatus' : component.get("v.addressValidationStatus"),
            'addressUnitNo' : userMarket == "SG" ? component.find("addressUnitNo").get("v.value") : null,
            'addressState': (userMarket == "ANZ" || userMarket == "IN") ? component.find("addressState").get("v.value") : null,	
            'addressSuburbTown': userMarket == "ANZ" ? component.find("addressSuburbTown").get("v.value") : null,	
        };
    },
    
    getAdultContactParameters : function(component, event, helper) {
        var isFromContact = component.get("v.isFromContact");
        var isChildCreation = component.get("v.isChildCreation");
        var userMarket = component.get("v.userMarket");
        var adultMasterOptOut = component.find("adultMasterOptOut").get("v.value");
        var adultEmailOptOut = component.find("adultEmailOptOut").get("v.value");
        var adultWhatsAppOptOut = component.find("adultWhatsAppOptOut").get("v.value");
        var adultDoNotCall = component.find("adultDoNotCall").get("v.value");
        var adultSMSOptOut = component.find("adultSMSOptOut").get("v.value");
        var adultDataShareOptOut = component.find("adultDataShareOptOut").get("v.value");
        var adultSecondaryVerified = component.find("adultSecondaryVerified").get("v.value");

		return {
            'adultSalutation': component.find("adultSalutation").get("v.value"),
            'adultFirstName': component.find("adultFirstName").get("v.value"),	
            'adultMiddleName': component.find("adultMiddleName").get("v.value"),
            'adultLastName': component.find("adultLastName").get("v.value"),
            'adultSuffix': component.find("adultSuffix").get("v.value"),
            'adultBirthdate': component.find("adultBirthdate").get("v.value"),
            'adultProfession': component.find("adultProfession").get("v.value"),
            'adultEmail': component.find("adultEmail").get("v.value"),
            'adultHomePhone': component.find("adultHomePhone").get("v.value"),
            'adultMainContact': isChildCreation && !isFromContact ? component.find("adultMainContact").get("v.value") : null,
            'adultGender': component.find("adultGender").get("v.value"),
            'adultEthnicity': component.find("adultEthnicity").get("v.value"),
            'adultLanguage': component.find("adultLanguage").get("v.value"),
            'adultAfterBirthCareCenter': component.find("adultAfterBirthCareCenter").get("v.value"),
            'adultEnrolledBy': component.find("adultEnrolledBy").get("v.value"),
            'adultPrimaryPurchaseChannel': userMarket != "ANZ" ? component.find("adultPrimaryPurchaseChannel").get("v.value") : null,
            'adultSecondaryPurchaseChannel': userMarket != "ANZ" ? component.find("adultSecondaryPurchaseChannel").get("v.value") : null,
            'adultMasterOptOut': adultMasterOptOut == null ? false : adultMasterOptOut,
            'adultEmailOptOut': adultEmailOptOut == null ? false : adultEmailOptOut,
            'adultWhatsAppOptOut': adultWhatsAppOptOut == null ? false : adultWhatsAppOptOut,
            'adultDoNotCall': adultDoNotCall == null ? false : adultDoNotCall,
            'adultSMSOptOut': adultSMSOptOut == null ? false : adultSMSOptOut,
            'adultDataShareOptOut': adultDataShareOptOut == null ? false : adultDataShareOptOut,
            'adultPreferredPaymentMethod': userMarket != "ANZ" ? component.find("adultPreferredPaymentMethod").get("v.value") : null,
            'adultHeight': userMarket != "ANZ" ? component.find("adultHeight").get("v.value") : null,
            'adultEstimatedDueDate': userMarket != "ANZ" ? component.find("adultEstimatedDueDate").get("v.value") : null,
            'adultWeight': userMarket != "ANZ" ? component.find("adultWeight").get("v.value") : null,
            'adultCaloriesDay': userMarket != "ANZ" ? component.find("adultCaloriesDay").get("v.value") : null,
            'adultMembershipStartDate': userMarket != "ANZ" ? component.find("adultMembershipStartDate").get("v.value") : null,
            'adultPreferredContactTime': component.find("adultPreferredContactTime").get("v.value"),
            'adultSecondaryVerified':adultSecondaryVerified == null ? false : adultSecondaryVerified,
            'adultCustomerRelationship': component.find("adultCustomerRelationship").get("v.value"),
            'adultOccupation': component.find("adultOccupation").get("v.value"),
            'adultMobilePhone': userMarket == "ANZ" ? component.find("adultMobilePhone").get("v.value") : null,
            'adultConsumerResponse' : userMarket != "ANZ" ? component.find("adultConsumerResponse").get("v.value") : null,
            'adultEducationLevel' : component.find("adultEducationLevel").get("v.value"),
            'adultMonthlyExpsense' : component.find("adultMonthlyExpsense").get("v.value"),
            'adultFamilyDiabetesHistory' : userMarket != "ANZ" ? component.find("adultFamilyDiabetesHistory").get("v.value") : null,
            'adultLungDiseaseName' : userMarket != "ANZ" ? component.find("adultLungDiseaseName").get("v.value") : null,
            'adultRenalDiseaseType' : userMarket != "ANZ" ? component.find("adultRenalDiseaseType").get("v.value") : null,
        };
    },
    
    getChildContactParameters : function(component, event, helper) {
        var isChildCreation = component.get("v.isChildCreation");
        var isFromContact = component.get("v.isFromContact");
        var userMarket = component.get("v.userMarket");
        var childVerified = component.find("childVerified").get("v.value");
        
		return {
            'childSalutation': component.find("childSalutation").get("v.value"),
            'childFirstName': component.find("childFirstName").get("v.value"),	
            'childMiddleName': component.find("childMiddleName").get("v.value"),
            'childLastName': component.find("childLastName").get("v.value"),
            'childSuffix': component.find("childSuffix").get("v.value"),
            'childMainContact': isChildCreation && !isFromContact ? component.find("childMainContact").get("v.value") : null,
            'childGender': component.find("childGender").get("v.value"),
            'childBirthdate': component.find("childBirthdate").get("v.value"),
            'childBirthHospital': component.find("childBirthHospital").get("v.value"),
            'childEnrolledBy': component.find("childEnrolledBy").get("v.value"),
            'childHeight': userMarket != "ANZ" ? component.find("childHeight").get("v.value") : null,
            'childHeightForAge': userMarket != "ANZ" ? component.find("childHeightForAge").get("v.value") : null,
            'childWeight': userMarket != "ANZ" ? component.find("childWeight").get("v.value"): null,
            'childWeightForAge': userMarket != "ANZ" ? component.find("childWeightForAge").get("v.value") : null,
            'childWeightForHeight': userMarket != "ANZ" ? component.find("childWeightForHeight").get("v.value") : null,
            'childCaloriesDay': userMarket != "ANZ" ? component.find("childCaloriesDay").get("v.value") : null,
            'childVerified': childVerified == null ? false : childVerified,
            'childAgeRange': component.find("childAgeRange").get("v.value"),
            'childCustomerRelationship': component.find("childCustomerRelationship").get("v.value")
        };
    },
    
    getBrandRelationshipParameters : function(component, event, helper) { 
        var userMarket = component.get("v.userMarket");
        var brWinBack = component.find("brWinBack").get("v.value");
        var brBrandOptOut = component.find("brBrandOptOut").get("v.value");
        var brProductBenefitsExplained = component.find("brProductBenefitsExplained").get("v.value");
        var brCareGiver = component.find("brCareGiver").get("v.value");
        var brGiftGiver = component.find("brGiftGiver").get("v.value");
        var brEndUser = component.find("brEndUser").get("v.value");
        
		return {
            'brBrandRelationship': component.find("brBrandRelationship").get("v.value"),
            'brBrandSwitchReason': component.find("brBrandSwitchReason").get("v.value"),	
            'brType': component.find("brType").get("v.value"),
            'brWinBack': brWinBack == null ? false : brWinBack,
            'brProductLoyaltyLength': component.find("brProductLoyaltyLength").get("v.value"),
            'brProductExperience': component.find("brProductExperience").get("v.value"),
            'brCurrentPreviousBrand': component.find("brCurrentPreviousBrand").get("v.value"),
            'brStatus': component.find("brStatus").get("v.value"),
            'brDateFirstUsed': component.find("brDateFirstUsed").get("v.value"),
            'brSKU': component.find("brSKU").get("v.value"),	
            'brServingSchedule': component.find("brServingSchedule").get("v.value"),
            'brServingPerDay': component.find("brServingPerDay").get("v.value"),
            'brPreferredFlavor': component.find("brPreferredFlavor").get("v.value"),
            'brMilkWaterMixture': component.find("brMilkWaterMixture").get("v.value"),
            'brScoopPerServing': component.find("brScoopPerServing").get("v.value"),
            'brRouteOfFeeding': component.find("brRouteOfFeeding").get("v.value"),
            'brCanPerMonth': component.find("brCanPerMonth").get("v.value"),
            'brBrandOptOut': brBrandOptOut == null ? false : brBrandOptOut,
            'brProductBenefitsExplained': brProductBenefitsExplained == null ? false : brProductBenefitsExplained,
            'brRating': component.find("brRating").get("v.value"),
            'brRemarks': component.find("brRemarks").get("v.value"),
            'brPreviousBrand': component.find("brPreviousBrand").get("v.value"),
            'brCareGiver': brCareGiver == null ? false : brCareGiver,
            'brGiftGiver': brGiftGiver == null ? false : brGiftGiver,
            'brEndUser': brEndUser == null ? false : brEndUser,
            'brBrandUsageReason' : component.find("brBrandUsageReason").get("v.value"),
        };
    },

    getChannelResponseParameters : function(component, event, helper) {
        var crSampleRequested = component.find("crSampleRequested").get("v.value");
        var crGrowthGuideAppSubmitted = component.find("crGrowthGuideAppSubmitted").get("v.value");
        
        return {
            'crChannel': component.find("crChannel").get("v.value"),
            'crCampaign': component.find("crCampaign").get("v.value"),    
            'crRegistrationDate': component.find("crRegistrationDate").get("v.value"),
            'crPromoterName': component.find("crPromoterName").get("v.value"),
            'crPromoterCode': component.find("crPromoterCode").get("v.value"),
            'crSupervisorName': component.find("crSupervisorName").get("v.value"),
            'crSupervisorCode': component.find("crSupervisorCode").get("v.value"),
            'crSampleRequested': crSampleRequested == null ? false : crSampleRequested,
            'crOrderCreationStatus': component.find("crOrderCreationStatus").get("v.value"),
            'crDeliveryAddress': component.find("crDeliveryAddress").get("v.value"),
            'crProductSampleRequested': component.find("crProductSampleRequested").get("v.value"),
            'crHCPClassification': component.find("crHCPClassification").get("v.value"),
            'crHCPName': component.find("crHCPName").get("v.value"),
            'crGrowthGuideAppSubmitted': crGrowthGuideAppSubmitted == null ? false : crGrowthGuideAppSubmitted,
            'crCustomerSpecialty': component.find("crCustomerSpecialty").get("v.value"),
            'crBirthHospital': component.find("crBirthHospital").get("v.value"),
            'crAfterBirthCareCenter': component.find("crAfterBirthCareCenter").get("v.value"),
            'crEnrolledBy': component.find("crEnrolledBy").get("v.value"),
            'crItemTypeRequested': component.find("crItemTypeRequested").get("v.value"),
            'crSampleRedemptionMethod': component.find("crSampleRedemptionMethod").get("v.value"),
            'crNonDeliveryRedemptionResult': component.find("crNonDeliveryRedemptionResult").get("v.value"),
            'crNonDeliveryRedemptionDate': component.find("crNonDeliveryRedemptionDate").get("v.value"),
            'crDrugStoreRedemptionChoice': component.find("crDrugStoreRedemptionChoice").get("v.value"),
        };
    },
    
    getCaseFeedbackParams : function(component,event,helper){
        var fbResolved = component.find("fbResolved").get("v.value");
        var fbFollowUpCall = component.find("fbFollowUpCall").get("v.value");
        var fbProductReplacement = component.find("fbProductReplacement").get("v.value");
        var fbCustomerCertification = component.find("fbCustomerCertification").get("v.value");
        var fbFileToTrackwise = component.find("fbFileToTrackwise").get("v.value");
        var fbSocialCase = component.find("fbSocialCase").get("v.value");
        var fbSampleAvailability = component.find("fbSampleAvailability").get("v.value");
        var fbResponseLetterisRequired = component.find("fbResponseLetterisRequired").get("v.value");
        
		return {
            'caseClassification': component.find("fbClassification").get("v.value"),	
            'caseStatus': component.find("fbStatus").get("v.value"),
            'casePriority': component.find("fbPriority").get("v.value"),
            'caseSubClassification': component.find("fbSubClassification").get("v.value"),
            'caseOrigin': component.find("fbOrigin").get("v.value"),
            'caseSubject': component.find("fbSubject").get("v.value"),
            'caseDescription': component.find("fbDescription").get("v.value"),
            'caseOrder': component.find("fbOrder").get("v.value"),
            'caseParentId': component.find("fbParentId").get("v.value"),
            'caseEscalatedTo': component.find("fbEscalatedTo").get("v.value"),
            'caseProduct': component.find("fbProduct").get("v.value"),
            'caseRetention': component.find("fbRetention").get("v.value"),
            'caseProductReplacement': fbProductReplacement == null ? false : fbProductReplacement,
            'caseCustomerCertification': fbCustomerCertification == null ? false : fbCustomerCertification,
            'caseProductReplacementStatus': component.find("fbProductReplacementStatus").get("v.value"),
            'caseStoreWherePurchased': component.find("fbStoreWherePurchased").get("v.value"),
            'caseBatchNumber': component.find("fbBatchNumber").get("v.value"),
            'caseProductPackageSize': component.find("fbProductPackageSize").get("v.value"),
            'caseManufacturingDate': component.find("fbManufacturingDate").get("v.value"),
            'caseDatePurchased': component.find("fbDatePurchased").get("v.value"),
            'caseFileToTrackwise': fbFileToTrackwise == null ? false : fbFileToTrackwise,
            'caseReplacementNotes': component.find("fbReplacementNotes").get("v.value"),
            'caseVariant': component.find("fbVariant").get("v.value"),
            'caseLotNumber': component.find("fbLotNumber").get("v.value"),
            'caseExpiryDate': component.find("fbExpiryDate").get("v.value"),
            'caseDateOpenedUsed': component.find("fbDateOpenedUsed").get("v.value"),
            'caseResolutionNotes': component.find("fbResolutionNotes").get("v.value"),
            'caseReopenCount': component.find("fbReopenCount").get("v.value"),
            'caseReopenNotes': component.find("fbReopenNotes").get("v.value"),
            'caseResolved': fbResolved == null ? false : fbResolved,
            'caseFollowUpCall': fbFollowUpCall == null ? false : fbFollowUpCall,
            'casePreferredDateTime': component.find("fbPreferredDateTime").get("v.value"),
            'caseReasonForCallback': component.find("fbReasonForCallback").get("v.value"),
            'caseWebEmail': component.find("fbWebEmail").get("v.value"),
            'caseSocialCase': fbSocialCase == null ? false : fbSocialCase,
            'caseReplacementProduct': component.find("fbReplacementProduct").get("v.value"),
            'caseSourceCreatedDate': component.find("fbSourceCreatedDate").get("v.value"),
            'caseCaseRegarding': component.find("fbCaseRegarding").get("v.value"),
            'caseReplyVia': component.find("fbReplyVia").get("v.value"),
            'caseEnquirerType': component.find("fbEnquirerType").get("v.value"),
            'caseComplexity': component.find("fbComplexity").get("v.value"),
            'caseReviewedBy': component.find("fbReviewedBy").get("v.value"),
            'caseReviewedDate': component.find("fbReviewedDate").get("v.value"),
            'caseAbbottAwarenessDate': component.find("fbAbbottAwarenessDate").get("v.value"),
            'caseDateofPackaging': component.find("fbDateofPackaging").get("v.value"),
            'caseTimeCode': component.find("fbTimeCode").get("v.value"),
            'caseDateofIncident': component.find("fbDateofIncident").get("v.value"),
            'casePackCondition': component.find("fbPackCondition").get("v.value"),
            'caseTrackwiseID': component.find("fbTrackwiseID").get("v.value"),
            'caseRecommendedBy': component.find("fbRecommendedBy").get("v.value"),
            'caseAdditionalObservation': component.find("fbAdditionalObservation").get("v.value"),
            'caseSampleAvailability': fbSampleAvailability == null ? false : fbSampleAvailability,
            'caseResponseLetterisRequired': fbResponseLetterisRequired == null ? false : fbResponseLetterisRequired,
            'caseUsageDetails': component.find("fbUsageDetails").get("v.value"),
            'caseNutritionHistory': component.find("fbNutritionHistory").get("v.value"),
            'caseLevelofEscalation': component.find("fbLevelofEscalation").get("v.value"),
            'caseReminderStatus': component.find("fbReminderStatus").get("v.value"),
            'caseState': component.find("fbState").get("v.value"),
            'caseQuantity': component.find("fbQuantity").get("v.value"),
            'caseProductReplacementDeliveredDate': component.find("fbProductReplacementDeliveredDate").get("v.value"),
        };
    },
    
    getCaseInquiryParams : function(component,event,helper){
        var inquiryResolved = component.find("inquiryResolved").get("v.value");
        var inquiryFollowUpCall = component.find("inquiryFollowUpCall").get("v.value");
        var inquirySocialCase = component.find("inquirySocialCase").get("v.value");
        
		return {
            'caseClassification': component.find("inquiryClassification").get("v.value"),	
            'caseStatus': component.find("inquiryStatus").get("v.value"),
            'casePriority': component.find("inquiryPriority").get("v.value"),
            'caseSubClassification': component.find("inquirySubClassification").get("v.value"),
            'caseSocialCase': inquirySocialCase == null ? false : inquirySocialCase,
            'caseOrigin': component.find("inquiryOrigin").get("v.value"),
            'caseSubject': component.find("inquirySubject").get("v.value"),
            'caseDescription': component.find("inquiryDescription").get("v.value"),
            'caseOrder': component.find("inquiryOrder").get("v.value"),
            'caseParentId': component.find("inquiryParentId").get("v.value"),
            'caseResolutionNotes': component.find("inquiryResolutionNotes").get("v.value"),
            'caseProduct': component.find("inquiryProduct").get("v.value"),
            'caseEscalatedTo': component.find("inquiryEscalatedTo").get("v.value"),
            'caseBatchNumber': component.find("inquiryBatchNumber").get("v.value"),
            'caseEndUserName': component.find("inquiryEndUserName").get("v.value"),
            'caseCurrentBrandUsed': component.find("inquiryCurrentBrandUsed").get("v.value"),
            'caseConsumption': component.find("inquiryConsumption").get("v.value"),
            'caseCaregiverName': component.find("inquiryCaregiverName").get("v.value"),
            'casePackageSize': component.find("inquiryPackageSize").get("v.value"),
            'caseReopenCount': component.find("inquiryReopenCount").get("v.value"),
            'caseResolved': inquiryResolved == null ? false : inquiryResolved,
            'caseReopenNotes': component.find("inquiryReopenNotes").get("v.value"),
            'caseLoyaltyCardNumber': component.find("inquiryLoyaltyCardNumber").get("v.value"),
            'caseFollowUpCall': inquiryFollowUpCall == null ? false : inquiryFollowUpCall,
            'casePreferredDateTime': component.find("inquiryPreferredDateTime").get("v.value"),
            'caseReasonForCallback': component.find("inquiryReasonForCallback").get("v.value"),
            'caseSourceCreatedDate': component.find("inquirySourceCreatedDate").get("v.value"),
            'caseWebEmail': component.find("inquiryWebEmail").get("v.value"),
            'caseCaseRegarding': component.find("inquiryCaseRegarding").get("v.value"),
            'caseReplyVia': component.find("inquiryReplyVia").get("v.value"),
            'caseEnquirerType': component.find("inquiryEnquirerType").get("v.value"),
            'caseComplexity': component.find("inquiryComplexity").get("v.value"),
            'caseReviewedBy': component.find("inquiryReviewedBy").get("v.value"),
            'caseReviewedDate': component.find("inquiryReviewedDate").get("v.value"),
            'caseNutritionHistory': component.find("inquiryNutritionHistory").get("v.value"),
            'caseReminderStatus': component.find("inquiryReminderStatus").get("v.value"),
        };
    }
})