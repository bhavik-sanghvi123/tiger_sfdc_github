/*------------------------------------------------------------
Author:      Lee Santos
Description: Trigger for AssetService object

History
04/16/2021   lsantos    Created
-------------------------------------------------------------------------------------------*/

trigger AssetServiceTrigger on Asset_Service__c(before insert, after insert, before update, after update, before delete, after delete) {
    if(UtilityClass.IsTriggerActive('AssetServiceTrigger')) {
        TriggerDispatcher.Run(new AssetServiceTriggerHandler());
    }
}