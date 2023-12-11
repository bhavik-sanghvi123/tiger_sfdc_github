({
	searchHelper : function(component) {

        var action = component.get("c.fetchLookupValues");
       
        action.setParams({
            'pricebookId': '',
            'householdId': '',
            'contactId': component.get('v.contactId'),
            'objName' : 'Address__c'
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