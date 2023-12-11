({
    selectRecord : function(component, event, helper){    
        var getSelectRecord = component.get("v.dataResult");
        component.set("v.reference", getSelectRecord.Id);
        component.set("v.resultName", getSelectRecord.Name);
        component.set("v.discount", getSelectRecord.DiscountPercentage__c);
        component.set("v.isGSTExclusive", getSelectRecord.ExclusiveOfGST__c);
        component.set("v.gstRate", getSelectRecord.GSTRate__c);
        var isGSTExclusive = component.get("v.isGSTExclusive");
        var gstRate = component.get("v.gstRate");

        if(isGSTExclusive) {
          var compEvent1 = component.getEvent("GetPercentageGSTEvt");
          compEvent1.setParams({"pbeGST" : gstRate});
          compEvent1.fire();
        } else {
          var compEvent1 = component.getEvent("GetPercentageGSTEvt");
          compEvent1.setParams({"pbeGST" : null});
          compEvent1.fire();
        }

        var compEvent2 = component.getEvent("selectedRecordEvent");
        compEvent2.setParams({"dataByEvent" : getSelectRecord });  
        compEvent2.fire();

        var compEvent3 = component.getEvent("GetPercentageDiscountEvt");
        compEvent3.setParams({"pbeDiscount" : getSelectRecord.DiscountPercentage__c});  
        compEvent3.fire();
    }
})