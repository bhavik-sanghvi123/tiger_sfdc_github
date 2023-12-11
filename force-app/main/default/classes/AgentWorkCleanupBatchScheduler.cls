/**
* @author        Rey Austral
* @date          11.06.2019
* @description   Class to execute batch job AgentWorkCleanupBatch
* @testClass     AgentWorkCleanupBatchTest
* @revision(s) 
*/
global class AgentWorkCleanupBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		AgentWorkCleanupBatch b = new AgentWorkCleanupBatch();
		database.executebatch(b, 1000);
	}
}