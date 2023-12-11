/**
* @author        Jennifer Alviz    
* @date          12.18.2020
* @description   Batch job to update CHANNEL RESPONSE Sync Eligibility Fields
* @revision(s)
*/
global class MC_CR_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    Set<Id> contactIds = new Set<Id>();
    Set<Id> eligibleContacts = new Set<Id>();
    String queryOverride;
    
    global MC_CR_SyncEligibilityBatch(Set<Id> conIds, String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Contact__c ,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM ChannelResponse__c'
            + ' WHERE'
            + ' Contact__c IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        } 

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ChannelResponse__c> scope) {
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        List<ChannelResponse__c> crToUpdate = new List<ChannelResponse__c>();
        Set<Id> crIds = new set<Id>();
        for(ChannelResponse__c cr: scope){
            crIds.add(cr.Id);
        }
        
        //ChannelResponseEventHandler.updateMCEligibility(crIds);

        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN (SELECT Contact__c FROM ChannelResponse__c WHERE Id IN: crIds)]);
        
        for(ChannelResponse__c cr: scope ) {  
                  
            String Market = contactMap.get(cr.Contact__c).Market__c;
            Boolean forUpdate = false; 
                      
            if(Market == CommonConstant.MARKET_ANZ){
                cr.MC_Sync_Eligibility_ANZ__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_ANZ__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_ID){
                cr.MC_Sync_Eligibility_ID__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_ID__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_IN){
                cr.MC_Sync_Eligibility_IN__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_IN__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_MY){
                cr.MC_Sync_Eligibility_MY__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_MY__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_PH){
                cr.MC_Sync_Eligibility_PH__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_PH__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_SG){
                cr.MC_Sync_Eligibility_SG__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_SG__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_TH){
                cr.MC_Sync_Eligibility_TH__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_TH__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_VN){
                cr.MC_Sync_Eligibility_VN__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_VN__c;
                forUpdate = true;

            }
            
            if(forUpdate) crToUpdate.add(cr);
        }
        
        if(!crToUpdate.isEmpty()) UtilityClass.updateList(crToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}