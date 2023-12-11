/**
* @author        Jennifer Alviz    
* @date          01.27.2021
* @description   Batch job to update CAMPAIGN MEMBER Sync Eligibility Fields
* @revision(s)
*/
global class MC_CampaignMem_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> contactIds = new Set<Id>();
    String queryOverride;
    
    global MC_CampaignMem_SyncEligibilityBatch(Set<Id> conIds,String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, ContactId,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                    
            + ' FROM CampaignMember'
            + ' WHERE'
            + ' ContactId IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        List<CampaignMember> cmToUpdate = new List<CampaignMember>();
        Set<Id> relevantContactIds = new Set<Id>();
        for(CampaignMember cmp : scope){
            relevantContactIds.add(cmp.contactId);
        }
        
        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN :relevantContactIds]);
        
        for(CampaignMember cm: scope) {  
                         
            String Market = contactMap.get(cm.ContactId).Market__c;
            Boolean forUpdate = true; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                cm.MC_Sync_Eligibility_ANZ__c = contactMap.get(cm.ContactId).MC_Sync_Eligibility_ANZ__c;
            }else if(Market == CommonConstant.MARKET_ID){
                cm.MC_Sync_Eligibility_ID__c = contactMap.get(cm.ContactId).MC_Sync_Eligibility_ID__c;
            }else if(Market == CommonConstant.MARKET_IN){
                cm.MC_Sync_Eligibility_IN__c = contactMap.get(cm.ContactId).MC_Sync_Eligibility_IN__c;
            }else if(Market == CommonConstant.MARKET_MY){
                cm.MC_Sync_Eligibility_MY__c = contactMap.get(cm.ContactId).MC_Sync_Eligibility_MY__c;
            }else if(Market == CommonConstant.MARKET_PH){
                cm.MC_Sync_Eligibility_PH__c = contactMap.get(cm.ContactId).MC_Sync_Eligibility_PH__c;
            }else if(Market == CommonConstant.MARKET_SG){
                cm.MC_Sync_Eligibility_SG__c = contactMap.get(cm.ContactId).MC_Sync_Eligibility_SG__c;
            }else if(Market == CommonConstant.MARKET_TH){
                cm.MC_Sync_Eligibility_TH__c = contactMap.get(cm.ContactId).MC_Sync_Eligibility_TH__c;
            }else if(Market == CommonConstant.MARKET_VN){
                cm.MC_Sync_Eligibility_VN__c = contactMap.get(cm.ContactId).MC_Sync_Eligibility_VN__c;
            }else{
                forUpdate = false;
            }
            
            if(forUpdate) cmToUpdate.add(cm);
        }
        
        if(!cmToUpdate.isEmpty()) UtilityClass.updateList(cmToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}