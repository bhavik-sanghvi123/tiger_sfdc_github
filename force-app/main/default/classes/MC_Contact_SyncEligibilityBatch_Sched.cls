public class MC_Contact_SyncEligibilityBatch_Sched implements Schedulable {
    
    String market = '';
    Integer months = 0;
    String newScope = '';
    public MC_Contact_SyncEligibilityBatch_Sched(String m, Integer n){ 
        market = m; 
        months = n; 
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new MC_Contact_SyncEligibilityBatch(market,months,newScope),50);
    }
}