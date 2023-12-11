({
    doInit : function(component, event, helper) { 
        var contactObj = component.get("v.primaryContact");
        var accountObj = component.get("v.household");
        var accountId = component.get("v.accountId");
        var action = component.get("c.fetchUser");
        var getToken = component.get("c.getExperianToken");
        var message = "ASEAPAC user doesn’t has privilege to create contact details. Please contact System Administrator for any inquiry.";
        var isChildCreation = component.get('v.isChildCreation');
        var isFromContact = component.get('v.isFromContact');
        var sObjectName = component.get("v.sObjectName");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.user", result);
                component.set("v.userMarket", result.Market__c);
                component.set("v.userRoleName", result.UserRole.Name);
                
                if(result.UserRole.Name === "ANI - ASEAPAC") {
                    component.set("v.invalidUser", true);
                    helper.showToast(component, event, helper, message);
                }
                else if(result.UserRole.Name === "ANI - Vietnam"){
                    component.find("primaryTagging").set("v.value", true);
                }
                
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    component.set('v.currentTabId' ,  focusedTabId);
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: isChildCreation ? "Related Contact Creation" : "Main Contact Creation"
                    });
                })
            } 
        });
        
        $A.enqueueAction(action); 
        
        //identify Date today and format is to dd/mm/yyyy
        var dateToday = new Date();        
        var dateTodayDay = dateToday.getDate();
        var dateTodayMonth = dateToday.getMonth() + 1; //January is 0!
        var dateTodayYear = dateToday.getFullYear();

        if(dateTodayDay < 10){
            dateTodayDay = '0' + dateTodayDay;
        } 
           
        if(dateTodayMonth < 10){
            dateTodayMonth = '0' + dateTodayMonth;
        }

        var todayFormattedDate = dateTodayYear+'/'+dateTodayMonth+'/'+dateTodayDay;
        component.set("v.dateToday", todayFormattedDate);
        
        if(sObjectName === "Contact") {
            component.set("v.isFromContact", true);
        }
        
          //raustral - 2.21.2019, check if the page is for child creation
        if (isChildCreation) {
            var contactObj = component.get("v.primaryContact");

            component.set('v.adultRecordType' , true);
            component.set("v.childRecordType", false);
            component.set("v.noSecondaryContact", false);
            
            helper.getPicklistValues(component, contactObj, 'Gender__c', 'adultGender');
            helper.getPicklistValues(component, contactObj, 'Salutation', 'adultSalutation');
        } else {
            helper.getPicklistValues(component, contactObj, 'Gender__c', 'primaryGender');
            helper.getPicklistValues(component, contactObj, 'Salutation', 'primarySalutation');  
        }
        
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
            window.location.reload();
        }
    },
    
    handleRadioAddress : function(component, event, helper){
        var addressDecision = event.getParam("value");
        
        if(addressDecision === 'addAddress') {
            var userMarket = component.get("v.userMarket");
            component.set("v.createAddress", true);
            component.set("v.noAddress", false);
            
            if(userMarket == "SG") {
                helper.getSingaporeCity(component, event, helper);
            }
        }
        if(addressDecision === 'none') {
            component.set("v.noAddress", true);
            component.set("v.createAddress", false);
        }
	},
    
    handleRadioBrandRelationship : function(component, event, helper){
        var brandRelationshipDecision = event.getParam("value");
        
        if(brandRelationshipDecision === 'addBrandRelationship') {
            component.set("v.createBrandRelationship", true);
            component.set("v.noBrandRelationship", false);
        }
        if(brandRelationshipDecision === 'none') {
            component.set("v.noBrandRelationship", true);
            component.set("v.createBrandRelationship", false);
        }
	},
    
    handleRadioClick : function(component, event, helper){
        var selectedRecordType = event.getParam("value");
        var contactObj = component.get("v.primaryContact");
        
        if(selectedRecordType === 'adult') {
            component.set("v.adultRecordType", true);
            component.set("v.childRecordType", false);
            component.set("v.noSecondaryContact", false);
            
            helper.getPicklistValues(component, contactObj, 'Gender__c', 'adultGender');
            helper.getPicklistValues(component, contactObj, 'Salutation', 'adultSalutation');
        }
        else if(selectedRecordType === 'child') {
            component.set("v.childRecordType", true);
            component.set("v.adultRecordType", false);
            component.set("v.noSecondaryContact", false);
            
            helper.getPicklistValues(component, contactObj, 'Gender__c', 'childGender');
            helper.getPicklistValues(component, contactObj, 'Salutation', 'childSalutation');
            helper.getPicklistValues(component, contactObj, 'AgeRange__c', 'childAgeRange');
            helper.getPicklistValues(component, contactObj, 'CustomerRelationship__c', 'childCustomerRelationship');
        }
        else if(selectedRecordType === 'none') {
            component.set("v.noSecondaryContact", true);
            component.set("v.childRecordType", false);
            component.set("v.adultRecordType", false);
        }
    },
    
    handleCaseResponse : function(component,event,helper){
        var caseResponseDecision = event.getParam("value");
        if(caseResponseDecision == "Feedback"){
            component.set("v.feedBackRecordType", true);
            component.set("v.inquiryRecordType", false);
            component.set("v.noCaseRecord", false);
        }
        else if(caseResponseDecision == "Inquiry"){
            component.set("v.feedBackRecordType", false);
            component.set("v.inquiryRecordType", true);
            component.set("v.noCaseRecord", false);
        }
        else if(caseResponseDecision == "none"){
            component.set("v.feedBackRecordType", false);
            component.set("v.inquiryRecordType", false);
            component.set("v.noCaseRecord", true);
        }
    },
    
    handleRadioBR: function(component, event, helper){
        var brMapping = event.getParam("value");
        
        if(brMapping === 'primaryUser') {
            component.set("v.mapToPrimaryContact", true);
            component.set("v.mapToSecondaryContact", false);
        } 
        else if(brMapping === 'secondaryUser')  {
            component.set("v.mapToSecondaryContact", true);
            component.set("v.mapToPrimaryContact", false);
        }
	},

    handleRadioChannelResponse : function(component, event, helper){
        var channelResponseDecision = event.getParam("value");
        
        if(channelResponseDecision === 'addChannelResponse') {
            component.set("v.createChannelResponse", true);
            component.set("v.noChannelResponse", false);
        }
        if(channelResponseDecision === 'none') {
            component.set("v.noChannelResponse", true);
            component.set("v.createChannelResponse", false);
        }
    },
    
    createContactAndHouseholdRecord : function(component, event, helper){
        var isAdult = component.get("v.adultRecordType");
        var isChild = component.get("v.childRecordType");
        var accountId = component.get("v.accountId");
        var noSecondaryContact = component.get("v.noSecondaryContact");
        var isCreateAddress = component.get("v.createAddress");
        var mapToPrimaryContact = component.get("v.mapToPrimaryContact");
        var mapToSecondaryContact = component.get("v.mapToSecondaryContact");
        var isCreateBrandRelationship = component.get("v.createBrandRelationship");
        var isCreateChannelResponse = component.get("v.createChannelResponse");

        
        helper.savePrimaryContactAndHousehold(component, event, helper, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse);  
    },
    
    postalCodeKeyPressController : function(component, event, helper) {
        var searchKey = component.get("v.searchKeyWord");
        var unitNumber = component.get("v.unitNumber");
        var postalCodeFormat = new RegExp("\\d\\d\\d\\d\\d\\d");
        
        if(searchKey.length == 6 && searchKey.length > 0){
            if(!postalCodeFormat.test(searchKey)) {
                component.set("v.customErrorMessage", "Invalid Postal Code!");
                component.set("v.invalidPostalCode", true);
                var message = component.get("v.customErrorMessage");
                helper.showToast(component, event, helper, message);            
            } else {
                component.find("addressStreet1").set("v.value", null);
                component.find("addressBuilding").set("v.value", null);
                component.find("addressStateProvince").set("v.value", null);
                helper.experianCallout(component, event, helper, searchKey, unitNumber);
            }
        } 
        else if (searchKey.length > 0 && searchKey.length < 6){
            component.set("v.customErrorMessage", "Invalid Postal Code!");
            component.set("v.invalidPostalCode", true);
            var message = component.get("v.customErrorMessage");
            helper.showToast(component, event, helper, message); 
        }
        else if(searchKey.length == 0) {
            component.set("v.invalidPostalCode", false);     
		}
	},
    
    unitNoKeyPressController : function(component, event, helper) {
        var searchKey = component.get("v.searchKeyWord");
        var unitNumber = component.get("v.unitNumber");
        var unitNumber5CharFormat = new RegExp("\\d\\d[-]\\d\\d|\\d\\d[-]\\d[A-Z]");
        var unitNumber6CharFormat = new RegExp("\\d\\d[-]\\d\\d\\d|\\d\\d[-]\\d\\d[A-Z]");
        var unitNumber7CharFormat = new RegExp("\\d\\d[-]\\d\\d\\d\\d|\\d\\d[-]\\d\\d[A-Z][A-Z]|\\d\\d[-]\\d\\d\\d[A-Z]");
        
        //reset invalid flag
        component.set("v.invalidUnitNo", false); 

        if((unitNumber.length == 5 && !unitNumber5CharFormat.test(unitNumber)) || (unitNumber.length == 6 && !unitNumber6CharFormat.test(unitNumber)) 
           || (unitNumber.length == 7 && !unitNumber7CharFormat.test(unitNumber)) || unitNumber.length > 7 || (unitNumber.length != 0 && unitNumber.length < 5)){
            component.set("v.customErrorMessage", "Invalid Unit Number!");
            var message = component.get("v.customErrorMessage");
            component.set("v.invalidUnitNo", true);
            helper.showToast(component, event, helper, message);
        }
        else if((unitNumber.length == 5 || unitNumber.length == 6 || unitNumber.length == 7) && searchKey != null && searchKey != "") {
            helper.experianCallout(component, event, helper, searchKey, unitNumber);
        }
		else if (unitNumber.length == 0){
        	component.set("v.invalidUnitNo", false);        
		}
	},
    
    validateRecords: function(component, event, helper){
        var isChildCreation = component.get('v.isChildCreation');
    	var isAdult = component.get("v.adultRecordType");
        var isChild = component.get("v.childRecordType");
        var noSecondaryContact = component.get("v.noSecondaryContact");
        var isCreateAddress = component.get("v.createAddress");
        var mapToPrimaryContact = component.get("v.mapToPrimaryContact");
        var mapToSecondaryContact = component.get("v.mapToSecondaryContact");
        var isError = false;
        var accountId = component.get("v.accountId");
        var message;
        var isFromContact = component.get("v.isFromContact");
        var isCreateBrandRelationship = component.get("v.createBrandRelationship");
        var todayFormattedDate = component.get("v.dateToday");
        var isCreateChannelResponse = component.get('v.createChannelResponse');
        var userMarket = component.get("v.userMarket");
        var brPass = false;
        var primaryAge;
        var adultAge;
        var childAge;
        var isFeedback = component.get("v.feedBackRecordType");
        var isInquiry = component.get("v.inquiryRecordType");
        var ifNoCase = component.get("v.noCaseRecord");
        
        var today = new Date();
        var todayDD = today.getDate();
        var todayMM = today.getMonth() + 1;
        var todayYYYY = today.getFullYear();

        //Case
        if(!ifNoCase){

            var userRoleName = component.get("v.userRoleName");
            
            if(isFeedback == true && isInquiry == false){

                var caseOriginFb = component.find("fbOrigin").get("v.value");
                var caseStatusFb = component.find("fbStatus").get("v.value");
                var caseEsclatedToFb  = component.find("fbEscalatedTo").get("v.value");

                var caseproductReplacementRequiredFb = component.find("fbProductReplacement").get("v.value");
                var caseCustomerCertificationAttachedFb = component.find("fbCustomerCertification").get("v.value");
                var caseProductReplacementStatusFb = component.find("fbProductReplacementStatus").get("v.value");

                var caseSocialCaseFb = component.find("fbSocialCase").get("v.value");
                var caseAbbottAwarenessDate = component.find("fbAbbottAwarenessDate").get("v.value");

                var primaryEDDCase = new Date(component.find("fbAbbottAwarenessDate").get("v.value"));
                var primaryDueDateDDCase = primaryEDDCase.getDate();
                var primaryDueDateMMCase = primaryEDDCase.getMonth() + 1; //January is 0!
                var primaryDueDateYYYYCase = primaryEDDCase.getFullYear();

                var productCaseFb = component.find("fbProduct").get("v.value");
                var storeWherePurchasedFb = component.find("fbStoreWherePurchased").get("v.value");
                var stateFb = component.find("fbState").get("v.value");
        

                if(primaryDueDateDDCase < 10){
                    primaryDueDateDDCase = '0' + primaryDueDateDDCase;
                } 
                
                if(primaryDueDateMMCase < 10){
                    primaryDueDateMMCase = '0' + primaryDueDateMMCase;
                }
                
                var abbottAwarenessDateFormatted = primaryDueDateYYYYCase+'/'+primaryDueDateMMCase+'/'+primaryDueDateDDCase;

                if(caseOriginFb == ''){
                    component.set("v.customErrorMessage", "Case\'s  Origin is required");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }
                if(caseStatusFb == ''){
                    component.set("v.customErrorMessage", "Case\'s  Status is required");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }  
                if(caseStatusFb == 'Escalated' && (caseEsclatedToFb == '' || caseEsclatedToFb == null)){
                    component.set("v.customErrorMessage", "Case\'s Escalated To field must be populated when Status is set to Escalated.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }
                if(caseStatusFb != 'Escalated' && (caseEsclatedToFb != '' && caseEsclatedToFb != null) ){
                    component.set("v.customErrorMessage", "Case\'s Status should be set to Escalated when Escalated to is changed.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }

                if(
                    (caseStatusFb == 'Closed-Resolved' || caseStatusFb == 'Closed-Unresolved') && caseproductReplacementRequiredFb == true &&
                    (caseCustomerCertificationAttachedFb == false && (caseProductReplacementStatusFb == 'Completed' || caseProductReplacementStatusFb == '' || caseProductReplacementStatusFb == 'Pending' || caseProductReplacementStatusFb == 'In Progress')) ||
                    (caseCustomerCertificationAttachedFb == true && (caseProductReplacementStatusFb != 'Completed' || caseProductReplacementStatusFb != 'Cancelled'))
                )
                {
                    component.set("v.customErrorMessage", "Please ensure that Customer Certification is attached and Product Replacement Status is set to Completed");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }

                if(userRoleName == 'ANI - India' && caseSocialCaseFb == false && (caseAbbottAwarenessDate == '' || caseAbbottAwarenessDate == null || abbottAwarenessDateFormatted > todayFormattedDate)){
                    component.set("v.customErrorMessage", "Case\'s Abbott Awareness Date' field must be populated with past date");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }

                if(productCaseFb != null && productCaseFb != null && userRoleName == 'ANI - India'){
                    helper.getProductHierarchyLevel(component,event,helper,productCaseFb).then(
                        function(res) {
                            var isBrand = component.get("v.caseProductIsBrand")
                            if(!isBrand){
                                component.set("v.customErrorMessage", "Case\'s Product should have a heirarchy level of Brand");
                                isError = true;
                                message = component.get("v.customErrorMessage");
                                helper.showToast(component, event, helper, message);
                            }
                        }
                    )
                }

                if(userMarket == 'IN' && caseStatusFb == 'Escalated' && (caseEsclatedToFb == '' || caseEsclatedToFb == null) && (productCaseFb == '' || productCaseFb == null || storeWherePurchasedFb == '' || storeWherePurchasedFb == null || stateFb == '' || stateFb == null) ){
                    component.set("v.customErrorMessage", "Case\'s Product, Store Where Purchased and State fields are required if Status is Escalated");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }

            }
            else if(isInquiry == true && isFeedback == false){
                var caseOriginInquiry = component.find("inquiryOrigin").get("v.value");
                var caseStatusFbInquiry = component.find("inquiryStatus").get("v.value");
                var caseEscalatedToInquiry = component.find("inquiryEscalatedTo").get("v.value");

                if(caseOriginInquiry == ''){
                    component.set("v.customErrorMessage", "Case\'s  Origin is required");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }
                if(caseStatusFbInquiry == ''){
                    component.set("v.customErrorMessage", "Case\'s  Status is required");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }

                if(caseStatusFbInquiry == 'Escalated' && (caseEscalatedToInquiry == '' || caseEscalatedToInquiry == null)){
                    component.set("v.customErrorMessage", "Case\'s Escalated To field must be populated when Status is set to Escalated.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }

                if(caseStatusFbInquiry != 'Escalated' && (caseEscalatedToInquiry != '' && caseEscalatedToInquiry != null)){
                    component.set("v.customErrorMessage", "Case\'s Status should be set to Escalated when Escalated to is changed.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }

            }
        }
        
        //raustral - 2.21.2019, validate primary child if the page is not for child creation only
        if (isChildCreation == false) {
            //Primary Contact
            var primaryLastNameValue = component.find("primaryLastName").get("v.value");
            var primaryMobileValue = component.find("primaryMobilePhone").get("v.value");
            var primaryBirthdate = component.find("primaryBirthdate").get("v.value");
            var primaryEstimatedDueDate = userMarket != "ANZ" ? component.find("primaryEstimatedDueDate").get("v.value") : null;
            
            if(primaryLastNameValue == null || primaryLastNameValue == '') {
                component.set("v.customErrorMessage", "Main Contact\'s "  + $A.get("{!$Label.c.LastName}") +  " is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
                helper.showToast(component, event, helper, message);
            }

            if(primaryMobileValue == null || primaryMobileValue == '') {
                component.set("v.customErrorMessage", "Main Contact\'s Mobile Phone is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
                helper.showToast(component, event, helper, message);
            }

            if(primaryBirthdate != null && primaryBirthdate != '') {
                var primaryBirthdate = component.get("v.primaryBirthdate");
                var primaryDOB = new Date(component.find("primaryBirthdate").get("v.value"));
                var primaryDD = primaryDOB.getDate();
                var primaryMM = primaryDOB.getMonth() + 1; //January is 0!
                var primaryYYYY = primaryDOB.getFullYear();

                if(primaryDD < 10){
                    primaryDD = '0' + primaryDD;
                } 
                
                if(primaryMM < 10){
                    primaryMM = '0' + primaryMM;
                }
                
                var primaryDOBFormattedDate = primaryYYYY+'/'+primaryMM+'/'+primaryDD;
                
                if(primaryDOBFormattedDate > todayFormattedDate){
                    component.set("v.customErrorMessage", "Main Contact\'s Birthdate should be in the past.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                } else {
                    if(todayMM == primaryMM && todayDD >= primaryDD) {
                        primaryAge = todayYYYY - primaryYYYY;
                    } else {
                        primaryAge = todayYYYY - primaryYYYY - 1;
                    }
                    
                    if(primaryAge < 18) {
                        component.set("v.isPrimaryWarning", true);
                    } else {
                        component.set("v.isPrimaryWarning", false);
                    }
                }
            }

            if(primaryEstimatedDueDate != null && primaryEstimatedDueDate != '') {
                var primaryEstimatedDueDate = component.get("v.primaryEstimatedDueDate");
                var primaryEDD = new Date(component.find("primaryEstimatedDueDate").get("v.value"));
                var primaryDueDateDD = primaryEDD.getDate();
                var primaryDueDateMM = primaryEDD.getMonth() + 1; //January is 0!
                var primaryDueDateYYYY = primaryEDD.getFullYear();

                if(primaryDueDateDD < 10){
                    primaryDueDateDD = '0' + primaryDueDateDD;
                } 
                
                if(primaryDueDateMM < 10){
                    primaryDueDateMM = '0' + primaryDueDateMM;
                }
                
                var primaryEDDFormattedDate = primaryDueDateYYYY+'/'+primaryDueDateMM+'/'+primaryDueDateDD;
                
                if(primaryEDDFormattedDate < todayFormattedDate){
                    component.set("v.customErrorMessage", "Main Contact\'s Estimated Due Date cannot be in the past.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                } 
            }
        }
        
        //Brand Relationship
        if(isCreateBrandRelationship){
            var brTypeValue = component.find("brType").get("v.value");
            var brStatusValue = component.find("brStatus").get("v.value");
            var brBrandRelationsip = component.find("brBrandRelationship").get("v.value");
            var brCurrentPreviousBrand = component.find("brCurrentPreviousBrand").get("v.value");
        }

    	//Address
        if(isCreateAddress){
            var addressStreet1Value = component.find("addressStreet1").get("v.value");
            var addressCityValue = (userMarket != "ANZ" && userMarket != "ID") ? component.find("addressCity").get("v.value") : null;
            var addressCountryValue = component.find("addressCountry").get("v.value");
            var addressStateValue = userMarket == "ANZ" || userMarket == "IN" ? component.find("addressState").get("v.value") : null;
            var addressSuburbTownValue = userMarket == "ANZ" ? component.find("addressSuburbTown").get("v.value") : null;
            var addressCityValue2 = userMarket == "ID" ? component.find("addressCity2").get("v.value") : null;
            var addressRegionValue = component.find("addressRegion").get("v.value");
            var addressDistrictValue = (userMarket != "ANZ" && userMarket != "IN") ? component.find("addressDistrict").get("v.value") : null;
            var addressSubDistrictValue = (userMarket != "ANZ" && userMarket != "IN") ? component.find("addressSubDistrict").get("v.value") : null;
            var addressWardValue = (userMarket != "ANZ" && userMarket != "IN") ? component.find("addressWard").get("v.value") : null;
            var invalidPostalCode = component.get("v.invalidPostalCode");
            var invalidUnitNo = component.get("v.invalidUnitNo");
        }
        
		//Secondary Contact (Adult)
        if(isAdult){
			var adultLastNameValue = component.find("adultLastName").get("v.value");
            var adultBirthdate = component.find("adultBirthdate").get("v.value");
            var adultEstimatedDueDate = userMarket != "ANZ" ? component.find("adultEstimatedDueDate").get("v.value") : null;
            
            if(isChildCreation && !isFromContact){
                var adultMainContactValue = component.find("adultMainContact").get("v.value");
                component.set("v.mainContactId", adultMainContactValue);
            }
        }

    	//Secondary Contact (Child)
        if(isChild){
    		var childLastNameValue = component.find("childLastName").get("v.value");
            var childBirthdate = component.find("childBirthdate").get("v.value");
            
            if(isChildCreation && !isFromContact){
                var childMainContactValue = component.find("childMainContact").get("v.value");
                component.set("v.mainContactId", childMainContactValue);
            }
        }

        //Channel Response
        if(isCreateChannelResponse) {
            var crChannel = component.find("crChannel").get("v.value");
            var crRegDate = component.find("crRegistrationDate").get("v.value");
            if(crRegDate == null || crRegDate == '') {
                component.set("v.customErrorMessage", "Registration Date is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
        }

        //Address
        if(isCreateAddress) {
            if(addressStreet1Value == null || addressStreet1Value == '') {
                component.set("v.customErrorMessage", "Address " + $A.get("{!$Label.c.Street1}") +" is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
            if((userMarket != 'ANZ' && userMarket != 'ID' && (addressCityValue == null || addressCityValue == '')) ||
               (userMarket == 'ID' && (addressCityValue2 == null || addressCityValue2 == ''))){
                component.set("v.customErrorMessage", "Address " + $A.get("{!$Label.c.City}") + " is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
            if((userMarket == 'ANZ' || userMarket == 'IN') && (addressStateValue == null || addressStateValue == '')) {
				component.set("v.customErrorMessage", "Address State is required.");
        		isError = true;
                message = component.get("v.customErrorMessage");
                helper.showToast(component, event, helper, message);
            }
            if(userMarket == 'ANZ' && (addressSuburbTownValue == null || addressSuburbTownValue == '')) {
                component.set("v.customErrorMessage", "Address Suburb/Town is required");
                isError = true;
                message = component.get("v.customErrorMessage");
                helper.showToast(component, event, helper, message);
            }
            if(addressCountryValue == null || addressCountryValue == '') {
                component.set("v.customErrorMessage", "Address Country is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
            if(userMarket == 'ID') {
                if (addressRegionValue == null || addressRegionValue == '') {
                    component.set("v.customErrorMessage", "Address Region is required");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }
                
                if (addressDistrictValue == null || addressDistrictValue == ''){
                    component.set("v.customErrorMessage", "Address District is required");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }
                
                if (addressSubDistrictValue == null || addressSubDistrictValue == '') {
                    component.set("v.customErrorMessage", "Address Sub-District is required");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }
                
                if (addressWardValue == null || addressWardValue == '') {
                    component.set("v.customErrorMessage", "Address Postal Code is required");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                }
            }
            
            if(invalidPostalCode) {
            	component.set("v.customErrorMessage", "Invalid Postal Code!");
                isError = true;
                message = component.get("v.customErrorMessage");
                helper.showToast(component, event, helper, message);
        	}
            if(invalidUnitNo) {
            	component.set("v.customErrorMessage", "Invalid Unit Number!");
                isError = true;
                message = component.get("v.customErrorMessage");
                helper.showToast(component, event, helper, message);
        	}
        }

        var labelPrefix = isChildCreation ? "Contact\'s " : "Secondary Contact\'s ";
        if(isAdult) {
        	if(adultLastNameValue == null || adultLastNameValue == '') {
                component.set("v.customErrorMessage", labelPrefix + " " + $A.get("{!$Label.c.LastName}") +" is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
            
            if(adultBirthdate != null && adultBirthdate != '') {
                var adultBirthdate = component.get("v.adultBirthdate");
                var adultDOB = new Date(component.find("adultBirthdate").get("v.value"));
                var adultDD = adultDOB.getDate();
                var adultMM = adultDOB.getMonth() + 1; //January is 0!
                var adultYYYY = adultDOB.getFullYear();

                if(adultDD < 10){
                    adultDD = '0' + adultDD;
                } 
                
                if(adultMM < 10){
                    adultMM = '0' + adultMM;
                }
                
                var adultDOBFormattedDate = adultYYYY+'/'+adultMM+'/'+adultDD;
                
                if(adultDOBFormattedDate > todayFormattedDate){
                    component.set("v.customErrorMessage", labelPrefix + "Birthdate should be in the past.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                } else {
                    if(todayMM == adultMM && todayDD >= adultDD) {
                        adultAge = todayYYYY - adultYYYY;
                    } else {
                        adultAge = todayYYYY - adultYYYY - 1;
                    }
                    
                    if(adultAge < 18) {
                        component.set("v.isAdultWarning", true);
                    } else {
                        component.set("v.isAdultWarning", false);
                    }
                }
            }

            if(adultEstimatedDueDate != null && adultEstimatedDueDate != '') {
                var adultEstimatedDueDate = component.get("v.adultEstimatedDueDate");
                var adultEDD = new Date(component.find("adultEstimatedDueDate").get("v.value"));
                var adultDueDateDD = adultEDD.getDate();
                var adultDueDateMM = adultEDD.getMonth() + 1; //January is 0!
                var adultDueDateYYYY = adultEDD.getFullYear();

                if(adultDueDateDD < 10){
                    adultDueDateDD = '0' + adultDueDateDD;
                } 
                
                if(adultDueDateMM < 10){
                    adultDueDateMM = '0' + adultDueDateMM;
                }
                
                var adultEDDFormattedDate = adultDueDateYYYY+'/'+adultDueDateMM+'/'+adultDueDateDD;
                
                if(adultEDDFormattedDate < todayFormattedDate){
                    component.set("v.customErrorMessage", labelPrefix + "Estimated Due Date cannot be in the past.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                } 
            }
            
            if(isChildCreation && !isFromContact && (adultMainContactValue == null || adultMainContactValue == '')) {
                component.set("v.customErrorMessage", labelPrefix + "Main Contact is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
        }
        
        if(isChild) {
        	if(childLastNameValue == null || childLastNameValue == '') {
                component.set("v.customErrorMessage", labelPrefix + " " + $A.get("{!$Label.c.LastName}") + " is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }

            if(childBirthdate != null && childBirthdate != '') {
                var childBirthdate = component.get("v.childBirthdate");
                var childDOB = new Date(component.find("childBirthdate").get("v.value"));
                var childDD = childDOB.getDate();
                var childMM = childDOB.getMonth() + 1; //January is 0!
                var childYYYY = childDOB.getFullYear();

                if(childDD < 10){
                    childDD = '0' + childDD;
                } 
                
                if(childMM < 10){
                    childMM = '0' + childMM;
                }
                
                var childDOBFormattedDate = childYYYY+'/'+childMM+'/'+childDD;
                
                if(childDOBFormattedDate > todayFormattedDate){
                    component.set("v.customErrorMessage", labelPrefix + "Birthdate should be in the past.");
                    isError = true;
                    message = component.get("v.customErrorMessage");
                    helper.showToast(component, event, helper, message);
                } else {
                    if(todayMM == childMM && todayDD >= childDD) {
                        childAge = todayYYYY - childYYYY;
                    } else {
                        childAge = todayYYYY - childYYYY - 1;
                    }
                    
                    if(childAge > 18) {
                        component.set("v.isChildWarning", true);
                    } else {
                        component.set("v.isChildWarning", false);
                    }
                }
            }

            if(isChildCreation && !isFromContact && (childMainContactValue == null || childMainContactValue == '')) {
                component.set("v.customErrorMessage", labelPrefix + "Main Contact is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
        }
        
        if(isCreateBrandRelationship && ((noSecondaryContact || mapToPrimaryContact || mapToSecondaryContact) 
           || ((!noSecondaryContact && !mapToSecondaryContact) || mapToPrimaryContact))){
            if(brTypeValue == '') {
                component.set("v.customErrorMessage", "Brand Relationship Type is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
            
            if(brStatusValue == '') {
                component.set("v.customErrorMessage", "Brand Relationship Status is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
            
            if(brBrandRelationsip == '' || brBrandRelationsip == null) {
                component.set("v.customErrorMessage", "Brand Relationship is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
            	helper.showToast(component, event, helper, message);
            }
            
        }

        if(isCreateChannelResponse){
            if(crChannel == null || crChannel == '') {
                component.set("v.customErrorMessage", "Channel is required.");
                isError = true;
                message = component.get("v.customErrorMessage");
                helper.showToast(component, event, helper, message);
            }
        }
        
        if(!isError) {
            var message;
            var isParent;
            var isPrimaryWarning = component.get("v.isPrimaryWarning");
            var isAdultWarning = component.get("v.isAdultWarning");
            var isChildWarning = component.get("v.isChildWarning");
            
            if(isCreateBrandRelationship && brCurrentPreviousBrand != '' && brCurrentPreviousBrand != null && brTypeValue == "User" && (brStatusValue == "New" || brStatusValue == "Existing")) {
                var action = component.get("c.getProductDetails"); 
                
                action.setParams({
                    'productId': brCurrentPreviousBrand
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    var result = response.getReturnValue();
                    
                    if(state === "SUCCESS"){
                        if(result == "true") {
                            isError = true;
                            component.set("v.customErrorMessage", "Brand Relationship status must not be New or Existing if Current Brand is a competitor product.");
                            message = component.get("v.customErrorMessage");
                            helper.showToast(component, event, helper, message);
                        } else {
                            if (isChildCreation) {
                                component.set("v.invalidUser", true);
                                if(isAdultWarning) {
                                    message = 'Contact\'s age is lesser than 18 years old. Do you want to Proceed?';
                                    isParent = false;
                                    helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent, isFeedback, isInquiry, ifNoCase);
                                }
                                
                                if(isChildWarning) {
                                    message = 'Contact\'s age is greater than 18 years old. Do you want to Proceed?';
                                    isParent = false;
                                    helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent, isFeedback, isInquiry, ifNoCase);
                                }
                                
                                else if(!isAdultWarning && !isChildWarning) {
                                    helper.savechildContact(component, event, helper, isAdult, isChild, isCreateBrandRelationship, isCreateChannelResponse,isFeedback,isInquiry,ifNoCase);
                                }
                            } else {
                                component.set("v.invalidUser", true);
                                if(isPrimaryWarning) {
                                    message = 'Main Contact\'s age is lesser than 18 years old. Do you want to Proceed?';
                                    isParent = true;
                                    helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent, isFeedback, isInquiry, ifNoCase);
                                } 
                                
                                if(isAdultWarning) {
                                    message = 'Secondary Contact\'s age is lesser than 18 years old. Do you want to Proceed?';
                                    isParent = false;
                                    helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent, isFeedback, isInquiry, ifNoCase);
                                }
                                
                                if(isChildWarning) {
                                    message = 'Secondary Contact\'s age is greater than 18 years old. Do you want to Proceed?';
                                    isParent = false;
                                    helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent, isFeedback, isInquiry, ifNoCase);
                                } 
                                
                                else if(!isPrimaryWarning && !isAdultWarning && !isChildWarning) {
                                	helper.saveHouseholdAndPrimary(component, event, helper, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isFeedback, isInquiry, ifNoCase);  
                                }
                            }
                        }
                    }
                });
                $A.enqueueAction(action);
            } 
            else {                
                if (isChildCreation) {
                    component.set("v.invalidUser", true);
                    
                    if(isAdultWarning) {
                        message = 'Contact\'s age is lesser than 18 years old. Do you want to Proceed?';
                        isParent = false;
                        helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent,isFeedback, isInquiry, ifNoCase);
                    }
                    
                    if(isChildWarning) {
                        message = 'Contact\'s age is greater than 18 years old. Do you want to Proceed?';
                        isParent = false;
                        helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent,isFeedback, isInquiry, ifNoCase);
                    }
                    
                    else if(!isAdultWarning && !isChildWarning) {
                    	helper.savechildContact(component, event, helper, isAdult, isChild, isCreateBrandRelationship, isCreateChannelResponse);
                    }
                } else {
                    component.set("v.invalidUser", true);
                    
                    if(isPrimaryWarning) {
                        message = 'Main Contact\'s age is lesser than 18 years old. Do you want to Proceed?';
                        isParent = true;
                        helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent,isFeedback, isInquiry, ifNoCase);
                    } 
                    
                    if(isAdultWarning) {
                        message = 'Secondary Contact\'s age is lesser than 18 years old. Do you want to Proceed?';
                        isParent = false;
                        helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent,isFeedback, isInquiry, ifNoCase);
                    }
                    
                    if(isChildWarning) {
                        message = 'Secondary Contact\'s age is greater than 18 years old. Do you want to Proceed?';
                        isParent = false;
                        helper.promptDialogBox(component, event, helper, message, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse, isChildCreation, isParent,isFeedback, isInquiry, ifNoCase);
                    }
                    
                    else if(!isPrimaryWarning && !isAdultWarning && !isChildWarning) {
                        helper.saveHouseholdAndPrimary(component, event, helper, isAdult, isChild, noSecondaryContact, isCreateAddress, mapToPrimaryContact, mapToSecondaryContact, accountId, isCreateBrandRelationship, isCreateChannelResponse,isFeedback, isInquiry, ifNoCase);  
                    }
                }
            }
        }
    },
    
    stateChange  : function(component, event, helper) {
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
            if(userMarket == "ID") {
                component.set('v.disabledCity2', event.getSource().get("v.value") == "");
                component.find("addressCity2").clearValue();
            }
            component.set("v.regionValue", event.getSource().get("v.value")); 
            component.find("addressDistrict").clearValue();
        }

        // TKT-002676: auto update state/province for MM cities
        var cityId = component.find("addressCity").get("v.value");
       	if(userMarket == "PH") {
        	helper.getMetroManilaCity(component, event, helper,cityId);
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