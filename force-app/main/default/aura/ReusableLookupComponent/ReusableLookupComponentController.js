({
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        
        var userMarket = component.get("v.userMarket");
        var searchKey = null;
        var contactLanguage = component.get("v.contactLanguage");
        var objName = component.get("v.objectAPIName");
        
        if(objName == "Case") {
            if(contactLanguage != null && contactLanguage != "") {
        		helper.searchHelper(component, event, helper, userMarket, searchKey, contactLanguage);
            } else {
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": "Please specify the Contact\'s Preferred Language first.",
                    "variant": "error"
                });
            }
        }
        
        else if(objName = "Skill") {
            helper.searchHelper(component, event, helper, null, searchKey, null);
        }
    },
    
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
		var userMarket = component.get("v.userMarket")
        var searchKey = component.get("v.SearchKeyWord");
        var contactLanguage = component.get("v.contactLanguage");
        var objName = component.get("v.objectAPIName");
        
        if(searchKey && searchKey.length > 3){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var contactId = component.get('v.contactId');
        
        	if(objName == "Case") {
                if(contactLanguage != null && contactLanguage != "") {
            		helper.searchHelper(component, event, helper, userMarket, searchKey, contactLanguage);
                } else {
                    component.find('notifLib').showToast({
                        "title": "Error!",
                        "message": "Please specify the Contact\'s Preferred Language first.",
                        "variant": "error"
                    });
            	}
            }
            else if(objName = "Skill") {
                helper.searchHelper(component, event, helper, null, searchKey, null);
            }
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
        var recordId;
        var recordName;
        var objName = component.get("v.objectAPIName");
        component.set("v.selectedRecord" , selectedRecordGetFromEvent); 
        
        if (objName == "Case") {
            recordId = selectedRecordGetFromEvent.Id;
            recordName = selectedRecordGetFromEvent.Name;
        }
        
        else if(objName == "Skill") {
            recordId = selectedRecordGetFromEvent.Id;
            recordName = selectedRecordGetFromEvent.MasterLabel;
        }
        
        var compEvent = component.getEvent("UpdateSelectedRecord");
        compEvent.setParams({"recordId" : recordId,
                             "recordName": recordName});  
        compEvent.fire();
        
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
})