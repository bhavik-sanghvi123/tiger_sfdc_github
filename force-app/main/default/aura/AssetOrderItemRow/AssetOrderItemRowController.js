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
    
    
    getProductDetails : function(component, event, helper) { 
        var assetId = event.getParam("assetId");
        var productId = event.getParam("productId");
        var productName = event.getParam("productName");
        var productCode = event.getParam("productCode");
        var productRecordType = event.getParam("productRecordType");
        var discount = component.get("v.oDiscount");
        var gst = component.get("v.oGST");
        var oiObj = component.get("v.orderItemInstance.oFromSObject");
        component.set("v.oAssetId", assetId);
        component.set("v.oProductId", assetId); 
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
        component.set("v.oOrderedForId", orderedForId);  
        component.set("v.orderItemInstance.oOrderedForId" , orderedForId); 
    },
    
    getChannelDetails : function(component, event, helper) {
        var channelId = event.getParam("channelId");
        component.set("v.oChannelId", channelId);  
        component.set("v.orderItemInstance.oChannelId" , channelId);
        
    },
    
    getAssetDetails : function(component, event, helper) {
        var assetId = event.getParam("assetId");
        var assetProduct = event.getParam("assetProduct");
        var productName = event.getParam("productName");
        var assetQuantity = event.getParam("assetQuantity");
        var assetProduct = event.getParam("assetProduct");
        var assetSerial = event.getParam("assetSerial");
        var assetDesc = event.getParam("assetDesc");
        var assetPrice = event.getParam("assetPrice");
        var assetModel = event.getParam("assetModel");
        var assetName = event.getParam("assetName");
        component.set("v.oAssetId", assetId); 
        component.set("v.oAssetProduct", assetProduct);
        component.set("v.oQuantity", assetQuantity);
        component.set("v.oPrice", assetPrice);
        component.set("v.oSerial", assetSerial);
        component.set("v.oDescription", assetDesc);
        component.set("v.oModel", assetModel);
        component.set("v.orderItemInstance.oAssetId", assetId)
        component.set("v.orderItemInstance.oPackageCode" , assetProduct);
        component.set("v.orderItemInstance.oQuantity" , assetQuantity);
        component.set("v.orderItemInstance.oSerial" , assetSerial);
        component.set("v.orderItemInstance.oPrice" , assetPrice);
        component.set("v.orderItemInstance.oDescription" , assetDesc);
        component.set("v.orderItemInstance.oModel" , assetModel);
        component.set("v.orderItemInstance.oAssetName" , assetName);
        
        helper.fetchAssetProductDetails(component, event, helper, productName, assetId);
        helper.fetchPricebookDetails(component, event, helper, assetId);
       
    },
    
    checkOrderQuantity : function(component, event, helper) {
        var availableQuantity = component.get("v.orderItemInstance.oQuantity");
        var orderQuantity = component.get("v.orderItemInstance.oOrderQuantity");
        if(orderQuantity > availableQuantity){
            component.find('notifLib').showToast({
                "title": "Order Creation!",
                "message": "Order quantity must not be more than the available quantity.",
                "variant": "error"
            	});  
        }
        else{
        	helper.computePriceAndTotal(component, event, helper);
        }
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