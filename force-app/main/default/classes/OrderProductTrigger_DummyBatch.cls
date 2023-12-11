public class OrderProductTrigger_DummyBatch implements Database.Batchable<sObject>, Database.Stateful {
    public OrderProductTrigger_DummyBatch(){}

    public Database.QueryLocator start(Database.BatchableContext BC){
        String queryStr = 'SELECT Id, Status FROM Order WHERE Account.Market__c = \'TW\' AND Status = \'Completed\'';

        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext BC, List<Order> oList){
        Set<Id> orderIds = new set<Id>();
        List<OrderItem> oiRecordsToUpdate = new List<OrderItem>();

        for(Order o: oList) {
            orderIds.add(o.Id);
        }

        List<OrderItem> oiList = [SELECT Id, IsFromTW__c FROM OrderItem WHERE OrderId IN :orderIds AND Product_Family__c = :CommonConstant.ANDPRODUCT];
        
        for(OrderItem oi: oiList) {
            oi.IsFromTW__c = true;

            oiRecordsToUpdate.add(oi);
        }
        
        if(!oiRecordsToUpdate.isEmpty()) Utilityclass.updateList(oiRecordsToUpdate);
    }

    public void finish(Database.BatchableContext BC){}
}