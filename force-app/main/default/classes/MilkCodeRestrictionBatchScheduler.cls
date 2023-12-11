/**
* @author        Rey Austral
* @date          1.17.2019
* @description   Class to execute batch job MilkCodeRestrictionBatchScheduler
* @testClass     MilkCodeRestrictionBatchTest
* @revision(s) 
*/
global class MilkCodeRestrictionBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		MilkCodeRestrictionBatch b = new MilkCodeRestrictionBatch();
		database.executebatch(b, 200);
	}
}