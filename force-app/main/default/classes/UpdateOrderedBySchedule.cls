/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Scheduler class for UpdateOrderedByBatch class

History
04/17/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
global class UpdateOrderedBySchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        UpdateOrderedByBatch uob = new UpdateOrderedByBatch();
        database.executebatch(uob,10);
    }
   
}