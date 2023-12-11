/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Scheduler class for UpdateMembershipDetailsBatch class

History
04/09/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
global class UpdateMembershipDetailsSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        UpdateMembershipDetailsBatch umd = new UpdateMembershipDetailsBatch();
        database.executebatch(umd,200);
    }
}