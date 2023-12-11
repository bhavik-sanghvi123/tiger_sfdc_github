/**
* @author        Jennifer Alviz    
* @date          12.18.2020
* @description   Batch job to run daily to update technical fields : AgeinMonths2__c and WeeksOfPregnancy2__c  for MC
* @revision(s)
*/
global class MC_Case_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful  {
    
    Set<Id> contactIds = new Set<Id>();
    Set<Id> eligibleContacts = new Set<Id>();
    String queryOverride;

    global MC_Case_SyncEligibilityBatch (Set<Id> conIds, String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, ContactId ,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM Case'
            + ' WHERE'
            + ' ContactId IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        } 

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope) {
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> caseIds = new set<Id>();
        for(Case c: scope){
            caseIds.add(c.Id);
        }
        
        //CaseEventHandler.updateMCEligibility(caseIds);

        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN (SELECT ContactId FROM Case WHERE Id IN: caseIds)]);
        
        for(Case c: scope ) {  
            
            String Market = contactMap.get(c.ContactId).Market__c;
            Boolean forUpdate = false; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                c.MC_Sync_Eligibility_ANZ__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_ANZ__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_ID){
                c.MC_Sync_Eligibility_ID__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_ID__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_IN){
                c.MC_Sync_Eligibility_IN__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_IN__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_MY){
                c.MC_Sync_Eligibility_MY__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_MY__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_PH){
                c.MC_Sync_Eligibility_PH__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_PH__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_SG){
                c.MC_Sync_Eligibility_SG__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_SG__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_TH){
                c.MC_Sync_Eligibility_TH__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_TH__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_VN){
                c.MC_Sync_Eligibility_VN__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_VN__c;
                forUpdate = true;

            }
            
            if(forUpdate) casesToUpdate.add(c);
        }
        
        if(!casesToUpdate.isEmpty()) UtilityClass.updateList(casesToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}