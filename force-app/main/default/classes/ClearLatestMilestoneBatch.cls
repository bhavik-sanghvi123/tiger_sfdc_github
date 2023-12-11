/**
* @author        Jennifer Alviz    
* @date          4.7.2021
* @description   Batch job to clear all latest milestones on VN BR for contacts who completed pregnancy
* @revision(s)

5/11/2021   malviz      One-time use only, commented out entire code
*/
public class ClearLatestMilestoneBatch {} /* Implements Database.Batchable<sObject>{
    
    String queryOverride;

    global ClearLatestMilestoneBatch(String newScope){
        String queryOverride;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID,LatestMilestone__c, User__c, User__r.Type__c'                    
            + ' FROM BrandRelationship__c'
            + ' WHERE'
            + ' User__c != null'
            + ' Household__c != null'
            + ' User__r.Type__c = \'Adult\''
            + ' AND Household__r.Market__c != \'VN\'';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        } 

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BrandRelationship__c> scope) {
        for(BrandRelationship__c br : scope){
            if(br.User__r.EstimatedDueDate__c == null && br.LatestMilestone__c != null){
                br.LatestMilestone__c = null;
                br.MilestoneStatus__c = null;
            }
           
        }
        
        if(!scope.isEmpty()) Utilityclass.updateList(scope);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}*/