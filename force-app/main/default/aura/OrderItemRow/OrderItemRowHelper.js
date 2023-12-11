({
	fetchPackageItemDetails : function(component, event, helper, productId) {
		var action = component.get("c.getPackageItems");
        
        action.setParams({
            'productId': productId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS"){
                if(result.length > 0) {
                    component.set("v.packageItemList", result);
                    component.set("v.orderItemInstance.oPackageItemList", result); 
                    
                    /**
                    var compEvent = component.getEvent("UpdatePackageItemList");
                    compEvent.setParams({"productId" : productId,
                                         "packageItemList": result});
                    compEvent.fire();
                    **/
            	} else {
            		component.set("v.packageItemList", null);
            		component.set("v.orderItemInstance.oPackageItemList", null); 
            	}
            }
        });
        
        $A.enqueueAction(action);
	}
})