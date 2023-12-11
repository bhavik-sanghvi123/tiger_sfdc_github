/*------------------------------------------------------------
Author:      Lee Santos
Description: Handler class for AssetService object
History
04/16/2021   lsantos Created
-------------------------------------------------------------------------------------------*/

public class AssetServiceTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) {
             
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
    }

    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ 
        
    }

    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
    }

    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        AssetServiceTriggerHelper.updateRelatedAsset(newList, newMapItems);
    }

    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
    }
}