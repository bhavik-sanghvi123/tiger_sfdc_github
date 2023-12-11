({
    doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var param1 = pageReference.state.c__param1;
        component.set("v.param1", param1);
    }
})

({
	goToPreviousPage : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:HouseholdAndContactCreationPage"
        });
        
        evt.fire();
    }
})