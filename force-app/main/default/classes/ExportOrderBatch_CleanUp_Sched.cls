public class ExportOrderBatch_CleanUp_Sched implements Schedulable {
	public void execute(SchedulableContext SC) {
    	Database.executeBatch(new ExportOrderBatch_Cleanup());
    }
}