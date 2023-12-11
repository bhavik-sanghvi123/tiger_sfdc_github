trigger AgentWorkTrigger on AgentWork (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	
    if(UtilityClass.IsTriggerActive('AgentWorkTrigger')) {
		TriggerDispatcher.Run(new AgentWorkTriggerHandler());
    }
}