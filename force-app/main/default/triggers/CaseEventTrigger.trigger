trigger CaseEventTrigger on CaseChangeEvent (after insert) {
    if(UtilityClass.IsTriggerActive('CaseTrigger')) {
        CaseEventHandler.processEvent(Trigger.new);
    }
}