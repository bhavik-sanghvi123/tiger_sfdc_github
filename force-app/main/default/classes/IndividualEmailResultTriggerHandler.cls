public class IndividualEmailResultTriggerHandler implements ITriggerHandler{
    public static Boolean bypassTrigger = false;
    
    public void BeforeInsert(List<SObject> newList){}
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){}
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){}
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){
        if(!bypassTrigger){
            Map<Id, List<et4ae5__IndividualEmailResult__c>> conIERMap = new Map<Id, List<et4ae5__IndividualEmailResult__c>>();
            List<et4ae5__IndividualEmailResult__c> processPHIERList = new List<et4ae5__IndividualEmailResult__c>();
            Map<Id, et4ae5__IndividualEmailResult__c> processPHIERMap = new Map<Id, et4ae5__IndividualEmailResult__c>();
            
            for(et4ae5__IndividualEmailResult__c ier : (List<et4ae5__IndividualEmailResult__c>) newList){
                if(conIERMap.containsKey(ier.et4ae5__Contact__c)){
                    conIERMap.get(ier.et4ae5__Contact__c).add(ier);
                }
                else{
                    conIERMap.put(ier.et4ae5__Contact__c, new List<et4ae5__IndividualEmailResult__c>{ier});
                }
            }
            for(Contact con : [SELECT Id, Market__c FROM Contact WHERE Id IN: conIERMap.keySet()]){
                processPHIERList.addAll(conIERMap.get(con.Id));
            }
            for(et4ae5__IndividualEmailResult__c ier : processPHIERList){
                processPHIERMap.put(ier.Id, ier);
            }
            System.debug('INSERT FG');
            if(!processPHIERMap.keySet().isEmpty()){
                IndividualEmailResultTriggerHelper.copyBounceStatusToContact(null, processPHIERMap);
            }
        }
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){
        if(!bypassTrigger){
            Map<Id, List<et4ae5__IndividualEmailResult__c>> conIERMap = new Map<Id, List<et4ae5__IndividualEmailResult__c>>();
            List<et4ae5__IndividualEmailResult__c> processPHIERList = new List<et4ae5__IndividualEmailResult__c>();
            Map<Id, et4ae5__IndividualEmailResult__c> processPHIERMap = new Map<Id, et4ae5__IndividualEmailResult__c>();
            
            for(et4ae5__IndividualEmailResult__c ier : (List<et4ae5__IndividualEmailResult__c>) newList){
                if(conIERMap.containsKey(ier.et4ae5__Contact__c)){
                    conIERMap.get(ier.et4ae5__Contact__c).add(ier);
                }
                else{
                    conIERMap.put(ier.et4ae5__Contact__c, new List<et4ae5__IndividualEmailResult__c>{ier});
                }
            }
            for(Contact con : [SELECT Id, Market__c FROM Contact WHERE Id IN: conIERMap.keySet()]){
                processPHIERList.addAll(conIERMap.get(con.Id));
            }
            for(et4ae5__IndividualEmailResult__c ier : processPHIERList){
                et4ae5__IndividualEmailResult__c oldItem = (et4ae5__IndividualEmailResult__c) oldMapItems.get(ier.Id);
                if(ier.et4ae5__HardBounce__c != oldItem.et4ae5__HardBounce__c || ier.et4ae5__SoftBounce__c != oldItem.et4ae5__SoftBounce__c){
                    processPHIERMap.put(ier.Id, ier);
                }
            }
            System.debug('UPDATE FG');
            if(!processPHIERMap.keySet().isEmpty()){
                IndividualEmailResultTriggerHelper.copyBounceStatusToContact(oldMapItems, processPHIERMap);
            }
        }
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        
    }
}