/**
* @author        Jennifer Alviz
* @date          8.11.2020
* @description   Class to execute batch job ContactEstimatedDueDateBatch_VN
* @revision(s) 
*/
global class ContactEstimatedDueDate_VN_Sched implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        ContactEstimatedDueDateBatch_VN contactBatchVN = new ContactEstimatedDueDateBatch_VN();
        database.executebatch(contactBatchVN ,200);
    }
}