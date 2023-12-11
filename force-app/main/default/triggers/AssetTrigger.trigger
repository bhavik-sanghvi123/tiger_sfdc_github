/*------------------------------------------------------------
Author:      Lee Santos
Description: Trigger for Asset object

History
04/16/2021   lsantos    Created
-------------------------------------------------------------------------------------------*/

trigger AssetTrigger on Asset(before insert, after insert, before update, after update, before delete, after delete) {
    if(UtilityClass.IsTriggerActive('AssetTrigger')) {
        TriggerDispatcher.Run(new AssetTriggerHandler());
    }
}