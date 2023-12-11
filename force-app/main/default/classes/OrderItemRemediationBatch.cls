/*----------------------------------------------------------------------------------------
* Script to calculatete Order Item and Order values
*   - Order: Total Discount Amount, Total GST Amount
*   - Order Product: Unit Price, Discount Amount, GST
-------------------------------------------------------------------------------------------*/
// for deletion
global class OrderItemRemediationBatch {} /* implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,'
                            + ' OrderId,'
                            + ' Product2Id,'
                            + ' UnitPrice,'
                            + ' DiscountAmount__c,'
                            + ' GST__c,'
                            + ' Quantity,'
                            + ' Order.TotalDiscountAmount__c,'
                            + ' Order.TotalGSTAmount__c'
                            + ' FROM OrderItem WHERE CreatedDate >= 2019-09-15T23:02:52.000+0000'
                            + ' AND CreatedBy.Name != \'Data Migration\''
                            + ' AND DiscountAmount__c > 0'
                            + ' ORDER BY OrderId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderItem> scope) {
       	Id pricebookId;
        
        if(System.Test.isRunningTest()) {
        	pricebookId = System.Test.getStandardPricebookId();
        } else {
        	pricebookId = [SELECT Id FROM Pricebook2 WHERE Name = 'Telesales Products 2019 (with 20% off) SG'].Id;
        }
        
        List<PricebookEntry> pbeList = [SELECT Product2Id, Product2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :pricebookId];
        List<OrderItem> orderItemList = new List<OrderItem>();
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id,Decimal> prodMap = new Map<Id,Decimal>();

        for(OrderItem oi : scope) {
            if(oi.OrderId != null) {
                orderIdSet.add(oi.OrderId);
            }
        }

        for(PricebookEntry pbe : pbeList) {
            prodMap.put(pbe.Product2Id, pbe.UnitPrice);
        }
          

        Map<Id,Order> orderMap = new Map<Id,Order>([SELECT TotalDiscountAmount__c, TotalGSTAmount__c
                                                    FROM Order 
                                                    WHERE Id IN :orderIdSet]);
        
        for(Order order : orderMap.values()) {
            order.TotalDiscountAmount__c = 0;
            order.TotalGSTAmount__c = 0;
            orderMap.put(order.Id, order);
        }
        Database.update(orderMap.values(), false);

        for(OrderItem oi : scope) {
            Decimal initialDiscount = 0.00;
            Decimal initialPrice = 0.00;
            Decimal initialGST = 0.00;
            
            if(prodMap.containsKey(oi.Product2Id)) {
                initialDiscount = prodMap.get(oi.Product2Id)* 0.20;
                initialPrice = prodMap.get(oi.Product2Id) - initialDiscount;
                initialGST = initialPrice * 0.07;

                oi.GST__c = initialGST * oi.Quantity;
                oi.DiscountAmount__c = initialDiscount * oi.Quantity;
                oi.UnitPrice = prodMap.get(oi.Product2Id) - initialDiscount + initialGST;
                orderItemList.add(oi);

                if(oi.OrderId != null) {
                    orderMap.get(oi.OrderId).TotalDiscountAmount__c = orderMap.get(oi.OrderId).TotalDiscountAmount__c + (initialDiscount * oi.Quantity);
                    orderMap.get(oi.OrderId).TotalGSTAmount__c = orderMap.get(oi.OrderId).TotalGSTAmount__c + (initialGST * oi.Quantity);
                    orderMap.put(oi.OrderId, orderMap.get(oi.OrderId));
                }
            }
        }

        Database.update(orderItemList, false);
        Database.update(orderMap.values(), false);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
} */