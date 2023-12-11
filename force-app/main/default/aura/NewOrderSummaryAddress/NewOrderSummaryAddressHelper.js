({
	retrieveAddress : function(component) {
        var action = component.get("c.getHouseholdAddress");
        var self = this;
        
        action.setParams({            
            householdId : component.get('v.householdId')
        });

        action.setCallback(this, function(action){          
            var state = action.getState();
            if(state == 'SUCCESS') {            
                var result = action.getReturnValue();                  
                if (result && result.length != 0) {
                    component.set('v.addressList', result);
                }
            } else {
                alert(action.getError()[0].message);
            }
        }); 
        $A.enqueueAction(action);
    },
})