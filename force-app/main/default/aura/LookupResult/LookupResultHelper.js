({
    getPricebookGSTRate : function(component, event, helper) {
        var action = component.get("c.getGstRate");
        var gstMarket = component.get("v.pricebookMarket");
		
        action.setParams({
          'gstMarket': gstMarket
        });
		
        action.setCallback(this,function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS")
            {
                var compEvent4 = component.getEvent("GetPercentageGSTEvt");
                compEvent4.setParams({"pbeGST" : result});
                compEvent4.fire();
            }
        });
        $A.enqueueAction(action);
    }
})