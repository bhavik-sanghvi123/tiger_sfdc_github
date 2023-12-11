({
	doInit : function(component, event, helper) {
		helper.retrieveAddress(component);
	},
	closeModal : function(component, event, helper) {
		var compEvent = component.getEvent("selectedAddressEvent");
		compEvent.setParams({"saveAddress" : false });  
        compEvent.fire();
	}
})