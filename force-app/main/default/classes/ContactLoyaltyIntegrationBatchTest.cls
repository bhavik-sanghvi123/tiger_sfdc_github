@isTest
private class ContactLoyaltyIntegrationBatchTest {
    @testsetup
    static void setupData() {
        Account acc = TestDataFactory.createTestHouseholdSG(1)[0];
        Contact con = TestDataFactory.createTestAdultContactSGPoints(1, acc.Id, 100, 50, 10, 5, 30)[0];
        Affiliate_Value__c city = TestDataFactory.createAffiliateValue('City', 'TEST_CITY', 'SG', null);
        Affiliate_Value__c district = TestDataFactory.createAffiliateValue('District', 'TEST_DISTRICT', 'SG', city.Id);
        String streetName = 'TEST_STREET';
		Address__c address = TestDataFactory.createAddress(true, con.Id, 'Singapore', city.Id, district.Id, null, streetName);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry('SG', 'SGD');
        Product2 p = [SELECT Id FROM Product2 WHERE Id =: pbe.Product2Id];
        BrandRelationship__c br = TestDataFactory.createTestBrandRelationShip(1, con.Id, p.Id)[0];
        Channel__c channel = TestDataFactory.createTestChannel(1, 'SG', 'Abbott Family Rewards SG')[0];
        List<ChannelResponse__c> crList = TestDataFactory.createTestChannelResponseMultiple(5, br, channel, address, p, false, 'Pending');
        System.debug(crList[0].Channel__r.Name);
    }
    
    @isTest
    static void sgLoyaltyMonthly() {
        System.Test.startTest();
        
        ContactLoyaltyIntegrationMonthlyBatch ucs = new ContactLoyaltyIntegrationMonthlyBatch();
        Database.executeBatch(ucs, 200);
        
        ContactLoyaltyIntegrationSchedulable job = new ContactLoyaltyIntegrationSchedulable();
        String sch = '0 30 6 1 * ?';
        System.schedule('Monthly Batch Job', sch, job);
        
        System.Test.stopTest();            
        
        Contact con = [SELECT Id, LifetimePoints__c, Start_Earn_Points__c, Start_Redeem_Points__c, TotalPointsRedeemed__c, Monthly_Expired_Points__c, Monthly_Earned_Points__c, Monthly_Redeemed_Points__c FROM Contact][0];
        System.assertEquals(con.Start_Earn_Points__c, con.LifetimePoints__c, 'not same earned points'); 
        System.assertEquals(con.Start_Redeem_Points__c, con.TotalPointsRedeemed__c, 'not same redeemed points'); 
        System.assertEquals(con.Monthly_Expired_Points__c, 0);
        System.assertEquals(con.Monthly_Earned_Points__c, 0);
        //System.assertEquals(con.Monthly_Redeemed_Points__c, 0);
    }
    
    @isTest
    static void sgLoyaltyDaily() {
        Contact con = [SELECT Id, ExpiredPoints__c, Monthly_Expired_Points__c FROM Contact][0];
        con.ExpiredPoints__c = 20;
        update con;
        
        System.Test.startTest();
        
        ContactLoyaltyIntegrationDailyBatch ucs = new ContactLoyaltyIntegrationDailyBatch();
        Database.executeBatch(ucs, 200);
        
        ContactLoyaltyIntegrationDailyBatch job = new ContactLoyaltyIntegrationDailyBatch();
        String sch = '0 30 7 * * ?'; 
        System.schedule('Daily Batch Job', sch, job);
        
        System.Test.stopTest();            
        
        Contact conUpdated = [SELECT Id, ExpiredPoints__c, Monthly_Expired_Points__c FROM Contact WHERE Id =: con.Id];
        System.assertEquals(conUpdated.Monthly_Expired_Points__c, 50, 'not same earned points'); 
    }
}