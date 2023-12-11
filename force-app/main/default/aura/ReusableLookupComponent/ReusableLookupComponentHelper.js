({
	searchHelper : function(component, event, helper, userMarket, searchKey, contactLanguage) {
        var action = component.get("c.fetchLookupValues");
        var objName = component.get("v.objectAPIName");
        
        action.setParams({
            'objName' : objName,
            'userMarket' : userMarket,
            'searchKey' : searchKey,
            'contactLanguage' : contactLanguage
        });
          
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
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
	}
})