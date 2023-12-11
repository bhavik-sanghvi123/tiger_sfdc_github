/**
* @author        Ezzel Montesa
* @date          01.08.2021
* @description   Class primarily responsible in handling trigger logic for Abbott Workplace Object
* @revision(s)
*/
public class AbbottWorkplaceTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) { }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){
    	List<AbbottWorkplace__c> newAbbottWP = (List<AbbottWorkplace__c>) newList; //list of new records
        List<AbbottWorkplace__c> awpToProcess = new List<AbbottWorkplace__c>(); //list of records to process        
        for(AbbottWorkplace__c awp : newAbbottWP){ //check if InstitutionEmail__c not null
            if(awp.InstitutionEmail__c <> null){
                awpToProcess.add(awp);                
            }
        }        
        if(!awpToProcess.IsEmpty()){
            updateAbbottWPRecords(awpToProcess);
        }
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){    
    	List<AbbottWorkplace__c> newAbbottWP = (List<AbbottWorkplace__c>) newList; //list of new records
        List<AbbottWorkplace__c> awpToProcess = new List<AbbottWorkplace__c>(); //list of records to process        
        for(AbbottWorkplace__c awp : newAbbottWP){ //check if InstitutionEmail__c not null and values have updated
            AbbottWorkPlace__c oldWP = (AbbottWorkplace__c) oldMapItems.get(awp.Id);
            if((awp.EmailOptOut__c <> oldWP.EmailOptOut__c || awp.EmailOptOutDate__c <> oldWP.EmailOptOutDate__c) && awp.InstitutionEmail__c <> null){
                awpToProcess.add(awp);                
            }
        }        
        if(!awpToProcess.IsEmpty()){
            updateAbbottWPRecords(awpToProcess);
        }
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ }
    
    public static void updateAbbottWPRecords(List<AbbottWorkplace__c> awpToProcess){ //Updates the Email Opt Out Preferences of records
        List<AbbottWorkplace__c> awpToUpdate = new List<AbbottWorkplace__c>(); //list of records to update
        List<String> awpInstEmailList = new List<String>(); //list of InstitutionEmail__c as reference
        Map<String, Boolean> awpInsEmailOptOut = new Map<String, Boolean>(); //maps InstitutionEmail__c and EmailOptOut__c
        Map<String, Date> awpInsEmailDate = new Map<String, Date>(); //maps InstitutionEmail__c and EmailOptOutDate__c
        
        for(AbbottWorkplace__c awp : awpToProcess){ //maps the EmailOptOUt Values based on Institution Email
            awpInstEmailList.add(awp.InstitutionEmail__c);
            awpInsEmailOptOut.put(awp.InstitutionEmail__c, awp.EmailOptOut__c); 
            awpInsEmailDate.put(awp.InstitutionEmail__c, awp.EmailOptOutDate__c);
        }
        
        //queries records with the same InstitutionEmail__c
        for(AbbottWorkplace__c awp : [SELECT EmailOptOut__c, EmailOptOutDate__c, InstitutionEmail__c FROM AbbottWorkplace__c WHERE InstitutionEmail__c in :awpInstEmailList]){
            Boolean forUpdate = false;
            if(awpInsEmailOptOut.containsKey(awp.InstitutionEmail__c)){
                awp.EmailOptOut__c = awpInsEmailOptOut.get(awp.InstitutionEmail__c);
                forUpdate = true;
            }
            
            if(awpInsEmailDate.containsKey(awp.InstitutionEmail__c)){
                awp.EmailOptOutDate__c = awpInsEmailDate.get(awp.InstitutionEmail__c);
                forUpdate = true;
            }
            
            if(forUpdate){
                awpToUpdate.add(awp);
			}
        }
        
        if(!awpToUpdate.IsEmpty()){
            update awpToUpdate;
        }
    }
}