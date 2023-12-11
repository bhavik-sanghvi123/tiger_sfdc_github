({
    doInit : function (component) {
        var workspaceAPI = component.find("workspace");
        var caseId = component.get("v.caseId");
        var userMarket = component.get("v.userMarket");
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name : "caseId",
                type : "String",
                value : caseId
            }
        ];
		
        if(userMarket == "IN") {
            flow.startFlow("IN_Call_Script_Flow", inputVariables);
        } 
        else if(userMarket == "MY") {
            flow.startFlow("MY_Call_Script_Flow", inputVariables);
        }
        else if(userMarket == "ID") {
            flow.startFlow("ID_Call_Script_Flow", inputVariables);
        }
        else if(userMarket == "VN") {
            flow.startFlow("VN_Call_Script_Flow", inputVariables);
        }
        else if(userMarket == "TH") {
            flow.startFlow("TH_Call_Script_Flow", inputVariables);
        }
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Call Script"
            });
        })
    },
})