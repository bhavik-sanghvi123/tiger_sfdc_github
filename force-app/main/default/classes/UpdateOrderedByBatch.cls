/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Batch Class to update Order records with no Ordered By value specified on a daily basis

History
04/17/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
global class UpdateOrderedByBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String eId = [SELECT Id, ExternalIdValue__c FROM ExternalId__mdt WHERE DeveloperName = :CommonConstant.PH_ORPHAN_TANGENT_ORDERS].ExternalIdValue__c;

        String query = 'SELECT Id,'
                            + ' OrderedBy__c,'
                            + ' ParentMembership__c,'
                            + ' ParentMembership__r.Contact__c,'
                            + ' Status,'
                            + ' Account.External_Id__c'
                            + ' FROM Order WHERE Account.External_Id__c = :eId AND ParentMembership__r.Contact__c != null';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        List<Order> orderList = new List<Order>();
        List<Order> orderChangeStatusList = new List<Order>();
        List<Order> orderUpdateStatusList = new List<Order>();
        Map<Id,String> orderStatusMap = new Map<Id,String>();

        for(Order orderRec : scope) {
            orderRec.OrderedBy__c = orderRec.ParentMembership__r.Contact__c;
            if (orderRec.Status != CommonConstant.ORDER_STATUS_DRAFT && orderRec.Status != CommonConstant.ORDER_STATUS_CANCELLED_ABANDONED) {
                orderStatusMap.put(orderRec.Id, orderRec.Status);
                orderRec.Status = CommonConstant.ORDER_STATUS_DRAFT;
                orderChangeStatusList.add(orderRec);
            }
            orderList.add(orderRec);
        }

        if(!orderList.isEmpty()) {
            Database.update(orderList, false);
        }

        if(!orderChangeStatusList.isEmpty()) {
            for(Order o : orderChangeStatusList) {
                o.Status = orderStatusMap.get(o.Id);
                orderUpdateStatusList.add(o);
            }
        }

        if(!orderUpdateStatusList.isEmpty()) {
            Database.update(orderUpdateStatusList, false);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}