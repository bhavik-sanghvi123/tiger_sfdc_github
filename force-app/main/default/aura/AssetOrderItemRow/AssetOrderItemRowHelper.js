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
                    
            	} else {
            		component.set("v.packageItemList", null);
            		component.set("v.orderItemInstance.oPackageItemList", null); 
            	}
            }
        });
        
        $A.enqueueAction(action);
	},
    
    fetchAssetProductDetails : function(component, event, helper, productId, assetId) {
        var action = component.get("c.getAssetProduct");
        
        action.setParams({
            'productId': productId,
            'assetId' : assetId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS"){
                    component.set("v.oProductId", result.Product2Id); 
                    component.set("v.oProduct", result.Product2.Name);         
                    component.set("v.orderItemInstance.oProductId", result.Product2Id); 
                    component.set("v.orderItemInstance.oProduct", result.Product2.Name); 
                	component.set("v.orderItemInstance.oCurrency", result.Product2.CurrencyIsoCode);

            }
        });
        
        $A.enqueueAction(action);
	},
    
    fetchPricebookDetails : function(component, event, helper, assetId) {
        var action = component.get("c.getPricebookId");
        
        action.setParams({
            'assetId': assetId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS"){
                    component.set("v.oPricebook", result); 
                    component.set("v.orderItemInstance.oPricebook", result); 
            }
        });
        
        $A.enqueueAction(action);
	},
    
     computePriceAndTotal : function(component, event, helper) {
        var currentLineItemPrice = component.get("v.lineItemPrice");
        var currentLineItemDiscount = component.get("v.lineItemDiscount");
        var currentLineItemGST = component.get("v.lineItemGST");
        component.set("v.lineItemPrice", 0.00);
        var computedTotal = component.get("v.computedGrandTotal");
    	var unitPrice = component.get("v.oPrice");
        var prodQuantity = component.get("v.orderItemInstance.oOrderQuantity");
        var gstAmount = component.get("v.orderItemInstance.oGSTAmount");
        var lineItemGST = gstAmount * prodQuantity;
        var lineItemPrice = (unitPrice * prodQuantity) + lineItemGST; 
        var discount = component.get("v.oDiscount");
        var oiObj = component.get("v.orderItemInstance.oFromSObject");
        var discountValue = component.get("v.orderItemInstance.oDiscountValue");
        var lineItemDiscount = discountValue * prodQuantity;
        
        component.set("v.lineItemPrice", lineItemPrice);
        component.set("v.lineItemDiscount", lineItemDiscount);
        component.set("v.lineItemGST", lineItemGST);
        component.set("v.orderItemInstance.oDiscountAmount", lineItemDiscount);
        component.set("v.orderItemInstance.oFinalPrice", lineItemPrice);
        component.set("v.orderItemInstance.oDiscountValue", discountValue);
        component.set("v.orderItemInstance.oGSTValue", lineItemGST);
       
        var compEvent = component.getEvent("UpdateGrandTotal");
        if(currentLineItemPrice < 0) {
        	compEvent.setParams({"grandTotal" : lineItemPrice});  
        } else {
            compEvent.setParams({"grandTotal" : lineItemPrice - currentLineItemPrice});  
        }        
        compEvent.fire();

        if(discount > 0 && oiObj == 'Product2') {
            var storeTotalDiscount = component.getEvent("UpdateTotalDiscountAmount");
            if(currentLineItemDiscount <= 0) {
                storeTotalDiscount.setParams({"totalDiscountAmount" : lineItemDiscount});
                
            } else {
                storeTotalDiscount.setParams({"totalDiscountAmount" : lineItemDiscount - currentLineItemDiscount});
            }
            storeTotalDiscount.fire();
        }

        if(lineItemGST > 0 && oiObj == 'Product2') {
            var storeTotalGST = component.getEvent("UpdateTotalGST");
            if(currentLineItemGST <= 0) {
                storeTotalGST.setParams({"totalGST" : lineItemGST});
                
            } else {
                storeTotalGST.setParams({"totalGST" : lineItemGST - currentLineItemGST});
            }
            storeTotalGST.fire();
        }
    },
    
})