({
    doInit : function(component, event, helper) {
        
        var totalCnt = component.get("c.getTotalCount");
        totalCnt.setParams({            
            "contactId": component.get("v.recordId")
        });
        totalCnt.setCallback(this, function(a) {
            component.set("v.totalNumberOfRows", a.getReturnValue());
        });
        $A.enqueueAction(totalCnt);
        
        var actions = [
            { label: 'Edit', name: 'edit' }
        ];
        
        component.set('v.columns', [
            {label: 'Case', fieldName: 'linkName', type: 'url',typeAttributes: { label: {fieldName: 'CaseNumber'}, target:'_self'}},
            {label: 'Status', fieldName: 'Status', type: 'text'}, 
            {label: 'Outcome', fieldName: 'CallOutcome__c', type: 'text'},
            {label: 'Brand', fieldName: 'CampaignBrand', type: 'text'},
            {label: 'Call Regarding', fieldName: 'CallRegardingName', type: 'text'},
            {label: 'Date/Time Opened', fieldName: 'CreatedDate', type: 'date',typeAttributes: {  
                                                                                                            day: 'numeric',  
                                                                                                            month: 'short',  
                                                                                                            year: 'numeric',  
                                                                                                            hour: '2-digit',  
                                                                                                            minute: '2-digit',  
                                                                                                            second: '2-digit',  
                                                                                                            hour12: true}},   
            {label: 'Campaign', fieldName: 'CampaignName', type: 'text'},            
            { type: 'action', typeAttributes: { rowActions: actions } } 
        ]);
        helper.getData(component);
        helper.getRecordType(component);
    },
    loadMoreData: function (component, event, helper) {      
        //Display a spinner to signal that data is being loaded
        event.getSource().set("v.isLoading", true);
        
        helper.fetchData(component, component.get('v.rowsToLoad')).then($A.getCallback(function (data) {
            if (component.get('v.data').length >= component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);               
            } else {
                var currentData = component.get('v.data');
                //Appends new data to the end of the table
                var newData = currentData.concat(data);
                component.set('v.data', newData);            
            }
            event.getSource().set("v.isLoading", false);
        }));
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": row.Id
                });
                editRecordEvent.fire();
                
                break;
            case 'delete':              
                break;
        }
    },
    createCall : function(cmp, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Case",
            'recordTypeId' : cmp.get('v.callRecordType'),
            "defaultFieldValues": {
                'ContactId' : cmp.get('v.recordId') ,
                'AccountId' : cmp.get('v.contactRecord.AccountId')
            }
        });
        createRecordEvent.fire();
    }
})