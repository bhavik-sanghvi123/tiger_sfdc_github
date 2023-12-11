public class ProductTriggerHandler  implements ITriggerHandler {

    public void BeforeInsert(List<SObject> newList) {
        ProductTriggerHelper.checkDuplicateProductCode(newList,null);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
       ProductTriggerHelper.checkDuplicateProductCode(newList,oldMapItems);
    }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ 
    }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        ProductTriggerHelper.updateMinMaxBirthMonth(newMapItems, oldMapItems);
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ }
}