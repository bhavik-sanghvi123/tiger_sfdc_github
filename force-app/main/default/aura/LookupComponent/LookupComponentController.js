({
	doInit : function (component, event, helper) {
        var objectName = component.get("v.objectName");
        var isSample = component.get("v.isSample");
        var conId = component.get("v.conId");
        helper.setDefaultPricebook(component, event, helper, objectName, isSample, conId);
    },
    
    onfocus : function(component,event,helper){
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        
        var getInputkeyWord = component.get("v.SearchKeyWord");
        var objectName = component.get("v.objectName");
        helper.searchHelper(component,event,getInputkeyWord,objectName);
    },
    
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    ordTypeChanged : function (component, event, helper) {
        var objectName = component.get("v.objectName");
        var isSample = component.get("v.isSample");
        var conId = component.get("v.conId");
        
        helper.setDefaultPricebook(component, event, helper, objectName, isSample, conId);
    },
    
    keyPressController : function(component, event, helper) {
      	// get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchKeyWord");
        var objectName = component.get("v.objectName");
      	
      	var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        helper.searchHelper(component,event,getInputkeyWord,objectName);
	},
  
  	// function for clear the Record Selection 
    clear :function(component,event,helper){
        if(confirm('Removing selected Pricebook will also remove all Product Line Items. Are you sure you want to proceed?')) {
            var pillTarget = component.find("lookup-pill");
            var lookUpTarget = component.find("lookupField"); 
            
            $A.util.addClass(pillTarget, 'slds-hide');
            $A.util.removeClass(pillTarget, 'slds-show');
            
            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');
            
            component.set("v.SearchKeyWord",null);
            component.set("v.listOfSearchRecords", null );
            component.set("v.reference", null);
            
            var finalGrandTotal = component.set("v.finalGrandTotal", "0.00");
            var finalDiscountAmount = component.set("v.finalDiscountAmount", "0.00");
            var finalGSTAmount = component.set("v.finalGSTAmount", "0.00")
            var items = component.get('v.orderItemList');
            // null check to avoid exception on length
            if($A.util.isEmpty(items)) { 
                items = [];
            }

            var compEvent = component.getEvent("GetPercentageGSTEvt");
            compEvent.setParams({"pbeGST" : null});
            compEvent.fire();
            
            // remove content based on length of list
            items.splice(0, items.length);
            component.set('v.orderItemList', items);
            helper.createOrderLine(component, event, helper); //added
        }
    },
    
  	// This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected record from the COMPONETN event 	 
       var selectedRecordGetFromEvent = event.getParam("dataByEvent");
	   
	   component.set("v.selectedRecord" , selectedRecordGetFromEvent); 
       
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
})