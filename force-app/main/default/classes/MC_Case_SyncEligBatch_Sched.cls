public class MC_Case_SyncEligBatch_Sched implements Schedulable {
    
    String newScope = '';
    
    public MC_Case_SyncEligBatch_Sched(String ns){ 
        newScope = ns; 
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new MC_Case_SyncEligibilityBatch(null,newScope), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Case').Batch_Size__c);
      
    }
}