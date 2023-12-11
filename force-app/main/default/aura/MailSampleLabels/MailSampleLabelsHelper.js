({
	executeRetrievalRecord : function(component, exported) {
		var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var self = this;
		var action = component.get('c.querySampleItemReport');	
		action.setParams({            
            startDate : component.get('v.startDate'),
            endDate : component.get('v.endDate')
        });

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == 'SUCCESS') {
				var records = [];
				records = response.getReturnValue();
				if (records.length > 0) {
					var tempValue = response.getReturnValue();
					component.set('v.noRecords', false);
					component.set('v.orderRecords', tempValue);
					component.set('v.currentPageNumber', 1);					
					component.set("v.maxPageNumber", Math.floor((tempValue.length+99)/100));
					self.renderTable(component);
				} else {					
					component.set('v.noRecords', true);	
				}
				component.set('v.isExported', exported);
				var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;                    
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: 'Mail Sample Label Report'
                    });

                    workspaceAPI.setTabIcon({
		                tabId: focusedTabId,
		                icon: "standard:report",
		                iconAlt: "Report"
		            });
                })
				
			}else {
				component.find('notifLib').showToast({
	                "title": "Export Report",
	                "message": action.getError()[0].message,
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
            startDate : component.get('v.startDate'),
            endDate : component.get('v.endDate')
        });
        action.setCallback(this, function(action){
            console.log(action.getState());
            var state = action.getState();
            if(state == 'SUCCESS') {
            	var d = new Date();
				var datestring = d.getDate()  + "-" + (d.getMonth()+1) + "-" + d.getFullYear()
				var result = action.getReturnValue();
                var strFile = "data:application/excel;base64,"+result.fileContent;
                download(strFile, "ExportMailSample_" + result.userMarket + "_" + datestring + ".xls", "application/excel");
                self.executeRetrievalRecord(component, true);
            } else {
            	component.find('notifLib').showToast({
	                "title": "Export Report",
	                "message": action.getError()[0].message,
	                "variant": "error"
            	}); 				
			}
        }); 
        $A.enqueueAction(action);
	},
	renderTable : function(component) {
		var records = component.get("v.orderRecords"),
        pageNumber = component.get("v.currentPageNumber"),
        pageRecords = records.slice((pageNumber-1)*100, pageNumber*100);
        component.set("v.currentList", pageRecords);
	}
})