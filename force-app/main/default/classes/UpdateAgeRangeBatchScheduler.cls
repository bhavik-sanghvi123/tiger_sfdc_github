/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Scheduler class for UpdateAgeRangeBatch class

History
11/07/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
global class UpdateAgeRangeBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateAgeRangeBatch uarb = new UpdateAgeRangeBatch();
        database.executebatch(uarb,200);
    }
}