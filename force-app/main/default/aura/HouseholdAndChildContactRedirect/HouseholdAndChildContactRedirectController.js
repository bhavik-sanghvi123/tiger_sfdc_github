({
	navigateToMyComponent : function(component, event, helper) {
		var evt = $A.get("e.force:navigateToComponent");	    
        var sObjectName = component.get("v.sObjectName");
        
	    evt.setParams({
	        componentDef : "c:HouseholdAndContactCreationPage",
            isredirect: true,
	        componentAttributes: {
	            primaryContactId : component.get('v.recordId'),
	            isChildCreation : true,
                sObjectName: sObjectName
	        }
	    });		        
	    evt.fire();		   
																						
    }
})