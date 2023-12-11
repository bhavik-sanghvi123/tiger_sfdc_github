/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Scheduler class for ProcessSampleOrderBatch class

History
06/25/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
global class ProcessSampleOrderScheduler implements Schedulable
{
    global void execute(SchedulableContext sc) {
        ProcessSampleOrderBatch psob = new ProcessSampleOrderBatch();
        database.executebatch(psob,200);
    }
   
}