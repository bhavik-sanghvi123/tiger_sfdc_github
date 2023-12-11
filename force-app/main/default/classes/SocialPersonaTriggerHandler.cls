/**
* @author        Marlon Ocillos
* @date          8.1.2019
* @description   Class primarily responsible in handling trigger logic for Social Persona
* @revision(s)
*/
public class SocialPersonaTriggerHandler implements ITriggerHandler {
	public void BeforeInsert(List<SObject> newList) { }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
    	contactChange(newList, oldMapItems);
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ }
    
    // Method to update associate cases on a social persona if the persona is associated to a different contact
    public static void contactChange(List<SocialPersona> newList, Map<Id, SObject> oldMap) {
        Map<Id, SocialPersona> spMap = new Map<Id, SocialPersona>();
        Map<Id, SocialPersona> caseAndSocPerMap = new Map<Id, SocialPersona>();
        List<Case> casesToUpdate = new List<Case>();
        List<SocialPost> socialPostToUpdate = new List<SocialPost>();
        Set<Id> conIds = new Set<Id>();
        
        for(SocialPersona spRec : newList) {
            SocialPersona oldSpRec = (SocialPersona)oldMap.get(spRec.Id);
            if(spRec.ParentId != oldSpRec.ParentId) {
                String spParentId = spRec.ParentId;
                if(spParentId.startsWith('003')) {
                    spMap.put(spRec.Id, spRec);
                    conIds.add(spRec.ParentId);
                }
            }
        }
        
        if(!spMap.isEmpty()) {
            Map<Id, Contact> conMap = new Map<Id, Contact>([select Id, AccountId from Contact where Id in :conIds]);
            
            for(SocialPost sPostrec : [select Id, WhoId, ParentId, PersonaId, Persona.ParentId from SocialPost where PersonaId in :spMap.keySet()]) {
                if(!caseAndSocPerMap.containsKey(sPostrec.ParentId)) {
                    sPostrec.WhoId = spMap.get(sPostrec.PersonaId).ParentId;
                    socialPostToUpdate.add(sPostrec);
                    caseAndSocPerMap.put(sPostrec.ParentId, spMap.get(sPostrec.PersonaId));
                }
            }
            
            if(!caseAndSocPerMap.isEmpty()) {
                for(Case caseRec : [select Id, ContactId from Case where Id in :caseAndSocPerMap.keySet()]) {
                    caseRec.ContactId = caseAndSocPerMap.get(caseRec.Id).ParentId;
                    caseRec.AccountId = conMap.get(caseAndSocPerMap.get(caseRec.Id).ParentId).AccountId;
                    casesToUpdate.add(caseRec);
                }
                
                if(!socialPostToUpdate.isEmpty()) {
                    update socialPostToUpdate;
                }
                
                if(!casesToUpdate.isEmpty()) {
                    update casesToUpdate;
                }
            }
        }
    }
}