@isTest 
public class UpdateMembershipDetailsBatchTest{

    @testsetup
    static void setupData() {
    
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);
        List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        List<Membership__c> lMembership = TestDataFactory.createMembership(1, lContact.get(0).Id, -90);
        lMembership[0].MembershipId__c = 'TESTMEM1';
        update lMembership[0];

    }

    public static testMethod  void testCreateMembership() {
        List<Membership__c> membershipListBeforeUpdate = [SELECT Id, MembershipStartDate__c, MembershipExpiryDate__c FROM Membership__c LIMIT 1];

        System.Test.startTest();
            UpdateMembershipDetailsBatch umd = new UpdateMembershipDetailsBatch();
            Database.executeBatch(umd, 200);

            UpdateMembershipDetailsSchedule job = new UpdateMembershipDetailsSchedule();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Member Details Batch Job', sch, job);
            
        System.Test.stopTest();

        List<Membership__c> membershipListAfterUpdate = [SELECT Id, Status__c, MembershipExpiryDate__c FROM Membership__c LIMIT 1];
        System.assertEquals((membershipListBeforeUpdate[0].MembershipStartDate__c).addDays(90), membershipListAfterUpdate[0].MembershipExpiryDate__c, 'Membership Expiry Date shoule be equal to Membership Start Date plus 90.');
        System.assertEquals('Expired', membershipListAfterUpdate[0].Status__c, 'Status should be expired.');
    }

    public static testMethod  void testCreateOrder() {
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_ADULT_RECORDTYPE).getRecordTypeId();
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        List<Membership__c> membershipListBeforeUpdate = [SELECT Id, MembershipStartDate__c, MembershipExpiryDate__c, Status__c FROM Membership__c LIMIT 1];
        membershipListBeforeUpdate[0].MembershipStartDate__c = System.today().addDays(-80);
        membershipListBeforeUpdate[0].Status__c = CommonConstant.MEMBERSHIP_STATUS_ACTIVATED;
        update membershipListBeforeUpdate[0];
        
        Contact con = new Contact();          
        con.LastName = 'Dela Cruz';           
        con.AccountId = accountId;
        con.RecordTypeId = idRecType;
        con.Phone = '5356324612';
        con.Type__c = 'Adult';
        insert con;

        Test.startTest();
            List<Order> lOrder = TestDataFactory.createOrder(1, accountId, con.Id, null);
            insert lOrder;
            lOrder[0].EffectiveDate = System.today().addDays(-10);
            lOrder[0].EndDate = System.today().addDays(-2);
            lOrder[0].ParentMembership__c = membershipListBeforeUpdate[0].Id;
            update lOrder[0];

            List<Order> orderListBeforeUpdate = [SELECT Id, EndDate FROM Order LIMIT 1];

            UpdateMembershipDetailsBatch umd = new UpdateMembershipDetailsBatch();
            Database.executeBatch(umd, 200);

            UpdateMembershipDetailsSchedule job = new UpdateMembershipDetailsSchedule();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Member Details Batch Job', sch, job);
        Test.stopTest();

        List<Membership__c> membershipListAfterUpdate = [SELECT Id, Status__c, NumberOfDaysDormant__c FROM Membership__c LIMIT 1];
        System.assertEquals((orderListBeforeUpdate[0].EndDate).daysBetween(Date.valueOf(System.today())), membershipListAfterUpdate[0].NumberOfDaysDormant__c, 'Number of Days Dormant should be updated.');
    }
}