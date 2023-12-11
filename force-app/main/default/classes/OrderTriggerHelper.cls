/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Helper class for Order object

History
01/31/2019   vmirandilla    Created
02/19/2019   RAustral       Added updateContactTransactionDate
02/20/2019   RAustral       Added updateBrandRelationship
03/12/2019   mbondoc        Added orderCount
03/12/2019   mbondoc        Added orderCountDelete
04/09/2019   vmirandilla    Update updateContactTransactionDate to add the logic on Membership tracking fields.
06/17/2019   vmirandilla    Update updateOrderRecord: add logic to populate Order's Channel.
                            Added getRelatedCampaign
06/21/2019   vmirandilla    Added validatePreferredDeliveryTime to determin valid Preferred Delivery Date
06/07/2021   scordova       Added cloneOrder and cloneOrderProcess to clone the parent Order record if it is 
                            marked as a Subscription Order.
06/11/2021   scordova       Added generateOrderExportFile to generate a CSV file based on the Order record.
06/16/2021   scordova       Added cloneOrderItem and cloneOrderItemsProcess to clone the parent Order record's
                            Order Products and link them to the to the cloned Orders if it is marked as a
                            Subscription Order.
06/18/2021   scordova       Added updateSubcriptionOrderCheckbox function. It updates the Subscription Order? checkbox to true if
                            both the Frequency and Delivery Patter fields are populated.
06/22/2021   scordova       Made updateSubcriptionOrderCheckbox function private and called in updateOrderRecord function.
06/28/2021   scordova       Updated cloneOrder, cloneOrderProceess, cloneOrderItem, and cloneOrderItemProcess functions to accomodate the Follow-up Bulk Orders feature.
07/01/2021   scordova       Added isOfOrderTypeTeleSales, retrieveOrderItemRecords, retrieveAccountRecord, retrieveProductRecord, assignOrderIdToOrderItem,
                            computeOrderItemQuantity, computeDaysTillNextCallFromLastOrder, and convertStringMultiplierToInteger functions.
07/29/2021   scordova       Converted the most of the List SObjects to Map to reduce governor limit usage.
                            Added the updateStatusToSubmitted function. It updated the Order Status to Submitted if conditions are met.
08/03/2021   mparihar       Updated updateContactTransactionDate method (added check for TW Market)
08/19/2021   scordova       Added updateContactHavePurchasedSample and retrieveContactRecords functions
09/24/2021   scordova       Removed isOfOrderTypeTeleSales function, retrieveStandardPricebookEntryRecords, and added updateContactPurchasedTWPEDStandardProduct function
10/11/2021   scordova       Removed the logic for the cloning of Follow-up Bulk Orders

10/27/2021   navalencia     Added Total_Purchase_Amount_Adult_Brand__c,Total_Purchase_Anniversary_Amount_Adult__c logic
11/03/2021   navalencia     Modify Logic for Total_Purchase_Amount_Adult_Brand__c,Total_Purchase_Anniversary_Amount_Adult__c 
-------------------------------------------------------------------------------------------*/

public class OrderTriggerHelper {
    
    /* This method will get the Contact's Household value to auto-populates Order's Household field
    */
    public static void updateOrderRecord(List<Order> orderList, Map<Id, sObject> oldOrderMap) {

        // check if there is a membership and assign its contact to the order
        Map<Id,Membership__c> membershipMap = getRelatedMembership(orderList);
        Set<Id> campaignIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Order o : orderList) {
            if(o.ParentMembership__c != null
                && membershipMap.get(o.ParentMembership__c).Contact__c != null) {
                o.OrderedBy__c = membershipMap.get(o.ParentMembership__c).Contact__c;
            }
            if(o.OrderedBy__c != null) {
                contactIds.add(o.OrderedBy__c);
            }
            if(o.RelatedCampaign__c != null) {
                campaignIds.add(o.RelatedCampaign__c);
            }

            if(Trigger.isUpdate) {
                Order old = (Order) oldOrderMap.get(o.Id);
                if(o.OrderedBy__c != old.OrderedBy__c
                    && old.OrderedBy__c != null)
                    o.OrderedBy_old__c = old.OrderedBy__c;
            }
        }

        Map<Id,Contact> conMap = getRelatedContact(contactIds);
        Map<Id,Campaign> campaignMap = getRelatedCampaign(campaignIds);
        List<AffiliateMetadata__mdt> amList = [SELECT MasterLabel, PreferredDeliveryDateWaitTime__c FROM AffiliateMetadata__mdt];
        Map<String, String> acs = UtilityClass.convertObjToMap(amList, CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_PREFERREDDELIVERYDATE);
        String userMarket = [SELECT Id, Market__c FROM User WHERE Id =: userInfo.getUserId()].Market__c;
        String waitTime = acs.get(userMarket);
		String userProfile = [SELECT Id, Profile.name FROM User WHERE Id =: userInfo.getUserId()].profile.name;


        for(Order o : orderList) {
            if(conMap.containsKey(o.OrderedBy__c)) {
                o.AccountId= conMap.get(o.OrderedBy__c).AccountId;
            }

            if (trigger.isInsert) {
                if(o.RelatedCampaign__c != null) {
                    o.Channel__c = campaignMap.get(o.RelatedCampaign__c).Channel__c;
                }
                if(userProfile != CommonConstant.PROFILE_ADMIN && o.PreferredDeliveryDate__c != null) {
                    validatePreferredDeliveryTime(o, waitTime);
                }

                //update MC Eligibility filter
                if(o.OrderedBy__c != null) {
                    String market = conMap.get(o.Orderedby__c).Market__c;
                    
                    if(Market == CommonConstant.MARKET_ANZ){
                        o.MC_Sync_Eligibility_ANZ__c = conMap.get(o.Orderedby__c).MC_Sync_Eligibility_ANZ__c;
                    }else if(Market == CommonConstant.MARKET_ID){
                        o.MC_Sync_Eligibility_ID__c = conMap.get(o.Orderedby__c).MC_Sync_Eligibility_ID__c;
                    }else if(Market == CommonConstant.MARKET_IN){
                        o.MC_Sync_Eligibility_IN__c = conMap.get(o.Orderedby__c).MC_Sync_Eligibility_IN__c;
                    }else if(Market == CommonConstant.MARKET_MY){
                        o.MC_Sync_Eligibility_MY__c = conMap.get(o.Orderedby__c).MC_Sync_Eligibility_MY__c;
                    }else if(Market == CommonConstant.MARKET_PH){
                        o.MC_Sync_Eligibility_PH__c = conMap.get(o.Orderedby__c).MC_Sync_Eligibility_PH__c;
                    }else if(Market == CommonConstant.MARKET_SG){
                        o.MC_Sync_Eligibility_SG__c = conMap.get(o.Orderedby__c).MC_Sync_Eligibility_SG__c;
                    }else if(Market == CommonConstant.MARKET_TH){
                        o.MC_Sync_Eligibility_TH__c = conMap.get(o.Orderedby__c).MC_Sync_Eligibility_TH__c;
                    }else if(Market == CommonConstant.MARKET_VN){
                        o.MC_Sync_Eligibility_VN__c = conMap.get(o.Orderedby__c).MC_Sync_Eligibility_VN__c;
                    }
                }
                
            }

            if (trigger.isUpdate) {
                Order oldOrder = (Order) oldOrderMap.get(o.Id);
                if(o.Status != oldOrder.Status) {
                    List<String> cancelledOrderStatusList = getCancelledOrderStatus();
                    if(!cancelledOrderStatusList.contains(o.Status) && cancelledOrderStatusList.contains(oldOrder.Status)) {
                        o.OrderCacellationReason__c = null;
                    }
                }
                if(o.RelatedCampaign__c != oldOrder.RelatedCampaign__c) {
                    if(o.RelatedCampaign__c != null) {
                        o.Channel__c = campaignMap.get(o.RelatedCampaign__c).Channel__c;
                    } else {
                        o.Channel__c = null;
                    }
                }
                if(userProfile != CommonConstant.PROFILE_ADMIN && o.PreferredDeliveryDate__c != null && o.PreferredDeliveryDate__c != oldOrder.PreferredDeliveryDate__c) {
                    validatePreferredDeliveryTime(o, waitTime);
                }
            }
        }

        updateSubcriptionOrderCheckbox(orderList);
        updateHasMultipleOrderProductsCheckbox(orderList);
        updateStatusToSubmitted(orderList);
    }
    
    public static Map<Id,Contact> getRelatedContact(Set<Id> conIdSet) {
        
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select AccountId,Id,Market__c,Phone, Email,
                                                    MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                                    MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                                    MC_Sync_Eligibility_VN__c
                                                      FROM Contact
                                                      WHERE Id IN :conIdSet]);
        
        return conMap ;
    }

    public static Map<Id,Campaign> getRelatedCampaign(Set<Id> campIdSet) {
        
        Map<Id,Campaign> campaignMap = new Map<Id,Campaign>([Select Id, Channel__c
                                                      FROM Campaign
                                                      WHERE Id IN :campIdSet]);
        
        return campaignMap;
    }

    public static void orderCountDelete(List<Order> orderList, Map<Id, sObject> oldOrderMap) {
        set<id> caseId = new set<id>();
        set<id> orderId = new set<id>();
        List<Order> deleteOrder = new List<Order>();
        integer getOrder;
        For(Order o: [Select Id, Case__c,  Order_Number_Formula__c From order where id in: orderList])
        {
            caseId.add(o.Case__c);
            deleteOrder.add(o);
        }
        
        getOrder = deleteOrder.size();
        Map<Id, Case> caseMaptoUpdate = new Map<Id, Case>();
        for(Case c : [Select Id, Order__c, RecordType.Name From Case Where Recordtype.Name = 'Call' AND id in: caseId])
        {
            caseMaptoUpdate.put(c.id, c);
        }
        
        for(AggregateResult result:[Select SUM(Order_Number_Formula__c) Qty, Case__c getId From Order Where Case__c in: caseMaptoUpdate.keyset() GROUP by Case__c])
        {
            String parentId = (String)result.get('getId');
            Case cas = caseMaptoUpdate.get(parentId);
            Decimal totalQuantity = (decimal)result.get('Qty');
            cas.Order_Count__c = totalQuantity - getOrder;
            caseMaptoUpdate.put(parentId,cas);
        }
        UtilityClass.updateList(caseMaptoUpdate.values());
    }

    public static List<String> getCancelledOrderStatus(){
        List<String> cancelledOrderStatusList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getLabel().contains('Cancelled')){
                cancelledOrderStatusList.add(pickListVal.getLabel());
            }
        }     
        return cancelledOrderStatusList;
    }

    public static Map<Id, Membership__c> getRelatedMembership(List<Order> orderList){
        Set<Id> membershipIds = new Set<Id>();
         for(Order o : orderList) {
            if(o.ParentMembership__c != null) {
                membershipIds.add(o.ParentMembership__c);
            }
        }

        return new Map<Id, Membership__c>([SELECT Contact__c
                                             FROM Membership__c
                                            WHERE Id IN: membershipIds]);
    }
    
    public static void validatePreferredDeliveryTime(Order orderRec, String waitTime) {
        DateTime myDateTime = (DateTime) orderRec.PreferredDeliveryDate__c;
        String dayOfWeek = myDateTime.format('E');
        Integer finalWaitTime = Integer.valueOf(waitTime) > 0 ? Integer.valueOf(waitTime) + 1 : Integer.valueOf(waitTime);

        if(finalWaitTime > 0 && orderRec.PreferredDeliveryDate__c < orderRec.EffectiveDate.addDays(finalWaitTime)) {
            orderRec.PreferredDeliveryDate__c.addError('Preferred Delivery Date must be at least ' + waitTime + ' days after Order Start Date');
        } 
        else if(finalWaitTime == 0 && orderRec.PreferredDeliveryDate__c <= orderRec.EffectiveDate.addDays(finalWaitTime)) {
            orderRec.PreferredDeliveryDate__c.addError('PPreferred Delivery Date must be in the future.');
        }
        else if(dayOfWeek == CommonConstant.SUNDAY) {
            orderRec.PreferredDeliveryDate__c.addError('Preferred Delivery Date must not fall on a Sunday');
        }
    }

    // membership will be taking care of the daily job
    // this will run only for delete, after update will be taken by the change event
    public static void updateContactTransactionDate(List<Order> orderList, Map<Id, sObject> oldOrderMap) {
        Set<Id> conIdSet = new Set<Id>();
        Set<Id> membershipIdSet = new Set<Id>();
        Set<Id> oldMembershipIdSet = new Set<Id>();
        Set<Id> endDateUpdateMembershipIsSet = new Set<Id>();
        String orderStatus;
        Date transactiondate = null;


        for(Order o : orderList) {
            orderStatus = o.Status;
            // runs only for delete
            // if (trigger.isUpdate) {
            //     Order oldOrder = (Order) oldOrderMap.get(o.Id);
            //     if ((o.Status != oldOrder.Status && (o.Status == CommonConstant.ORDER_STATUS_COMPLETED || oldOrder.Status == CommonConstant.ORDER_STATUS_COMPLETED) && o.OrderedBy__c != null) 
            //     || (o.OrderedBy__c != oldOrder.OrderedBy__c && o.OrderedBy__c != null)) {
            //         conIdSet.add(o.OrderedBy__c);
            //     }

            //     if (o.ParentMembership__c != oldOrder.ParentMembership__c) {
                    
            //         if(o.ParentMembership__c != null) {
            //             membershipIdSet.add(o.ParentMembership__c);
            //         }
            //         if(oldOrder.ParentMembership__c != null) {
            //             oldMembershipIdSet.add(oldOrder.ParentMembership__c);
            //         }
            //     } 
            //     else if(o.EndDate != oldOrder.EndDate) {
            //         endDateUpdateMembershipIsSet.add(o.ParentMembership__c);
            //     }
            //     else if(o.Status != oldOrder.Status && (o.Status == 'Cancelled - Before Delivery' || o.Status == 'Cancelled - Upon Delivery' || o.Status == 'Cancelled - Abandoned' || o.Status == 'Cancelled - New Order Created' ))
            //     {
            //         membershipIdSet.add(o.ParentMembership__c);
            //     }
            // } 

            if(o.OrderedBy__c != null && o.Status == CommonConstant.ORDER_STATUS_COMPLETED) {
                conIdSet.add(o.OrderedBy__c);
            } 

            // else if(o.ParentMembership__c != null) {
            //     membershipIdSet.add(o.ParentMembership__c);
            // }
        }
        
        List<Contact> contactToUpdateList = [Select Id,Market__c, FirstTransaction__c, FirstTransactionDate__c, LatestTransaction__c, LatestTransactionDate__c, MembershipStartDate__c, 
                                             (Select EndDate,Type From Orders__r Where EndDate != null AND Status =: CommonConstant.ORDER_STATUS_COMPLETED
                                              order by EndDate) 
                                              //US-0537 - JERIC -  add BR here to reference first and last transaction date
                                             From Contact Where Id IN : conIdSet];                                          
        for (Contact con : contactToUpdateList) {             
            Integer orderSize = con.Orders__r.size();
            //added by Monika
            for(Order ordr : con.Orders__r){
                if(con.Market__c == CommonConstant.MARKET_TW  && transactiondate==null && ordr.Type != CommonConstant.ORDER_TYPE_SAMPLEREQUEST){
                    transactiondate = ordr.EndDate;
                }
                if(con.Market__c != CommonConstant.MARKET_TW && transactiondate==null){
                    transactiondate = ordr.EndDate;
                }
            }
            if (con.Orders__r.isEmpty()) {
                con.FirstTransaction__c = null;
                con.FirstTransactionDate__c = null;
                con.LatestTransaction__c = null;
                con.LatestTransactionDate__c = null;
                con.MembershipStartDate__c = null;
            } else {
                con.FirstTransactionDate__c = transactiondate;
                con.FirstTransaction__c = con.Orders__r.get(0).Id;
                con.LatestTransactionDate__c = con.Orders__r.get(orderSize - 1).EndDate;
                con.LatestTransaction__c = con.Orders__r.get(orderSize - 1).Id;
                con.MembershipStartDate__c = con.Orders__r.get(0).EndDate;
            }
        }
        
        if (!contactToUpdateList.isEmpty()) {
            //update contactToUpdateList;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        
            List<Database.SaveResult> sr = Database.update(contactToUpdateList, dml);
        }

        // if(!membershipIdSet.isEmpty()) {
        //     updateMembershipDetails(membershipIdSet, false, false, orderStatus);
        // }

        // if(!oldMembershipIdSet.isEmpty()) {
        //     updateMembershipDetails(oldMembershipIdSet, true, false, orderStatus);
        // }

        // if(!endDateUpdateMembershipIsSet.isEmpty()) {
        //     updateMembershipDetails(endDateUpdateMembershipIsSet, false, true, orderStatus);
        // }
    }
    
    /*
    public static void updateRelatedAsset(List<Order> orderList, Map<Id, sObject> oldOrderMap){
        try{     
        List<Asset> assetListToUpdate = new List<Asset>();
        Schema.Location location;
        Set <String> orderIds = new Set <String>();
        Set <String> assetIds = new Set <String>();
        Set <String> locationIds = new Set <String>();
        
        System.debug('NewOrderList : ' + orderList);
        for(Order orderRecord : orderList){
            
            System.debug('Order Market : ' + orderRecord.Account.Market__c);
            if(orderRecord.Status == 'Completed' && orderRecord.Account.Market__c == 'ANZ'){
                orderIds.add(orderRecord.Id);
                
                location = [SELECT Id, LocationType FROM Location WHERE NAME = 'Field'];
            }
            System.debug('OrderId : ' + orderIds);
        }
        
        List<OrderItem> orderItemList = [Select Id, OrderId, Order.AccountId, Asset__c, Order.OrderedBy__c, Allocated_Quantity__c FROM OrderItem WHERE OrderId IN : orderIds];
        for(OrderItem orderItem : orderItemList){
            assetIds.add(orderItem.Asset__c);
        }
        
        
        for(Asset asset : [SELECT Id, AccountId, ContactId, Status, LocationId, Allocated_Quantity__c, Quantity FROM Asset WHERE Id IN : assetIds]){
            for(OrderItem orderItem : orderItemList){
                if(orderItem.Asset__c == asset.Id){
                    asset.AccountId = orderItem.Order.AccountId;
                    asset.ContactId = orderItem.Order.OrderedBy__c;
                    asset.Status = 'Loaned';
                    asset.LocationId = location.Id;
                    asset.Allocated_Quantity__c = orderItem.Allocated_Quantity__c;
                    asset.Quantity = asset.Quantity - asset.Allocated_Quantity__c;
                }
            }
            assetListToUpdate.add(asset);
        }
        
        /*List<Schema.Location> locationList = [SELECT Id, LocationType FROM Location WHERE Id IN : locationIds];
         for(Schema.Location location : locationList){
                location.LocationType = 'Site';
                locationListToUpdate.add(location);
            }
        
          System.debug('AssetList : ' + assetListToUpdate);
        update locationListToUpdate;
        update assetListToUpdate;
        } catch(DMLException e){
            System.debug(e.getMessage());
        }
    }
    */

    public static void updateSubcriptionOrderCheckbox(List<Order> orderList) {
        if(orderList.size() == 0) {
            System.debug('orderList is empty.');
            return;
        } 

        try {
            for(Order o: orderList) {
                if(o.Delivery_Pattern__c != null && o.Frequency__c != null) { // Checks if both the Delivery Pattern and Frequency fields are populated.
                    o.Repeat_Order__c = true;
                }
                else {
                    o.Repeat_Order__c = false;
                }
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    public static void updateHasMultipleOrderProductsCheckbox(List<Order> orderList) {
        if(orderList.size() == 0) {
            System.debug('orderList is empty.');
            return;
        } 

        try {
            Set<Id> orderIds = new Set<Id>();

            for(Order o : orderList) {
                orderIds.add(o.Id);
            }

            Map<Id, OrderItem> orderItems = retrieveOrderItemRecords(orderIds);
            
            
            for(Order o: orderList) {
                if(orderItems.size() > 1) {
                    Integer counter = 0;
                    for(Id oId : orderItems.keySet()) {
                        if(orderItems.get(oId).OrderId == o.Id) {
                            counter += 1;

                            if(counter > 1) {
                                o.Has_Multiple_Order_Products__c = true;
                                break;
                            }
                            else {
                                o.Has_Multiple_Order_Products__c = false;
                            }
                        }
                    }
                }
                else {
                    o.Has_Multiple_Order_Products__c = false;
                }
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    public static void updateStatusToSubmitted(List<Order> orderList) {
        if(orderList.size() == 0) {
            System.debug('orderList is empty.');
            return;
        } 

        try {
            Set<Id> accountIds = new Set<Id>();

            for(Order o : orderList) {
                accountIds.add(o.AccountId);
            }

            Map<Id, Account> accountList = retrieveAccountRecords(accountIds);

            for(Order o: orderList) {
                if(o.ChannelResponse__c == null || (o.ChannelResponse__c != null && !o.ChannelResponse__r.SampleGivenOnGround__c) ){
                    if(o.Day_Before_Shipment_Day__c && accountList.get(o.AccountId).Market__c == CommonConstant.MARKET_TW  && o.Repeat_Order__c) {
                        o.Status = CommonConstant.ORDER_STATUS_SUBMITTED;
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    public static void cloneOrder(List<Order> orderList, String cloneType) {
        if(orderList.isEmpty()) {
            System.debug('orderList is empty.');
            return;
        } 

        try {
            Boolean flag = false; //runs the main logic only if flag is set to true
            Boolean flagSubscriptionOrder = false; 
            Set<Id> accountIds = new Set<Id>();
            Set<Id> orderIds = new Set<Id>();

            for(Order o: orderList) {
                if(!o.CreatedFromCRRecord__c && !o.CreatedFromNewOrderButton__c) {
                    flag = true;
                }

                if(o.Frequency__c != null && o.Delivery_Pattern__c != null) {
                    flag = true;
                    flagSubscriptionOrder = true;
                    
                }

                if(o.Status == CommonConstant.ORDER_STATUS_TRANSFERRED) {
                    flag = true;
                }
                
                accountIds.add(o.AccountId);
                orderIds.add(o.Id);
            }

            if(flag) {
                List<Order> insertClonedOrders = new List<Order>();
                Set<Id> orderItemIds = new Set<Id>();
                Set<Id> productIds = new Set<Id>();

                Map<Id, Account> accountList = retrieveAccountRecords(accountIds);
                Map<Id, OrderItem> orderItems = retrieveOrderItemRecords(orderIds);

                for(Id oId : orderItems.keySet()) {
                    orderItemIds.add(oId);
                    productIds.add(orderItems.get(oId).Product2Id);
                }
                Map<Id, Product2> productList = retrieveProductRecords(productIds);
                
                Map<Id, Set<Id>> orderToOrderItemIdSetMap = new Map<Id, Set<Id>>();
                for(OrderItem oitem : orderItems.values()) {
                    if(orderToOrderItemIdSetMap.containsKey(oitem.OrderId) ){
                        orderToOrderItemIdSetMap.get(oitem.OrderId).add(oitem.Id);
                    }
                    else{
                        orderToOrderItemIdSetMap.put(oitem.OrderId, new Set<Id>{oitem.Id});    
                    }
                }

                for(Order o: orderList) {
                    if(cloneType == 'Subscription Order' && flagSubscriptionOrder) {
                        if(o.Repeat_Order__c && o.Is_Cloned__c) { // Skips cloning this record if it is a Subscription Order and a clone 
                            continue;
                        }
                        else {
                            cloneOrderProcess(o, o.Frequency__c.intValue(), o.Id, insertClonedOrders, cloneType, null, null);
                        }
                    }
                    else if(cloneType == 'Follow-up Bulk Orders') {
                        if(o.Status == CommonConstant.ORDER_STATUS_TRANSFERRED && accountList.get(o.AccountId).Market__c == CommonConstant.MARKET_TW) {
                            Integer computedDaysToProcess;
                            
                            for(Id oId : orderToOrderItemIdSetMap.get(o.Id)) {
                                OrderItem oItem = orderItems.get(oId);
                                Product2 product = productList.get(oItem.Product2Id);
                                
                                if(oItem != null && product != null){
                                    Integer orderItemQuantity = oItem.Quantity != null ? Integer.valueOf(oItem.Quantity) : 0;
                                    Integer productMinBulkQuantity = product.Min_Bulk_Quantity__c != null ? Integer.valueOf(product.Min_Bulk_Quantity__c) : 0;
                                    
                                    if(orderItemQuantity > 0 && orderItemQuantity >= productMinBulkQuantity && product.Bulk_Consumption_Days__c != null && product.Bulk_Consumption_Days__c > 0){
                                        Integer computedDaysTillNextCallFromLastOrder = computeDaysTillNextCallFromLastOrder(orderItemQuantity, product);
                                        
                                        if(computedDaysTillNextCallFromLastOrder != null && (computedDaysToProcess == null || computedDaysTillNextCallFromLastOrder < computedDaysToProcess) ){
                                            computedDaysToProcess = computedDaysTillNextCallFromLastOrder;
                                        }
                                    }
                                }
                            }
                            
                            if(computedDaysToProcess != null)
                            o.Days_till_next_call_from_last_order__c = computedDaysToProcess;
                        }
                    }
                }
                
                if(!insertClonedOrders.isEmpty()) {
                    UtilityClass.insertList(insertClonedOrders);

                    System.debug('insertClonedOrders successfully inserted!');
                }
            }
            
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    private static void cloneOrderProcess(Order currentOrder, Integer frequency, Id parentId, List<Order> insertClonedOrders, String cloneType, OrderItem orderItem, Map<Id, Product2> productList) {
        Order clonedOrder = currentOrder.clone(false, true, false, false);
        clonedOrder.Status = CommonConstant.ORDER_STATUS_DRAFT; // Status must ALWAYS be set to Draft when cloning a new Order record

        if(cloneType == 'Subscription Order') {
            clonedOrder.Subscription_Order_Countdown__c = frequency;
            clonedOrder.PreferredDeliveryDate__c = currentOrder.PreferredDeliveryDate__c + Integer.valueOf(currentOrder.Delivery_Pattern__c);
        }

        clonedOrder.Is_Cloned__c = true;
        clonedOrder.Parent_Order__c = parentId;

        insertClonedOrders.add(clonedOrder);

        if(frequency <= 1) {
            System.debug('Frequency is 1.');
        }
        else {
            // The 3rd parameter must always be the original Order Id to assign to the next clone's Parent Order field
            cloneOrderProcess(clonedOrder, frequency - 1, parentId, insertClonedOrders, cloneType, orderItem, productList);
        }
    }

    public static void cloneOrderItem(List<Order> orderList, String cloneType) {
        if(orderList.isEmpty()) {
            System.debug('orderList is empty.');
            return;
        } 

        try {
            Boolean flag = false; //runs the main logic only if flag is set to true
            Boolean flagSubscriptionOrder = false; 
            List<OrderItem> insertClonedOrderItems = new List<OrderItem>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> parentOrderIds = new Set<Id>();
            List<OrderItem> selectedOrderItems = new List<OrderItem>();

            for(Order o: orderList) {
                if(!o.CreatedFromCRRecord__c && !o.CreatedFromNewOrderButton__c) {
                    flag = true;
                }

                if(o.Frequency__c != null && o.Delivery_Pattern__c != null) {
                    flag = true;
                    flagSubscriptionOrder = true;
                }

                if(o.Status == CommonConstant.ORDER_STATUS_TRANSFERRED) {
                    flag = true;
                }
                
                accountIds.add(o.AccountId);

                if(o.Parent_Order__c != null) {
                    parentOrderIds.add(o.Parent_Order__c);
                }
            }

            if(flag) {
                Map<Id, Account> accountList = retrieveAccountRecords(accountIds);
                Map<Id, OrderItem> orderItems = retrieveOrderItemRecords(parentOrderIds);
                
                
                for(Order o: orderList) {
                    List<OrderItem> selectedOrderItemsOfParent = new List<OrderItem>();

                    if(cloneType == 'Subscription Order' && flagSubscriptionOrder) {
                        if(o.Repeat_Order__c && o.Is_Cloned__c) { // Skips cloning the parent's Order Items if it is not a Subscription Order and clone

                            for(Id oId : orderItems.keySet()) {
                                if(orderItems.get(oId).OrderId == o.Parent_Order__c) {
                                    selectedOrderItemsOfParent.add(orderItems.get(oId));
                                }
                            }

                            cloneOrderItemsProcess(insertClonedOrderItems, o, cloneType, null, selectedOrderItemsOfParent);
                        }
                    }
                }
            }
            
            if(!insertClonedOrderItems.isEmpty()) {
                UtilityClass.insertList(insertClonedOrderItems);

                System.debug('insertClonedOrderItems successfully inserted!');
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    private static void cloneOrderItemsProcess(List<OrderItem> insertClonedOrderItems, Order order, String cloneType, OrderItem orderItem, List<OrderItem> orderItems) {
        if(cloneType == 'Subscription Order') {
            for(OrderItem oi: orderItems) {
                assignOrderIdToOrderItem(oi, insertClonedOrderItems, order);
            }
        }
    }

    // Updates Contact record's Have_Purchased_Paid_Sample__c to true if it is a Child Record Type, Order Status is set to Completed, and the product is either a Stage 1 or 3 Paid Sample
    public static void updateContactHavePurchasedSample(List<Order> orderList) {
        if(orderList.isEmpty()) {
            System.debug('orderList is empty.');
            return;
        }

        try {
            Set<Id> accountIds = new Set<Id>();
            Set<Id> orderIds = new Set<Id>();
            Boolean flag = false;
            List<Contact> contactRecordsToUpdate = new List<Contact>();

            for(Order o : orderList) {
                if(o.Status == CommonConstant.ORDER_STATUS_COMPLETED) {
                    flag = true;
                }

                accountIds.add(o.AccountId);
                orderIds.add(o.Id);
            }

            if(flag) {
                Set<Id> productIds = new Set<Id>();
                Set<Id> orderedForIds = new Set<Id>();
                Boolean flag2 = false;
                Id childRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_CHILD_RECORDTYPE).getRecordTypeId();
                Map<Id, OrderItem> orderItems = retrieveOrderItemRecords(orderIds);

                for(Id oId : orderItems.keySet()) {
                    productIds.add(orderItems.get(oId).Product2Id);
                    orderedForIds.add(orderItems.get(oId).OrderedFor__c);
                }

                Map<Id, Contact> orderedForList = retrieveContactRecords(orderedForIds); // returns contact records where Have_Purchased_Paid_Sample__c is set to false

                for(Id cId : orderedForList.keySet()) {
                    if(!orderedForList.get(cId).Have_Purchased_Paid_Sample__c) {
                        flag2 = true;
                        break;
                    }
                }

                if(flag2) {
                    Map<Id, Product2> productList = retrieveProductRecords(productIds);

                    for(Order o : orderList) {
                        for(Id oiId : orderItems.keySet()) {
                            //Checks if the Household is from TW Market and Order Status is Completed
                            if(orderedForList.get(orderItems.get(oiId).OrderedFor__c).Account.Market__c == CommonConstant.MARKET_TW && o.Status == CommonConstant.ORDER_STATUS_COMPLETED) {
                                for(Id pId : productList.keySet()) {
                                    // Checks if the product ordered is either a Stage 1 or 3 Paid Sample
                                    if(productList.get(pId).Stage1PaidSample__c || productList.get(pId).Stage3PaidSample__c) {
                                        // Checks if the Contact Record Type is Child
                                        if(orderedForList.get(orderItems.get(oiId).OrderedFor__c).RecordTypeId == childRecordTypeId) {
                                            orderedForList.get(orderItems.get(oiId).OrderedFor__c).Have_Purchased_Paid_Sample__c = true;
                                            contactRecordsToUpdate.add(orderedForList.get(orderItems.get(oiId).OrderedFor__c));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(!contactRecordsToUpdate.isEmpty()) {
                UtilityClass.updateList(contactRecordsToUpdate);

                System.debug('contactRecordsToUpdate successfully updated!');
            }
        }
        catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public static void updateContactPurchasedTWPEDStandardProduct(List<Order> orderList) {
        if(orderList.isEmpty()) {
            System.debug('orderList is empty.');
            return;
        }

        try {
            Set<Id> orderIds = new Set<Id>();
            Boolean flag = false;
            List<Contact> contactRecordsToUpdate = new List<Contact>();

            for(Order o : orderList) {
                if(o.Status == CommonConstant.ORDER_STATUS_COMPLETED) {
                    flag = true;
                }

                orderIds.add(o.Id);
            }

            if(flag) {
                Set<Id> orderedForIds = new Set<Id>();
                Set<Id> pricebookEntryIds = new Set<Id>();
                Set<Id> productIds = new Set<Id>();
                Boolean flag2 = false;
                Id childRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_CHILD_RECORDTYPE).getRecordTypeId();
                Map<Id, OrderItem> orderItemMap = retrieveOrderItemRecords(orderIds);

                for(Id oiId : orderItemMap.keySet()) {
                    if(orderItemMap.get(oiId).OrderedFor__c != null) {
                        orderedForIds.add(orderItemMap.get(oiId).OrderedFor__c);
                    }
                    
                    productIds.add(orderItemMap.get(oiId).Product2Id);
                    pricebookEntryIds.add(orderItemMap.get(oiId).PricebookEntryId);
                }

                if(!orderedForIds.isEmpty()) {
                    Map<Id, PricebookEntry> pricebookEntryList = retrieveStandardPricebookEntryRecords(pricebookEntryIds);

                    for(Id pbeId : pricebookEntryIds) {
                        if(pricebookEntryList.get(pbeId) != null) {
                            flag2 = true;
                            break;
                        }
                    }

                    if(flag2) {
                        Boolean flag3 = false;
                        Map<Id, Product2> productList = retrieveProductRecords(productIds);
                        Set<Id> orderedByIds = new Set<Id>();

                        for(Order o : orderList) {
                            orderedByIds.add(o.OrderedBy__c);
                        }

                        Map<Id, Contact> orderedForList = new Map<Id, Contact>();
                        Map<Id, Contact> contactMap = retrieveContactRecords(orderedByIds);

                        for(Id cId : contactMap.keySet()) {
                            if(contactMap.get(cId).Parent__c != null) {
                                orderedForList.put(cId, contactMap.get(cId));
                            }

                            if(!contactMap.get(cId).Purchased_Standard_PED_Product__c) {
                                flag3 = true;
                            }
                        }

                        if(flag3) {
                            for(Id oiId : orderItemMap.keySet()) {
                                if(orderItemMap.get(oiId).OrderedFor__c != null) {
                                    if(orderedForList.get(orderItemMap.get(oiId).OrderedFor__c).Account.Market__c == CommonConstant.MARKET_TW) {
                                        // mark this contact
                                        if(pricebookEntryList.get(orderItemMap.get(oiId).PricebookEntryId).Id != null && orderedForList.get(orderItemMap.get(oiId).OrderedFor__c).RecordTypeId == childRecordTypeId &&
                                        !orderedForList.get(orderItemMap.get(oiId).OrderedFor__c).Purchased_Standard_PED_Product__c &&
                                        !productList.get(pricebookEntryList.get(orderItemMap.get(oiId).PricebookEntryId).Product2Id).Available_For_Promo__c &&
                                        !productList.get(pricebookEntryList.get(orderItemMap.get(oiId).PricebookEntryId).Product2Id).Stage1PaidSample__c &&
                                        !productList.get(pricebookEntryList.get(orderItemMap.get(oiId).PricebookEntryId).Product2Id).Stage3PaidSample__c) {
                                            orderedForList.get(orderItemMap.get(oiId).OrderedFor__c).Purchased_Standard_PED_Product__c = true;
                                            contactRecordsToUpdate.add(orderedForList.get(orderItemMap.get(oiId).OrderedFor__c));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if(!contactRecordsToUpdate.isEmpty()) {
                UtilityClass.updateList(contactRecordsToUpdate);

                System.debug('contactRecordsToUpdate successfully updated!');
            }
        }
        catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    private static Map<Id, OrderItem> retrieveOrderItemRecords(Set<Id> orderIds) {
        return new Map<Id, OrderItem>([SELECT Id, Product2Id, PricebookEntryId, UnitPrice, Quantity, OrderId, OrderedFor__c FROM OrderItem WHERE OrderId IN :orderIds ORDER BY Quantity]);
    }

    private static Map<Id, Account> retrieveAccountRecords(Set<Id> accountIds) {
        return new Map<Id, Account>([SELECT Id, Market__c FROM Account WHERE ID IN :accountIds]);
    }

    private static Map<Id, Product2> retrieveProductRecords(Set<Id> productIds) {
        return new Map<Id, Product2>([SELECT Id, Name, Min_Bulk_Quantity__c, Bulk_Consumption_Days__c, Family, Available_For_Promo__c, Stage1PaidSample__c, Stage3PaidSample__c FROM Product2 WHERE Id IN :productIds]);
    }

    private static Map<Id, Contact> retrieveContactRecords(Set<Id> contactIds) {
        return new Map<Id, Contact>([SELECT Id, RecordTypeId, AccountId, Account.Market__c, Parent__c, Have_Purchased_Paid_Sample__c, Purchased_Standard_PED_Product__c FROM Contact
                                    WHERE Id IN :contactIds OR Parent__c IN :contactIds]);
    }

    private static Map<Id, PricebookEntry> retrieveStandardPricebookEntryRecords(Set<Id> pricebookEntryIds) {
        return new Map<Id, PricebookEntry>([SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Id = :pricebookEntryIds AND Pricebook2.Name =: CommonConstant.TW_PED_STANDARD_PRICEBOOK]);
    }

    private static void assignOrderIdToOrderItem(OrderItem orderItem, List<OrderItem> insertClonedOrderItems, Order order) {
        OrderItem orderItem2 = orderItem.clone(false, true, false, false);
        orderItem2.OrderId = order.Id;

        insertClonedOrderItems.add(orderItem2);
    }

    // private static Decimal computeOrderItemQuantity(Product2 product, Decimal orderItemQuantity) {
    //     Decimal quantity;

    //     if(product.Family == 'Adult') {
    //         quantity = orderItemQuantity;
    //     }
    //     else if(product.Family == 'Pediatric') {
    //         quantity = orderItemQuantity * convertStringMultiplierToInteger(product.Name);
    //     }

    //     return quantity;
    // }

    private static Integer computeDaysTillNextCallFromLastOrder(Decimal quantity, Product2 product) {
        Integer quotientResult = 0;
        Integer productResult = 0;
        Decimal minBulkQuantity;
        if(product.Min_Bulk_Quantity__c > 0){
            minBulkQuantity = product.Min_Bulk_Quantity__c;
        }
        if(minBulkQuantity != null && quantity >= minBulkQuantity) {
            quotientResult = (quantity / minBulkQuantity).intValue();
        }
        else{
            quotientResult = 1;
        }
        productResult = quotientResult * product.Bulk_Consumption_Days__c.intValue();

        return productResult;
    }

    // private static Decimal convertStringMultiplierToInteger(String word) {
    //     List<String> parts = word.splitByCharacterType();

    //     Boolean flag = false;
    //     String word2;

    //     for(String s : parts) {
    //         if(flag && s.isNumeric()) {
    //             word2 = s;
    //             break;
    //         }
    //         else {
    //             flag = false;
    //         }
            
    //         if(s == 'x' || s == 'X') {
    //             flag = true;
    //         }
    //     }

    //     Decimal result = 1.0;

    //     if(word2.isNumeric()) {
    //         result = Decimal.valueOf(word2);
    //     }

    //     return result;
    // }

    public static void getTransactionLastTwoYears(List<Order> orderList, Map<Id, SObject> oldOrderMap){
        Date today = Date.today();
        Map<Id, Decimal> orderByMap = new Map<Id, Decimal>();
        List<Contact> updateContactList = new List<Contact>();
        for(Order o: orderList){
            Order oldOrder = (Order) oldOrderMap.get(o.Id);
            if(oldOrder.Status != CommonConstant.ORDER_STATUS_DRAFT && oldOrder.Status != CommonConstant.ORDER_STATUS_COMPLETED && oldOrder.EndDate == null 
               && o.Status == CommonConstant.ORDER_STATUS_COMPLETED && ( (today.daysBetween(o.EndDate) < -731) || (today.daysBetween(o.EndDate) >= 0) ) && 
               ( (o.Type == CommonConstant.ORDER_TYPE_TELESALES_INBOUND) || (o.Type == CommonConstant.ORDER_TYPE_TELESALES_OUTBOUND) ) ){
                   if(!orderByMap.isEmpty() && orderByMap.containsKey(o.OrderedBy__c)){   
                       Decimal orderAmount = orderByMap.get(o.OrderedBy__c);
                       orderByMap.put(o.OrderedBy__c, orderAmount + o.TotalAmount); 
                   }
                   else{
                       orderByMap.put(o.OrderedBy__c, o.TotalAmount); 
                   }
               }
        }
        for(Contact c: [SELECT Id, Total_Purchase_Amount_Adult_Brand__c, Total_Purchase_Anniversary_Amount_Adult__c FROM Contact WHERE Id IN: orderByMap.keySet()]){
            Decimal contactOrderTotal = orderByMap.get(c.Id);
            c.Total_Purchase_Amount_Adult_Brand__c = c.Total_Purchase_Amount_Adult_Brand__c == null || c.Total_Purchase_Amount_Adult_Brand__c == 0 ? contactOrderTotal : c.Total_Purchase_Amount_Adult_Brand__c + contactOrderTotal;
            c.Total_Purchase_Anniversary_Amount_Adult__c = c.Total_Purchase_Anniversary_Amount_Adult__c == null || c.Total_Purchase_Anniversary_Amount_Adult__c == 0 ? contactOrderTotal : c.Total_Purchase_Anniversary_Amount_Adult__c + contactOrderTotal;
            updateContactList.add(c);
        }
        update updateContactList;
    }
    
       
    /*public static void getTransactionLastTwoYears(List<Order> orderList, List<Order> Old_orderList){
        
        Date today = Date.today();
        List<Contact> cu = new List<Contact>();
        Boolean UpdateTotalPurchace = true;

        //check if order is already completed
        for(Order o: Old_orderList){
            if(o.Status == CommonConstant.ORDER_STATUS_DRAFT){
                UpdateTotalPurchace = false;
            }
            else if((o.Status == CommonConstant.ORDER_STATUS_COMPLETED)){
                UpdateTotalPurchace = false;
            }
            else if(o.EndDate != null){
                UpdateTotalPurchace = false;
            }
        }

        //update Total_Purchase_Amount_Adult_Brand__c after completing the order
        if(UpdateTotalPurchace){

            for(Order o: orderList){

                if(o.Status == CommonConstant.ORDER_STATUS_COMPLETED){
                    if((today.daysBetween(o.EndDate) < -731) || (today.daysBetween(o.EndDate) >= 0)){
                        if((o.Type == CommonConstant.ORDER_TYPE_TELESALES_INBOUND) || (o.Type == CommonConstant.ORDER_TYPE_TELESALES_OUTBOUND)){

                            for(Contact c : [Select Id, Total_Purchase_Amount_Adult_Brand__c from contact where id =: o.OrderedBy__c]){
    
                                c.Total_Purchase_Amount_Adult_Brand__c += o.TotalAmount;
                                cu.add(c);
                            }
                            update cu;
                        }
                    }
                }
            }
        }
        
    }

   
    public static void getTransactionAnniversaryLastTwoYears(List<Order> orderList, List<Order> Old_orderList){
        
        Date today = Date.today();
        List<Contact> cu = new List<Contact>();
        Boolean UpdateAnnivTotalPurchace = true;


        //check if order is already completed
        for(Order o: Old_orderList){
            if(o.Status == CommonConstant.ORDER_STATUS_DRAFT){
                UpdateAnnivTotalPurchace = false;
            }
            else if((o.Status == CommonConstant.ORDER_STATUS_COMPLETED)){
                UpdateAnnivTotalPurchace = false;
            }
            else if(o.EndDate != null){
                UpdateAnnivTotalPurchace = false;
            }
        }

        //update Total_Purchase_Anniversary_Amount_Adult__c after completing the order
        if(UpdateAnnivTotalPurchace){

            for(Order o: orderList){

                if(o.Status == CommonConstant.ORDER_STATUS_COMPLETED){
                    if((today.daysBetween(o.EndDate) < -731) || (today.daysBetween(o.EndDate) >= 0)){
                        if((o.Type == CommonConstant.ORDER_TYPE_TELESALES_INBOUND) || (o.Type == CommonConstant.ORDER_TYPE_TELESALES_OUTBOUND)){

                            for(Contact c : [Select Id, Total_Purchase_Anniversary_Amount_Adult__c from contact where id =: o.OrderedBy__c]){

                                c.Total_Purchase_Anniversary_Amount_Adult__c += o.TotalAmount;
                                cu.add(c);
                            }

                            update cu;
                        }
                    }
                }
            }
        }
    }*/

    /*
    public static void updateBrandRelationship(List<Order> orderList, Map<Id, sObject> oldOrderMap) {
        Set<Id> conIdSet = new Set<Id>();
        Map<String, String> orderContactMap = new Map<String, String>();
        
        for(Order o : orderList) {
            if (trigger.isUpdate) {
                Order oldOrder = (Order) oldOrderMap.get(o.Id);
                if (o.Status != oldOrder.Status && o.OrderedBy__c != null && o.Status == CommonConstant.ORDER_STATUS_COMPLETED) {
                    conIdSet.add(o.OrderedBy__c);
                    orderContactMap.put(o.Id , o.OrderedBy__c);
                }
            } 
        }
        
        if(!conIdSet.isEmpty()) {
            Map<String, Set<String>> contactProductMap = new Map<String, Set<String>>();
            Map<String, List<OrderItem>> BRProductContactMap = new Map<String, List<OrderItem>>();
            for (OrderItem oItem : [Select Product2.KeyBrand__c, Product2.BrandRelationshipLink__c, OrderId, Order.EndDate From OrderItem Where OrderId IN: orderContactMap.keySet() ]) {
                String contactId = orderContactMap.get(oItem.OrderId);
                
                if(!contactProductMap.containsKey(contactId)){
                    contactProductMap.put(contactId, new Set<String>());
                }
                contactProductMap.get(contactId).add(oItem.Product2.KeyBrand__c);

                // create map of contact - product2
                if(oItem.Product2.BrandRelationshipLink__c != null){
                    String key = contactId + '-' + oItem.Product2.BrandRelationshipLink__c;
                    if(!BRProductContactMap.containsKey(key)){
                        BRProductContactMap.put(key, new List<OrderItem>());
                    }
                    BRProductContactMap.get(key).add(oItem);
                }            
            }
            
            Map<Id, BrandRelationship__c> toUpdateBrand = new Map<Id, BrandRelationship__c>();
            Map<Id, OrderItem> oiMap = new Map<Id, OrderItem>();
            for (Contact con : [SELECT (SELECT KeyBrand__c, Status__c, Type__c, WinBack__c, BrandRelationship__c, FirstTransactionDate__c, LatestTransactionDate__c FROM BrandRelationships__r),
                                        (SELECT KeyBrand__c, Status__c, Type__c, WinBack__c, BrandRelationship__c, FirstTransactionDate__c, LatestTransactionDate__c FROM MainBrandRelationships__r)
                                    FROM Contact
                                   WHERE ID IN: conIdSet]) {

                Set<String> productBrand = contactProductMap.get(con.Id);
                for (BrandRelationship__c brand : con.BrandRelationships__r) {

                    Boolean forUpdate = false;

                    if (productBrand.contains(brand.KeyBrand__c)) {
                        if (brand.Type__c == CommonConstant.BRAND_TYPE_LEAD) {
                            brand.Type__c = CommonConstant.BRAND_TYPE_USER;
                            brand.Status__c = CommonConstant.BRAND_STATUS_NEW;
                            forUpdate = true;
                        } else if (brand.Type__c ==  CommonConstant.BRAND_TYPE_USER && brand.Status__c == CommonConstant.BRAND_STATUS_LAPSED) {
                            brand.Status__c = CommonConstant.BRAND_STATUS_EXISTING;
                            brand.WinBack__c = true;
                            forUpdate = true;
                        }
                    }

                    if(forUpdate){
                        toUpdateBrand.put(brand.Id, brand);
                    }
                }

                // update transaction date of the contact where it is main contact
                for (BrandRelationship__c brandX : con.MainBrandRelationships__r) {
                    
                    Boolean forUpdate = false;

                    BrandRelationship__c brand = toUpdateBrand.containsKey(brandX.Id) ? toUpdateBrand.get(brandX.Id) : brandX; // check if it has been previously updated

                    //check if contact - product2 has match
                    if(brand.BrandRelationship__c != null
                        && BRProductContactMap.containsKey(con.Id + '-' + brand.BrandRelationship__c)){
                        for(OrderItem oi: BRProductContactMap.get(con.Id + '-' + brand.BrandRelationship__c)){
                            oi.BrandRelationshipLinkStatus__c = true;
                            oiMap.put(oi.Id, oi);

                            // check first transaction date
                            if(brand.FirstTransactionDate__c == null){
                                brand.FirstTransactionDate__c = oi.Order.EndDate;
                                forUpdate = true;
                            }

                            // check latest transaction date
                            if(brand.LatestTransactionDate__c == null
                                || (brand.LatestTransactionDate__c != null 
                                    && brand.LatestTransactionDate__c < oi.Order.EndDate)
                                ){
                                brand.LatestTransactionDate__c = oi.Order.EndDate;
                                forUpdate = true;
                            }
                        }
                    }

                    if(forUpdate){
                        toUpdateBrand.put(brand.Id, brand);
                    }
                }
            }

            if(!toUpdateBrand.isEmpty()) {
                //update toUpdateBrand;
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
                List<Database.SaveResult> sr = Database.update(toUpdateBrand.values(), dml);
            }

            //update order item
            if(!oiMap.isEmpty()) {
                Database.update(oiMap.values(), false);
            }
        }
    }
    
    public static void orderCount(List<Order> orderList, Map<Id, sObject> oldOrderMap) {
        set<id> caseId = new set<id>();
        
        For(Order o: [Select Id, Case__c, Order_Number_Formula__c, ParentMembership__c From order where id in: orderList])
        {
            caseId.add(o.Case__c);
        }
        
        Map<Id, Case> caseMaptoUpdate = new Map<Id, Case>();
        for(Case c : [Select Id, Order__c, RecordType.Name From Case Where Recordtype.Name = 'Call' AND id in: caseId])
        {
            caseMaptoUpdate.put(c.id, c);
        }
        
        system.debug(caseMaptoUpdate);
        
        for(AggregateResult result:[Select SUM(Order_Number_Formula__c) Qty, Case__c getId From Order Where Case__c in: caseMaptoUpdate.keyset() GROUP by Case__c])
        {
            String parentId = (String)result.get('getId');
            Case cas = caseMaptoUpdate.get(parentId);
            Decimal totalQuantity = (decimal)result.get('Qty');
            cas.Order_Count__c = totalQuantity;
            caseMaptoUpdate.put(parentId,cas);
        }
        system.debug(caseMaptoUpdate.values());
        database.update(caseMaptoUpdate.values());
    }
    
    public static void updateMembershipDetails(Set<Id> membershipIdSet, Boolean isDeduct, Boolean endDateUpdate, String orderStatus) {
        List<Membership__c> membershipList = new List<Membership__c>();
        Boolean orderProcessed = false;
        for(Membership__c mem : [SELECT NumberOfDaysDormant__c, NumberOfTransactions__c, MembershipStartDate__c,
                                    (SELECT EndDate From Orders__r WHERE Status != 'Cancelled - New Order Created' AND Status != 'Cancelled - Before Delivery' AND Status != 'Cancelled - Upon Delivery' AND Status != 'Cancelled - Abandoned' 
                                    ORDER BY EndDate) 
                                    FROM Membership__c
                                    WHERE Id IN :membershipIdSet]) {

            mem.NumberOfTransactions__c = 0;
            
            if(!mem.Orders__r.isEmpty()) {
                mem.NumberOfTransactions__c = mem.Orders__r.size();
                
                if(!orderProcessed) {
                    for(Order order : mem.Orders__r) {    
                        if(order.EndDate != null) {
                            orderProcessed = true;
                            if(order.EndDate == Date.valueOf(System.today())) {
                                mem.NumberOfDaysDormant__c = 0;    
                            } else {
                                mem.NumberOfDaysDormant__c = order.EndDate.daysBetween(System.today());
                            }
                            
                            if(mem.NumberOfDaysDormant__c >= 90) {
                                mem.Status__c = CommonConstant.MEMBERSHIP_STATUS_EXPIRED;
                                mem.MembershipExpiryDate__c = order.EndDate.addDays(90);
                            }
                        }
                    }
                }
            } else {
                if(mem.MembershipStartDate__c != null) {
                    if(mem.MembershipStartDate__c == Date.valueOf(System.today())) {
                        mem.NumberOfDaysDormant__c = 0;    
                    } else {
                        mem.NumberOfDaysDormant__c = mem.MembershipStartDate__c.daysBetween(System.today());
                    }

                    if(mem.NumberOfDaysDormant__c >= 90) {
                        mem.Status__c = CommonConstant.MEMBERSHIP_STATUS_EXPIRED;
                        mem.MembershipExpiryDate__c = mem.MembershipStartDate__c.addDays(90);
                    }
                }
            }

            if (mem.NumberOfDaysDormant__c < 0) {
                mem.NumberOfDaysDormant__c = 0;
            }

            membershipList.add(mem);
        }

        if(!membershipList.isEmpty()) {
            update membershipList;
        }
    }*/
  
}