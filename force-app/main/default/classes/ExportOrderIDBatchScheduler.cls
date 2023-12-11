/*----------------------------------------------------------------------------------------
Author:      Jericson Mercado
Description: Scheduler class for TH Order Export

History
04/28/2020   Jericson   Created
-------------------------------------------------------------------------------------------*/
global class ExportOrderIDBatchScheduler implements Schedulable
{
    global void execute(SchedulableContext sc) {
        ExportOrderTHBatch eo = new ExportOrderTHBatch('ID');
        database.executebatch(eo,2000); 
    }
}