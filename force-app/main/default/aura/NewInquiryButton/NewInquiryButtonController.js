({
    doInit: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");
        
        helper.getDetails(component, event, helper, recordId, sObjectName);
        helper.getRecordTypeId(component, event, helper);
    },
    
    onSave : function(component, event, helper) {
        component.set("v.disabled", true);
        helper.saveRecord(component, event, helper);
    },
    
    onCancel : function(component, event, helper) {
    	component.set("v.openInquiryForm", false); 
    }
})