/*
Author: Jennifer
Description: One-time batch to update Household's primary contact details
Date:
June 20, 2020 Created
*/
public class UpdateHouseholdDetails_Batch Implements Database.Batchable<sObject> {
    String overrideQuery = '';
    public UpdateHouseholdDetails_Batch(String q) {
        overrideQuery = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT ID, PrimaryContact__c,AccountId'                           
            + ' FROM Contact'
            + ' WHERE'
            + ' PrimaryContact__c = true'
            + ' AND Account.NumberofPrimaryContacts__c = 0';

        if(overrideQuery != '') {
            query = overrideQuery;
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        
        Set<Id> conIds = new Set<Id>();
        for(Contact con: scope){
            conIds.add(con.Id);
        }
        if(!conIds.isEmpty()) ContactEventHandler.updateAccountTrackingFields(conIds);
    }
    public void finish(Database.BatchableContext BC) {}
}