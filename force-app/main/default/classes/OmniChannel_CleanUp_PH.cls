/**
* @author        Jennifer Alviz
* @date          4.6.2021
* @description   Batch job to remove PH Conversion Calls from previous month in omni-channel
* @revision(s)

*/
global class OmniChannel_CleanUp_PH Implements Database.Batchable<sObject> {
    
    String queryOverride;
    global OmniChannel_CleanUp_PH(String newScope){
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id , Market__c, AutoAssignCalls__c, Status, CallAccepted__c, RelatedBrandRelationship__c,'
            + ' RelatedBrandRelationship__r.FirstTransactionDate__c '                        
            + ' FROM Case'
            + ' WHERE'
            + ' AutoAssignCalls__c = true'
            + ' AND CallAccepted__c = false'
            + ' AND Market__c = \'PH\''
            + ' AND CreatedDate < Today';
            
        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope) {
       
        Set<Id> callsToRemove = new Set<Id>();

        for(Case c : scope){
            // check if call is Conversion
            if(c.RelatedBrandRelationship__r.FirstTransactionDate__c == null){
                callsToRemove.add(c.Id);
            }
            
        }

        List<PendingServiceRouting> psrList = new List<PendingServiceRouting>([SELECT id from PendingServiceRouting WHERE WorkItemId in: callsToRemove]);
        
        if(!scope.isEmpty()) Delete psrList;
    }

    
    global void finish(Database.BatchableContext BC) {
    }
}