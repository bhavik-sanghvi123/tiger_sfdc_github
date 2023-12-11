/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Scheduler class for ExperianAddressValidationBatch class

History
08/02/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
global class ExperianAddressValidationSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ExperianAddressValidationBatch eav = new ExperianAddressValidationBatch();
        database.executebatch(eav,50);
    }
   
}