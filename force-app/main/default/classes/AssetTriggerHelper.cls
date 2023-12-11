/*------------------------------------------------------------
Author:      Lee Santos
Description: Helper class for Asset object

History
04/23/2021  Lee     Created
06/17/2021  malviz  Added checkSerialNumber
-------------------------------------------------------------------------------------------*/

public class AssetTriggerHelper {

    public static void checkSerialNumber(List<Asset> assetList){
        for(Asset a : assetList){
            Integer assetQuantity = Integer.valueOf(a.Quantity);
            Integer assetInputQuantity = Integer.valueOf(a.Input_Quantity__c);
            String serialno = a.SerialNumber;

            if(serialno != null){
                if(assetInputQuantity != 0 && assetInputQuantity != null &&  assetQuantity > 0 ){   
                    a.addError('Assets with Serial Number cannot have more than 1 quantity.');
                }
                if(assetInputQuantity > 1 && (assetQuantity == 0 || assetQuantity == null)){   
                    a.addError('Assets with Serial Number cannot have more than 1 quantity.');
                }
            }
        }
    }
    
    public static void updateQuantities(List<Asset> assetList, Map<Id, sObject> oldAssetMap){
        try{
            Set <String> assetIds = new Set <String>();
            List<Asset> assetToUpdateList = new List<Asset>();
            for(Asset asset : assetList){
                if(asset.Input_Quantity__c != null || asset.Return_Quantity__c != null || asset.Write_off_Quantity__c != null){
                    assetIds.add(asset.Id);
                }
                
            }
            for(Asset assetToUpdate : [SELECT Id, Quantity, Input_Quantity__c, Return_Quantity__c, Write_off_Quantity__c, Allocated_Quantity__c,SerialNumber,Total_Quantity__c FROM Asset WHERE ID IN : assetIds]){
               
                String serialno = assetToUpdate.SerialNumber;

                if(assetToUpdate.Quantity == null){
                    assetToUpdate.Quantity = 0;
                }
                if(assetToUpdate.Input_Quantity__c == null){
                    assetToUpdate.Input_Quantity__c = 0;
                }
                if(assetToUpdate.Return_Quantity__c == null){
                    assetToUpdate.Return_Quantity__c = 0;
                }
                if(assetToUpdate.Write_off_Quantity__c == null){
                    assetToUpdate.Write_off_Quantity__c = 0;
                }
                if(assetToUpdate.Allocated_Quantity__c == null){
                    assetToUpdate.Allocated_Quantity__c = 0;
                }
                
                if(asset.Input_Quantity__c != null && serialno == null){ 
                    assetToUpdate.Quantity = assetToUpdate.Quantity + assetToUpdate.Input_Quantity__c;
                }

                //update searialized asset if quantity is still 0
                Integer assetQuantity = Integer.valueOf(assetToUpdate.Quantity);
                if(asset.Input_Quantity__c != null && serialno != null && assetQuantity == 0){
                    assetToUpdate.Quantity = assetToUpdate.Quantity + assetToUpdate.Input_Quantity__c;
                }

                /*if(asset.Input_Quantity__c != null){ 
                    assetToUpdate.Quantity = assetToUpdate.Quantity + assetToUpdate.Input_Quantity__c;
                }*/

                if(asset.Return_Quantity__c != null){  
                    assetToUpdate.Quantity = assetToUpdate.Quantity + assetToUpdate.Return_Quantity__c;
                    assetToUpdate.Allocated_Quantity__c = assetToUpdate.Allocated_Quantity__c - assetToUpdate.Return_Quantity__c;
                }
                if(asset.Write_off_Quantity__c != null){  
                    assetToUpdate.Allocated_Quantity__c = assetToUpdate.Allocated_Quantity__c - assetToUpdate.Write_off_Quantity__c;
                }
                
                assetToUpdate.Input_Quantity__c = null;
                assetToUpdate.Return_Quantity__c = null;
                assetToUpdate.Write_off_Quantity__c = null;
                
                assetToUpdateList.add(assetToUpdate);
            }
            update assetToUpdateList;
        }
        catch(DmlException e){
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    
    
}