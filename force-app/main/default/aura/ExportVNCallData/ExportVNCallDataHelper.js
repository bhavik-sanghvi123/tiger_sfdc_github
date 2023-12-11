({
	executeRetrievalAgent : function(component) {
		var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var self = this;
		var action = component.get('c.queryAgentName');			

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == 'SUCCESS') {
				var records = [];
				records = response.getReturnValue();
			
				
				var result = action.getReturnValue();          
                var items = [];
                for (var i = 0; i < result.length; i++) {
                    var item = {
                        "label": result[i].Name,
                        "value": result[i].Id,
                    };
                    items.push(item);
                }

                items.push({
                        "label": 'tung tang',
                        "value": '0050o00000VZtbyAAD',
                });
				component.set('v.agentList', items);
				component.set('v.noRecords', true);	
			
				
				var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;                    
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: 'Call Report'
                    });

                    workspaceAPI.setTabIcon({
		                tabId: focusedTabId,
		                icon: "standard:report",
		                iconAlt: "Report"
		            });
                })
				
			}else {
				component.find('notifLib').showToast({
	                "title": "Export Call",
	                "message": "error here",
	                "variant": "error"
            	});
			}
			$A.util.addClass(spinner, "slds-hide");
		});

		$A.enqueueAction(action);
	},
	executeRetrievalRecord : function(component, exported) {
		var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var self = this;
		var action = component.get('c.queryRecordData');	
		action.setParams({                        
            agentId : component.get('v.agentValue')
        });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == 'SUCCESS') {
				var records = [];
				records = response.getReturnValue();
				if (records.length > 0) {
					var tempValue = response.getReturnValue();
					component.set('v.noRecords', false);
					component.set('v.callRecords', tempValue);
					component.set('v.currentPageNumber', 1);					
					component.set("v.maxPageNumber", Math.floor((tempValue.length+99)/100));
					self.renderTable(component);
				} else {					
					component.set('v.noRecords', true);	
				}
				component.set('v.isExported', exported);
				// var workspaceAPI = component.find("workspace");
    //             workspaceAPI.getFocusedTabInfo().then(function(response) {
    //                 var focusedTabId = response.tabId;                    
    //                 workspaceAPI.setTabLabel({
    //                     tabId: focusedTabId,
    //                     label: 'Call Report'
    //                 });

    //                 workspaceAPI.setTabIcon({
		  //               tabId: focusedTabId,
		  //               icon: "standard:report",
		  //               iconAlt: "Report"
		  //           });
    //             })
				
			}else {
				component.find('notifLib').showToast({
	                "title": "Export Call",
	                "message": "error here",
	                "variant": "error"
            	});
			}
			$A.util.addClass(spinner, "slds-hide");
		});

		$A.enqueueAction(action);
	},
	executeDownloadExcel : function(component) {
		var action = component.get("c.getExcelFileAsBase64String");
        var self = this;
        action.setParams({                        
            "agentUserId" : component.get('v.agentValue')
        });
        action.setCallback(this, function(action){
            console.log(action.getState());
            var state = action.getState();
            if(state == 'SUCCESS') {
            	var d = new Date();
                var nowString = d.toLocaleString();
				var datestring = d.getDate()  + "-" + (d.getMonth()+1) + "-" + d.getFullYear() + "-" + d.getTime();
				var result = action.getReturnValue();
                var strFile = "data:application/excel;base64,"+result.fileContent;
                download(strFile, "ExportCall_" + datestring + ".xls", "application/excel");
                //download(strFile, "ExportCall_" + nowString + ".csv", "text/csv");
                self.executeRetrievalRecord(component, true);
            } else {
            	component.find('notifLib').showToast({
	                "title": "Export Call",
	                "message": action.getError()[0].message,
	                "variant": "error"
            	}); 				
			}
        }); 
        $A.enqueueAction(action);
	},
	renderTable : function(component) {
		var records = component.get("v.callRecords"),
        pageNumber = component.get("v.currentPageNumber"),
        pageRecords = records.slice((pageNumber-1)*100, pageNumber*100);
        component.set("v.currentList", pageRecords);
	}
})