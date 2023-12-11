({
    createSkillRow: function(component, event, helper) {
        var rowItemList = component.get("v.skillList");
        rowItemList.push({
            'sobjectType': 'Skill',
            'srSkill': null,
            'srStartDate': null,
            'srEndDate': null,
        });
        
        component.set("v.skillList", rowItemList);
        var currentSkillList = component.get("v.skillList");
        var compEvent = component.getEvent("SkillListEvt");
        compEvent.setParams({"skillItems" : currentSkillList});  
        compEvent.fire();
    },
    
    executeSave : function(component, event, helper) {
        var action = component.get("c.saveServiceResourceSkills");
        var self = this;
        var skillList = self.convertSkillList(component, event, helper, component.get("v.skillList"));
        
        action.setParams({            
            skillList : skillList,
        });
        
        action.setCallback(this, function(action){
            var workspaceAPI = component.find("workspace");
            var state = action.getState();
            
            if(state == 'SUCCESS') {            
				component.find('notifLib').showToast({
                    "title": "Success!",
                    "message": "Skills has been added to Service Resource.",
                    "variant": "success"
                });     
                
                $A.get("e.force:closeQuickAction").fire()
            } else {
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": action.getError()[0].message,
                    "variant": "error"
                });  
			}
        }); 
        $A.enqueueAction(action);
	},
    
    convertSkillList : function(component, event, helper, skillList) {
        var result = [];
        
        if (skillList && skillList.length != 0) {            
            for(var i=0; i < skillList.length; i++) {
                var srSkill = {};
                var currentSkill = skillList[i];
                srSkill.ServiceResourceId = component.get("v.serviceResourceId");
                srSkill.SkillId = currentSkill.srSkill;
                srSkill.EffectiveStartDate = currentSkill.srStartDate;
                srSkill.EffectiveEndDate = currentSkill.srEndDate;

                result.push(srSkill);
            }
        }
        return result;
    },
})