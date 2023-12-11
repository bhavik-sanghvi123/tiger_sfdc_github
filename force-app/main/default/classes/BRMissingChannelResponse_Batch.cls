/*
Author: Jericson
Description: Picks up outlier BR that wasn't updated by CR trigger when populating transaction dates [Most like Lock Row issue]
Test Class in ChannelResponseTriggerHandlerTest.cls
Date:
May 20, 2020 Created
*/
public class BRMissingChannelResponse_Batch Implements Database.Batchable<sObject> {
    String overrideQuery = '';
    public BRMissingChannelResponse_Batch(String q) {
        overrideQuery = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id'                           
            + ' FROM ChannelResponse__c'
            + ' WHERE BrandRelationship__r.FirstChannelResponseDate__c = null'
            + '   AND CreatedBy.Name = \'Data Integration\'';

        if(overrideQuery != '') {
            query = overrideQuery;
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ChannelResponse__c> scope) {
        Set<Id> crIds = new Set<Id>();

        for(ChannelResponse__c cr: scope)
            crIds.add(cr.Id);

        ChannelResponseEventHandler.updateBRandContact(crIds);
    }
    public void finish(Database.BatchableContext BC) {}
}