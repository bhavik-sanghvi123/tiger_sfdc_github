@isTest
private class AssetServiceTriggerHelperTest {
    
    @isTest
    static void testUpdateRelatedAsset() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'ANZ');
        insert sysad;
        
        System.runAs(sysad) {    
            Asset_Service__c assetService = TestDataFactory.createAssetService();
            
            Test.startTest();{
                assetService.Status__c = 'Completed';
                update assetService;
            }
            Test.stopTest();
            
            Asset_Service__c assetServiceTest = [SELECT Id, Asset__c, AccountId__c, AssetServiceRegarding__c FROM Asset_Service__c WHERE Name = 'TestAssetService'];
            Asset asset = [SELECT Id, AccountId, ContactId FROM Asset WHERE Id =: assetServiceTest.Asset__c];
            System.assertEquals(null, asset.AccountId );
            System.assertEquals(null, asset.ContactId );
        }
    }
    
}