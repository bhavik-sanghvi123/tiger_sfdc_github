@isTest
public class OrderProductTrigger_DummyBatch_Test {
    @testSetup
    static void setup() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'TW');
   		insert sysad;
        
        System.runAs(sysad) {
            List<Account> lAccount = new List<Account>();
            lAccount.add(TestDataFactory.createTestHouseholdNoInsert(1, CommonConstant.MARKET_TW)[0]);
            UtilityClass.insertList(lAccount);
            
            List<Contact> lContact = new List<Contact>();
            lContact.add(TestDataFactory.createTestAdultContactNoInsert(1, lAccount.get(0).Id)[0]);
            lContact.add(TestDataFactory.createTestChildContactNoInsert(1, lAccount.get(0).Id)[0]);
            UtilityClass.insertList(lContact);
            
            List<PricebookEntry> entryList = new List<PricebookEntry>();
            entryList.add(TestDataFactory.createPricebookEntry(CommonConstant.MARKET_TW));
            UtilityClass.insertList(entryList);
            
            List<Order> lOrder = new List<Order>();
            lOrder.addAll(TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId()));
            UtilityClass.insertList(lOrder);
            
            List<OrderItem> orderItemList = new List<OrderItem>();
            orderItemList.add(TestDataFactory.createOrderItem(lOrder[0].Id, entryList[0].Id));
            orderItemList.add(TestDataFactory.createOrderItem(lOrder[1].Id, entryList[0].Id));
            UtilityClass.insertList(orderItemList);
        }
    }
    
	static testMethod void runOrderProductTrigger_DummyBatch_Test(){
        Test.startTest();
        List<Product2> pList = [SELECT Id, Family FROM Product2];
        List<Order> oList = [SELECT Id, Status, Account.Market__c FROM Order];
        
        for(Product2 p : pList) {
            p.Family = CommonConstant.ANDPRODUCT;
        }
        
        for(Order o : oList) {
            o.Status = CommonConstant.ORDER_STATUS_COMPLETED;
        }
        
        UtilityClass.updateList(pList);
        UtilityClass.updateList(oList);
            
        Database.executebatch(new OrderProductTrigger_DummyBatch());
        Test.stopTest();
    }
}