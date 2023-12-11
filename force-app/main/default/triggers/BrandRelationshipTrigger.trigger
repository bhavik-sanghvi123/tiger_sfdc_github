trigger BrandRelationshipTrigger on BrandRelationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {	
	
    if(UtilityClass.IsTriggerActive('BrandRelationshipTrigger')) {
		  TriggerDispatcher.Run(new BrandRelationshipTriggerHandler());
    }
}