/**
* @author        Rey Austral
* @date          1.17.2019
* @description   Class to execute batch job MilkCodeNonRestrictionBatch
* @testClass     MilkCodeNonRestrictionBatchTest
* @revision(s) 
*/
global class MilkCodeNonRestrictionBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		MilkCodeNonRestrictionBatch b = new MilkCodeNonRestrictionBatch();
		database.executebatch(b, 200);
	}
}