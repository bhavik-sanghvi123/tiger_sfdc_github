/***********************************************************************
* @author        Monika Parihar    
* @date          8/10/2021
* @description   Schedular class for Batch MC_Contact_SyncEligibilityTWBatch
* @revision(s)
**************************************************************************/

public class MC_Contact_SyncEligibilityTWBatch_Sched implements Schedulable {
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new MC_Contact_SyncEligibilityTWBatch(),20);
    }
}