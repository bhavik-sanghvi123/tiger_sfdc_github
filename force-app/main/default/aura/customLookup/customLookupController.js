({
    onfocus : function(component,event,helper){
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        
        var pricebookId = component.get("v.pricebookId");
        var householdId = component.get("v.householdId");
        var contactId = component.get('v.contactId');
        var productId = component.get('v.productId');
        var searchKey = null;
        helper.searchHelper(component, event, pricebookId, householdId, contactId, productId, searchKey);
    },
    
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var pricebookId = component.get("v.pricebookId");
        var householdId = component.get("v.householdId");
        var searchKey = component.get('v.SearchKeyWord');
        
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if(searchKey && searchKey.length > 2){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var contactId = component.get('v.contactId');
            var productId = component.get('v.productId');
            helper.searchHelper(component, event, pricebookId, householdId, contactId, productId, searchKey);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    
  	//This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        //get the selected record from the COMPONENT event 	 
        var selectedRecordGetFromEvent = event.getParam("recordByEvent");
        var productId = selectedRecordGetFromEvent.Id;
        var productName = selectedRecordGetFromEvent.Name;
        var productCode = selectedRecordGetFromEvent.ProductCode;
        var productRecordType;
        component.set("v.selectedRecord", selectedRecordGetFromEvent); 
        
        if(selectedRecordGetFromEvent.Id != null && component.get('v.objectAPIName') != 'Asset') {
            var pricebookId = component.get("v.pricebookId");
            helper.getPricebookEntry(component, event, helper, productId, pricebookId);
        }
        
        if (component.get('v.objectAPIName') == 'Product2') {
            productRecordType = selectedRecordGetFromEvent.RecordType.Name;
            var compEvent = component.getEvent("UpdateSelectedProduct");
            compEvent.setParams({"productId" : productId,
                                 "productName": productName,
                                 "productCode": productCode,
                                 "productRecordType": productRecordType});  
            compEvent.fire();
        } 
        else if(component.get('v.objectAPIName') == 'Contact') {
            var compEvent = component.getEvent("UpdateSelectedContact");
            compEvent.setParams({"orderedForId" : productId});  
            compEvent.fire();
        } 
        else if(component.get('v.objectAPIName') == 'Channel__c') {
            var compEvent = component.getEvent("UpdateSelectedChannel");
            compEvent.setParams({"channelId" : productId});  
            compEvent.fire();
        }
        else if(component.get('v.objectAPIName') == 'Asset') {   
        	var assetProd = selectedRecordGetFromEvent.Product2Id;
        	var assetQuantity = selectedRecordGetFromEvent.Quantity;
        	var assetSerial = selectedRecordGetFromEvent.SerialNumber;
        	var assetDesc = selectedRecordGetFromEvent.Description;
        	var assetPrice = selectedRecordGetFromEvent.Price;
            var assetModel = selectedRecordGetFromEvent.ModelNo__c;
            var assetName = selectedRecordGetFromEvent.Name;
            var compEvent = component.getEvent("UpdateSelectedAsset");
            compEvent.setParams({"assetId" : productId,
                                 "productName": assetProd,
                                 "assetProduct" : productCode,
                                 "assetQuantity" : assetQuantity,
                                 "assetSerial" : assetSerial,
                                 "assetDesc" : assetDesc,
                                 "assetPrice" : assetPrice,
                                 "assetModel" : assetModel,
                                 "assetName" : assetName});
            compEvent.fire();
            
            var pricebookId = component.get("v.pricebookId");
            helper.getPricebookEntry(component, event, helper, assetProd, pricebookId);
        }
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	},
    handlePredefinedValue : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            component.set("v.selectedRecord" , params.defaultValue); 

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
})