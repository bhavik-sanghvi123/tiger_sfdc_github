/*
Author: Frank Gomendoza
Description: Helper class for Individual Email Result object
History:
08/04/2022   fgomendoza    Created copyBounceStatusToContact
*/
public class IndividualEmailResultTriggerHelper {
    public static void copyBounceStatusToContact(Map<Id, SObject> oldMap, Map<Id, et4ae5__IndividualEmailResult__c> newMap){
        Map<Id, Contact> conUpdateMap = new Map<Id, Contact>();  
        Set<Id> conIds = new Set<Id>();
        
        if(Trigger.isInsert || Trigger.isUpdate){
            for(et4ae5__IndividualEmailResult__c ier : newMap.values()){
                if(ier.et4ae5__HardBounce__c){
                    conIds.add(ier.et4ae5__Contact__c);
                }
            }
            for(Contact con : [SELECT Id FROM Contact WHERE Id IN: conIds AND EmailBounced__c = false]){
                con.EmailBounced__c = true;
                conUpdateMap.put(con.Id, con);
            }
        }
        else if(Trigger.isDelete){
            
        }

        update conUpdateMap.values();
    }
}