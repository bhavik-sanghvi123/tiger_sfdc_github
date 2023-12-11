public class MembershipTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) {}
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) {}

    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){}
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){
        Map<Id, List<Membership__c>> conMembershipMap = new Map<Id, List<Membership__c>>();
        List<Membership__c> processPHMemList = new List<Membership__c>();
        Map<Id, Membership__c> processPHMemMap = new Map<Id, Membership__c>();
        
        for(Membership__c mem : (List<Membership__c>) newList){
            if(conMembershipMap.containsKey(mem.Contact__c)){
                conMembershipMap.get(mem.Contact__c).add(mem);
            }
            else{
                conMembershipMap.put(mem.Contact__c, new List<Membership__c>{mem});
            }
        }
        for(Contact con : [SELECT Id, Market__c FROM Contact WHERE Id IN: conMembershipMap.keySet() AND Market__c = 'PH']){
            processPHMemList.addAll(conMembershipMap.get(con.Id));
        }
        for(Membership__c mem : processPHMemList){
            processPHMemMap.put(mem.Id, mem);
        }
        System.debug('INSERT MembershipTriggerHandler');
        if(!processPHMemMap.keySet().isEmpty()){
            MembershipTriggerHelper.copyMembershipToContact(null, processPHMemMap);
        }
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){
        Map<Id, List<Membership__c>> conMembershipMap = new Map<Id, List<Membership__c>>();
        List<Membership__c> processPHMemList = new List<Membership__c>();
        Map<Id, Membership__c> processPHMemMap = new Map<Id, Membership__c>();
        
        for(Membership__c mem : (List<Membership__c>) newList){
            if(conMembershipMap.containsKey(mem.Contact__c)){
                conMembershipMap.get(mem.Contact__c).add(mem);
            }
            else{
                conMembershipMap.put(mem.Contact__c, new List<Membership__c>{mem});
            }
        }
        for(Contact con : [SELECT Id, Market__c FROM Contact WHERE Id IN: conMembershipMap.keySet() AND Market__c = 'PH']){
            processPHMemList.addAll(conMembershipMap.get(con.Id));
        }
        for(Membership__c mem : processPHMemList){
            Membership__c oldItem = (Membership__c) oldMapItems.get(mem.Id);
            if(mem.Status__c != oldItem.Status__c || mem.MembershipStartDate__c != oldItem.MembershipStartDate__c || mem.MembershipExpiryDate__c != oldItem.MembershipExpiryDate__c || mem.Contact__c != oldItem.Contact__c ||
               mem.Recent_Product_Purchased__c != oldItem.Recent_Product_Purchased__c || mem.NumberOfDaysDormant__c != oldItem.NumberOfDaysDormant__c || mem.NumberOfTransactions__c != oldItem.NumberOfTransactions__c ||
               mem.MembershipId__c != oldItem.MembershipId__c)
            {
                processPHMemMap.put(mem.Id, mem);
            }
        }
        System.debug('UPDATE MembershipTriggerHandler');
        if(!processPHMemMap.keySet().isEmpty()){
            MembershipTriggerHelper.copyMembershipToContact(oldMapItems, processPHMemMap);
        }
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){}
}