/*
Author: Jericson Mercado
Description: Deletes all Case with Reminder Status "Closed - Reassigned" for they are spam emails'
*/
public with sharing class EmailToCaseSpamCleanup_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private String market;
    public EmailToCaseSpamCleanup_Batch(String m) { market = m; }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> statusList = new Set<String> {'Closed - Reassigned'};

        String queryStr = 'SELECT Id'
                        +  ' FROM Case'
                        + ' WHERE ReminderStatus__c IN: statusList'
                        +   ' AND Market__c =: market';

        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> cList){
        DELETE cList;
    }

    public void finish(Database.BatchableContext BC){}
}