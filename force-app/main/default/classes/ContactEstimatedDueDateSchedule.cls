/**
* @author        Rey Austral
* @date          1.14.2019
* @description   Class to execute batch job ContactEstimatedDueDateSchedule
* @revision(s) 
*/
global class ContactEstimatedDueDateSchedule implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        ContactEstimatedDueDateBatch contactBatch = new ContactEstimatedDueDateBatch();
        database.executebatch(contactBatch,200);
    }
}