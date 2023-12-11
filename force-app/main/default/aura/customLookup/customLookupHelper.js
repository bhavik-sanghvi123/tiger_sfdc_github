({
	searchHelper : function(component, event, pricebookId, householdId, contactId, productId, searchKey) {
        var action = component.get("c.fetchLookupValues");
       
        action.setParams({
            'pricebookId': pricebookId,
            'householdId': householdId,
            'contactId': contactId,
            'productId' : productId, 
            'objName' : component.get("v.objectAPIName"),
            'searchKey' : searchKey
        });
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }

                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });

        $A.enqueueAction(action);
	},
    
    getPricebookEntry : function(component, event, helper, productId, pricebookId) {
        var action = component.get("c.getPricebookEntryDetails");
        
        action.setParams({
            'pricebookId': pricebookId,
            'productId' : productId
        });
          
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.pbeUnitPrice", result.UnitPrice); 
                
                var compEvent = component.getEvent("GetUnitPriceEvt");
                compEvent.setParams({"pbeUnitPrice" : result.UnitPrice});  
                compEvent.fire();
            }
        });
        $A.enqueueAction(action);
	},
})