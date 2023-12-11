/**
* @author        Jennifer Alviz    
* @date          2.8.2021
* @description   Batch job to resync calls to omni-channel backlog, 
                 - agent resigns and calls assigned to them needs to be reassigned to other agents
                 - call routing criteria is updated
* @revision(s)
*/
global class OmniChannelResyncBatch Implements Database.Batchable<sObject> {
    
    String queryOverride;
    Set<Id> caseOwnerIds;
    
    global OmniChannelResyncBatch(Set<Id> ownerIds, String newScope){
        queryOverride = newScope;
        caseOwnerIds =  (Set<Id>) ownerIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<Omnichannel_Cleanup_Status__mdt> OCStatusList = Omnichannel_Cleanup_Status__mdt.getAll().values();
        Set<String> statusLabelList = new Set<String>();
        for(Omnichannel_Cleanup_Status__mdt rec : OCStatusList){
            statusLabelList.add(rec.Label);
        }
        String query = 'SELECT ID,Market__c,CallAccepted__c'                         
            + ' FROM Case'
            + ' WHERE'
            + ' Status NOT IN: statusLabelList'
            + ' AND AutoAssignCalls__c = true'
            + ' AND OwnerId IN :caseOwnerIds'
            + ' ORDER BY CreatedDate asc';
            
        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Case> casesToUpdate = new List<Case>();
        List<Id> casesForRouting = new List<Id>();
        Map<String, String> MCUserMap = new Map<String, String>();
        
        //get ids of MC Connect users
        for(User u: [Select Id, market__c from user where name LIKE 'MC Connect%' ]){
            MCUserMap.put(u.market__c, u.Id);
        }
    
        for(Case c: scope){
                  
            // Uncheck accepted calls
            if(c.CallAccepted__c){
                c.CallAccepted__c = false;
            }
            
            // Reassign calls to MC Connect User
            if(c.Market__c != null){
                c.OwnerId = MCUserMap.get(c.Market__c);
            }
            
            casesToUpdate.add(c);
            casesForRouting.add(c.Id);
        }
        
        
        if(!casesToUpdate.isEmpty()) UtilityClass.updateList(casesToUpdate);
        
        // Delete all matching PSR records 
        DELETE [SELECT Id FROM PendingServiceRouting WHERE WorkItemId IN: casesForRouting];
        
        // Creates new PSR records, calls flow back to Omni-channel
        SkillsBasedRouting.routeUsingSkills(casesForRouting);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}