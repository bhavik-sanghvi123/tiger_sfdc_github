/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Scheduler class for DeactivateRewardsBatch class

History
01/15/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
public class DeactivateRewardsSchedule implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        DeactivateRewardsBatch dr = new DeactivateRewardsBatch();
        database.executebatch(dr, 50);
    }
   
}