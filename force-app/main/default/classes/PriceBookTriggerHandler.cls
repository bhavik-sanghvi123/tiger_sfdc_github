public class PriceBookTriggerHandler  implements ITriggerHandler {
    
    public void BeforeInsert(List<SObject> newList)  { 
        PriceBookTriggerHelper.insertActivePriceBook(newList);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) {
        PriceBookTriggerHelper.updateActivePriceBook(newList, oldMapItems);
    }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
         
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){}
    
}