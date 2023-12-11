/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Helper class for Order Product object

History
01/23/2019   vmirandilla    Created
08/23/2019   raustral       added partial update of order (TKT-001166)
10/28/2020   malviz         added updateMembership,getOrderMemberships (TKT-002646)
08/20/2021   malviz         updated productMap on updateCallOrderInfo
08/20/2021   scordova       Added checkPaidSampleProductOrdered, checkPaidSampleProductOrderedProcess, retrieveProductRecords, retrieveContactRecords,
                            retrieveCurrentOrderRecords, retrievePastOrderRecords, and retrieveOrderItemRecords functions.
09/07/2021   scordova       Added updateContactPurchasedTWPEDStandardProduct and retrievePricebookEntryRecords functions.
                            Removed unused queries in getTransactionLastTwoYears, getTransactionAnniversaryLastTwoYears, and updateMembership functions.
-------------------------------------------------------------------------------------------*/

public class OrderProductTriggerHelper{

    public static void getPromotion(List<OrderItem> orderItemList) {

        Set<Id> promoItedIdSet = new Set<Id>();
        for(OrderItem oi : orderItemList) {
            if(oi.PromotionItem__c != null)
                promoItedIdSet.add(oi.PromotionItem__c);
        }

        Map<Id,PromotionItem__c> promoItemMap = new Map<Id,PromotionItem__c>(
                                                         [SELECT Promotion__c
                                                            FROM PromotionItem__c
                                                           WHERE Id IN :promoItedIdSet]);

        for(OrderItem oi : orderItemList) {
            if(promoItemMap.containsKey(oi.PromotionItem__c)) {
                oi.Promotion__c = promoItemMap.get(oi.PromotionItem__c).Promotion__c;
            }
        }
    }

    public static void getProductInfo(List<OrderItem> orderItemList, Map<Id, SObject> oldOrderItemMap){
        Set<Id> productIdSet = new Set<Id>();
        for(OrderItem o : orderItemList){
            if(o.Product2Id != null){
                productIdSet.add(o.Product2Id);
            }
        }

        Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Min_Birth_Month__c, Max_Birth_Month__c FROM Product2 WHERE Id IN: productIdSet]);

        for(OrderItem o : orderItemList){
            if(Trigger.isInsert){
                if(o.Product2Id != null && productMap.containsKey(o.Product2Id)){
                    Product2 productRec = productMap.get(o.Product2Id);
                    o.Product_Min_Birth_Month__c = productRec.Min_Birth_Month__c == null? 0 : productRec.Min_Birth_Month__c;
                    o.Product_Max_Birth_Month__c = productRec.Max_Birth_Month__c == null? 0 : productRec.Max_Birth_Month__c;
                }
                else if(o.Product2Id == null){
                    o.Product_Min_Birth_Month__c = 0;
                    o.Product_Max_Birth_Month__c = 0;
                }
            }
            else{
                OrderItem oldOrderItem = (OrderItem) oldOrderItemMap.get(o.Id);
                if(o.Product2Id != null && o.Product2Id != oldOrderItem.Product2Id && productMap.containsKey(o.Product2Id)){
                    Product2 productRec = productMap.get(o.Product2Id);
                    o.Product_Min_Birth_Month__c = productRec.Min_Birth_Month__c == null? 0 : productRec.Min_Birth_Month__c;
                    o.Product_Max_Birth_Month__c = productRec.Max_Birth_Month__c == null? 0 : productRec.Max_Birth_Month__c;
                }
                else if(o.Product2Id == null){
                    o.Product_Min_Birth_Month__c = 0;
                    o.Product_Max_Birth_Month__c = 0;
                }
            }
        }
    }

    //Update Call Order Information based on number of unique Parent Brands per product category
    public static void updateCallOrderInfo(Set<Id> caseIds, Set<Id> productIds){
        Map<Id,List<Order>> callOrderMap = getRelatedOrders(caseIds);
        Set<Id> existingProductIds = new Set<Id>();
        Map<id, Product2> productMap = new Map<id,Product2>([SELECT Id, ParentBrand__c, ProductCode
                                                               FROM Product2
                                                              WHERE Id in : productIds]);
                                                        
        List<Case> casesToUpdate = new List<Case>();

        for(Id cId : callOrderMap.keySet()){
            Case c = new Case(Id = cId);

            Integer totalQuantity = 0;
            Set<Id> conversionSet = new Set<Id>();
            Set<Id> retentionSet = new Set<Id>();
            Set<Id> crosssellSet = new Set<Id>();
            Set<Id> trialSet = new Set<Id>();
            Set<Id> winbackSet = new Set<Id>();
            Set<String> upsellSet = new Set<String>();
            
            //get product ids of existing orders on each call
            for(Order o : callOrderMap.get(c.Id)){
                for(OrderItem oi : o.OrderItems){
                    if(!productMap.containsKey(oi.Product2Id)){
                        existingProductIds.add(oi.Product2Id);
                    }
                }
            }
            
            //add existing order products on product map
            for(Product2 prod : [Select Id, ParentBrand__c, ProductCode from Product2 where Id in :existingProductIds]){
                if(!productMap.containsKey(prod.Id)){
                    productMap.put(prod.Id, prod);
                }
            }
            
            for(Order o : callOrderMap.get(c.Id)){
                for(OrderItem oi : o.OrderItems){
                   totalQuantity = totalQuantity + Integer.valueOf(oi.Quantity);
                   
                    if(oi.Category__c == 'Conversion'){
                        conversionSet.add(productMap.get(oi.Product2Id).ParentBrand__c);       
                    }
                    if(oi.Category__c == 'Retention'){
                        retentionSet.add(productMap.get(oi.Product2Id).ParentBrand__c);     
                    }
                    if(oi.Category__c == 'Cross-Sell'){
                        crosssellSet.add(productMap.get(oi.Product2Id).ParentBrand__c);     
                    }
                    if(oi.Category__c == 'Trial'){
                        trialSet.add(productMap.get(oi.Product2Id).ParentBrand__c);     
                    }
                    if(oi.Category__c == 'Win Back'){
                        winbackSet.add(productMap.get(oi.Product2Id).ParentBrand__c);     
                    }
                    if(oi.Category__c == 'Up-Sell'){
                        upsellSet.add(productMap.get(oi.Product2Id).ProductCode);     
                    }      
                }
            }
            c.TotalNumberoftheProductsOrdered__c = String.valueOf(totalQuantity);
            c.NumberOfConversion__c = String.valueOf(conversionSet.size());
            c.NumberOfRetention__c = String.valueOf(retentionSet.size());
            c.NumberOfCrossSell__c = String.valueOf(crosssellSet.size());
            c.NumberOfTrial__c = String.valueOf(trialSet.size());
            c.NumberOfWinBack__c = String.valueOf(winbackSet.size());
            c.NumberOfUpSell__c = String.valueOf(upsellSet.size());
            casesToUpdate.add(c);
        }
        if(!casesToUpdate.isEmpty()) UtilityClass.updateList(casesToUpdate);
    }
    
    public static Map<Id,Order> getCallOrders(List<OrderItem> orderItemList){
        Set<Id> orderSetId = new Set<Id>();
        for(OrderItem oi : orderItemList)
            orderSetId.add(oi.OrderId);

        Map<Id,Order> callOrdersMap = new Map<Id,Order>([Select Case__c
                                                           FROM Order 
                                                          WHERE Id IN :orderSetId
                                                            AND Case__c != null
                                                            AND Case__r.RecordType.Name = 'Call']);
        return callOrdersMap;
    }

    public static Map<Id,List<Order>> getRelatedOrders(Set<Id> caseId){ 
        List<Order> callOrders = new List<Order>();
        Map<Id, List<Order>> caseOrderMap = new Map<Id, List<Order>>();
        for(Order o : [SELECT Case__c,
                              (SELECT OrderId, Product2Id, Category__c, Quantity
                                 FROM OrderItems)
                         FROM Order
                        WHERE Case__c IN: caseId
                          AND Case__r.RecordType.Name = 'Call']){

            if(!caseOrderMap.containsKey(o.Case__c))
                caseOrderMap.put(o.Case__c, new List<Order>());
            caseOrderMap.get(o.Case__c).add(o);
        }
        return caseOrderMap;
    }

    //https://trackertrial-986.cloudforce.com/a046F00001t6OFk
    public static void updateOrderStatus(Set<Id> orderIds) {

        List<AffiliateMetadata__mdt> am = [Select MasterLabel, OrderStatusItemLevel__c ,OrderCancellationReason__c
                                            From AffiliateMetadata__mdt Where OrderStatusItemLevel__c = true];
        Map<String, String> amMap = UtilityClass.convertObjToMap(am, CommonConstant.AFFILIATE_MASTERLABEL , 'OrderCancellationReason__c');

        List<Order> toUpdateOrderList  = new List<Order>();
        List<Order> orderList  = [Select Id, Status, Account.Market__c, (SELECT OrderItemNumber, Status__c from  OrderItems) from Order where Id IN: orderIds];

        for (Order o : orderList) {
            //only execute partial update with OrderStatusItemLevel__c = true for each market

            if (amMap.containsKey(o.Account.Market__c)) {
                Boolean hasBlank = false;
                Boolean hasCancelled = false;
                String oldStatus = o.Status;

                for (OrderItem oItem : o.OrderItems) {
                    //check all the status of the order item

                    if (String.isBlank( oItem.Status__c)) {
                        hasBlank = true;
                    } else if ( oItem.Status__c == 'Cancelled') {
                        hasCancelled = true;
                    }
                }

                //update the order status based on the status of all order item link to the order
                o.Status = CommonConstant.ORDER_STATUS_DELIVERED;

                if (hasCancelled) {
                    if (String.isNotBlank(amMap.get(o.Account.Market__c))) {
                        //AffiliateValue__c is external id and unique
                        Affiliate_Value__c cancelReference = new Affiliate_Value__c( AffiliateValue__c = amMap.get(o.Account.Market__c));
                        o.OrderCacellationReason__r = cancelReference;
                    }
                    
                    o.Status = CommonConstant.ORDER_STATUS_CANCELLED_UPONDELIV;
                    o.EndDate = Date.today();
                } else if (hasBlank == false && hasCancelled == false){
                    o.Status = CommonConstant.ORDER_STATUS_COMPLETED;
                    o.EndDate = Date.today();
                }

                //only update the status if there are changes
                //even if the order items status has been change there are instance that the order status is still the same
                if (oldStatus != o.Status) {
                    toUpdateOrderList.add(o);
                }
            }
        }

        if (!toUpdateOrderList.isEmpty()) UtilityClass.updateList(toUpdateOrderList);
    }

    public static void updateMembership(Set<Id> membershipIds, Set<Id> productIds, Map<Id, Id> orderProductMap){
        List<Membership__c> membershipsToUpdate = new List<Membership__c>(); 
        
        for(Membership__c mem : [SELECT Id,Recent_Product_Purchased__c,
                                    (SELECT Id,CreatedDate From Orders__r WHERE Status != 'Cancelled - New Order Created' AND Status != 'Cancelled - Before Delivery' AND Status != 'Cancelled - Upon Delivery' AND Status != 'Cancelled - Abandoned' 
                                    ORDER BY CreatedDate DESC LIMIT 1) 
                                    FROM Membership__c
                                    WHERE Id IN :membershipIds]) {
                                        
            if(!mem.Orders__r.isEmpty()) {
                Boolean toUpdate = false;

                for(Order o : mem.Orders__r) {  
                    if(orderProductMap.containsKey(o.Id) && mem.Recent_Product_Purchased__c != orderProductMap.get(o.id)){
                        mem.Recent_Product_Purchased__c = orderProductMap.get(o.id);
                        toUpdate = true;
                    }
                }

                if(toUpdate){
                    membershipsToUpdate.add(mem); 
                }
            }                                                                  
        }
        if (!membershipsToUpdate.isEmpty()) UtilityClass.updateList(membershipsToUpdate);
    }
    
    public static Map<Id,Order> getOrderMemberships(List<OrderItem> orderItemList){
        Set<Id> orderSetId = new Set<Id>();
        Map<Id,Order>  ordersMap = new  Map<Id,Order> ();
        
        for(OrderItem oi : orderItemList){
            orderSetId.add(oi.OrderId);
        }
        
        List<Order> orderList = new List<Order>();        
        orderList = [Select Id,AccountId,Account.Market__c, ParentMembership__c FROM Order WHERE id in :orderSetId AND ParentMembership__c != null AND Account.Market__c = 'PH'];
        
        for(Order o : orderList){                  
            if(!ordersMap.containsKey(o.Id)){
                ordersMap.put(o.Id,o);
            }
        }
        return ordersMap;
    }

    //Added by Aswanth Aravapalli
    public static void getTransactionLastTwoYears(List<OrderItem> orderListItem){
        Set<ID> orderId = new Set<Id>();

        for(OrderItem ot: orderListItem){
            orderId.add(ot.OrderId);
        }

        List<Order> orderList = [Select Id, OrderedBy__c, OrderedBy__r.Total_Purchase_Amount_Adult_Brand__c, (Select Id, TotalPrice from OrderItems where Product_Family__c = 'Adult') from Order where Id IN :orderId and OrderedBy__r.Market__c =:CommonConstant.MARKET_TW];
        Set<ID> conID = new Set<Id>();

        for(Order o: orderList){
            if(String.isNotBlank(o.OrderedBy__c)){
                conID.add(o.OrderedBy__c);
            }
        }

        List<Contact> cu = new List<Contact>();
        Map<Id,Integer> mapC = new Map<Id,Integer>();
        Map<Id,Order> neworderMap = new Map<Id,Order>([Select Id,OrderedBy__c, (Select Id, TotalPrice from OrderItems where Product_Family__c = 'Adult') from Order where OrderedBy__c IN :conID ]);
        List<Contact> conList = [Select Id , (Select Id,OrderedBy__c from Orders__r   where OrderedBy__c IN :conID and status =: CommonConstant.ORDER_STATUS_COMPLETED AND EndDate = LAST_N_Days:730 AND EndDate < LAST_N_Days:1)from contact where id IN: conID];
        for(Contact c:conList){
            if(!c.Orders__r.IsEmpty()){
                for(Order ord: c.Orders__r ){
                    for(OrderItem oit : neworderMap.get(ord.id).OrderItems){
                        if(!mapC.isEmpty() && mapC.Containskey(c.id)){
                            Integer i = Integer.valueOf(mapC.get(c.id));
                            mapC.put(c.id,i+Integer.valueOf(oit.TotalPrice));
                        }
                        else{
                            mapC.put(c.id,Integer.valueOf(oit.TotalPrice));
                        }     
                    }
                }
            }else{
                mapC.put(c.id,0);
            }
        }

        for(Contact c : [Select id from contact where id IN :mapC.keySet()]){
            c.Total_Purchase_Amount_Adult_Brand__c = mapC.get(c.id);
            cu.add(c);
        }

        if(!cu.isEmpty()){
            UtilityClass.updateList(cu);
        }
    }

    //Added by Aswanth Aravapalli
    public static void getTransactionAnniversaryLastTwoYears(List<OrderItem> orderListItem){
        Set<ID> orderId = new Set<Id>();

        for(OrderItem ot: orderListItem){
            orderId.add(ot.OrderId);
        }
        List<Order> orderList = new List<Order>([Select Id,OrderedBy__c,OrderedBy__r.Total_Purchase_Anniversary_Amount_Adult__c, (Select Id,TotalPrice from OrderItems where Product_Family__c = 'Adult') from Order where Id IN :orderId and OrderedBy__r.Market__c =: CommonConstant.MARKET_TW]);
        Set<ID> conID = new Set<Id>();

        for(Order o: orderList){
            if(String.isNotBlank(o.OrderedBy__c)){
                conID.add(o.OrderedBy__c);
            }
        }

        List<Contact> cu = new List<Contact>();
        Map<Id,Integer> mapC = new Map<Id,Integer>();
        Map<Id,Order> neworderMap = new Map<Id,Order>([Select Id,OrderedBy__c, (Select Id, TotalPrice from OrderItems where Product_Family__c = 'Adult') from Order where OrderedBy__c IN :conID ]);
        List<Contact> conList = new List<Contact>([Select Id , (Select Id,OrderedBy__c from Orders__r   where OrderedBy__c IN :conID AND status =:CommonConstant.ORDER_STATUS_COMPLETED AND EndDate = LAST_N_Days:730 AND EndDate < LAST_N_Days:1)from contact where id IN: conID]);

        for(Contact c:conList){
            if(!c.Orders__r.IsEmpty()){
                for(Order ord: c.Orders__r ){
                    for(OrderItem oit : neworderMap.get(ord.id).OrderItems){
                        if(!mapC.isEmpty() && mapC.Containskey(c.id)){
                            Integer i = Integer.valueOf(mapC.get(c.id));
                            mapC.put(c.id,i+Integer.valueOf(oit.TotalPrice));
                        }
                        else{
                            mapC.put(c.id,Integer.valueOf(oit.TotalPrice));
                        }     
                    }
                }
           }else{
                mapC.put(c.id,0);
           }
        }

        for(Contact c : [Select id from contact where id IN :mapC.keySet()]){
            c.Total_Purchase_Anniversary_Amount_Adult__c = mapC.get(c.id);
            cu.add(c);
        }

        if(!cu.isEmpty()){
            UtilityClass.updateList(cu);
        }
    }

    // Checks if a product has already been ordered for a Child Contact record previously
    public static void checkPaidSampleProductOrdered(List<OrderItem> orderListItem) {
        if(orderListItem.isEmpty()) {
            System.debug('orderList is empty.');
            return;
        }

        try {
            // Set<Id> accountIds = new Set<Id>();
            Set<Id> productIds = new Set<Id>();
            Set<Id> orderedForIds = new Set<Id>();
            Set<Id> orderedByIds = new Set<Id>();
            Set<Id> orderIds = new Set<Id>();
            Id childRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_CHILD_RECORDTYPE).getRecordTypeId();
            Id adultRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_ADULT_RECORDTYPE).getRecordTypeId();
            

            for(OrderItem oi : orderListItem) {
                if(oi.OrderedFor__c != null) {
                    orderedForIds.add(oi.OrderedFor__c);
                }
                
                productIds.add(oi.Product2Id);
                orderIds.add(oi.OrderId);
            }

            Map<Id, Product2> productList = retrieveProductRecords(productIds);
            Map<Id, Order> orderList = retrieveCurrentOrderRecords(orderIds);
            Map<Id, Contact> orderedForList = new Map<Id, Contact>();
            Map<Id, Contact> orderedByList = new Map<Id, Contact>();
            Map<Id, Contact> contactMap;
            Map<Id, OrderItem> oiList = new Map<Id, OrderItem>();
            List<OrderItem> orderItemRecords;

            for(Id oID : orderList.keySet()) {
                orderedByIds.add(orderList.get(oID).OrderedBy__c);
            }

            Map<Id, Order> orderList2 = retrievePastOrderRecords(orderedByIds, orderedForIds);
            
            if(!orderedForIds.isEmpty()) {
                orderItemRecords = retrieveOrderItemRecords(orderedForIds, orderedByIds, productIds);
            }
            else {
                orderItemRecords = retrieveOrderItemRecords(null, orderedByIds, productIds);
            }

            if(!orderList2.isEmpty() && !orderItemRecords.isEmpty()) {
                for(Id oID : orderList2.keySet()) {
                    for(OrderItem oi : orderItemRecords) {
                        if(oi.Order.OrderedBy__c == orderList2.get(oID).OrderedBy__c) {
                            oiList.put(oID, oi);
                        }
                    }
                }
            }
            

            contactMap = retrieveContactRecords(orderedByIds);

            for(Id cId : contactMap.keySet()) {
                if(contactMap.get(cId).Parent__c != null) {
                    orderedForList.put(cId, contactMap.get(cId));
                }
                else {
                    orderedByList.put(cId, contactMap.get(cId));
                }
            }

            checkPaidSampleProductOrderedProcess(orderListItem, 'Paid Sample Product', childRecordTypeId, adultRecordTypeId, productList, orderList, orderList2, oiList, orderedForList, orderedByList);
            checkPaidSampleProductOrderedProcess(orderListItem, 'Promo Product', childRecordTypeId, adultRecordTypeId, productList, orderList, orderList2, oiList, orderedForList, orderedByList);
        }
        catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
            
        }
    }

    private static void checkPaidSampleProductOrderedProcess(List<OrderItem> orderListItem, String checkType, Id childRecordTypeId, Id adultRecordTypeId, Map<Id, Product2> productList, Map<Id, Order> orderList,
                                                                Map<Id, Order> orderList2, Map<Id, OrderItem> oiList, Map<Id, Contact> orderedForList, Map<Id, Contact> orderedByList) {

        Boolean flag = false; // Breaks the innrer loops to iterate to the next OrderItem if set to true
        String message = 'Customer is not eligible for First Time Promo: ';

        // The loop will immediately iterate to the next OrderItem if the product has already been ordered for the target previously
        for(OrderItem oi : orderListItem) {
            if(checkType == 'Paid Sample Product') {
                if(!orderList2.isEmpty() && !oiList.isEmpty()) {
                    for(Id oId2 : orderList2.keySet()) {
                        if(oi.OrderedFor__c != null && orderedForList.containsKey(oi.OrderedFor__c)) {
                            Contact orderedForCon = orderedForList.get(oi.OrderedFor__c);
                            if(orderedForCon.Account.Market__c == CommonConstant.MARKET_TW && oi.OrderedFor__c == orderedForCon.Id) {
                                for(Id pId : productList.keySet()) {
                                    if(orderedForCon.RecordTypeId == childRecordTypeId && oiList.containsKey(oId2)) {
                                        OrderItem oiExisting = oiList.get(oId2);
                                        if(oi.OrderedFor__c == oiExisting.OrderedFor__c && oi.Product_Code__c == oiExisting.Product_Code__c) {
                                            if(productList.get(pId).Stage1PaidSample__c) {
                                                oi.Product_Code__c.addError('The client has already ordered this stage 1 paid sample product before and cannot order it again.');
                                                flag = true;
                                                break;
                                            }

                                            if(productList.get(pId).Stage3PaidSample__c) {
                                                oi.Product_Code__c.addError('The client has already ordered this stage 3 paid sample product before and cannot order it again.');
                                                flag = true;
                                                break;
                                            }
                                        }
                                    }
                                }
    
                                if(flag) {
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            else if(checkType == 'Promo Product' && orderList.containsKey(oi.OrderId) && !orderList.get(oi.OrderId).CreatedFromCRRecord__c) {
                if(!orderList2.isEmpty()) {
                    for(Id oId2 : orderList2.keySet()) {
                        if(oi.OrderedFor__c != null && orderedForList.containsKey(oi.OrderedFor__c)) {
                            Contact orderedForCon = orderedForList.get(oi.OrderedFor__c);
                            if(orderedForCon.Account.Market__c == CommonConstant.MARKET_TW && oi.OrderedFor__c == orderedForCon.Id) {
                                for(Id pId : productList.keySet()) {
                                    Product2 prod = productList.get(pId);
                                    if(prod.Available_For_Promo__c) {
                                        if(orderedForCon.RecordTypeId == childRecordTypeId && orderedForCon.AgeinMonths__c >= prod.Min_Birth_Month__c &&
                                        orderedForCon.AgeinMonths__c <= prod.Max_Birth_Month__c) {
                                            if(prod.Max_eligible_for_Promo__c != null && oi.Quantity <= prod.Max_eligible_for_Promo__c) {
                                                if(!oiList.isEmpty() && oiList.containsKey(oId2)) {
                                                    OrderItem oiExisting = oiList.get(oId2);
                                                    Integer newQuantityInt = oi.Quantity != null ? oi.Quantity.intValue() : 0;
                                                    Integer existingQuantityInt = oiExisting.Quantity != null ? oiExisting.Quantity.intValue() : 0;
                                                    Integer sumQuantity = newQuantityInt + existingQuantityInt;
                                                    if(sumQuantity > prod.Max_eligible_for_Promo__c){
                                                        oi.Quantity.addError(message + 'Quantity is above Max Eligible For Promo');
                                                        flag = true;
                                                        break;
                                                    }
                                                    /*if(oi.Product_Code__c == oiExisting.Product_Code__c) {
                                                        oi.Product_Code__c.addError('The client has already ordered this promo product before and cannot order it again.');
                                                        flag = true;
                                                        break;
                                                    }*/
                                                }
                                                
                                            }
                                            else {
                                                oi.Quantity.addError(message + 'Quantity is above Max Eligible For Promo');
                                                flag = true;
                                                break;
                                            }
                                            
                                        }
                                        else {
                                            oi.Product2Id.addError(message + 'Your child is outside of the product\'s age range.');
                                            flag = true;
                                            break;
                                        }
                                    }
                                }
    
                                if(flag) {
                                    break;
                                }
                            }
                        }
                        else {
                            if(orderList.containsKey(oi.OrderId) && orderList.get(oi.OrderId).OrderedBy__c != null && orderedByList.containsKey(orderList.get(oi.OrderId).OrderedBy__c)){
                                Contact orderedByCon = orderedByList.get(orderList.get(oi.OrderId).OrderedBy__c);
                                if(orderedByCon.Account.Market__c == CommonConstant.MARKET_TW) {
                                    for(Id pId : productList.keySet()) {
                                        Product2 prod = productList.get(pId);
                                        if(prod.Available_For_Promo__c) {
                                            if(orderedByCon.RecordTypeId == adultRecordTypeId && orderedByCon.EstimatedDueDate__c != null) {
                                                Integer birthMonths = orderedByCon.EstimatedDueDate__c.monthsBetween(Date.today());
                                                if(birthMonths >= prod.Min_Birth_Month__c && birthMonths <= prod.Max_Birth_Month__c) {
                                                    if(prod.Max_eligible_for_Promo__c != null && oi.Quantity <= prod.Max_eligible_for_Promo__c) {
                                                        if(!oiList.isEmpty() && oiList.containsKey(oId2)) {
                                                            OrderItem oiExisting = oiList.get(oId2);
                                                            Integer newQuantityInt = oi.Quantity != null ? oi.Quantity.intValue() : 0;
                                                            Integer existingQuantityInt = oiExisting.Quantity != null ? oiExisting.Quantity.intValue() : 0;
                                                            Integer sumQuantity = newQuantityInt + existingQuantityInt;
                                                            if(sumQuantity > prod.Max_eligible_for_Promo__c){
                                                                oi.Quantity.addError(message + 'Quantity is above Max Eligible For Promo');
                                                                flag = true;
                                                                break;
                                                            }
                                                            /*if(oi.Product_Code__c == oiList.get(oId2).Product_Code__c) {
                                                                oi.Product_Code__c.addError('The client has already ordered this promo product before and cannot order it again.');
                                                                flag = true;
                                                                break;
                                                            }*/
                                                        }
                                                    }
                                                    else {
                                                        oi.Quantity.addError(message + 'Quantity is above Max Eligible For Promo');
                                                        flag = true;
                                                        break;
                                                    }
                                                }
                                                else {
                                                    oi.Product2Id.addError(message + 'Your child is outside of the product\'s age range.');
                                                    flag = true;
                                                    break;
                                                }
                                            }
                                            
                                            if(flag) {
                                                break;
                                            }
                                        }
                                    }
        
                                    if(flag) {
                                        break;
                                    }
                                }
                            } 
                        }
                    }
                }
                else {
                    if(oi.OrderedFor__c != null) {
                        if(orderedForList.containsKey(oi.OrderedFor__c)){
                            Contact orderedFor = orderedForList.get(oi.OrderedFor__c);
                            if(orderedFor.Account.Market__c == CommonConstant.MARKET_TW && oi.OrderedFor__c == orderedFor.Id) {
                                for(Id pId : productList.keySet()) {
                                    Product2 prod = productList.get(pId);
                                    if(prod.Available_For_Promo__c) {
                                        if(orderedFor.RecordTypeId == childRecordTypeId && orderedFor.AgeinMonths__c >= prod.Min_Birth_Month__c &&
                                        orderedFor.AgeinMonths__c <= prod.Max_Birth_Month__c) {
                                            if(oi.Quantity > prod.Max_eligible_for_Promo__c) {
                                                oi.Quantity.addError(message + 'Quantity is above Max Eligible For Promo');
                                                flag = true;
                                                break;
                                            }
                                        }
                                        else {
                                            oi.Product2Id.addError(message + 'Your child is outside of the product\'s age range.');
                                            flag = true;
                                            break;
                                        }
                                    }
                                }
                                
                                if(flag) {
                                    break;
                                }
                            }
                        }
                    }
                    else {
                        if(orderList.containsKey(oi.OrderId) && orderList.get(oi.OrderId).OrderedBy__c != null && orderedByList.containsKey(orderList.get(oi.OrderId).OrderedBy__c)){
                            Contact orderedByCon = orderedByList.get(orderList.get(oi.OrderId).OrderedBy__c);
                            if(orderedByCon.Account.Market__c == CommonConstant.MARKET_TW) {
                                for(Id pId : productList.keySet()) {
                                    Product2 prod = productList.get(pId);
                                    if(prod.Available_For_Promo__c) {
                                        if(orderedByCon.RecordTypeId == adultRecordTypeId && orderedByCon.EstimatedDueDate__c != null) {
                                            Integer birthMonths = orderedByCon.EstimatedDueDate__c.monthsBetween(Date.today());
                                            if(birthMonths >= prod.Min_Birth_Month__c && birthMonths <= prod.Max_Birth_Month__c) {
                                                if(oi.Quantity > prod.Max_eligible_for_Promo__c) {
                                                    oi.Quantity.addError(message + 'Quantity is above Max Eligible For Promo');
                                                    flag = true;
                                                    break;
                                                }
                                            }
                                            else {
                                                oi.Product2Id.addError(message + 'Your child is outside of the product\'s age range.');
                                                flag = true;
                                                break;
                                            }
                                        }
                                        
                                        if(flag) {
                                            break;
                                        }
                                    }
                                }
                                
                                if(flag) {
                                    break;
                                }
                            }
                        }
                    }
                }      

                if(flag) {
                    break;
                }
            }

            if(flag) {
                break;
            }
        }
    }

    /*
    public static void updateContactPurchasedTWPEDStandardProduct(List<OrderItem> orderListItem) {
        if(orderListItem.isEmpty()) {
            System.debug('orderList is empty.');
            return;
        }

        try {
            Set<Id> orderedForIds = new Set<Id>();
            Set<Id> pricebookEntryIds = new Set<Id>();
            Set<Id> orderIds = new Set<Id>();
            Set<Id> productIds = new Set<Id>();
            Boolean flag = false;
            Id childRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_CHILD_RECORDTYPE).getRecordTypeId();

            for(OrderItem oi : orderListItem) {
                if(oi.OrderedFor__c != null) {
                    orderedForIds.add(oi.OrderedFor__c);
                }
                
                orderIds.add(oi.OrderId);
                productIds.add(oi.Product2Id);
                pricebookEntryIds.add(oi.PricebookEntryId);
            }

            if(!orderedForIds.isEmpty()) {
                Map<Id, PricebookEntry> pricebookEntryList = retrievePricebookEntryRecords(pricebookEntryIds);

                for(Id pbeId : pricebookEntryIds) {
                    if(pricebookEntryList.get(pbeId) != null) {
                        flag = true;

                        break;
                    }
                }

                if(flag) {
                    Map<Id, Order> orderList = retrieveCurrentOrderRecords(orderIds);
                    Map<Id, Product2> productList = retrieveProductRecords(productIds);
                    List<Contact> contactRecordsToUpdate = new List<Contact>();
                    Set<Id> orderedByIds = new Set<Id>();

                    for(Id oID : orderList.keySet()) {
                        orderedByIds.add(orderList.get(oID).OrderedBy__c);
                    }

                    Map<Id, Contact> orderedForList = new Map<Id, Contact>();
                    Map<Id, Contact> orderedByList = new Map<Id, Contact>();
                    Map<Id, Contact> contactMap = retrieveContactRecords(orderedByIds);

                    for(Id cId : contactMap.keySet()) {
                        if(contactMap.get(cId).Parent__c != null) {
                            orderedForList.put(cId, contactMap.get(cId));
                        }
                        else {
                            orderedByList.put(cId, contactMap.get(cId));
                        }
                    }

                    for(OrderItem oi : orderListItem) {
                        if(oi.OrderedFor__c != null) {
                            if(orderedForList.get(oi.OrderedFor__c).Account.Market__c == CommonConstant.MARKET_TW) {
                                // mark this contact
                                if(pricebookEntryList.get(oi.PricebookEntryId).Id != null && orderedForList.get(oi.OrderedFor__c).RecordTypeId == childRecordTypeId &&
                                    !orderedForList.get(oi.OrderedFor__c).Purchased_Standard_PED_Product__c &&
                                    !productList.get(pricebookEntryList.get(oi.PricebookEntryId).Product2Id).Available_For_Promo__c &&
                                    !productList.get(pricebookEntryList.get(oi.PricebookEntryId).Product2Id).Stage1PaidSample__c &&
                                    !productList.get(pricebookEntryList.get(oi.PricebookEntryId).Product2Id).Stage3PaidSample__c) {
                                    orderedForList.get(oi.OrderedFor__c).Purchased_Standard_PED_Product__c = true;
                                    contactRecordsToUpdate.add(orderedForList.get(oi.OrderedFor__c));
                                }
                            }
                        }
                    }

                    if(!contactRecordsToUpdate.isEmpty()) {
                        UtilityClass.updateList(contactRecordsToUpdate);
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    */

    private static Map<Id, Product2> retrieveProductRecords(Set<Id> productIds) {
        return new Map<Id, Product2>([SELECT Id, Name, Min_Bulk_Quantity__c, Bulk_Consumption_Days__c, Family, Stage1PaidSample__c, Stage3PaidSample__c,
        Available_For_Promo__c, Min_Birth_Month__c, Max_Birth_Month__c, Max_eligible_for_Promo__c FROM Product2 WHERE Id IN :productIds]);
    }

    private static Map<Id, Contact> retrieveContactRecords(Set<Id> contactIds) {
        return new Map<Id, Contact>([SELECT Id, Name, AccountId, Account.Market__c, RecordTypeId, Parent__c, AgeinMonths__c, Purchased_Standard_PED_Product__c, Have_Purchased_Paid_Sample__c, EstimatedDueDate__c
                                    FROM Contact WHERE Id IN :contactIds OR Parent__c IN :contactIds]);
    }

    private static Map<Id, Order> retrieveCurrentOrderRecords(Set<Id> orderIds) {
        return new Map<Id, Order>([SELECT Id, Name, OrderedBy__c, CreatedFromCRRecord__c FROM Order WHERE Id IN :orderIds]);
    }

    private static Map<Id, Order> retrievePastOrderRecords(Set<Id> orderedByIds, Set<Id> orderedForIds) {
        return new Map<Id, Order>([SELECT Id, Name, OrderedBy__c, (SELECT Id, OrderedFor__c FROM OrderItems WHERE OrderedFor__c IN :orderedForIds) FROM Order WHERE OrderedBy__c IN :orderedByIds AND
                                                                Status IN ('Completed', 'Transferred', 'Submitted') LIMIT 100]);
    }

    private static List<OrderItem> retrieveOrderItemRecords(Set<Id> orderedForIds, Set<Id> orderedByIds, Set<Id> productIds) {
        return [SELECT Id, OrderId, Order.OrderedBy__c, Order.Status, Product2Id, OrderedFor__c, Product_Code__c FROM OrderItem
                WHERE OrderedFor__c IN :orderedForIds AND Order.OrderedBy__c IN :orderedByIds AND Product2Id IN :productIds AND Order.Status IN ('Completed', 'Transferred', 'Submitted') LIMIT 100];
    }

    private static Map<Id, PricebookEntry> retrievePricebookEntryRecords(Set<Id> pricebookEntryIds) {
        return new Map<Id, PricebookEntry>([SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Id = :pricebookEntryIds AND Pricebook2.Name =: CommonConstant.TW_PED_STANDARD_PRICEBOOK]);
    }
}