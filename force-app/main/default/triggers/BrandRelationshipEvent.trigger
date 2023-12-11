trigger BrandRelationshipEvent on BrandRelationship__ChangeEvent (after insert) {
    if(UtilityClass.IsTriggerActive('BrandRelationshipTrigger')) {
        BrandRelationshipEventHandler.processEvent(trigger.new);
    }
}