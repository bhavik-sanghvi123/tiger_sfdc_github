/*------------------------------------------------------------
Author:      Crissar Ibarra
Description: Helper class for Nutrition History object

History
10/25/2021   cribarra     Created
12/17/2021   fgomendoza   Enhancement
-------------------------------------------------------------------------------------------*/

public class NutritionHistoryTriggerHelper{
    
    public static void updateBROnCreateOfNH(Map<Id, Medical_Diagnosis__c> userToMDMap) {        
        List<BrandRelationship__c> brListToUpdate = new List<BrandRelationship__c>();
        for(BrandRelationship__c br: [SELECT ID, User__c, Height__c, Height_Percentile__c, Height_Status__c, Medical_Nutrition_Created_Date__c, Market__c FROM BrandRelationship__c WHERE User__c IN: userToMDMap.keySet() AND Market__c = 'MY'] ){
            br.Height__c = userToMDMap.get(br.User__c).Height__c;
            br.Height_Percentile__c = String.valueof(userToMDMap.get(br.User__c).Height_Percentile__c);
            br.Height_Status__c= String.valueof(userToMDMap.get(br.User__c).Height_Status__c);
            br.Medical_Nutrition_Created_Date__c = userToMDMap.get(br.User__c).CreatedDate.date();
            brListToUpdate.add(br);
        }
        if(!brListToUpdate.IsEmpty()){
            update brListToUpdate;
        }
    }

    public static void updateCaseNH(Map<Id, Id> caseToMDIdMap){
        List<Case> updateCaseList = new List<Case>();
        for(Case c : [SELECT Id, MedicalDiagnosis__c FROM Case WHERE Id IN: caseToMDIdMap.keySet()]){
            c.MedicalDiagnosis__c = caseToMDIdMap.get(c.Id);
            updateCaseList.add(c);
        }
        if(!updateCaseList.isEmpty()){
            update updateCaseList;
        }
    }
}