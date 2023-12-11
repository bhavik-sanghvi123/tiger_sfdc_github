/**
* @author        Jennifer Alviz    
* @date          01.27.2021
* @description   Batch job to update REWARD Sync Eligibility Fields
* @revision(s)
*/
global class MC_Reward_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> contactIds = new Set<Id>();
    String queryOverride;
    
    global MC_Reward_SyncEligibilityBatch(Set<Id> conIds,String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Contact__c ,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM Reward__c'
            + ' WHERE'
            + ' Contact__c IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Reward__c> scope) {
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        List<Reward__c> rewardsToUpdate = new List<Reward__c>();
        Set<Id> rewardContactIds = new Set<Id>();
        for(Reward__c reward : scope){
            rewardContactIds.add(reward.Contact__c);
        }
        
        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN :rewardContactIds]);
        
        for(Reward__c r: scope) {  
                         
            String Market = contactMap.get(r.Contact__c).Market__c;
            Boolean forUpdate = true; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                r.MC_Sync_Eligibility_ANZ__c = contactMap.get(r.Contact__c).MC_Sync_Eligibility_ANZ__c;
            }else if(Market == CommonConstant.MARKET_ID){
                r.MC_Sync_Eligibility_ID__c = contactMap.get(r.Contact__c).MC_Sync_Eligibility_ID__c;
            }else if(Market == CommonConstant.MARKET_IN){
                r.MC_Sync_Eligibility_IN__c = contactMap.get(r.Contact__c).MC_Sync_Eligibility_IN__c;
            }else if(Market == CommonConstant.MARKET_MY){
                r.MC_Sync_Eligibility_MY__c = contactMap.get(r.Contact__c).MC_Sync_Eligibility_MY__c;
            }else if(Market == CommonConstant.MARKET_PH){
                r.MC_Sync_Eligibility_PH__c = contactMap.get(r.Contact__c).MC_Sync_Eligibility_PH__c;
            }else if(Market == CommonConstant.MARKET_SG){
                r.MC_Sync_Eligibility_SG__c = contactMap.get(r.Contact__c).MC_Sync_Eligibility_SG__c;
            }else if(Market == CommonConstant.MARKET_TH){
                r.MC_Sync_Eligibility_TH__c = contactMap.get(r.Contact__c).MC_Sync_Eligibility_TH__c;
            }else if(Market == CommonConstant.MARKET_VN){
                r.MC_Sync_Eligibility_VN__c = contactMap.get(r.Contact__c).MC_Sync_Eligibility_VN__c;
            }else{
                forUpdate = false;
            }
            
            if(forUpdate) rewardsToUpdate.add(r);
        }
        
        if(!rewardsToUpdate.isEmpty()) UtilityClass.updateList(rewardsToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}