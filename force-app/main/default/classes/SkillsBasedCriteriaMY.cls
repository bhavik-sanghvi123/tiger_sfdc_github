/**
* @author        Rey Austral
* @date          1.29.2019           
* @description   Class responsible for getting the criteria needed for the skills routing
* @revision(s)
*/
public with sharing class SkillsBasedCriteriaMY {
	/*
    Consolidated to SkillsBaseCriteria class - Jeric
	public static Map<Id, Set<String>> determineRequiredSkills(List<Case> casesToDetermine) {		
        //get the contact of the case
        Set<Id> contactSet = new Set<Id>();
        for(Case cse : casesToDetermine) {
        	contactSet.add(cse.ContactId);
        }

        //query all the brand relationship, then get the latest channel response
        //this map will be used to get the channel of the case
        List<BrandRelationship__c> brandList = new LIst<BrandRelationship__c>();
        //Map<contactId, Map<keybrand, latest channel response value> >
        Map<Id, Map<String, String>> contactBrandMap = new Map<Id, Map<String, String>>();
        if (!contactSet.isEmpty()) {
        	
			for (Contact con : [Select Id, (Select Id, KeyBrand__c, LatestChannelResponse__r.Category__c From MainBrandRelationships__r order by LatestChannelResponseDate__c) 
                                From Contact Where Id in :contactSet]) {
				Map<String, String> brandChannelMap = new Map<String, String>();
				for (BrandRelationship__c brand : con.MainBrandRelationships__r) {
                    if ( String.isNotEmpty(brand.LatestChannelResponse__r.Category__c ) ) {
					   brandChannelMap.put(brand.KeyBrand__c, brand.LatestChannelResponse__r.Category__c);
                    }
				}
				contactBrandMap.put(con.Id, brandChannelMap);
			}

        }
        System.debug(contactBrandMap);
        
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        for(Case caseRec : casesToDetermine) {           
        	Set<String> skillSet = new Set<String>();

            if(!callSkillsToReturn.containsKey(caseRec.Id)) {
            	//get the preferred language of the contact
                if(caseRec.ContactId != null && caseRec.Contact.PreferredLanguage__c != null) {
                    skillSet.add(CommonConstant.SKILL_LANGUAGE + caseRec.Contact.PreferredLanguage__r.Name);
                } 

                if (contactBrandMap.containsKey(caseRec.ContactId) && caseRec.Campaign__c != null) {
                	//since there are multiple brand in a contact
                	//get only the channel that belongs to the same brand of the campaign
                	Map<String, String> brandChannelMap = contactBrandMap.get(caseRec.ContactId);
                	if (brandChannelMap.containsKey(caseRec.Campaign__r.Brand__c)) {
                		skillSet.add(CommonConstant.SKILL_CHANNEL + brandChannelMap.get(caseRec.Campaign__r.Brand__c) );
                	}
                }
                //get the value of the brand in the campaign record
                if(caseRec.Campaign__c != null && String.isNotBlank( caseRec.Campaign__r.Brand__c ) ) {
                    if (caseRec.Campaign__r.Brand__c != 'Multi-Brand' && caseRec.Campaign__r.Brand__c != 'Others') {
                        skillSet.add(CommonConstant.SKILL_BRAND + caseRec.Campaign__r.Brand__c);
                    }                    
                } 

                if(caseRec.Campaign__c != null && String.isNotBlank(caseRec.Campaign__r.Market__c ) ) {
                    skillSet.add(CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c);
                }

                callSkillsToReturn.put(caseRec.Id, skillSet);
            }
        }
        System.debug(callSkillsToReturn);
        return callSkillsToReturn;
	}*/
}