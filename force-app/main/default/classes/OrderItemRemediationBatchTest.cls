// @isTest for deletion
public class OrderItemRemediationBatchTest {} /* 
    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'SG');
        insert sysad;
        
        System.runAs(sysad) {
            List<Account> accountList = TestDataFactory.createTestHousehold(1);
            List<Contact> contactList = TestDataFactory.createTestAdultContact(1, accountList.get(0).Id);
            PricebookEntry pbEntry = TestDataFactory.createPricebookEntry();
            insert pbEntry;
            
            //update Pricebook details
            Pricebook2 pb = [SELECT Id, Market__c, DefaultForTelesales__c FROM Pricebook2 LIMIT 1];
            pb.DiscountPercentage__c = 20.00;
            pb.Market__c = CommonConstant.MARKET_SG;
            pb.DefaultForTelesales__c = TRUE;
            update pb;
            
            //Update Product details
            Product2 prod = [SELECT Id, Market__c, AvailableForOrder__c FROM Product2 LIMIT 1];
            prod.Market__c = CommonConstant.MARKET_SG;
            prod.AvailableForOrder__c = TRUE;
            update prod;
            
            //Create Order
			List<Order> lOrder = TestDataFactory.createOrder(1, accountList.get(0).Id, contactList.get(0).Id, pb.Id);
			insert lOrder;			
            
            //Create Order Item
            OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, pbEntry.Id);
            insert item;
            item.DiscountAmount__c = 50.00;
            update item;
            Test.setCreatedDate(item.Id, DateTime.newInstance(2019,09,17));
        }
    }

    public static testMethod  void testBatchJob() {        
        System.Test.startTest();
            OrderItemRemediationBatch oirb = new OrderItemRemediationBatch();
            Database.executeBatch(oirb, 200);
        System.Test.stopTest();
    }
} */