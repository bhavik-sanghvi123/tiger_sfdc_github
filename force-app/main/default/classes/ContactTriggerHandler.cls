/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Handler class for Contact object
                  - Handles the incremental and decremental updates for the tracking fields on Contact's Household record.
History
01/08/2019   vmirandilla   Created
02/08/2019   raustral - Added checkMultiplePrimary and checkMultiplePrimary method
03/08/2018   vmirandilla - Added enableMilkRestrictionCode method
11/06/2019   jermercado - removed calculateTrackingFields, updateHouseholdPrimaryContact methods and introduces a unified process on calculaterackingFields2
20/05/2020   jermercado - moved after insert and after update to ContactEventHandler
07/20/2020   malviz - bypass delete when To be Archived is true
01/21/2021   emontesa - added checkMCEligibility
01/09/2021   mparihar  - updated logic in afterupdate method 
11/19/2021   navalencia - added updateParentEdd method on afterinsert and afterupdate
-------------------------------------------------------------------------------------------*/

public class ContactTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) { 
        //validation for primary contact field, there should be only 1 primary contact per household
        ContactTriggerHelper.checkMultiplePrimary(newList, null);
        ContactTriggerHelper.enableMilkRestrictionCode(newList);
        ContactTriggerHelper.fetchMarketFromHousehold(newList, null);
        ContactTriggerHelper.populateAgeRange(newList);
        ContactTriggerHelper.prepopulateContact(newList, null);
        ContactTriggerHelper.checkMCEligibility(newList);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
        //validation for primary contact field, there should be only 1 primary contact per household
        ContactTriggerHelper.checkMultiplePrimary(newList, oldMapItems);
        ContactTriggerHelper.enableMilkRestrictionCode(newList);
        ContactTriggerHelper.fetchMarketFromHousehold(newList, oldMapItems);
        ContactTriggerHelper.populateAgeRangeOnUpdate(newList, oldMapItems);
        ContactTriggerHelper.prepopulateContact(newList, oldMapItems);
        ContactTriggerHelper.appendDescription(newList, oldMapItems);
        ContactTriggerHelper.resetEmailBounced(newList, oldMapItems);
    }

    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
        //ContactTriggerHelper.calculaterackingFields2(newList, null);
        //ContactTriggerHelper.checkPrimaryCarer(newList, null);

        //Handles the incremental changes of Contact's Household tracking fields during Contact creation.
//        ContactTriggerHelper.calculateTrackingFields(newList, TRUE);
        //Updating the primary contact field of the house hold
//        ContactTriggerHelper.updateHouseholdPrimaryContact(newList, null);
        List<Contact> contacts = (List<Contact>) newList;
        Set<Id> conIds = new Set<Id>();
        for(Contact con: contacts){
            conIds.add(con.Id);
        }
        if(!conIds.isEmpty()) ContactEventHandler.updateAccountTrackingFields(conIds);
        //added by narence
       ContactTriggerHelper.updateParentEdd(null,newList);

    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){
        //ContactTriggerHelper.calculaterackingFields2(newList, oldMapItems);

        //Handles the incremental or decremental changes of Contact's Household tracking fields during Contact update.
//        ContactTriggerHelper.updateTrackingFields(oldMapItems, newMapItems);
        //Updating the primary contact field of the house hold
//        ContactTriggerHelper.updateHouseholdPrimaryContact(newList, oldMapItems); //US-0620 REMOVE ALL EXCEPT ADDRESS
       // ContactTriggerHelper.checkSampleRequest(newList, oldMapItems);
        //ContactTriggerHelper.checkPrimaryCarer(newList, oldMapItems);
        List<Contact> contacts = (List<Contact>) newList;
        Map<Id,Contact> oldMap = (Map<Id,Contact>)oldMapItems; //added by monika
        List<Contact> lstContact = new List<Contact>(); //added by monika
        Set<Id> setContact = new Set<Id>();
        
        Set<Id> conIds = new Set<Id>();
        for(Contact con: contacts){
            conIds.add(con.Id);
            
             /*****************Code start Here (added by monika)*******************/
            if(con.EstimatedDueDate__c != oldMap.get(con.Id).EstimatedDueDate__c  && con.EstimatedDueDate__c!= null  && con.Market__c== CommonConstant.MARKET_TW){       
                 //Estimated Date is updated from blank to value,creates child record for Contact
                if(oldMap.get(con.Id).EstimatedDueDate__c== null){
                    lstContact.add(con);
                }
                //added by Monika- Estimated Date is updated ,updates DOB of child  Contact
                setContact.add(con.Id);
            }
            /*****************Code End Here *******************/
        }
        if(!conIds.isEmpty())        ContactEventHandler.updateAccountTrackingFields(conIds);
        //if(!lstContact.isEmpty())    ContactTriggerHelper.createChildContactTW(lstContact); //Added by Monika
        //if(!setContact.isEmpty())    ContactTriggerHelper.updateChildContactDOBTW(setContact); //Added by Monika

       //added by narence
       ContactTriggerHelper.updateParentEdd(oldMapItems,newList);

    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
    
        Map<Id,Contact> oldContact = (Map<Id,Contact>) oldMapItems;
        Map<Id,Contact> contactToProcessMap = new Map<Id,Contact>();
        List<Contact> contactToProcess = new List<Contact>();
        
        for(Contact con: oldContact.values()){
           If(con.To_be_Archived__c == false){
               contactToProcess.add(con);
               contactToProcessMap.put(con.Id, con);
           }
        }
        
        if(!contactToProcess.isEmpty()){
            ContactTriggerHelper.calculaterackingFields2(contactToProcess, contactToProcessMap);
            ContactTriggerHelper.preventDeletion(oldList); 
        }
        //Handles the decremental changes of Contact's Household tracking fields during Contact deletion.
//        ContactTriggerHelper.calculateTrackingFields(oldMapItems.values(), FALSE);
        
    }

}