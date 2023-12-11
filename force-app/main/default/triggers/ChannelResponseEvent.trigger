trigger ChannelResponseEvent on ChannelResponse__ChangeEvent (after insert) {
    if(UtilityClass.IsTriggerActive('ChannelResponseTrigger')) {
        ChannelResponseEventHandler.processEvent(trigger.new);
    }
}