/*----------------------------------------------------------------------------------------
Author:      Marc Anthony Bondoc
Description: Scheduler class for UpdatePromotionStatusBatch class

History
02/13/2019   mbondoc   Created
-------------------------------------------------------------------------------------------*/
global class UpdatePromotionStatusSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        UpdatePromotionStatusBatch ucs = new UpdatePromotionStatusBatch();
        database.executebatch(ucs,200); 
    }
   
}