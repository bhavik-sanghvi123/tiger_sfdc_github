({
	doInit : function(component, event, helper) {
		var sObjectName = component.get("v.sObjectName");
        var srId = component.get("v.recordId");
        component.set("v.serviceResourceId", srId);
        var action = component.get("c.retrieveServiceResourceDetails");
        
        action.setParams({
            'srId': srId,
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state === "SUCCESS"){
                component.set("v.serviceResourceName", result.Name);
            } 
        });
        
        $A.enqueueAction(action);
        
        helper.createSkillRow(component, event, helper);
	},
    
	cancelCreation : function(component, event, helper) {
        if (confirm('Are you sure you want to Cancel?')) {
            $A.get("e.force:closeQuickAction").fire()
        }
	},
    
    addNewRow: function(component, event, helper) {
        helper.createSkillRow(component, event, helper);
    },
    
    processSavingSkills : function(component, event, helper) {
        helper.executeSave(component, event, helper);
	},
    
    removeDeletedRow: function(component, event, helper) {
        var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.skillList");
        var sObjectSource = AllRowsList[index].oFromSObject;
        
        var srSkill = AllRowsList[index].srSkill;
        var srStartDate = AllRowsList[index].srStartDate;
        var srEndDate = AllRowsList[index].srEndDate;
        
        AllRowsList.splice(index, 1);
        component.set("v.skillList", AllRowsList);
    },
})