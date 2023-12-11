/**
* @author        Jennifer Alviz    
* @date          03.25.2021
* @description   Batch job to update Child Contacts Sync Eligibility Fields - for VN
* @revision(s)
*/
global class MC_ChildContact_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    String market;
    Set<Id> contactIds = new Set<Id>();
    String queryOverride;
    
    global MC_ChildContact_SyncEligibilityBatch(String m, Set<Id> conIds,String newScope){
        market = m;
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Parent__c,PrimaryContact__c ,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM Contact'
            + ' WHERE'
            + ' Parent__c != null'
            + ' AND Type__c = \'Child\''
            + ' AND Parent__c IN :contactIds ';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        Map<Id, Contact> parentContactMap = new Map<Id,Contact>();
        List<Contact> conToUpdate = new List<Contact>();
        Set<Id> parentIds = new Set<Id>();
        for(Contact con : scope){
            parentIds.add(con.Parent__c);
        }
        
        parentContactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                                MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                                MC_Sync_Eligibility_VN__c
                                                FROM Contact 
                                                WHERE Id IN :parentIds]);
    
        for(Contact con : scope) {  
                         
            Boolean forUpdate = true; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                con.MC_Sync_Eligibility_ANZ__c = parentContactMap.get(con.Parent__c).MC_Sync_Eligibility_ANZ__c;
            }else if(Market == CommonConstant.MARKET_ID){
                con.MC_Sync_Eligibility_ID__c = parentContactMap.get(con.Parent__c).MC_Sync_Eligibility_ID__c;
            }else if(Market == CommonConstant.MARKET_IN){
                con.MC_Sync_Eligibility_IN__c = parentContactMap.get(con.Parent__c).MC_Sync_Eligibility_IN__c;
            }else if(Market == CommonConstant.MARKET_MY){
                con.MC_Sync_Eligibility_MY__c = parentContactMap.get(con.Parent__c).MC_Sync_Eligibility_MY__c;
            }else if(Market == CommonConstant.MARKET_PH){
                con.MC_Sync_Eligibility_PH__c = parentContactMap.get(con.Parent__c).MC_Sync_Eligibility_PH__c;
            }else if(Market == CommonConstant.MARKET_SG){
                con.MC_Sync_Eligibility_SG__c = parentContactMap.get(con.Parent__c).MC_Sync_Eligibility_SG__c;
            }else if(Market == CommonConstant.MARKET_TH){
                con.MC_Sync_Eligibility_TH__c = parentContactMap.get(con.Parent__c).MC_Sync_Eligibility_TH__c;
            }else if(Market == CommonConstant.MARKET_VN){
                con.MC_Sync_Eligibility_VN__c = parentContactMap.get(con.Parent__c).MC_Sync_Eligibility_VN__c;
            }else{
                forUpdate = false;
            }
            
            if(forUpdate) conToUpdate.add(con);
        }
        if(!conToUpdate.isEmpty()) Utilityclass.updateList(conToUpdate);

    }
    
    global void finish(Database.BatchableContext BC) {
    }
}