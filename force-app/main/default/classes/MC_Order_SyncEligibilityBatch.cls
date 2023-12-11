/**
* @author        Jennifer Alviz    
* @date          01.27.2021
* @description   Batch job to update ORDER PRODUCT Sync Eligibility Fields
* @revision(s)
*/
global class MC_Order_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> contactIds = new Set<Id>();
    global Set<Id> orderIds = new set<Id>();
    Set<Id> eligibleContacts = new Set<Id>();
    String queryOverride;

    global MC_Order_SyncEligibilityBatch(Set<Id> conIds, String newScope){
        contactIds =  (Set<Id>) conIds;
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, Orderedby__c ,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                        
            + ' FROM Order'
            + ' WHERE'
            + ' Orderedby__c IN :contactIds';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        } 
            
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
        List<Order> ordersToUpdate = new List<Order>();
        for(Order o: scope){
            orderIds.add(o.Id);
        }
        
        //OrderEventHandler.updateMCEligibility(orderIds);

        contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                        MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                        MC_Sync_Eligibility_VN__c
                                        FROM Contact 
                                        WHERE Id IN (SELECT Orderedby__c FROM Order WHERE Id IN: orderIds)]);
        
        for(Order o: scope ) {  
               
            String Market = contactMap.get(o.Orderedby__c).Market__c;
            Boolean forUpdate = false; 
                    
            if(Market == CommonConstant.MARKET_ANZ){
                o.MC_Sync_Eligibility_ANZ__c = contactMap.get(o.Orderedby__c).MC_Sync_Eligibility_ANZ__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_ID){
                o.MC_Sync_Eligibility_ID__c = contactMap.get(o.Orderedby__c).MC_Sync_Eligibility_ID__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_IN){
                o.MC_Sync_Eligibility_IN__c = contactMap.get(o.Orderedby__c).MC_Sync_Eligibility_IN__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_MY){
                o.MC_Sync_Eligibility_MY__c = contactMap.get(o.Orderedby__c).MC_Sync_Eligibility_MY__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_PH){
                o.MC_Sync_Eligibility_PH__c = contactMap.get(o.Orderedby__c).MC_Sync_Eligibility_PH__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_SG){
                o.MC_Sync_Eligibility_SG__c = contactMap.get(o.Orderedby__c).MC_Sync_Eligibility_SG__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_TH){
                o.MC_Sync_Eligibility_TH__c = contactMap.get(o.Orderedby__c).MC_Sync_Eligibility_TH__c;
                forUpdate = true;

            }else if(Market == CommonConstant.MARKET_VN){
                o.MC_Sync_Eligibility_VN__c = contactMap.get(o.Orderedby__c).MC_Sync_Eligibility_VN__c;
                forUpdate = true;

            }
            
            if(forUpdate) ordersToUpdate.add(o);
        }
        
        if(!ordersToUpdate.isEmpty()) UtilityClass.updateList(ordersToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
         if(!orderIds.isEmpty()){
            Database.executebatch(new MC_OrderProduct_SyncEligibilityBatch(orderIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Order_Product').Batch_Size__c);
         }
    }
}