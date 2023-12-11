public class MC_OrderProduct_SyncEligBatch_Sched implements Schedulable {
    
    String newScope = '';
    
    public MC_OrderProduct_SyncEligBatch_Sched(String ns){ 
        newScope = ns; 
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new MC_OrderProduct_SyncEligibilityBatch(null,newScope), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Order_Product').Batch_Size__c);
      
    }
}