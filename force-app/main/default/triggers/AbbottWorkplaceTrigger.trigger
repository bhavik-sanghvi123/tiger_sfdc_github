/**
* @author        Ezzel Montesa
* @date          01.08.2021
* @description   Trigger Class for Abbott Workplace Object
* @revision(s)
*/
trigger AbbottWorkplaceTrigger on AbbottWorkplace__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(UtilityClass.IsTriggerActive('AbbottWorkplaceTrigger')) {
        TriggerDispatcher.Run(new AbbottWorkplaceTriggerHandler());
    }
}