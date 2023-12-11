trigger MembershipTrigger on Membership__c (before insert, after insert, before update, after update) {
	if(UtilityClass.IsTriggerActive('MembershipTrigger')) {
        TriggerDispatcher.Run(new MembershipTriggerHandler());
    }
}