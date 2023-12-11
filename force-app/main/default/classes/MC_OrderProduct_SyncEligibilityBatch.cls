/**
* @author        Jennifer Alviz    
* @date          01.27.2021
* @description   Batch job to update ORDER PRODUCT Sync Eligibility Fields
* @revision(s)
*/
global class MC_OrderProduct_SyncEligibilityBatch Implements Database.Batchable<sObject> , Database.Stateful {
    
    global Set<Id> orderIds= new Set<Id>();
    String queryOverride;
    
    global MC_OrderProduct_SyncEligibilityBatch(Set<Id> oIds,String newScope){
        orderIds = (Set<Id>) oIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, OrderId,' 
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM OrderItem'
            + ' WHERE'
            + ' OrderId IN :orderIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        } 

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderItem> scope) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, Order> orderMap = new Map<Id, Order>();
        List<OrderItem> oiToUpdate = new List<OrderItem>();
        set<Id> orderIdSet = new Set<Id>();
        for(OrderItem oi : scope){
            orderIdSet.add(oi.OrderId);
        }
        contactMap = new Map<Id, Contact>([Select Id, Market__c FROM Contact WHERE Id IN (SELECT Orderedby__c FROM Order WHERE Id IN :orderIdSet)]);
        
        orderMap = new Map<Id, Order>([Select Id,Orderedby__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,
                                                     MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,MC_Sync_Eligibility_VN__c
                                                     FROM Order
                                                     WHERE Id IN :orderIdSet]);
                                                     
        for(OrderItem oi: scope) {  
            Id conId = orderMap.get(oi.OrderId).Orderedby__c;             
            String Market = contactMap.get(conId).Market__c;
            Boolean forUpdate = true; 
                         
            if(Market == CommonConstant.MARKET_ANZ){
                oi.MC_Sync_Eligibility_ANZ__c = orderMap.get(oi.OrderId).MC_Sync_Eligibility_ANZ__c;
            }else if(Market == CommonConstant.MARKET_ID){
                oi.MC_Sync_Eligibility_ID__c = orderMap.get(oi.OrderId).MC_Sync_Eligibility_ID__c;
            }else if(Market == CommonConstant.MARKET_IN){
                oi.MC_Sync_Eligibility_IN__c = orderMap.get(oi.OrderId).MC_Sync_Eligibility_IN__c;
            }else if(Market == CommonConstant.MARKET_MY){
                oi.MC_Sync_Eligibility_MY__c = orderMap.get(oi.OrderId).MC_Sync_Eligibility_MY__c;
            }else if(Market == CommonConstant.MARKET_PH){
                oi.MC_Sync_Eligibility_PH__c = orderMap.get(oi.OrderId).MC_Sync_Eligibility_PH__c;
            }else if(Market == CommonConstant.MARKET_SG){
                oi.MC_Sync_Eligibility_SG__c = orderMap.get(oi.OrderId).MC_Sync_Eligibility_SG__c;
            }else if(Market == CommonConstant.MARKET_TH){
                oi.MC_Sync_Eligibility_TH__c = orderMap.get(oi.OrderId).MC_Sync_Eligibility_TH__c;
            }else if(Market == CommonConstant.MARKET_VN){
                oi.MC_Sync_Eligibility_VN__c = orderMap.get(oi.OrderId).MC_Sync_Eligibility_VN__c;
            }else{
                forUpdate = false;
            }
            
            if(forUpdate) oiToUpdate.add(oi);
        }
        
        if(!oiToUpdate.isEmpty()) UtilityClass.updateList(oiToUpdate);

    }
    
    global void finish(Database.BatchableContext BC) {
    }
}