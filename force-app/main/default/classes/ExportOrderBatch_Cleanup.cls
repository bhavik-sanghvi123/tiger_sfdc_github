public class ExportOrderBatch_Cleanup implements Database.Batchable<sObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> statusList = new Set<String> {'Submitted','Transferred'};

        String queryStr = 'SELECT Id FROM OrderExport2__c WHERE Order__r.Status NOT IN: statusList';

        if(Test.isRunningTest()){
            queryStr = 'SELECT Id FROM OrderExport2__c';
        }

        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<OrderExport2__c> oList){
        DELETE oList;
    }

    public void finish(Database.BatchableContext BC){}
}