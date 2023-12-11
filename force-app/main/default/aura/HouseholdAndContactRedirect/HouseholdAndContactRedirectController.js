({
	navigateToMyComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        var primaryContact = component.get("v.primaryContact");
        var accountId = component.get("v.recordId");
        component.set("v.accountId", accountId);
        
        evt.setParams({
            componentDef : "c:HouseholdAndContactCreationPage",
            componentAttributes: {
                accountId : accountId,
                primaryContact : primaryContact
            }
        });
        
        evt.fire();
    }
})