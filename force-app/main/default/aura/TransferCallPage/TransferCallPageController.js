({
    doInit: function(component, event, helper) {
        var caseId = component.get("v.recordId");
        component.set("v.openTransferCallForm", true);
		helper.getUserMarket(component, event, helper);
        helper.getRelatedContactDetails(component, event, helper, caseId);
    },
    
    getOwnerDetails : function(component, event, helper) {  
        var recordName = event.getParam("recordName");
        var recordId = event.getParam("recordId");
        component.set("v.ownerName", recordName); 
        component.set("v.ownerId", recordId); 
    },
    
    populateFilter : function(component, event, helper) {
        var affiliateId = component.find("caseContactLanguage").get("v.value");
        
        if(affiliateId != null && affiliateId != "") {
       		helper.getPrefferedLanguageDetails(component, event, helper, affiliateId);
            component.set("v.isLanguageDefined", true);
        } else {
            component.set("v.contactLanguage", "");
            component.find("caseContactLanguage").set("v.value", null);
            component.set("v.isLanguageDefined", false);
            //component.find("caseOwner").set("v.selectedRecord", null);
        }
    },
    
    onCancel : function(component, event, helper) {
    	component.set("v.openTransferCallForm", false); 
    },
    
    saveDetails : function(component, event, helper) {
        var caseId = component.get("v.recordId");
        var contactId = component.get("v.contactId");
        var ownerId = component.get("v.ownerId");
        var callBackReason = component.find("caseCallReasonTransfer").get("v.value");
        var contactLanguage = component.find("caseContactLanguage").get("v.value");
        
        if(ownerId != "" && callBackReason != null && contactLanguage != null && contactLanguage != "") {
            //component.set("v.isError", false);
            //component.set("v.errorMsg", "");
			helper.transferCalltoAgent(component, event, helper, caseId, ownerId, callBackReason, contactId, contactLanguage);
        } else {
            component.find('notifLib').showToast({
                "title": "Error!",
                "message": "Please populate all the required fields.",
                "variant": "error"
            });
            //component.set("v.isError", true);
            //component.set("v.errorMsg", "Please populate all the required fields."); 
        }
	}
})