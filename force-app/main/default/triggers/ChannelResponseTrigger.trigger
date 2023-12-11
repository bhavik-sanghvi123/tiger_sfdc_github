trigger ChannelResponseTrigger on ChannelResponse__c (before insert, after insert, before update, after update, before delete, after delete) {
	
    if(UtilityClass.IsTriggerActive('ChannelResponseTrigger')) {
        TriggerDispatcher.Run(new ChannelResponseTriggerHandler());
    }
}