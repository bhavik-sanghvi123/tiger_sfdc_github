/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Scheduler class for DeleteInvalidSocialContacts batch class

History
06/25/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
global class DeleteInvalidSocialContactsScheduler implements Schedulable
{
    global void execute(SchedulableContext sc) {
        DeleteInvalidSocialContactsBatch disc = new DeleteInvalidSocialContactsBatch();
        database.executebatch(disc,200);
    }
   
}