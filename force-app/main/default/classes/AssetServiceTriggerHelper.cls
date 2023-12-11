/*------------------------------------------------------------
Author:      Lee Santos
Description: Helper class for AssetService object

History
04/16/2021
-------------------------------------------------------------------------------------------*/

public class AssetServiceTriggerHelper {
    
    
    public static void updateRelatedAsset(List<Asset_Service__c> assetServiceList, Map<Id, sObject> oldAssetServiceMap){
                  
        List<Asset> assetListToUpdate = new List<Asset>();
        
        Set <String> assetIds = new Set <String>();
        Set <String> locationIds = new Set <String>();
        
        for(Asset_Service__c assetService : assetServiceList){
            if(assetService.Status__c == 'Completed'){
            	assetIds.add(assetService.Asset__c);
            }
        }
        
        for(Asset asset : [SELECT Id, AccountId, ContactId FROM Asset WHERE Id IN : assetIds]){
            asset.AccountId = null;
            asset.ContactId = null;
            assetListToUpdate.add(asset);
        }
        
        update assetListToUpdate;
        
       
    }
    
}