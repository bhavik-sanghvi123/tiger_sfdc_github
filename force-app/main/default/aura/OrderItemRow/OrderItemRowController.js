({
    doInit : function (component, event, helper) {
        component.set("v.orderItemInstance.Category__c", 'Conversion');
        var sourceObj = component.get("v.oFromSObject");

        if(sourceObj === 'PromotionItem__c') {
            component.set("v.lineItemPrice", 0.00);
            var promoQuantity = component.get("v.oQuantity");
            var unitPrice = component.get("v.oUnitPrice");
            var lineItemPrice = unitPrice * promoQuantity; 
            component.set("v.lineItemPrice", lineItemPrice);
        }
    },
    
    //Delete Order Line Item
    removeRow : function(component, event, helper){
        // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
    
    getUnitPriceValue : function(component, event, helper) {
        var getUnitPrice = event.getParam("pbeUnitPrice");
        var discount = component.get("v.oDiscount");
        component.set("v.pbeUnitPrice" , getUnitPrice);
        component.set("v.orderItemInstance.oUnitPrice" , getUnitPrice); //test
        var newUnitPrice = getUnitPrice;

        if(discount != null && discount != "") {
            var deducation = getUnitPrice * discount
            var discountedPrice = getUnitPrice - deducation;
            component.set("v.pbeUnitPrice" , discountedPrice);
            component.set("v.orderItemInstance.oDiscountValue", deducation);
            component.set("v.orderItemInstance.oUnitPrice" , discountedPrice);
            newUnitPrice = discountedPrice
        } 

        var gst = component.get("v.oGST");
        var gstAmount;
        if(gst != null && gst != "") {
            gstAmount = newUnitPrice * gst;
        } else {
            gstAmount = "0.00";
        }
        component.set("v.orderItemInstance.oGSTAmount", gstAmount);
    },
    
    addOrderLineEvent : function(component, event, helper) {
        var getUnitPrice = event.getParam("pbeUnitPrice");
        component.set("v.pbeUnitPrice" , getUnitPrice); 
        component.set("v.orderItemInstance.oUnitPrice" , getUnitPrice); 
    },
    
    computePriceAndTotal : function(component, event, helper) {
        var currentLineItemPrice = component.get("v.lineItemPrice");
        var currentLineItemDiscount = component.get("v.lineItemDiscount");
        var currentLineItemGST = component.get("v.lineItemGST");
        component.set("v.lineItemPrice", 0.00);
        var computedTotal = component.get("v.computedGrandTotal");
    	var unitPrice = component.get("v.pbeUnitPrice");
        var prodQuantity = component.get("v.orderItemInstance.oQuantity");
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
    
    getProductDetails : function(component, event, helper) { 
        var productId = event.getParam("productId");
        var productName = event.getParam("productName");
        var productCode = event.getParam("productCode");
        var productRecordType = event.getParam("productRecordType");
        var discount = component.get("v.oDiscount");
        var gst = component.get("v.oGST");
        var oiObj = component.get("v.orderItemInstance.oFromSObject");
        component.set("v.oProductId", productId); 
        component.set("v.oProduct", productName); 
        component.set("v.orderItemInstance.oProductId", productId); 
        component.set("v.orderItemInstance.oProduct", productName); 
        component.set("v.orderItemInstance.oPackageCode", productCode); 
        component.set("v.orderItemInstance.oProductRecType", productRecordType);
        
        //updates row details when a product is updated
        var currentTotalPrice = component.find("oTotalPrice").get("v.value");
        var compEvent = component.getEvent("UpdateGrandTotal");
        var currentValue = component.get("v.finalGrandTotal");
        component.set("v.orderItemInstance.oQuantity", null); 
        component.set("v.orderItemInstance.oPackageItemList", null); 
        component.set("v.pbeUnitPrice", null);
        component.set("v.lineItemPrice", null);
        compEvent.setParams({"grandTotal" : currentValue - currentTotalPrice});
        compEvent.fire();

        var prodQuantity = component.get("v.orderItemInstance.oQuantity");
        var discountValue = component.get("v.orderItemInstance.oDiscountValue");
        var lineItemDiscount = discountValue * prodQuantity; 
        if(discount > 0 && oiObj == "Product2") {
            var compEvent2 = component.getEvent("UpdateTotalDiscountAmount");
            var currentDiscountAmount = component.get("v.finalDiscountAmount");
            compEvent2.setParams({"totalDiscountAmount" : currentDiscountAmount - lineItemDiscount});
            compEvent2.fire();
        }

        var gstValue = component.get("v.orderItemInstance.oGSTAmount");
        var lineItemGST = gstValue * prodQuantity
        if(gst > 0 && oiObj == "Product2") {
            var compEvent3 = component.getEvent("UpdateTotalGST");
            var currentGSTAmount = component.get("v.finalGSTAmount");
            compEvent3.setParams({"totalGST" : currentGSTAmount - lineItemGST});
            compEvent3.fire();
        }

        if(productRecordType == "Package") {
            helper.fetchPackageItemDetails(component, event, helper, productId);
        }
    },
    
    getGrandTotal : function(component, event, helper) {
        component.set("v.finalGrandTotal", computedValue); 
    },
    
    getContactDetails : function(component, event, helper) {
        var orderedForId = event.getParam("orderedForId");
        var orderedForName = event.getParam("orderedForName"); // Sean Cordova

        component.set("v.oOrderedForId", orderedForId);  
        component.set("v.orderItemInstance.oOrderedForId" , orderedForId); 

        // Sean Cordova
        component.set("v.oOrderedFor", orderedForId);  
        component.set("v.orderItemInstance.oOrderedFor" , orderedForName); 
    },
    
    getChannelDetails : function(component, event, helper) {
        var channelId = event.getParam("channelId");
        component.set("v.oChannelId", channelId);  
        component.set("v.orderItemInstance.oChannelId" , channelId); 
    },

    fetchPackageItemList : function(component, event, helper) {        
        var packageItemList = event.getParam("packageItemList");
        if(packageItemList.length > 0) {
            component.set("v.orderItemInstance.oPackageItemList", packageItemList);
        } else {
            component.set("v.orderItemInstance.oPackageItemList", null);
        }
    }
})