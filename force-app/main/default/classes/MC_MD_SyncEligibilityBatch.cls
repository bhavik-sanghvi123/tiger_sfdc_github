/**
* @author        Jennifer Alviz    
* @date          01.27.2020
* @description   Batch job to update MEDICAL DIAGNOSIS / NUTRITION HISTORY Sync Eligibility Fields
* @revision(s)
*/
global class MC_MD_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> contactIds = new Set<Id>();
    String queryOverride;
    
    global MC_MD_SyncEligibilityBatch(Set<Id> conIds,String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Contact__c,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                           
            + ' FROM Medical_Diagnosis__c'
            + ' WHERE'
            + ' Contact__c IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }    

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Medical_Diagnosis__c> scope) {
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        List<Medical_Diagnosis__c> mdToUpdate = new List<Medical_Diagnosis__c>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Medical_Diagnosis__c md : scope){
            contactIdSet.add(md.Contact__c);
        }
        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN :contactIdSet]);
        
        for(Medical_Diagnosis__c md: scope) {  
                         
            String Market = contactMap.get(md.Contact__c).Market__c;
            Boolean forUpdate = true; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                md.MC_Sync_Eligibility_ANZ__c = contactMap.get(md.Contact__c).MC_Sync_Eligibility_ANZ__c;
            }else if(Market == CommonConstant.MARKET_ID){
                md.MC_Sync_Eligibility_ID__c = contactMap.get(md.Contact__c).MC_Sync_Eligibility_ID__c;
            }else if(Market == CommonConstant.MARKET_IN){
                md.MC_Sync_Eligibility_IN__c = contactMap.get(md.Contact__c).MC_Sync_Eligibility_IN__c;
            }else if(Market == CommonConstant.MARKET_MY){
                md.MC_Sync_Eligibility_MY__c = contactMap.get(md.Contact__c).MC_Sync_Eligibility_MY__c;
            }else if(Market == CommonConstant.MARKET_PH){
                md.MC_Sync_Eligibility_PH__c = contactMap.get(md.Contact__c).MC_Sync_Eligibility_PH__c;
            }else if(Market == CommonConstant.MARKET_SG){
                md.MC_Sync_Eligibility_SG__c = contactMap.get(md.Contact__c).MC_Sync_Eligibility_SG__c;
            }else if(Market == CommonConstant.MARKET_TH){
                md.MC_Sync_Eligibility_TH__c = contactMap.get(md.Contact__c).MC_Sync_Eligibility_TH__c;
            }else if(Market == CommonConstant.MARKET_VN){
                md.MC_Sync_Eligibility_VN__c = contactMap.get(md.Contact__c).MC_Sync_Eligibility_VN__c;
            }else{
                forUpdate = false;
            }
            
            if(forUpdate) mdToUpdate.add(md);
        }
        
        if(!mdToUpdate .isEmpty()) UtilityClass.updateList(mdToUpdate );
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}