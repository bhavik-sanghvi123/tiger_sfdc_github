/*----------------------------------------------------------------------------------------
Author:      Crissar Ibarra
Description: Scheduler class for ExportSampleRequestOrderBatch batch class

History
08/22/2019   cibarra Created
-------------------------------------------------------------------------------------------*/
global class ExportSampleRequestOrderBatchScheduler implements Schedulable
{
    global void execute(SchedulableContext sc) {
        ExportSampleRequestOrderBatch esro = new ExportSampleRequestOrderBatch();
        database.executebatch(esro,5000);
    }
}