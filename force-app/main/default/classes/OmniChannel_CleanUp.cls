/*
Author: Jericson Mercado
Description: Removes all Completed and Cancelled cases that are still in the omni channel backlogs. To ensure agents are getting case to work to.
Runs Daily at 6AM to ensure agents will have new ones assigned for the day.

Test class in CaseTriggerHandlerTest
*/
public class OmniChannel_CleanUp implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        List<Omnichannel_Cleanup_Status__mdt> OCStatusList = Omnichannel_Cleanup_Status__mdt.getAll().values();
        Integer omniCleanupDays = Integer.valueOf(System.Label.Omnichannel_Cleanup_Days);
        Set<String> statusLabelList = new Set<String>();
        for(Omnichannel_Cleanup_Status__mdt rec : OCStatusList){
            statusLabelList.add(rec.Label);
        }
        String queryStr = 'SELECT Id'
                        + ' FROM PendingServiceRouting'
                        + ' WHERE RoutingType = \'SkillsBased\' AND'
                        + ' (WorkItem.status IN: statusLabelList OR Workitem.CallAccepted__c = true OR CreatedDate < Last_N_Days: ' + omniCleanupDays + ')';

        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Sobject> sList){
        Database.delete(sList, false);
    }

    public void finish(Database.BatchableContext BC){}
}