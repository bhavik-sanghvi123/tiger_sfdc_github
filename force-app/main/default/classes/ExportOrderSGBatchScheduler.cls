/*----------------------------------------------------------------------------------------
Author:      Rey Austral
Description: Scheduler class for ExportOrderSGBatch batch class

History
08/19/2019   raustral   Created
-------------------------------------------------------------------------------------------*/
global class ExportOrderSGBatchScheduler implements Schedulable
{
    global void execute(SchedulableContext sc) {
        ExportOrderSGBatch eo = new ExportOrderSGBatch();
        database.executebatch(eo,5000);
    }
   
}