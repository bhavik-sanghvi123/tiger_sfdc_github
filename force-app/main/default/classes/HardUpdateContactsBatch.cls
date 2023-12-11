/**
* @author        Jennifer Alviz
* @date          4.6.2021
* @description   Batch job to hard update contact records, so formula field MC_VN_Sync_Eligibility__c will sync latest value on marketing cloud
* @revision(s)

5/11/2021   malviz      One-time use only, commented out entire code
7/15/2021   malviz      TKT-004752: use to force update contacts
*/
global class HardUpdateContactsBatch Implements Database.Batchable<sObject> {
    
    String queryOverride;
    global HardUpdateContactsBatch(String newScope){
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id , MC_VN_Sync_Eligibility__c, Hard_Update__c'                           
            + ' FROM Contact'
            + ' WHERE'
            + ' MC_VN_Sync_Eligibility__c = false'
            + ' AND Market__c = \'VN\'';
            
        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
       
        for(Contact con : scope){
            if (con.Hard_Update__c == false){
                con.Hard_Update__c = true;            
            }else{
                con.Hard_Update__c = false;     
            }
            
        }
        
        if(!scope.isEmpty()) Utilityclass.updateList(scope);
    }

    
    global void finish(Database.BatchableContext BC) {
    }
}