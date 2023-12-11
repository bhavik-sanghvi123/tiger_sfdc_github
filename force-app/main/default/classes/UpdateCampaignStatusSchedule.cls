/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Scheduler class for UpdateCampaignStatusBatch class

History
01/10/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
global class UpdateCampaignStatusSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        UpdateCampaignStatusBatch ucs = new UpdateCampaignStatusBatch();
        database.executebatch(ucs,200);
    }
   
}