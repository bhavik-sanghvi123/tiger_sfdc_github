/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Scheduler class for DeleteInvalidSocialContacts batch class

History
06/25/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
global class CreateHouseholdForSocialContactsSched implements Schedulable
{
    global void execute(SchedulableContext sc) {
        CreateHouseholdForSocialContactsBatch chfc = new CreateHouseholdForSocialContactsBatch();
        database.executebatch(chfc,200);
    }
   
}