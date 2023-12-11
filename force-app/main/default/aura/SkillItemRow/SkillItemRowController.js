({
    removeRow : function(component, event, helper){
        // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
    
    getSkillDetails : function(component, event, helper) {  
        var recordName = event.getParam("recordName");
        var recordId = event.getParam("recordId");
        
        component.set("v.skillName", recordName); 
        component.set("v.skillId", recordId);
        component.set("v.srSkill", recordId); 
    },
})