/*------------------------------------------------------------
Author:      Crissar Ibarra
Description: Handler class for Nutritin History object
                  
10/25/2021   cribarra     Created
-------------------------------------------------------------------------------------------*/

public class NutritionHistoryTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) {}
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) {}
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){}
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
        Map<Id, Medical_Diagnosis__c> userToMDMap = new Map<Id, Medical_Diagnosis__c>();
        Map<Id, Id> caseToMDIdMap = new Map<Id, Id>();
        List<Medical_Diagnosis__c> newMDList = (List<Medical_Diagnosis__c>) newList;
        for(Medical_Diagnosis__c md : newMDList){
            //For updateBROnCreateOfNH method
            if(md.EndUser__c != null) {
                userToMDMap.put(md.EndUser__c, md);
            }
            //For updateCaseNH method
            if(md.Related_Case__c != null && md.CreatedforIntegration__c == true){
                caseToMDIdMap.put(md.Related_Case__c, md.Id);
            }
        }
        if(!userToMDMap.keySet().isEmpty()) NutritionHistoryTriggerHelper.updateBROnCreateOfNH(userToMDMap);
        if(!caseToMDIdMap.keySet().isEmpty()) NutritionHistoryTriggerHelper.updateCaseNH(caseToMDIdMap);
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){
        Map<Id, Id> caseToMDIdMap = new Map<Id, Id>();
        List<Medical_Diagnosis__c> newMDList = (List<Medical_Diagnosis__c>) newList;
        for(Medical_Diagnosis__c md : newMDList){
            Medical_Diagnosis__c oldMd = (Medical_Diagnosis__c) oldMapItems.get(md.Id);
            if(md.Related_Case__c != null && md.CreatedforIntegration__c == true && oldMd.Related_Case__c != md.Related_Case__c){
                caseToMDIdMap.put(md.Related_Case__c, md.Id);
            }
        }
        if(!caseToMDIdMap.keySet().isEmpty()) NutritionHistoryTriggerHelper.updateCaseNH(caseToMDIdMap);
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){}
}