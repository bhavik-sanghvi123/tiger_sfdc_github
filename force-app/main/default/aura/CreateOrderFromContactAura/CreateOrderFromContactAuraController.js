({
	doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank', tooltip: 'Click to visit website' }},
            {label: 'Age', fieldName: 'age', type: 'integer'},
            {label: 'Market', fieldName: 'market', type: 'text'},
            {label: 'Default Address', fieldName: 'defaultAddress', type: 'text'}, 
            {label: 'Campaigns', fieldName: 'campaignNames', type: 'text'}
        ]);
        
        component.set("v.tableMsg", "Please select filters for your Contact data.");
        //helper.getMarketVal(component, helper);
	},
    
    openFilterModal : function(component, event, helper) {
        $A.util.removeClass(component.find("filterModal"), "slds-hide");
	},
    
    closeFilterModal : function(component, event, helper) {
        $A.util.addClass(component.find("filterModal"), "slds-hide");
	},
    
    filterContacts : function(component, event, helper) {
        component.set("v.showSpinner", true);
		var campObj = JSON.parse(JSON.stringify(component.get("v.campaign")));
        var brName = false, mainAge = false, mainMarket = false, endAge = false, endMarket = false, camp = false, crName = false;
        
        
        if (component.get("v.brName") == null || component.get("v.brName") == '') {
            brName = true;
        }
        if (component.get("v.mainAge") == undefined || component.get("v.mainAge") == null || component.get("v.mainAge") == '') {
            mainAge = true;
        }
        /*if (component.find("mainMarket").get("v.value") == undefined || component.find("mainMarket").get("v.value") == null || component.find("mainMarket").get("v.value") == '') {
            mainMarket = true;
        }*/
        if (component.get("v.endAge") == undefined || component.get("v.endAge") == null || component.get("v.endAge") == '') {
            endAge = true;
        }
        /*if (component.find("endMarket").get("v.value") == undefined || component.find("endMarket").get("v.value") == null || component.find("endMarket").get("v.value") == '') {
            endMarket = true;
        }*/
		if (campObj.length == 0) {
			camp = true;
		}
        if (component.get("v.crName") == null || component.get("v.crName") == '') {
            crName = true;
        }

        
        if (brName && mainAge && endAge && camp && crName) {
            component.set("v.tableMsg", "Please select filters for your Contact data.");
            $A.util.removeClass(component.find("pageMsg"), "slds-hide");
            $A.util.addClass(component.find("contactTable"), "slds-hide");
            component.set("v.showSpinner", false);
        }
        else {
            helper.getFilteredContacts(component, helper);
        }
        
        $A.util.addClass(component.find("filterModal"), "slds-hide");
	},
    
    createOrderModal : function(component, event, helper) {
        var selectedRows = component.get("v.selectedRows");
        if (selectedRows.length == 0) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "No Selected Contacts",
                "message": "Please select data to create order/s for."
            });
            toastEvent.fire();
        }
        else {
            component.set('v.modalCol', [{label: 'Name', fieldName: 'name', type: 'text'}]);
            component.set("v.isModalOpen", true);
        }
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    updateSelectedText : function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRows", selectedRows);
        
        component.set("v.newOrder", true);
        component.set("v.newItem", true);
        component.set("v.orderHeader", 'ORDER CREATION');
        $A.util.removeClass(component.find("newTable"), "slds-hide");
        $A.util.addClass(component.find("editTable"), "slds-hide");
    },
    
    backPage : function(component, event, helper) {
        var baseUrl = component.get("v.baseUrl");
        window.open(baseUrl + '/lightning/o/Contact/home','_top');
    },
    
    submitOrder : function(component, event, helper) {
        component.set("v.showSpinner", true);
        event.preventDefault(); // stop form submission
        
        var response = event.getParam("fields");
        var orderFields = JSON.stringify(response);
        var contactList = component.get("v.selectedRows");
        helper.saveOrder(component, orderFields, contactList);
        
        component.set("v.showSpinner", false);
    },
    
    submitOrderItem : function(component, event, helper) {
        component.set("v.showSpinner", true);
        event.preventDefault(); // stop form submission
        
        var response = event.getParam("fields");
        var orderFields = JSON.stringify(response);
        var contactList = component.get("v.selectedRows");
        helper.saveItem(component, orderFields, contactList);
    },
    
    backOrder : function (component, event, helper) {
        component.set("v.newOrder", true);
        component.set("v.orderHeader", 'ORDER CREATION');
        $A.util.removeClass(component.find("editTable"), "slds-hide");
        $A.util.addClass(component.find("newTable"), "slds-hide");
        
        var recordId = component.get("v.selectedRows")[0].orderId;
        component.set("v.orderRec", recordId);
    },
    
    editedOrder : function (component, event, helper) {
        component.set("v.newOrder", false);
        component.set("v.orderHeader", 'ORDER PRODUCT CREATION');
        $A.util.removeClass(component.find("newTable"), "slds-hide");
        $A.util.addClass(component.find("editTable"), "slds-hide");
    }
})