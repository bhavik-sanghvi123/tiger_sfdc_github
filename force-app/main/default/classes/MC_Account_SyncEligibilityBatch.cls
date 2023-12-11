/**
* @author        Jennifer Alviz    
* @date          02.02.2020
* @description   Batch job to update ACCOUNT Sync Eligibility Fields
* @revision(s)
*/
global class MC_Account_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> accountIds = new Set<Id>();
    global Set<Id> eligibleHouseholds = new Set<Id>();
    
    global MC_Account_SyncEligibilityBatch(Set<Id> accIds, Set<Id> eligAccountIds){
        eligibleHouseholds = (Set<Id>) eligAccountIds;
        accountIds = (Set<Id>) accIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Market__c ,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM Account'
            + ' WHERE'
            + ' Id IN :accountIds';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accountToUpdate = new List<Account>();
        
        for(Account acc: scope ) {  
                         
            Boolean toUpdate = false; 
            Boolean eligibility = false;

            if(eligibleHouseholds.contains(acc.Id)){
                eligibility = true;
            }
                         
            if(acc.Market__c == CommonConstant.MARKET_ANZ && acc.MC_Sync_Eligibility_ANZ__c != eligibility){
                acc.MC_Sync_Eligibility_ANZ__c = eligibility;
                toUpdate = true;

            }else if(acc.Market__c == CommonConstant.MARKET_ID && acc.MC_Sync_Eligibility_ANZ__c != eligibility){
                acc.MC_Sync_Eligibility_ID__c = eligibility;
                toUpdate = true;

            }else if(acc.Market__c == CommonConstant.MARKET_IN && acc.MC_Sync_Eligibility_ANZ__c != eligibility){
                acc.MC_Sync_Eligibility_IN__c = eligibility;
                toUpdate = true;

            }else if(acc.Market__c == CommonConstant.MARKET_MY && acc.MC_Sync_Eligibility_ANZ__c != eligibility){
                acc.MC_Sync_Eligibility_MY__c = eligibility;
                toUpdate = true;

            }else if(acc.Market__c == CommonConstant.MARKET_PH && acc.MC_Sync_Eligibility_ANZ__c != eligibility){
                acc.MC_Sync_Eligibility_PH__c = eligibility;
                toUpdate = true;

            }else if(acc.Market__c == CommonConstant.MARKET_SG && acc.MC_Sync_Eligibility_ANZ__c != eligibility){
                acc.MC_Sync_Eligibility_SG__c = eligibility;
                toUpdate = true;

            }else if(acc.Market__c == CommonConstant.MARKET_TH && acc.MC_Sync_Eligibility_ANZ__c != eligibility){
                acc.MC_Sync_Eligibility_TH__c = eligibility;
                toUpdate = true;

            }else if(acc.Market__c == CommonConstant.MARKET_VN && acc.MC_Sync_Eligibility_ANZ__c != eligibility){
                acc.MC_Sync_Eligibility_VN__c = eligibility;
                toUpdate = true;

            }
            
            if(toUpdate) accountToUpdate.add(acc);
        }
        
        if(!accountToUpdate .isEmpty()) UtilityClass.updateList(accountToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}