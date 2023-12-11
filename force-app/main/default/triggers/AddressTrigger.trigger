/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Trigger for Address object

History
01/18/2019   vmirandilla    Created
-------------------------------------------------------------------------------------------*/

trigger AddressTrigger on Address__c (before insert, after insert, before update, after update, before delete, after delete) {
	
    if(UtilityClass.IsTriggerActive('AddressTrigger')) {
        TriggerDispatcher.Run(new AddressTriggerHandler());
    }
}