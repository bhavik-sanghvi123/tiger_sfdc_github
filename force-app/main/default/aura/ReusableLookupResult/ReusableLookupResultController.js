({
   selectRecord : function(component, event, helper){      
       // get the selected record from list  
       var getSelectRecord = component.get("v.record");
       
       // call the event   
       var compEvent = component.getEvent("SelectedRecordEvent");
       compEvent.setParams({"recordByEvent" : getSelectRecord});  
       compEvent.fire();
    },
})