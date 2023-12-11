({
    searchHelper : function(component,event,getInputkeyWord,objName) {
     	var action = component.get("c.lookupRecord");
      	
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'objName': objName
        });
      	
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              	// if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
        
        $A.enqueueAction(action);
	},
    
    setDefaultPricebook : function(component, event, helper, objectName, isSample, conId) {
    	var action = component.get("c.getDefaultPricebook");
        
        action.setParams({
            'objName': objectName,
            'isSample': isSample,
            'conId': conId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if (state === "SUCCESS") {
                component.set("v.selectedRecord", result);
                var recordDetails = component.get("v.selectedRecord");
                var value = recordDetails.Name;
                var reference = recordDetails.Id;
                var discount = recordDetails.DiscountPercentage__c;
                
                component.set("v.reference", recordDetails.Id);
      			component.set("v.resultName", recordDetails.Name);
                component.set("v.discount", recordDetails.DiscountPercentage__c);
                component.set("v.isGSTExclusive", recordDetails.ExclusiveOfGST__c);
                component.set("v.gstRate", recordDetails.GSTRate__c);

                var isGSTExclusive = component.get("v.isGSTExclusive");
                var gstRate = component.get("v.gstRate");
                if(isGSTExclusive) {
                    var compEvent = component.getEvent("GetPercentageGSTEvt");
                    compEvent.setParams({"pbeGST" : gstRate});
                    compEvent.fire();
                } else {
                    var compEvent = component.getEvent("GetPercentageGSTEvt");
                    compEvent.setParams({"pbeGST" : null});
                    compEvent.fire();
                }


                var compEvent = component.getEvent("defaultRecordEvent");
                compEvent.setParams({"dataByEvent" : recordDetails});  
                compEvent.fire();

                var compEvent2 = component.getEvent("GetPercentageDiscountEvt");
                compEvent2.setParams({"pbeDiscount" : result.DiscountPercentage__c});
                compEvent2.fire();
                
                if(reference != undefined) {
                    var forclose = component.find("lookup-pill");
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.removeClass(forclose, 'slds-hide');
                    
                    var forclose = component.find("searchRes");
                    $A.util.addClass(forclose, 'slds-is-close');
                    $A.util.removeClass(forclose, 'slds-is-open');
                    
                    var lookUpTarget = component.find("lookupField");
                    $A.util.addClass(lookUpTarget, 'slds-hide');
                    $A.util.removeClass(lookUpTarget, 'slds-show');  
                }
            }            
        });
        
        $A.enqueueAction(action);
	},
    
    //added
    createOrderLine: function(component, event, helper) {
        // get the Order details from component and add(push) New Object to List  
        var RowItemList = component.get("v.orderItemList");
        RowItemList.push({
            'sobjectType': 'OrderItem',
            'oProductId': null,
            'oProduct': null,
            'oPackageCode': null,
            'oProductRecType': null,
            'oQuantity': null,
            'oUnitPrice': null,
            'oPromotionItemId': null,
            'oPromotionType': null,
            'oOrderedFor': null,
            'oChannel': null,
            'oCategory': null,
            'oTotalPrice': null,
            'oDiscountAmount': null,
            'oDiscountValue': null,
            'oGSTAmount': null,
            'oGSTValue': null,
            'oFinalPrice': null,
            'oPackageItemList': null,
            'oFromSObject': 'Product2'
        });
        // set the updated list to attribute (orderItemList) again
        
        component.set("v.orderItemList", RowItemList);
        var currentOrderItemList = component.get("v.orderItemList");
        var compEvent = component.getEvent("OrderItemListEvt");
        compEvent.setParams({"orderItems" : currentOrderItemList});  
        compEvent.fire();
    },
})