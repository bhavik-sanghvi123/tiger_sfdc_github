trigger IndividualEmailResultTrigger on et4ae5__IndividualEmailResult__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(UtilityClass.IsTriggerActive('IndividualEmailResultTrigger')) {
        TriggerDispatcher.Run(new IndividualEmailResultTriggerHandler());
    }
}