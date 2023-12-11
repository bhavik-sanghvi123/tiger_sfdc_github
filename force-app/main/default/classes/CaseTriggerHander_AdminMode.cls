public without sharing class CaseTriggerHander_AdminMode {

    public static void removeInOmniChannel(Set<Id> caseIds) {
        DELETE [SELECT Id FROM PendingServiceRouting WHERE WorkItemId IN: caseIds];
    }
}