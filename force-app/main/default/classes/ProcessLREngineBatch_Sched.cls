public class ProcessLREngineBatch_Sched implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        
        List<LookupRollupSummary__mdt> lrSummary = [SELECT ChildFieldname__c,ChildObject__c,ParentFieldname__c,ParentObject__c,Query__c,History_Filter__c,
                                                    RollupFieldname__c, RollupOperation__c,No_of_Days__c FROM LookupRollupSummary__mdt WHERE Is_Active__c=true];
        
        Database.executebatch(new ProcessLREngineBatch(lrSummary));

    }
    

}