({
	doInit : function(component, event, helper) {
        helper.executeRetrievalAgent(component);		
		helper.executeRetrievalRecord(component, false);
	},
    handleOptionSelected : function(component, event, helper) {
        helper.executeRetrievalRecord(component, false);
    },
	downloadExcelFile : function(component, event, helper) {
		var selectedRecordGetFromEvent = event.getParam("exportData");
		if (selectedRecordGetFromEvent) {
			helper.executeDownloadExcel(component);        
		}
		component.set('v.openModal', false);
		
    },
    confirmationExport : function(component, event, helper) {
    	if (component.get('v.noRecords') == false) {
			component.set('v.openModal', true);
		} else {
            component.find('notifLib').showToast({
                "title": "Export Call",
                "message": 'No records to export',
                "variant": "error"
            }); 			
		}
    },
    firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.renderTable(component);
    },
    prevPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
        helper.renderTable(component);
    },
    nextPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
        helper.renderTable(component);
    },
    lastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
        helper.renderTable(component);
    }
})