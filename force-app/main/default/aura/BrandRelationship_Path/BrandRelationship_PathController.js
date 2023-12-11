({
	doInit : function(component, event, helper) {	
		helper.executeGetPath(component);
	},
	handleRecordUpdated : function(component, event, helper) {        
        var eventParams = event.getParams();        
        //check if certain field has been updated by the user
        //refresh the component if found
        if(eventParams.changeType === "CHANGED") {
            var changedFields = eventParams.changedFields;          
        	var changeFieldsList  = Object.keys(changedFields);
        	
        	if( changeFieldsList.includes("Status__c") ) {
                console.log("change");
        		helper.executeGetPath(component);
        	}        	
        } 
	}
})