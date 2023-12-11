public class OmniChannel_CleanUp_Sched implements Schedulable {
	public void execute(SchedulableContext SC) {
    	Database.executeBatch(new OmniChannel_CleanUp());
    }
}