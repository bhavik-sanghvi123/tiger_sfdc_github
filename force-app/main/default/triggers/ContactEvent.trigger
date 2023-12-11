trigger ContactEvent on ContactChangeEvent (after insert) {
    if(UtilityClass.IsTriggerActive('ContactTrigger')) {
        ContactEventHandler.processEvent(trigger.new);
    }
}