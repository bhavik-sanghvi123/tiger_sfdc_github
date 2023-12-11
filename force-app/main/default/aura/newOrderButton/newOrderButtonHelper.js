({
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
    
    createOrderLineFromPromotion: function(component, event, helper, productValue, quantityValue, unitPriceValue, promotionTypeValue, productIdValue, promotionItemIdValue, promotionProductCode) {
        // get the Order details from component and add(push) New Object to List  
        var RowItemList = component.get("v.orderItemList");
        RowItemList.push({
            'sobjectType': 'OrderItem',
            'oProductId': productIdValue,
            'oProduct': productValue,
            'oPackageCode': promotionProductCode,
            'oProductRecType': null,
            'oQuantity': quantityValue,
            'oUnitPrice': unitPriceValue,
            'oPromotionItemId': promotionItemIdValue,
            'oPromotionType': promotionTypeValue,
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
            'oFromSObject': 'PromotionItem__c'
        });
        // set the updated list to attribute (orderItemList) again    
        component.set("v.orderItemList", RowItemList);
    },
    
    showToast : function(component, event, helper, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error Message",
            "message": message,
        });
        toastEvent.fire();
	},
    
    getPromotionList : function(component, event, helper, promoName) {
        var action = component.get("c.getRelatedPromotion");

        action.setParams({
            'promoName' : promoName,
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var finalList = [];
                for(var i=0; i<result.length; i++)
                {
                    var promo = result[i];
                    promo.label = result[i].Name;
                    promo.value = result[i].Id; 
                    finalList.push(result[i]);       
                }
                
                component.set("v.promotionList", finalList);
                var promotionList = component.get("v.promotionList");
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},
    
    updateOrderRecord : function(component, event, helper, orderId, typeValue, paymentMethodValue, orderNotesValue) {
        var action = component.get("c.saveUpdatedOrderDetails"); 
        
        action.setParams({
            'orderId': orderId,
        	'typeValue': typeValue,
            'paymentMethodValue': paymentMethodValue,
        	'orderNotesValue': orderNotesValue
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set('v.orderNotesValue', orderNotesValue);
                component.set('v.showSummaryPage', true);
                window.scroll(0, 0);
                   
                
                //alert("Successfully updated Order");
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allOrderItems = component.get("v.orderItemList");
        for (var indexVar = 0; indexVar < allOrderItems.length; indexVar++) {
            //alert(allOrderItems[indexVar].oProductId);
            if (allOrderItems[indexVar].oProductId == null || allOrderItems[indexVar].oQuantity == null) {
                isValid = false;
                //alert('test ' + (indexVar + 1));
            }
        }
        return isValid;
    },

    // Sean Cordova
    getPromoterDetails : function(component) {
        var abbottPartnerCodeValue = component.get("v.abbottPartnerCodeValue");
        var action = component.get("c.getAbbottPartnerPartnerCode");
        // var action2 = component.get("c.getAbbottPartnerPartnerName");
            
        // action.setParams({
        //     abbottPartnerId : abbottPartnerCodeValue
        // });

        // action.setCallback(this, function(response) {
        //     var state = response.getState();
        //     var result = response.getReturnValue();
            
        //     if(state === "SUCCESS"){
        //         if(result != null && result != '') {
        //             component.set('v.promoterCodeValue', result);
        //         }
        //     } 
        // });
        
        // $A.enqueueAction(action);

        // action2.setParams({
        //     abbottPartnerId : abbottPartnerCodeValue
        // });

        // action2.setCallback(this, function(response) {
        //     var state = response.getState();
        //     var result = response.getReturnValue();
            
        //     if(state === "SUCCESS"){
        //         if(result != null && result != '') {
        //             component.set('v.promoterNameValue', result);
        //         }
        //     } 
        // });
        
        // $A.enqueueAction(action2);
    }
})