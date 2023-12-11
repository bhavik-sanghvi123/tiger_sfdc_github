/*------------------------------------------------------------
Author      : Mario Christ
Description : Schedulable class to create membership by calling Dice API

History
18-Oct-2022   Mario Christ   Created class
-------------------------------------------------------------------------------------------*/
global class DiceMembershipCreation_Sched implements Schedulable {
    global void execute(SchedulableContext SC) {
        DiceMembershipCreation_Batch diceBatch = new DiceMembershipCreation_Batch();
        Database.executeBatch(diceBatch, 20);
    }
}