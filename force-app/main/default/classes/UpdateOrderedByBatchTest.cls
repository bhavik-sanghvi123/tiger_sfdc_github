@isTest 
public class UpdateOrderedByBatchTest{

    @testsetup
    static void setupData() {
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);
        lAccount[0].External_Id__c = 'ph-orphan-tangent-orders';
        update lAccount;

        List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        
        List<Membership__c> lMembership = TestDataFactory.createMembership(1, lContact.get(0).Id, -90);
        lMembership[0].MembershipId__c = 'TESTMEM1';
        update lMembership[0];

        List<Order> lOrder = TestDataFactory.createOrder(2, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
        insert lOrder; 
        
        PricebookEntry entry = TestDataFactory.createPricebookEntry();
        insert entry;

        OrderItem orderItem = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
        insert orderItem;
        lOrder[0].ParentMembership__c = lMembership.get(0).Id;
        lOrder[0].Status = 'Submitted';
        update lOrder[0];
    }

    public static testMethod  void testBatchJob() {
        List<Membership__c> lMembership = [SELECT Id, Contact__c FROM Membership__c LIMIT 1];

        System.Test.startTest();
            UpdateOrderedByBatch uob = new UpdateOrderedByBatch();
            Database.executeBatch(uob, 200);

            UpdateOrderedBySchedule job = new UpdateOrderedBySchedule();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Link Orders to Contacts via Membership Test', sch, job);
            
        System.Test.stopTest();

        List<Order> lOrderAfterUpdate = [SELECT Id, OrderedBy__c FROM Order LIMIT 1];
        System.assertEquals(lMembership[0].Contact__c, lOrderAfterUpdate[0].OrderedBy__c, 'Ordered By field should be updated after batch run');
    }
}