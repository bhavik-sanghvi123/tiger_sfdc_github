/**
* @author        Jennifer Alviz    
* @date          01.27.2020
* @description   Batch job to update MEMBERSHIP Sync Eligibility Fields
* @revision(s)
*/
global class MC_Membership_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> contactIds = new Set<Id>();
    String queryOverride;
    
    global MC_Membership_SyncEligibilityBatch(Set<Id> conIds,String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Contact__c ,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM Membership__c'
            + ' WHERE'
            + ' Contact__c IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Membership__c> scope) {
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        List<Membership__c> memToUpdate = new List<Membership__c>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Membership__c mem : scope){
            contactIdSet.add(mem.Contact__c);
        }
        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN :contactIdSet]);
        
        for(Membership__c mem: scope ) {  
                         
            String Market = contactMap.get(mem.Contact__c).Market__c;
            Boolean forUpdate = true; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                mem.MC_Sync_Eligibility_ANZ__c = contactMap.get(mem.Contact__c).MC_Sync_Eligibility_ANZ__c;
            }else if(Market == CommonConstant.MARKET_ID){
                mem.MC_Sync_Eligibility_ID__c = contactMap.get(mem.Contact__c).MC_Sync_Eligibility_ID__c;
            }else if(Market == CommonConstant.MARKET_IN){
                mem.MC_Sync_Eligibility_IN__c = contactMap.get(mem.Contact__c).MC_Sync_Eligibility_IN__c;
            }else if(Market == CommonConstant.MARKET_MY){
                mem.MC_Sync_Eligibility_MY__c = contactMap.get(mem.Contact__c).MC_Sync_Eligibility_MY__c;
            }else if(Market == CommonConstant.MARKET_PH){
                mem.MC_Sync_Eligibility_PH__c = contactMap.get(mem.Contact__c).MC_Sync_Eligibility_PH__c;
            }else if(Market == CommonConstant.MARKET_SG){
                mem.MC_Sync_Eligibility_SG__c = contactMap.get(mem.Contact__c).MC_Sync_Eligibility_SG__c;
            }else if(Market == CommonConstant.MARKET_TH){
                mem.MC_Sync_Eligibility_TH__c = contactMap.get(mem.Contact__c).MC_Sync_Eligibility_TH__c;
            }else if(Market == CommonConstant.MARKET_VN){
                mem.MC_Sync_Eligibility_VN__c = contactMap.get(mem.Contact__c).MC_Sync_Eligibility_VN__c;
            }else{
                forUpdate = false;
            }
            
            if(forUpdate) memToUpdate.add(mem);
        }
        
        if(!memToUpdate .isEmpty()) UtilityClass.updateList(memToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}