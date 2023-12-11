/*------------------------------------------------------------
Author:      Lee Santos
Description: Handler class for Asset object
History
04/16/2021      lsantos     Created
06/17/2021      malviz      added checkSerialNumber
-------------------------------------------------------------------------------------------*/

public class AssetTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) {
        AssetTriggerHelper.checkSerialNumber(newList);    
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
        AssetTriggerHelper.checkSerialNumber(newList);    
    }

    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ 
        
    }

    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
        AssetTriggerHelper.updateQuantities(newList, newMapItems);
    }

    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        AssetTriggerHelper.updateQuantities(newList, oldMapItems);
    }

    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
    }
}