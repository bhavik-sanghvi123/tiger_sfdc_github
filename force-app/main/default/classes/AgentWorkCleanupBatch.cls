/**
* @author        Rey Austral
* @date          11.06.2019
* @description   Batch job to run daily to delete old records
* @testClass     AgentWorkCleanupBatchTest
* @revision(s)
*/
global class AgentWorkCleanupBatch implements Database.Batchable<sObject> {	
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		

        String query = 'select Id from AgentWork where createddate < last_n_days:14 and Status not in (\'Assigned\',\'Opened\') ';
        return Database.getQueryLocator(query);
    }

   	global void execute(Database.BatchableContext BC, List<AgentWork> scope) { Delete scope; } 	
    
	global void finish(Database.BatchableContext BC) {
		
	}
	
}