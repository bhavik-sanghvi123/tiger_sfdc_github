/*----------------------------------------------------------------------------------------
Author:      Jennifer Alviz
Description: Scheduler class for MembershipNumberOfTransactionsBatch class

History
6/26/2020   malviz   Created
-------------------------------------------------------------------------------------------*/
global class MembershipNumberOfTransactions_Sched implements Schedulable{
    global void execute(SchedulableContext sc){
        MembershipNumberOfTransactionsBatch umd = new MembershipNumberOfTransactionsBatch();
        database.executebatch(umd,200);
    }
}