/**
* @author        Jennifer Alviz    
* @date          01.27.2021
* @description   Batch job to update INDIVIDUAL EMAIL RESULT Sync Eligibility Fields
* @revision(s)
*/
global class MC_IER_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> contactIds = new Set<Id>();
    String queryOverride;
    
    global MC_IER_SyncEligibilityBatch(Set<Id> conIds,String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, et4ae5__Contact__c,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                    
            + ' FROM et4ae5__IndividualEmailResult__c'
            + ' WHERE'
            + ' et4ae5__Contact__c IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }   

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<et4ae5__IndividualEmailResult__c> scope) {
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        List<et4ae5__IndividualEmailResult__c> ierToUpdate = new List<et4ae5__IndividualEmailResult__c>();
        Set<Id> relevantContactIds = new Set<Id>();
        for(et4ae5__IndividualEmailResult__c ier : scope){
            relevantContactIds.add(ier.et4ae5__Contact__c );
        }
        
        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN :relevantContactIds]);
        
        for(et4ae5__IndividualEmailResult__c  ier: scope) {  
                         
            String Market = contactMap.get(ier.et4ae5__Contact__c ).Market__c;
            Boolean forUpdate = true; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                ier.MC_Sync_Eligibility_ANZ__c = contactMap.get(ier.et4ae5__Contact__c ).MC_Sync_Eligibility_ANZ__c;
            }else if(Market == CommonConstant.MARKET_ID){
                ier.MC_Sync_Eligibility_ID__c = contactMap.get(ier.et4ae5__Contact__c ).MC_Sync_Eligibility_ID__c;
            }else if(Market == CommonConstant.MARKET_IN){
                ier.MC_Sync_Eligibility_IN__c = contactMap.get(ier.et4ae5__Contact__c ).MC_Sync_Eligibility_IN__c;
            }else if(Market == CommonConstant.MARKET_MY){
                ier.MC_Sync_Eligibility_MY__c = contactMap.get(ier.et4ae5__Contact__c ).MC_Sync_Eligibility_MY__c;
            }else if(Market == CommonConstant.MARKET_PH){
                ier.MC_Sync_Eligibility_PH__c = contactMap.get(ier.et4ae5__Contact__c ).MC_Sync_Eligibility_PH__c;
            }else if(Market == CommonConstant.MARKET_SG){
                ier.MC_Sync_Eligibility_SG__c = contactMap.get(ier.et4ae5__Contact__c ).MC_Sync_Eligibility_SG__c;
            }else if(Market == CommonConstant.MARKET_TH){
                ier.MC_Sync_Eligibility_TH__c = contactMap.get(ier.et4ae5__Contact__c ).MC_Sync_Eligibility_TH__c;
            }else if(Market == CommonConstant.MARKET_VN){
                ier.MC_Sync_Eligibility_VN__c = contactMap.get(ier.et4ae5__Contact__c ).MC_Sync_Eligibility_VN__c;
            }else{
                forUpdate = false;
            }
            
            if(forUpdate) ierToUpdate.add(ier);
        }
        
        if(!ierToUpdate.isEmpty()) UtilityClass.updateList(ierToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}