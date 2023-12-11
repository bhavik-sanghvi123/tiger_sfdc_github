public class TaskTriggerHandler  implements ITriggerHandler {

    public void BeforeInsert(List<SObject> newList) {
        TaskTriggerHelper.updateWhoId(newList);
        TaskTriggerHelper.updateActivityHistory(newList);
        TaskTriggerHelper.updateRelatedCase(newList);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){}
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ }
}