@isTest
private class AssetTriggerHelperTest {
    
    @isTest
    static void testInputQuantity() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'ANZ');
        insert sysad;
        
        System.runAs(sysad) {    
            Asset asset = TestDataFactory.createAsset(); 
            
            Test.startTest();{
                insert asset;
            }
            Test.stopTest();
            
            Asset assetTest = [SELECT Id, Quantity FROM Asset WHERE Name = 'Test Asset'];
            System.assertEquals(1, assetTest.Quantity );
        }
    }
    
}