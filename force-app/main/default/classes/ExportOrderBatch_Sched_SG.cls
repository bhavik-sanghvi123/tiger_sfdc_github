public class ExportOrderBatch_Sched_SG implements Schedulable {
	public void execute(SchedulableContext SC) {       
    	Database.executeBatch(new ExportOrderBatch('SG', false));
    }
}