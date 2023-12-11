trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {  
    
    if(UtilityClass.IsTriggerActive('CaseTrigger')) {
        TriggerDispatcher.Run(new CaseTriggerHandler());
    }
}