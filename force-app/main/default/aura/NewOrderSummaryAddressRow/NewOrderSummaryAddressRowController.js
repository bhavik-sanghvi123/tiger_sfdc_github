({
	handleSelected : function(component, event, helper) {		
		var compEvent = component.getEvent("selectedAddressEvent");
		compEvent.setParams({
			"saveAddress" : true,
			"addressObj" : component.get('v.summaryRecord')
		});  
        compEvent.fire();
	}
})