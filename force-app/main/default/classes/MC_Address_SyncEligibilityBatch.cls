/**
* @author        Jennifer Alviz    
* @date          01.26.2021
* @description   Batch job to update ADDRESS Sync Eligibility Fields
* @revision(s)
*/
global class MC_Address_SyncEligibilityBatch Implements Database.Batchable<sObject> , Database.Stateful{
    
    Set<Id> contactIds = new Set<Id>();
    String queryOverride;
    
    global MC_Address_SyncEligibilityBatch(Set<Id> conIds,String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, ParentContact__c,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'            
            + ' FROM Address__c'
            + ' WHERE'
            + ' ParentContact__c IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Address__c> scope) {
        List<Address__c> addressToUpdate = new List<Address__c>();
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
      	Set<Id> parentContactIds = new Set<Id>();
        for(Address__c address : scope){
            parentContactIds.add(address.ParentContact__c);
        }
        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN :parentContactIds]);
        
        for(Address__c add: scope) {  
                         
            String Market = contactMap.get(add.ParentContact__c).Market__c;
            Boolean forUpdate = true; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                add.MC_Sync_Eligibility_ANZ__c = contactMap.get(add.ParentContact__c).MC_Sync_Eligibility_ANZ__c;
            }else if(Market == CommonConstant.MARKET_ID){
                add.MC_Sync_Eligibility_ID__c = contactMap.get(add.ParentContact__c).MC_Sync_Eligibility_ID__c;
            }else if(Market == CommonConstant.MARKET_IN){
                add.MC_Sync_Eligibility_IN__c = contactMap.get(add.ParentContact__c).MC_Sync_Eligibility_IN__c;
            }else if(Market == CommonConstant.MARKET_MY){
                add.MC_Sync_Eligibility_MY__c = contactMap.get(add.ParentContact__c).MC_Sync_Eligibility_MY__c;
            }else if(Market == CommonConstant.MARKET_PH){
                add.MC_Sync_Eligibility_PH__c = contactMap.get(add.ParentContact__c).MC_Sync_Eligibility_PH__c;
            }else if(Market == CommonConstant.MARKET_SG){
                add.MC_Sync_Eligibility_SG__c = contactMap.get(add.ParentContact__c).MC_Sync_Eligibility_SG__c;
            }else if(Market == CommonConstant.MARKET_TH){
                add.MC_Sync_Eligibility_TH__c = contactMap.get(add.ParentContact__c).MC_Sync_Eligibility_TH__c;
            }else if(Market == CommonConstant.MARKET_VN){
                add.MC_Sync_Eligibility_VN__c = contactMap.get(add.ParentContact__c).MC_Sync_Eligibility_VN__c;
            }else{
                forUpdate = false;
            }
            
            if(forUpdate) addressToUpdate.add(add);
        }
        
        if(!addressToUpdate .isEmpty()) UtilityClass.updateList(addressToUpdate );
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}