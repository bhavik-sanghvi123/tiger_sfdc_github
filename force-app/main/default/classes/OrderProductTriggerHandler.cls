/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Handler class for Order Product object
                  - Auto-populates Promotion derived from Promotion Item
History
01/23/2019   vmirandilla    Created
08/23/2019   raustral       added partialOrderStatusUpdate (TKT-001166)
05/28/2020   jericson       filters the records to be thrown to the helper class
10/28/2020	 malviz			added updateMembership (TKT-002646)
08/20/2021   scordova       Added function call to checkPaidSampleProductOrdered inside BeforeInsert function
09/07/2021   scordova       Added function call to updateContactPurchasedTWPEDStandardProduct inside AfterInsert function

11/3/2021    navalencia     Comment out function call of getTransactionLastTwoYears,getTransactionAnniversaryLastTwoYears
-------------------------------------------------------------------------------------------*/

public class OrderProductTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) {
        OrderProductTriggerHelper.getPromotion(newList);
        OrderProductTriggerHelper.checkPaidSampleProductOrdered(newList);
        OrderProductTriggerHelper.getProductInfo(newList, null);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
        OrderProductTriggerHelper.getPromotion(newList);
        OrderProductTriggerHelper.getProductInfo(newList, oldMapItems);
    }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){
        Map<Id,Order> callOrdersMap = OrderProductTriggerHelper.getCallOrders(newList); // get all order with related to call
        Map<Id, Order> orderMembershipMap = OrderProductTriggerHelper.getOrderMemberships(newList);// get all PH orders with memberships
        
        //OrderProductTriggerHelper.getTransactionLastTwoYears(newList);//Added by Aswanth Aravapalli 
        //OrderProductTriggerHelper.getTransactionAnniversaryLastTwoYears(newList);//Added by Aswanth Aravapalli
        Set<Id> caseIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> membershipIds = new Set<Id>();
        Set<Id> oProductIds = new Set<Id>();
        Map<Id, Id> orderProductMap = new Map<Id, Id>();
        
        
        for(OrderItem oi: (List<OrderItem>) newList){
            if(callOrdersMap.containsKey(oi.OrderId)
                && oi.Category__c != null){
                caseIds.add(callOrdersMap.get(oi.OrderId).Case__c);
                productIds.add(oi.Product2Id);
            }
            
            if(orderMembershipMap.containsKey(oi.OrderId)){
                membershipIds.add(orderMembershipMap.get(oi.OrderId).ParentMembership__c);
                oProductIds.add(oi.Product2Id);
                orderProductMap.put(oi.OrderId,oi.Product2Id);
            }
        }

        
        if(!caseIds.isEmpty()) OrderProductTriggerHelper.updateCallOrderInfo(caseIds, productIds);
        if(!membershipIds.isEmpty()) OrderProductTriggerHelper.updateMembership(membershipIds,oProductIds, orderProductMap);

        // OrderProductTriggerHelper.updateContactPurchasedTWPEDStandardProduct(newList);
    }

    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        //OrderProductTriggerHelper.getTransactionLastTwoYears(newList);//Added by Aswanth Aravapalli
        //OrderProductTriggerHelper.getTransactionAnniversaryLastTwoYears(newList);//Added by Aswanth Aravapalli
        Map<Id,Order> callOrdersMap = OrderProductTriggerHelper.getCallOrders(newList); // get all order with related to call
        Set<Id> caseIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        
        Set<Id> partialOrderStatusUpdateIds = new Set<Id>();
        
        for(OrderItem oi: (List<OrderItem>) newList){
            OrderItem old = (OrderItem) oldMapItems.get(oi.Id);
            if(callOrdersMap.containsKey(oi.OrderId)
                && (oi.Category__c != old.Category__c
                    || oi.Quantity != old.Quantity)) {
                caseIds.add(callOrdersMap.get(oi.OrderId).Case__c);
                productIds.add(oi.Product2Id);
            }

            if (oi.Status__c != old.Status__c)
                partialOrderStatusUpdateIds.add(oi.OrderId);
        }

        if(!caseIds.isEmpty()) OrderProductTriggerHelper.updateCallOrderInfo(caseIds, productIds);
        if(!partialOrderStatusUpdateIds.isEmpty()) OrderProductTriggerHelper.updateOrderStatus(partialOrderStatusUpdateIds);

        // OrderProductTriggerHelper.updateContactPurchasedTWPEDStandardProduct(newList);
    }

    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        OrderProductTriggerHelper.getTransactionLastTwoYears(oldList);//Added by Aswanth Aravapalli
        OrderProductTriggerHelper.getTransactionAnniversaryLastTwoYears(oldList);//Added by Aswanth Aravapalli
    }
}