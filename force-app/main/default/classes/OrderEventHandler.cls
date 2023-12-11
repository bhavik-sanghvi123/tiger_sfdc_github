/*------------------------------------------------------------
Author:      Jericson Mercado
Description: Change Event class for Order object

History
06/01/2020   jericson   Created
10/29/2020   malviz     Added updateMembershipPH  
11/03/2020   joyvette   updated updateBrandRelationship
11/20/2020   malviz     TKT-002670: updateBrandRelationship - filter out Sample Order on Status/Type update
1/20/2021    maviz      TKT-003115: updateContactOptOutSG
1/21/2021    malviz     Added updateMCEligibility
3/29/2021    makiz      updated updateContactOptOutSG, moved updateMCEligibility to OrderTrigger before insert
08/03/2021   mparihar   Updated updateContactTransactionDate method (added check for TW Market)
09/22/2021   mparihar   added transactiondate null logic
-------------------------------------------------------------------------------------------*/

public class OrderEventHandler {

    public static void processEvent(List<OrderChangeEvent> events) {
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> updateBrandRelationshipIds = new Set<Id>();
        Map<Id, OrderChangeEvent> updateContactTransactionList = new Map<Id, OrderChangeEvent>();
        Map<Id, OrderChangeEvent> updateMembershipList = new Map<Id, OrderChangeEvent>();
        Map<Id, OrderChangeEvent> updateMembershipPHList = new Map<Id, OrderChangeEvent>();
        Map<Id, OrderChangeEvent> updateContactOptOutList = new Map<Id, OrderChangeEvent>();
        Set<Id> updateMCEligibilityIds = new Set<Id>();
        
        for(OrderChangeEvent event: events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;

            for (Integer index = 0; index < header.recordIds.size(); index++) {

                // CREATE
                if(header.changeType == 'CREATE') {
                    orderIds.add(header.recordIds[0]);

                    if(event.Status == 'Completed'
                        && event.OrderedBy__c != null){
                        updateContactTransactionList.put(header.recordIds[0], event);
                    }

                    if(event.ParentMembership__c != null){
                        updateMembershipList.put(header.recordIds[0],event);
                    }
                    
                    if(event.Type == 'Sample Request'){
                        updateContactOptOutList.put(header.recordIds[0],event);
                    }
                    
                    /*// Update MC Eligibility Fields
                    if(event.Orderedby__c != null){
                        updateMCEligibilityIds.add(header.recordIds[0]);
                    }*/
                }

                // UPDATE
                else if(header.changeType == 'UPDATE') {

                    if(header.changedFields.contains('Status')
                        && event.Status == 'Completed') {
                        updateBrandRelationshipIds.add(header.recordIds[index]);
                    }

                    /*if(header.changedFields.contains('Status')
                        && header.changedFields.contains('EndDate') ) {
                        //updateMembershipList.add(header.recordIds[0]);
                    }*/

                    if(header.changedFields.contains('OrderedBy__c')
                        || header.changedFields.contains('Status')) {
                        updateContactTransactionList.put(header.recordIds[index], event);
                    }
                    
                    if(header.changedFields.contains('ParentMembership__c') 
                        && event.ParentMembership__c != null){
                        updateMembershipPHList.put(header.recordIds[index],event);
                    }
                }
            }
        }

        if(!orderIds.isEmpty()) orderCount(orderIds);
        if(!updateContactTransactionList.isEmpty()) updateContactTransactionDate(updateContactTransactionList);
        if(!updateBrandRelationshipIds.isEmpty()) updateBrandRelationship(updateBrandRelationshipIds);
        if(!updateMembershipList.isEmpty()) updateMembership(updateMembershipList);
        if(!updateMembershipPHList.isEmpty()) updateMembershipPH(updateMembershipPHList);
        if(!updateContactOptOutList.isEmpty()) updateContactOptOutSG(updateContactOptOutList);
        //if(!updateMCEligibilityIds.isEmpty()) updateMCEligibility(updateMCEligibilityIds);
    }

    // updates case
    public static void orderCount(Set<Id> orderIds){
        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        
        for(Order o: [SELECT Case__c,
                             Case__r.Order_Count__c
                        FROM Order
                       WHERE Id IN: orderIds
                         AND Case__c != null
                         AND Case__r.RecordType.Name = 'Call']) {

            Decimal count = o.Case__r.Order_Count__c == null ?
                            0 : o.Case__r.Order_Count__c;

            Case c = caseMap.containsKey(o.Case__c) ?
                     caseMap.get(o.Case__c) :
                     new Case( Id = o.Case__c,
                               Order_Count__c = count);
            c.Order_Count__c += 1;
            caseMap.put(c.Id, c);
        }

        if(!caseMap.isEmpty()) UtilityClass.updateList(caseMap.values());
    }

    // update contact
    public static void updateContactTransactionDate(Map<Id, OrderChangeEvent> orderEventMap) {
        Set<Id> conIdSet = new Set<Id>();
        Set<Id> membershipIdSet = new Set<Id>();
        Set<Id> oldMembershipIdSet = new Set<Id>();
        Set<Id> endDateUpdateMembershipIsSet = new Set<Id>();
        Date transactiondate;
        
        for(Order o :[SELECT OrderedBy__c, EndDate, Status
                        FROM Order
                       WHERE Id IN: orderEventMap.keySet()
                         AND OrderedBy__c != null]) {
            conIdSet.add(o.OrderedBy__c);

            OrderChangeEvent event = orderEventMap.get(o.Id);
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            if(header.changeType == 'UPDATE'
                && header.changedFields.contains('Orderedby__c'))
                conIdSet.add( (Id) event.OrderedBy_old__c);
        }
        List<Contact> contactList = new List<Contact>();
        for (Contact con : [SELECT Market__c,FirstTransaction__c, FirstTransactionDate__c, LatestTransaction__c,
                                   LatestTransactionDate__c, MembershipStartDate__c, 
                                    (SELECT EndDate,Type
                                        FROM Orders__r
                                        WHERE EndDate != null
                                        AND Status = 'Completed'
                                    ORDER BY EndDate, OrderNumber) 
                              FROM Contact
                             WHERE Id IN: conIdSet]) {
            transactiondate = null; //added by monika for FirstTrasactionDate issue (earlier failing for multiple order update)                
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
            Contact con2 = new Contact(Id = con.Id,
                                        FirstTransaction__c = con.FirstTransaction__c,
                                        FirstTransactionDate__c = con.FirstTransactionDate__c,
                                        LatestTransaction__c = con.LatestTransaction__c,
                                        LatestTransactionDate__c = con.LatestTransactionDate__c,
                                        MembershipStartDate__c = con.MembershipStartDate__c);
 
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

            // check if anything changed
            if(con.FirstTransaction__c != con2.FirstTransaction__c
                || con.FirstTransactionDate__c != con2.FirstTransactionDate__c
                || con.LatestTransaction__c != con2.LatestTransaction__c
                || con.LatestTransactionDate__c != con2.LatestTransactionDate__c
                || con.MembershipStartDate__c != con2.MembershipStartDate__c) {
                contactList.add(con);
            }
        }
        if (!contactList.isEmpty()) UtilityClass.updateList(contactList);
    }

    public static void updateBrandRelationship(Set<Id> orderIds) {
        Map<String, String> orderContactMap = new Map<String, String>();
        Set<Id> realOrder = new Set<Id>();

        for(Order o : [SELECT OrderedBy__c, Type
                         FROM Order
                        WHERE Id IN: orderIds
                          AND OrderedBy__c != null
                          AND Status = 'Completed']) {
            orderContactMap.put(o.Id , o.OrderedBy__c);

            //get real Orders (not Sample) 
            if(o.Type != 'Sample Request') realOrder.add(o.Id);
        }

        if(!orderContactMap.isEmpty()) {
            Map<String, Set<String>> contactProductMap = new Map<String, Set<String>>();
            Map<String, List<OrderItem>> BRProductContactMap = new Map<String, List<OrderItem>>();
            for (OrderItem oItem : [Select Product2.KeyBrand__c, Product2.BrandRelationshipLink__c, OrderId, Order.EndDate From OrderItem Where OrderId IN: orderContactMap.keySet() ]) {
                String contactId = orderContactMap.get(oItem.OrderId);

                if(realOrder.contains(oItem.OrderId)){
                    if(!contactProductMap.containsKey(contactId))
                        contactProductMap.put(contactId, new Set<String>());
                    contactProductMap.get(contactId).add(oItem.Product2.KeyBrand__c);
                }

                // create map of contact - product2
                if(oItem.Product2.BrandRelationshipLink__c != null){
                    String key = contactId + '-' + oItem.Product2.BrandRelationshipLink__c;
                    if(!BRProductContactMap.containsKey(key))
                        BRProductContactMap.put(key, new List<OrderItem>());
                    BRProductContactMap.get(key).add(oItem);
                }            
            }

            Map<Id, BrandRelationship__c> toUpdateBrand = new Map<Id, BrandRelationship__c>();
            Map<Id, OrderItem> oiMap = new Map<Id, OrderItem>();
            for (Contact con : [SELECT (SELECT KeyBrand__c, Status__c, Type__c, WinBack__c, BrandRelationship__c, FirstTransactionDate__c, LatestTransactionDate__c FROM BrandRelationships__r),
                                        (SELECT KeyBrand__c, PrimaryContact__c, Status__c, Type__c, WinBack__c, BrandRelationship__c, FirstTransactionDate__c, LatestTransactionDate__c FROM MainBrandRelationships__r)
                                    FROM Contact
                                   WHERE ID IN: orderContactMap.values()]) {
                       
                Set<String> productBrand = contactProductMap.get(con.Id);
                //replaced BrandRelationships__r with MainBrandRelationships__r
                for (BrandRelationship__c brand : con.MainBrandRelationships__r) {

                    // TKT-002670: dont update type & status for sample orders
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
                    
                    if(forUpdate) toUpdateBrand.put(brand.Id, brand);
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

                    if(forUpdate) toUpdateBrand.put(brand.Id, brand);
                }
            }

            if(!toUpdateBrand.isEmpty()) UtilityClass.updateList(toUpdateBrand.values());
            if(!oiMap.isEmpty()) UtilityClass.updateList(oiMap.values());
        }
    }
    
     // update membership
    public static void updateMembership(Map<Id, OrderChangeEvent> orderMap) {
        List<Membership__c> memList = new List<Membership__c>();
      
        for(Membership__c mem: [SELECT Status__c
                                    FROM Membership__c
                                   WHERE Id IN (SELECT ParentMembership__c FROM Order WHERE ID IN: orderMap.keySet()) AND Status__c = 'Expired'] ) {                                      
                                       
                mem.Status__c = 'Activated';
                memList.add(mem);  
      }
        
        if(!memList.isEmpty()) UtilityClass.updateList(memList);
    } 
    
    // TKT-002646: update membership recent Product
    // Only For PH
    public static void updateMembershipPH(Map<Id, OrderChangeEvent> orderMap) {
        List<Membership__c> membershipsToUpdate = new List<Membership__c>();
        List<Order> orderList = new List<Order>([SELECT Id,
                                                 (SELECT Id, OrderId, Product2Id from OrderItems ORDER BY ServiceDate DESC Limit 1)
                                                 FROM Order where Id IN :orderMap.keySet() AND Account.Market__c = 'PH']);
        
        List<Membership__c> membershipList = new List<Membership__c>([SELECT Status__c, Recent_Product_Purchased__c,
                                (SELECT EndDate FROM Orders__r WHERE Status != 'Cancelled - New Order Created' AND Status != 'Cancelled - Before Delivery' AND Status != 'Cancelled - Upon Delivery' AND Status != 'Cancelled - Abandoned' 
                                    ORDER BY CreatedDate DESC LIMIT 1) 
                                    FROM Membership__c
                                   WHERE Id IN (SELECT ParentMembership__c FROM Order WHERE ID IN: orderMap.keySet()) AND Contact__r.Market__c = 'PH'] );
        
        // create map of Order - Latest Order Product Id
        Map<Id,Id> orderItemsMap = new Map<Id,Id>();
        for(Order o : orderList){
           
            for(OrderItem oi : o.OrderItems){
                if(!orderItemsMap.containsKey(o.Id)){
                    orderItemsMap.put(oi.OrderId, oi.Product2Id);
                }
            }
        }
        
        for(Membership__c mem: membershipList) {  
            Boolean toUpdate = false;
            if(!mem.Orders__r.isEmpty()) { 
                for(Order o : mem.Orders__r) {
                    if(orderItemsMap.containsKey(o.Id) && mem.Recent_Product_Purchased__c != orderItemsMap.get(o.Id)){                     
                        mem.Recent_Product_Purchased__c = orderItemsMap.get(o.Id);
                        toUpdate = true; 
                    }
                }
            }
            if(toUpdate){
                membershipsToUpdate.add(mem); 
            }
        }
        if(!membershipsToUpdate.isEmpty()) UtilityClass.updateList(membershipsToUpdate);
    }
    
    // TKT-003115: update contact opt out fields when sample request is created
    // TKT-003675: clear opt out dates in case boolean is already false and date is populated
    // Only For SG
    public static void updateContactOptOutSG(Map<Id, OrderChangeEvent> orderMap) {
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id,MasterOptOut__c,DoNotCall,HasOptedOutOfEmail,WhatsappOptOut__c,SMSOptOut__c,DataSharingWithThirdPartyOptOut__c,
                                                          DoNotCallDate__c,EmailOptOutDate__c,WhatsappOptOutDate__c,SMSOptOutDate__c,DataSharingOptOutDate__c
                                                          from Contact 
                                                          where Id IN (SELECT Orderedby__c FROM Order WHERE ID IN: orderMap.keySet()) AND Account.Market__c = 'SG'] );
        List<Order> orderList = new List<Order>([SELECT Id,Type
                                                 FROM Order where Id IN :orderMap.keySet() AND Account.Market__c = 'SG']);
        
        for(Contact con : contactMap.values()){
            Boolean toUpdate = false;
            
            if(con.DoNotCallDate__c != null){
                con.DoNotCall = false;
                con.DoNotCallDate__c = null;
                toUpdate = true; 
            }
            if(con.EmailOptOutDate__c != null){
                con.HasOptedOutOfEmail = false;
                con.EmailOptOutDate__c = null;
                toUpdate = true; 
            }
            if(con.WhatsappOptOutDate__c != null){
                con.WhatsappOptOut__c = false;
                con.WhatsappOptOutDate__c = null;
                toUpdate = true; 
            }
            if(con.SMSOptOutDate__c != null){
                con.SMSOptOut__c = false;
                con.SMSOptOutDate__c = null;
                toUpdate = true; 
            }
            if(con.DataSharingOptOutDate__c != null){
                con.DataSharingWithThirdPartyOptOut__c = false;
                con.DataSharingOptOutDate__c = null;
                toUpdate = true; 
            }
            
            if(toUpdate){
                contactsToUpdate.add(con); 
            }
        }
        
        if(!contactsToUpdate.isEmpty()) UtilityClass.updateList(contactsToUpdate);
    }
  
}