public class MC_Address_SyncEligBatch_Sched implements Schedulable {
    
    String newScope = '';
    
    public MC_Address_SyncEligBatch_Sched(String ns){ 
        newScope = ns; 
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new MC_Address_SyncEligibilityBatch(null,newScope), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Address').Batch_Size__c);
      
    }
}