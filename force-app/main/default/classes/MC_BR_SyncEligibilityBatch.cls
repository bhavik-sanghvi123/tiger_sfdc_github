/**
* @author        Jennifer Alviz    
* @date          12.18.2020
* @description   Batch job to update BRAND RELATIONSHIP Sync Eligibility Fields
* @revision(s)
*/
global class MC_BR_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful{
    
    Set<Id> contactIds = new Set<Id>();
    Set<Id> eligibleContacts = new Set<Id>();
    String queryOverride;
    
    global MC_BR_SyncEligibilityBatch(Set<Id> conIds, String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, PrimaryContact__c ,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM BrandRelationship__c'
            + ' WHERE'
            + ' PrimaryContact__c IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BrandRelationship__c > scope) {
        List<BrandRelationship__c> brToUpdate = new List<BrandRelationship__c>();
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        Set<Id> brIds = new set<Id>();
        for(BrandRelationship__c br: scope){
            brIds.add(br.Id);
        }
        
        //BrandRelationshipEventHandler.updateMCEligibility(brIds);

        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN (SELECT PrimaryContact__c FROM BrandRelationship__c WHERE Id IN: brIds)]);
        
        for(BrandRelationship__c br: scope ) {  
      
            String Market = contactMap.get(br.PrimaryContact__c).Market__c;
            Boolean forUpdate = false; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                br.MC_Sync_Eligibility_ANZ__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_ANZ__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_ID){
                br.MC_Sync_Eligibility_ID__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_ID__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_IN){
                br.MC_Sync_Eligibility_IN__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_IN__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_MY){
                br.MC_Sync_Eligibility_MY__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_MY__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_PH){
                br.MC_Sync_Eligibility_PH__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_PH__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_SG){
                br.MC_Sync_Eligibility_SG__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_SG__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_TH){
                br.MC_Sync_Eligibility_TH__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_TH__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_VN){
                br.MC_Sync_Eligibility_VN__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_VN__c;
                forUpdate = true;

            }
            
            if(forUpdate) brToUpdate.add(br);
        }
        
        if(!brToUpdate.isEmpty()) UtilityClass.updateList(brToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}