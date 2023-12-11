/**
* @author        Marlon Ocillos
* @date          5.24.2019
* @description   Class primarily responsible in handling trigger logic for AgentWork
* @revision(s)
*/
public with sharing class AgentWorkTriggerHandler implements ITriggerHandler {
	
	public void BeforeInsert(List<SObject> newList) { }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
    	updateCallCAccepted(newList, oldMapItems);
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ }
    
    /**
    * @author        	Marlon Ocillos
    * @date          	5.24.2019
    * @description   	Method is called to update the Call Acceptede field when a call is Accepted
    * @revision(s)
    */
    public static void updateCallCAccepted(List<AgentWork> newList, Map<Id, SObject> oldMapItems) {
        Set<Id> caseIds = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();
        for(AgentWork awRec : newList) {
            AgentWork awRecOld = (AgentWork)oldMapItems.get(awRec.Id);
            if(awRec.AcceptDatetime != null && awRecOld.AcceptDatetime == null) {
                caseIds.add(awRec.WorkItemId);
            }
        }
        
        if(!caseIds.isEmpty()) {
            for(Case caseRec : [select Id, CallAccepted__c from Case where CallAccepted__c = false and Id in :caseIds]) {
                caseRec.CallAccepted__c = true;
                casesToUpdate.add(caseRec);
            }
        }
        
        if(!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
}