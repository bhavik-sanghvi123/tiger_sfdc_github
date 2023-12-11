/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Handler class for Address object
                  - Auto-populates Parent Household derived from current Contact's Household value
History
01/18/2019   vmirandilla    Created
11/06/2020   malviz         Added updateProvince
-------------------------------------------------------------------------------------------*/

public class AddressTriggerHandler implements ITriggerHandler{
	
    public static boolean DoNotRunTest = false; //for AddressExternalReferenceBatchTest
    public void BeforeInsert(List<SObject> newList) {
        AddressTriggerHelper.getHousehold(newList);
        
        //filter PH Address
        List<Address__c> addressList = (List<Address__c>) newList;
        List<Address__c> addressPHList = new List<Address__c>();
        for(Address__c address: addressList ){
           If(address.Country__c == 'Philippines' && address.City2__c != null){
               addressPHList.add(address);
           }
       	}
        if(!addressPHList.isEmpty()) AddressTriggerHelper.updateProvince(addressPHList);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
        AddressTriggerHelper.getHousehold(newList);
        
        //filter PH Address
        List<Address__c> addressList = (List<Address__c>) newList;
        List<Address__c> addressPHList = new List<Address__c>();
        for(Address__c address: addressList ){
           If(address.Country__c == 'Philippines' && address.City2__c != null){
               addressPHList.add(address);
           }
       	}
        if(!addressPHList.isEmpty()) AddressTriggerHelper.updateProvince(addressPHList);
    }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ 
       List<Address__c> oldAddress = (List<Address__c>) oldList;
       List<Address__c> addressToProcess = new List<Address__c>();
       
       for(Address__c address: oldAddress ){
           If(address.To_be_Archived__c == false){
               addressToProcess.add(address);
           }
       }
       
       if(!addressToProcess.isEmpty()) AddressTriggerHelper.checkDefaultAddress(addressToProcess, null);
    }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
        AddressTriggerHelper.checkDefaultAddress(newList, null);
        if(!DoNotRunTest){
            AddressTriggerHelper.checkExternalId(newList, null);   
        }
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        AddressTriggerHelper.checkDefaultAddress(newList, oldMapItems);
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ }
}