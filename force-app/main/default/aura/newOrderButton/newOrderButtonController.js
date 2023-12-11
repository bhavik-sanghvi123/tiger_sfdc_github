({
    // function call on component Load - dito nag loload yung mga textbox
    doInit: function(component, event, helper) {
        // create a Default RowItem [Contact Instance] on first time Component Load
        // by call this helper function  
        component.get("v.oQuantity");
        component.get("v.oProduct");
        component.get("v.oUnitPrice");
        component.get("v.oPromotionType");

        var isPageAccessible = component.get("v.isPageAccessible");
        var promoName = component.get("v.promoName");
        helper.getPromotionList(component, event, helper, promoName);
        helper.createOrderLine(component, event, helper);
        
        var action = component.get("c.getOrderRecord");
        var orderId = component.get("v.orderId");
        
        action.setParams({
            orderId : orderId
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") {
                component.set("v.primaryOrder", result);
                component.set("v.orderType", result.Type);
                component.set("v.whoOrdered", result.OrderedBy__c);
                component.set('v.paymentValue', "Cash on Delivery");
                component.set('v.orderTypeValue', component.get("v.orderType"));
                if (component.get("v.contactId") == undefined || component.get("v.contactId")  == null || component.get("v.contactId")) {
                    component.set("v.contactId", result.OrderedBy__c);
                }
            }
            
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;                    
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: 'New Order'
                });
                
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "standard:orders",
                    iconAlt: "Orders"
                });
            })
        });
        $A.enqueueAction(action);
    },
    
    saveDetails: function(component, event, helper) {
        
        var orderId = component.get("v.orderId");
        var typeValue = component.find("orderType").get("v.value");
        var paymentMethodValue = component.find("orderPaymentMethod").get("v.value");
        var orderNotesValue = component.find("orderNotes").get("v.value"); 
        var userMarket = component.get("v.userMarket");

        console.log("userMarket -> " + userMarket);
        
        var vatValue = component.get("v.vatValue");
        var taxIDValue = component.get("v.taxIDValue");
        var taxNameValue = component.get("v.taxNameValue");
        var abbottPartnerCodeValue = component.get("v.abbottPartnerCodeValue");
        var abbottSalesPersonValue = component.get("v.abbottSalesPersonValue");
        var twInvalid = false;
        
        //alert(component.get("v.oProductId"));

        console.log(vatValue);
        console.log(abbottPartnerCodeValue);
        console.log(abbottSalesPersonValue);
        
        var orderList = component.get("v.orderItemList");

        if(userMarket == "TW") {
            if(vatValue == undefined || vatValue == '') {
                component.find('notifLib').showToast({
                    "title": "Order Information!",
                    "message": "Please select a VAT type.",
                    "variant": "error"
                });

                twInvalid = true;
            }
            else if((vatValue == 'VAT III') && ((taxIDValue == undefined || taxIDValue == '') || (taxNameValue == undefined || taxNameValue == ''))) {
                component.find('notifLib').showToast({
                    "title": "Order Information!",
                    "message": "Please fill up Tax ID and Tax Name fields when VAT III is selected.",
                    "variant": "error"
                });

                twInvalid = true;
            }
            else if(abbottPartnerCodeValue == undefined || abbottPartnerCodeValue == '') {
                component.find('notifLib').showToast({
                    "title": "Order Information!",
                    "message": "Please select an Abbott Partner Code.",
                    "variant": "error"
                });

                twInvalid = true;
            }
            else if(abbottSalesPersonValue == undefined || abbottSalesPersonValue == '') {
                component.find('notifLib').showToast({
                    "title": "Order Information!",
                    "message": "Please select an Abbott Sales Person.",
                    "variant": "error"
                });

                twInvalid = true;
            }
            else {
                twInvalid = false;
            }
        }
        
        if (orderList.length == 0) {
            component.find('notifLib').showToast({
                "title": "Order Creation!",
                "message": "Please add atleast 1 product.",
                "variant": "error"
            });    
        }
        else if (helper.validateRequired(component, event, helper) && !twInvalid) {   
            helper.updateOrderRecord(component, event, helper, orderId, typeValue, paymentMethodValue, orderNotesValue);            
        }
        else if(!twInvalid) {
            component.find('notifLib').showToast({
                "title": "Order Creation!",
                "message": "Please complete your product line entry by specifying both Product and Quantity.",
                "variant": "error"
            });
        }
    },
    
    handleComponentEvent : function(component, event, helper) {
        var getUnitPrice = event.getParam("pbeUnitPrice");
        component.set("v.pbeUnitPrice", getUnitPrice); 
    },

    handleDiscountEvent : function(component, event, helper) {
        var getPercentageDiscount = event.getParam("pbeDiscount");
        if(getPercentageDiscount == null) {
            getPercentageDiscount = 0;
        }
        component.set("v.pbeDiscount", getPercentageDiscount / 100);
    },

    handleGSTEvent : function(component, event, helper) {
        var getPercentageGST = event.getParam("pbeGST");
        if(getPercentageGST == null) {
            getPercentageGST = 0;
        }
        component.set("v.pbeGST", getPercentageGST / 100);
    },
    
    getGrandTotal : function(component, event, helper) {
        var grandTotal = event.getParam("grandTotal");
        var currentTotal = component.get("v.finalGrandTotal");
        var computedValue = (grandTotal*1) + (currentTotal*1);
        component.set("v.finalGrandTotal", computedValue); 
    },

    getTotalDiscountAmount : function(component, event, helper) {
        var totalDiscountAmount = event.getParam("totalDiscountAmount");
        var currentTotal = component.get("v.finalDiscountAmount");
        var computedValue = (totalDiscountAmount*1) + (currentTotal*1);
        component.set("v.finalDiscountAmount", computedValue); 
    },

    getTotalGST : function(component, event, helper) {
        var totalGST = event.getParam("totalGST");
        var currentTotal = component.get("v.finalGSTAmount");
        var computedValue = (totalGST*1) + (currentTotal*1);
        component.set("v.finalGSTAmount", computedValue); 
    },
    
    // function for save the Records
    Save: function(component, event, helper) {
        // first call the helper function in if block which will return true or false.
        // this helper function check the "first Name" will not be blank on each row.
        if (helper.validateRequired(component, event)) {
            // call the apex class method for save the Contact List
            // with pass the contact List attribute to method param.  
            var action = component.get("c.saveOrderItem");
            action.setParams({
                "ListOrderItem": component.get("v.orderItemList")
            });
            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // if response if success then reset/blank the 'orderItemList' Attribute 
                    // and call the common helper method for create a default Object Data to Contact List 
                    component.set("v.orderItemList", []);
                    helper.createObjectData(component, event);
                    alert('record Save');
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
        }
    },
    
    // function for delete the row
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (orderItemList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.orderItemList");
        var sObjectSource = AllRowsList[index].oFromSObject;
        
        if(sObjectSource === "PromotionItem__c") {
            var promotionType = AllRowsList[index].oPromotionType;
            component.set("v.promoNameforDeletion", promotionType);
            component.set("v.removePromotion", true);
        } else {
            //start added
            var oQuantity = AllRowsList[index].oQuantity;
            var oUnitPrice = AllRowsList[index].oUnitPrice;
            var oDiscountValue = AllRowsList[index].oDiscountValue * oQuantity;
            var oGSTValue = AllRowsList[index].oGSTAmount * oQuantity;
            var newGrandTotal =  component.get("v.finalGrandTotal");
            var newTotalDiscountAmount =  component.get("v.finalDiscountAmount");
            var newGSTValue = component.get("v.finalGSTAmount");
            var newValue = (oQuantity * oUnitPrice);
            component.set("v.finalGrandTotal", newGrandTotal - newValue - oGSTValue);
            component.set("v.finalDiscountAmount", newTotalDiscountAmount - oDiscountValue);
            component.set("v.finalGSTAmount", newGSTValue - oGSTValue);
            //end added
            
            AllRowsList.splice(index, 1);
            // set the contactList after remove selected row element  
            component.set("v.orderItemList", AllRowsList);
        }
    },
    
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List
        component.set("v.isVisible", true);
        helper.createOrderLine(component, event, helper);
    },
    
    addToOrder : function(component, event, helper) {
        component.set("v.isVisible", true);
        var promoValue = component.get("v.promoValue");
        
        var action = component.get("c.getRelatedPromotionItems");
        action.setParams({
            promotionId : promoValue
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS") {
                component.set("v.promotionItemList", result);
                
                for(var i=0; i < result.length; i++) {
                    component.set("v.oProduct", result[i].Product__r.Name);
                    component.set("v.oProductId", result[i].Product__c);
                    component.set("v.oQuantity", result[i].DefaultOrderQuantity__c);
                    component.set("v.oUnitPrice", result[i].PromotionPrice__c);
                    component.set("v.oPromotionType", result[i].Promotion__r.Name);
                    component.set("v.oPromotionItemId", result[i].Id);
                    component.set("v.oPackageCode", result[i].Product__r.ProductCode);
                    
                    var productValue = component.get("v.oProduct");
                    var productIdValue = component.get("v.oProductId");
                    var quantityValue = component.get("v.oQuantity");
                    var unitPriceValue = component.get("v.oUnitPrice");
                    var promotionTypeValue = component.get("v.oPromotionType");
                    var promotionItemIdValue = component.get("v.oPromotionItemId");
                    var promotionProductCode = component.get("v.oPackageCode");
                    helper.createOrderLineFromPromotion(component, event, helper, productValue, quantityValue, unitPriceValue, promotionTypeValue, productIdValue, promotionItemIdValue, promotionProductCode);
                    
                    var newGrandTotal =  component.get("v.finalGrandTotal");
                    var newValue = quantityValue * unitPriceValue;
                    component.set("v.finalGrandTotal", newGrandTotal + newValue);
                }
                component.set("v.addPromotion", false);
                component.set("v.promoValue", "");
                var promoName = component.set("v.promoName","");
            }
        });
        $A.enqueueAction(action);
    },
    
    cancelOrBackFunction: function(component, event, helper){
        var eventParam = event.getParam("cancelOrder");
        if (eventParam) 
            component.set("v.showModalforCancelButton", true);       
        else {
            component.set("v.showSummaryPage", false);       
            window.scroll(0, 0);
        }            
    },
    showModalforCancelButton : function(component, event, helper) {
        component.set("v.showModalforCancelButton", true);   
    },
    //close pop-up modal and refresh page
    closeModalforCancelButton : function(component, event, helper) {
        component.set("v.showModalforCancelButton",false);
    },
    
    showPromotionModal: function(component, event, helper){
        component.set("v.addPromotion", true);
        var promoName = component.get("v.promoName");
        helper.getPromotionList(component, event, helper, promoName);
    },
    
    closePromotionModal: function(component, event, helper){
        component.set("v.addPromotion", false);      
        component.set("v.promoValue", "");
        var promoName = component.set("v.promoName","");
    },
    
    closeRemovePromotionModal: function(component, event, helper){
        component.set("v.removePromotion", false); 
    },
    
    // function for delete the rows under the Promo Name
    removeProductPromotions: function(component, event, helper) {
        var promoName = component.get("v.promoNameforDeletion");
        var AllRowsList = component.get("v.orderItemList");
        var rowListSize = AllRowsList.length - 1;
        var newValue;
        
        for(rowListSize; rowListSize >= 0; rowListSize--){
            if(AllRowsList[rowListSize].oPromotionType === promoName) {
                var newGrandTotal =  component.get("v.finalGrandTotal");
                newValue = AllRowsList[rowListSize].oQuantity * AllRowsList[rowListSize].oUnitPrice;
                component.set("v.finalGrandTotal", newGrandTotal - newValue);
                AllRowsList.splice(rowListSize, 1);
            }
        }
        
        component.set("v.orderItemList", AllRowsList);
        component.set("v.removePromotion", false);
    },
    
    sampleOrderRequest: function(component, event, helper){
        var orderType = event.getParam("value");
        var oldOrderType = event.getParam("oldValue");
        if(oldOrderType != "Sample Request" && orderType == "Sample Request") {
            component.set("v.orderItemList", []);
            component.set("v.isSample", true);
            component.set("v.finalGrandTotal", "");
            component.find("orderPaymentMethod").set("v.value", "");
            helper.createOrderLine(component, event, helper)
        } else if (oldOrderType == "Sample Request" && orderType != "Sample Request") {
            component.set("v.orderItemList", []);
            component.set("v.isSample", false);
            component.set("v.finalGrandTotal", "");
            component.find("orderPaymentMethod").set("v.value", "Cash on Delivery");
            helper.createOrderLine(component, event, helper)
        }
    },
    
    submit : function (component, event, helper) {
        var action = component.get("c.updateOrder");
        var orderID = component.get("v.orderId");
        var orderCancelReason = component.find("primaryOrderCancel").get("v.value");
        var message;
        
        var caseId = component.get("v.caseId");
        var contactId = component.get("v.contactId");
        var sObjectName = component.get("v.sObjectName");
        var displayId;
        
        
        if (orderCancelReason === null || orderCancelReason === '') {
            message = "Please select an Order Cancellation Reason."
            helper.showToast(component, event, helper, message);
        } else {
            if(sObjectName === 'Contact') {
                displayId = contactId;
            } else {
                displayId = caseId;
            }
            
            action.setParams({
                orderID : orderID,
                orderCancelReason : orderCancelReason
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                
                if(state === "SUCCESS") {
                    var evt = $A.get("e.force:navigateToSObject"); 
                    
                    evt.setParams({
                        "recordId" : displayId
                    });
                    evt.fire();
                }
            });        
            $A.enqueueAction(action);
            
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
                
            })
            
        } 
    },
    
    paymentChanges : function(component, event, helper)  {
         var changeValue = component.find("orderPaymentMethod").get("v.value");
         component.find("orderPaymentMethod").set("v.value",changeValue);
         component.set('v.paymentValue', changeValue);
    },
    
    orderTypeChanges : function(component, event, helper) {
        var changeValue = component.find("orderType").get("v.value");
        component.find("orderType").set("v.value",changeValue);
        component.set('v.orderTypeValue', changeValue);
        
        if(changeValue == "Sample Request") {
        	component.set('v.paymentValue', null);
            component.find("orderPaymentMethod").set("v.value", null);
        } else {
            component.set('v.paymentValue', "Cash on Delivery");
            component.find("orderPaymentMethod").set("v.value", "Cash on Delivery");
        }
    },

    vatChanges : function(component, event, helper)  {
        var changeValue = component.find("orderVAT").get("v.value");
        component.find("orderVAT").set("v.value",changeValue);
        component.set('v.vatValue', changeValue);
    },

    taxIDChanges : function(component, event, helper)  {
        var changeValue = component.find("orderTaxId").get("v.value");
        component.find("orderTaxId").set("v.value",changeValue);
        component.set('v.taxIDValue', changeValue);
    },
    
    taxNameChanges : function(component, event, helper)  {
        var changeValue = component.find("orderTaxName").get("v.value");
        component.find("orderTaxName").set("v.value",changeValue);
        component.set('v.taxNameValue', changeValue);
    },

    abbottPartnerCodeChanges : function(component, event, helper)  {
        var changeValue = component.find("orderAbbottPartnerCode").get("v.value");
        component.find("orderAbbottPartnerCode").set("v.value",changeValue);
        component.set('v.abbottPartnerCodeValue', changeValue);
    },

    abbottSalesPersonChanges : function(component, event, helper)  {
        var changeValue = component.find("orderAbbottSalesPerson").get("v.value");
        component.find("orderAbbottSalesPerson").set("v.value",changeValue);
        component.set('v.abbottSalesPersonValue', changeValue);
    },

    salesPersonCodeChanges : function(component, event, helper)  {
        var changeValue = component.find("orderSalesPersonCode").get("v.value");
        component.find("orderSalesPersonCode").set("v.value",changeValue);
        component.set('v.salesPersonCodeValue', changeValue);
    },

    salesPersonNameChanges : function(component, event, helper)  {
        var changeValue = component.find("orderSalesPersonName").get("v.value");
        component.find("orderSalesPersonName").set("v.value",changeValue);
        component.set('v.salesPersonNameValue', changeValue);
    },

    descriptionChanges : function(component, event, helper)  {
        var changeValue = component.find("orderDescription").get("v.value");
        component.find("orderDescription").set("v.value",changeValue);
        component.set('v.description', changeValue);
    },

    keyPressController : function(component, event, helper) {
        // get the search promo name keyword
        var promoName = component.get("v.promoName");
        console.log(promoName);
		helper.getPromotionList(component, event, helper, promoName);
    },
})