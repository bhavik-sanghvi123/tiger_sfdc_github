/**
* @author        Rey Austral
* @date          1.11.2019           
* @description   Interface that serves as template for every trigger events.
* @revision(s)
*/
public interface ITriggerHandler {

    void BeforeInsert(List<SObject> newList); 
 
    void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newItems, List<SObject> oldList, Map<Id, SObject> oldItems);
 
    void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems); 
 
    void AfterInsert(List<SObject> newList, Map<Id, SObject> newItems);
 
    void AfterUpdate(List<SObject> newList, Map<Id, SObject> newItems, List<SObject> oldList, Map<Id, SObject> oldItems);
 
    void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldItems);
}