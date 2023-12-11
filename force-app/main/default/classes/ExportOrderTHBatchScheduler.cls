/*----------------------------------------------------------------------------------------
Author:      Rey Austral
Description: Scheduler class for ExportOrderTHBatch batch class

History
09/30/2019   raustral   Created
-------------------------------------------------------------------------------------------*/
global class ExportOrderTHBatchScheduler implements Schedulable
{
    global void execute(SchedulableContext sc) {
        ExportOrderTHBatch eo = new ExportOrderTHBatch('TH');
        database.executebatch(eo,2000); 
    }
}