({
	confirmExport : function(component, event, helper) {
		var compEvent = component.getEvent("selectedRecordEvent");
		compEvent.setParams({"exportData" : true });  
        compEvent.fire();
	},
	closeModal : function(component, event, helper) {
		var compEvent = component.getEvent("selectedRecordEvent");
		compEvent.setParams({"exportData" : false });  
        compEvent.fire();
	}
})