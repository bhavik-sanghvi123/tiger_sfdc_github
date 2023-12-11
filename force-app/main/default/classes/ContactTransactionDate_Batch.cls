/*
Author: Jennifer
Description:Updates transaction dates of contacts  that wasn't updated by the Order Trigger when order is completed [Most likely Lock Row issue]
Date:
June 20, 2020 Created
*/
public class ContactTransactionDate_Batch Implements Database.Batchable<sObject> {
    String overrideQuery = '';
    public ContactTransactionDate_Batch(String q) {
        overrideQuery = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT ID, ParentMembership__c,OrderedBy__c, Status '                           
            + ' FROM Order'
            + ' WHERE'
            + ' createddate = TODAY'
            + ' AND Status = \'Completed\''
            + ' AND OrderedBy__c != null'
            + ' AND Createdby.Name = \'Data Integration\'';

        if(overrideQuery != '') {
            query = overrideQuery;
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Order> scope) {
        
        OrderTriggerHelper.updateContactTransactionDate(scope, null);
    }
    public void finish(Database.BatchableContext BC) {}
}