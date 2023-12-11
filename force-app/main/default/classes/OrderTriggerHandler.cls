/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Handler class for Address object
                  - Auto-populates Household derived from current Contact's Household value
History
01/31/2019   vmirandilla    Created
02/19/2019   RAustral       Added updateContactTransactionDate
02/20/2019   RAustral       Added updateBrandRelationship
05/28/2020   jericson       moved after logics to change event. update to membership will be handled by existing batch job
07/20/2020   malviz         bypass delete when To be Archived is true
06/07/2021   scordova       Added cloneOrder function call inside AfterUpdate function.
06/16/2021   scordova       Added cloneOrderItem function call inside AfterInsert function.
06/18/2021   scordova       Added updateSubcriptionOrderCheckbox function call inside BeforeUpdate function.
06/22/2021   scordova       Removed updateSubcriptionOrderCheckbox function call inside BeforeUpdate function as it is now
                            called within the updateOrderRecord function.
06/28/2021   scordova       Added new function calls to cloneOrder and cloneOredItem to accomodate the new Follow-up Bulk Orders feature.
07/19/2021   scordova       Added new function call to updateContactHavePurchasedSample inside AfterUpdate function.
10/11/2021   scordova       Removed cloneOrderItem function call for Follow-up Bulk Orders from AfterInsert function.

10/27/2021   navalencia     added getTransactionLastTwoYears,getTransactionAnniversaryLastTwoYears function in AfterUpdate function
-------------------------------------------------------------------------------------------*/

public class OrderTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) {
        OrderTriggerHelper.updateOrderRecord(newList, null);    
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
        OrderTriggerHelper.updateOrderRecord(newList, oldMapItems);
        OrderTriggerHelper.cloneOrder(newList, 'Follow-up Bulk Orders');
    }

    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ 
        List<Order> oldORder = (List<Order>) oldList;
        List<Order> orderToProcess = new List<Order>();
       
        for(Order o: oldOrder ){
           If(o.To_be_Archived__c == false){
               orderToProcess.add(o);
           }
        }
        
        if(!orderToProcess.isEmpty()) OrderTriggerHelper.orderCountDelete(orderToProcess,null);
    }

    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
        // OrderTriggerHelper.updateContactTransactionDate(newList, null);
        // OrderTriggerHelper.orderCount(newList,null);
        OrderTriggerHelper.cloneOrderItem(newList, 'Subscription Order');
    }

    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        //OrderTriggerHelper.updateContactTransactionDate(newList, oldMapItems);
        // OrderTriggerHelper.updateBrandRelationship(newList, oldMapItems);
        OrderTriggerHelper.cloneOrder(newList, 'Subscription Order');
        OrderTriggerHelper.updateContactHavePurchasedSample(newList);
        OrderTriggerHelper.updateContactPurchasedTWPEDStandardProduct(newList);
        
        //added by narence valencia
        OrderTriggerHelper.getTransactionLastTwoYears(newList,oldMapItems);
        //OrderTriggerHelper.getTransactionAnniversaryLastTwoYears(newList,oldList);
    }

    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        List<Order> oldORder = (List<Order>) oldList;
        List<Order> orderToProcess = new List<Order>();
       
        for(Order o: oldOrder ){
           If(o.To_be_Archived__c == false){
               orderToProcess.add(o);
           }
        }
        
        if(!orderToProcess.isEmpty()) OrderTriggerHelper.updateContactTransactionDate(orderToProcess, null);
    }
}