({
    getData : function(component) {
        
        var action = component.get("c.getCall");
        action.setParams({
            "limits": component.get("v.initialRows"),
            "offsets": component.get("v.rowNumberOffset"),
            "contactId": component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var records =a.getReturnValue();
            records.forEach(function(record){
                record.linkName = '/lightning/r/case/'+record.Id+'/view';
                record.CallRegardingName = record.CallRegarding__c ? record.CallRegarding__r.Name : '';
                record.CampaignName = record.Campaign__c ? record.Campaign__r.Name : '';
                record.CampaignBrand = record.Campaign__c ? record.Campaign__r.Brand__c : '';
            });
            component.set("v.data", records);           
            component.set("v.currentCount", component.get("v.initialRows"));            
        });
        $A.enqueueAction(action);
    },
    getRecordType : function(component) {
        
        var action = component.get("c.getCallRecordType");
       
        action.setCallback(this, function(a) {
            component.set("v.callRecordType", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },   
    fetchData: function(component , rows){
        return new Promise($A.getCallback(function(resolve, reject) {
            var currentDatatemp = component.get('c.getCall');
            var counts = component.get("v.currentCount");
            currentDatatemp.setParams({
                "limits": component.get("v.initialRows"),
                "offsets": counts,
                "contactId": component.get("v.recordId")
            });
            currentDatatemp.setCallback(this, function(a) {
                var records =a.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/lightning/r/case/'+record.Id+'/view';
                    record.CallRegardingName = record.CallRegarding__c ? record.CallRegarding__r.Name : '';
                    record.CampaignName = record.Campaign__c ? record.Campaign__r.Name : '';
                    record.CampaignBrand = record.Campaign__c ? record.Campaign__r.Brand__c : '';
                });
                
                resolve(records);
                var countstemps = component.get("v.currentCount");
                countstemps = countstemps+component.get("v.initialRows");
                component.set("v.currentCount",countstemps);
                
            });
            $A.enqueueAction(currentDatatemp);
        }));
    }
})