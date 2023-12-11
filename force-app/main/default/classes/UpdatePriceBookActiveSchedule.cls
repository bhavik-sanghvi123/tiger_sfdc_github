/*----------------------------------------------------------------------------------------
Author:      Marc Anthony Bondoc
Description: Scheduler class for UpdatePriceBookActiveBatch class

History
02/19/2019   mbondoc   Created
-------------------------------------------------------------------------------------------*/
global class UpdatePriceBookActiveSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        UpdatePriceBookActiveBatch ucs = new UpdatePriceBookActiveBatch();
        database.executebatch(ucs,200); 
    }
   
}