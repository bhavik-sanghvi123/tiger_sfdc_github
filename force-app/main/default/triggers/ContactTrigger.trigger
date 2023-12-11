/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Trigger for Contact object

History
01/08/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/

trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete) {
    
    if(UtilityClass.IsTriggerActive('ContactTrigger')) {
        TriggerDispatcher.Run(new ContactTriggerHandler());
    }
}