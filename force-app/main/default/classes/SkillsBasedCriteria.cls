public with sharing class SkillsBasedCriteria {
    
    /* BASE SKILLS Checking */
    public static Map<Id, Set<String>> determineRequiredSkills(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        
        for(Case caseRec : casesToDetermine) {
            Set<String> skillSet = new Set<String>();

            if(!callSkillsToReturn.containsKey(caseRec.Id)) {
                if(caseRec.Campaign__c != null) {
                    skillSet.add(CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c);
                    if(String.IsNotBlank(caseRec.Campaign__r.Brand__c)) {
                        if(caseRec.Campaign__r.Brand__c != 'Multi-Brand' && caseRec.Campaign__r.Brand__c != 'Others') {
                            skillSet.add(CommonConstant.SKILL_BRAND + caseRec.Campaign__r.Brand__c);   
                        }
                    }
                }

                //get the preferred language of the contact
                if(caseRec.ContactId != null && caseRec.Contact.PreferredLanguage__c != null) {
                    skillSet.add(CommonConstant.SKILL_LANGUAGE + caseRec.Contact.PreferredLanguage__r.Name);
                }

                if(!skillSet.isEmpty()){
                    callSkillsToReturn.put(caseRec.Id, skillSet);
                }
            }
        }
        
        return callSkillsToReturn;
    }

    /* skills processing for MY */
    public static Map<Id, Set<String>> determineRequiredSkillsMY(List<Case> casesToDetermine) {		
        /**
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
		**/
        
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        for(Case caseRec : casesToDetermine) {           
        	Set<String> skillSet = new Set<String>();

            if(!callSkillsToReturn.containsKey(caseRec.Id)) {
            	//get the preferred language of the contact
                if(caseRec.ContactId != null && caseRec.Contact.PreferredLanguage__c != null) {
                    skillSet.add(CommonConstant.SKILL_LANGUAGE + caseRec.Contact.PreferredLanguage__r.Name);
                } 
				
                /**
                if (contactBrandMap.containsKey(caseRec.ContactId) && caseRec.Campaign__c != null) {
                	//since there are multiple brand in a contact
                	//get only the channel that belongs to the same brand of the campaign
                	Map<String, String> brandChannelMap = contactBrandMap.get(caseRec.ContactId);
                	if (brandChannelMap.containsKey(caseRec.Campaign__r.Brand__c)) {
                		skillSet.add(CommonConstant.SKILL_CHANNEL + brandChannelMap.get(caseRec.Campaign__r.Brand__c) );
                	}
                }
				**/
                
                //get the case category
                if(String.IsNotBlank(caseRec.Category__c)) {
                    skillSet.add(CommonConstant.SKILL_CHANNEL + caseRec.Category__c);
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
        return callSkillsToReturn;
	}

    /* skills processing for PH */
    public static Map<Id, Set<String>> determineRequiredSkillsPH(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        Map<Id, String> conversionMap = new Map<Id, String>();

        // requery to get the fields to be referenced
        casesToDetermine = [SELECT RelatedBrandRelationship__r.FirstTransactionDate__c, Campaign__c,
                                   Campaign__r.Market__c, Campaign__r.Brand__c
                              FROM Case
                             WHERE Id IN: casesToDetermine];

        for(Case caseRec : casesToDetermine) {
            if(!callSkillsToReturn.containsKey(caseRec.Id)) {
                if(caseRec.Campaign__c != null) {
                    callSkillsToReturn.put(caseRec.Id, new Set<String>{CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c});
                    if(String.IsNotBlank(caseRec.Campaign__r.Brand__c)) {
                        if(caseRec.Campaign__r.Brand__c != 'Multi-Brand' && caseRec.Campaign__r.Brand__c != 'Others') {
                        	callSkillsToReturn.get(caseRec.Id).add(CommonConstant.SKILL_BRAND + caseRec.Campaign__r.Brand__c);   
                        }
                    }
                }

                // check if there is a purchase already for the said brand to know if conversion-conversion or post-conversion skills is needed
                String conversionSkill = caseRec.RelatedBrandRelationship__r.FirstTransactionDate__c != null ?
                                         CommonConstant.SKILL_POST_CONVERSION : CommonConstant.SKILL_CONVERSION;

                callSkillsToReturn.get(caseRec.Id).add(conversionSkill);
            }
        }
        
        return callSkillsToReturn;
    }

    /* skills processing for TH */
    public static Map<Id, Set<String>> determineRequiredSkillsTH(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        Map<Id, String> channelMap = new Map<Id, String>();
        Set<Id> channelIds = new Set<Id>();
        Campaign ExperienceProgram = [Select Id, Name from Campaign Where Name = :Label.Campaign_ExperienceProgram];

        for(Case caseRec : casesToDetermine) {
            if(caseRec.Channel__c != null) {
                channelIds.add(caseRec.Channel__c);
            }
        }
        
        if(!channelIds.isEmpty()) {
            List<Channel__c> channelList = [select Id, Category__c from Channel__c where Id in :channelIds];
            for(Channel__c chanRec : channelList) {
                channelMap.put(chanRec.Id, chanRec.Category__c);
            }
        }
        
        for(Case caseRec : casesToDetermine) {
            if(!callSkillsToReturn.containsKey(caseRec.Id)) {
                if(caseRec.Campaign__c != null) {
                    callSkillsToReturn.put(caseRec.Id, new Set<String>{CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c});
                    if(String.IsNotBlank(caseRec.Campaign__r.Brand__c)) {
                        if(caseRec.Campaign__r.Brand__c != 'Multi-Brand' && caseRec.Campaign__r.Brand__c != 'Others') {
                        	callSkillsToReturn.get(caseRec.Id).add(CommonConstant.SKILL_BRAND + caseRec.Campaign__r.Brand__c);   
                        }
                    }
                    
                    if(caseRec.Channel__c != null) {
                        if(!channelMap.isEMpty()) {
                            String channelStr = channelMap.get(caseRec.Channel__c);
                            if(channelStr != null) {
                                callSkillsToReturn.get(caseRec.Id).add(CommonConstant.SKILL_CHANNEL + channelStr);  
                            }
                        }
                    }

                    //TKT-003519: Add Criteria - Experience Program
                    if(ExperienceProgram != null){
                        if(caseRec.Campaign__c == ExperienceProgram.Id) {
                            callSkillsToReturn.get(caseRec.Id).add(CommonConstant.SKILL_CAMPAIGN + ExperienceProgram.Name);                       
                        }
                    }
                }
            }
        }
        
        return callSkillsToReturn;
    }

    /* skills processing for VN */
    public static Map<Id, Set<String>> determineRequiredSkillsVN(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        
        for(Case caseRec : casesToDetermine) {
            if(!callSkillsToReturn.containsKey(caseRec.Id)) {
                if(caseRec.Campaign__c != null) {
                    callSkillsToReturn.put(caseRec.Id, new Set<String>{CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c});
                    if(String.IsNotBlank(caseRec.Campaign__r.Brand__c)) {
                        if(caseRec.Campaign__r.Brand__c != 'Multi-Brand' && caseRec.Campaign__r.Brand__c != 'Others') {
                        	callSkillsToReturn.get(caseRec.Id).add(CommonConstant.SKILL_BRAND + caseRec.Campaign__r.Brand__c);   
                        }
                    }
                }
                
                if(caseRec.Contact.Region__c != null) {
                    callSkillsToReturn.get(caseRec.Id).add(CommonConstant.SKILL_REGION + caseRec.Contact.Region__r.Name);
                }
            }
        }
        
        return callSkillsToReturn;
    }

    /* skills processing for ID */
    public static Map<Id, Set<String>> determineRequiredSkillsID(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        Set<Id> channelIds = new Set<Id>();
        Map<Id, Channel__c> channelMap = new Map<Id, Channel__c>();
        for(Case caseRec : casesToDetermine) {
            if(caseRec.Channel__c != null) {
                channelIds.add(caseRec.Channel__c);
            }
        }
        if(!channelIds.isEmpty()) {
            channelMap = new Map<Id, Channel__c>([SELECT Id, Category__c FROM Channel__c WHERE Id IN :channelIds]);
        }

        Map<String, List<String>> callExcludeMap = new Map<String, List<String>>();
        for(CallRoutingExclusion__mdt cre : [SELECT Id, Field__c, Value__c FROM CallRoutingExclusion__mdt WHERE Market__c = 'ID']){
            if(callExcludeMap.containsKey(cre.Field__c)){
                callExcludeMap.get(cre.Field__c).add(cre.Value__c);
            }
            else{
                callExcludeMap.put(cre.Field__c, new List<String>{cre.Value__c});
            }
        }
        for(Case caseRec : casesToDetermine) {
            Set<String> skillSet = new Set<String>();
            Boolean toBeRouted = true;
            if(caseRec.Campaign__c != null && callExcludeMap.containsKey('Campaign') && callExcludeMap.get('Campaign').contains(caseRec.Campaign__r.Name)){
                toBeRouted = false;
            }
            if(caseRec.Channel__c != null && channelMap.containsKey(caseRec.Channel__c) && callExcludeMap.containsKey('Channel Category')) {
                Channel__c ch = channelMap.get(caseRec.Channel__c);
                if(ch.Category__c != null && callExcludeMap.get('Channel Category').contains(ch.Category__c) ){
                    toBeRouted = false;
                }
            }

            if(!callSkillsToReturn.containsKey(caseRec.Id) && toBeRouted) {
                if(caseRec.Campaign__c != null) {
                    skillSet.add(CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c);
                    if(String.IsNotBlank(caseRec.Campaign__r.Brand__c)) {
                        if(caseRec.Campaign__r.Brand__c != 'Multi-Brand' && caseRec.Campaign__r.Brand__c != 'Others') {
                            skillSet.add(CommonConstant.SKILL_BRAND + caseRec.Campaign__r.Brand__c);   
                        }
                    }

                    if(caseRec.Campaign__r.Group__c != null) {
                        skillSet.add(CommonConstant.SKILL_GROUP + caseRec.Campaign__r.Group__c); 
                    }
                }

                //get the preferred language of the contact
                if(caseRec.ContactId != null && caseRec.Contact.PreferredLanguage__c != null) {
                    skillSet.add(CommonConstant.SKILL_LANGUAGE + caseRec.Contact.PreferredLanguage__r.Name);
                }

                if(!skillSet.isEmpty()){
                    callSkillsToReturn.put(caseRec.Id, skillSet);
                }
            }
        }
        
        return callSkillsToReturn;
    }
    
    /* skills processing for TW */
    public static Map<Id, Set<String>> determineRequiredSkillsTW(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        
        for(Case caseRec : casesToDetermine) {
            Set<String> skillSet = new Set<String>();

            if(!callSkillsToReturn.containsKey(caseRec.Id)) {
                if(caseRec.Campaign__c != null) {
                    skillSet.add(CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c);
                    if(String.IsNotBlank(caseRec.Campaign__r.Brand__c)) {
                        if(caseRec.Campaign__r.Brand__c != 'Multi-Brand' && caseRec.Campaign__r.Brand__c != 'Others') {
                            skillSet.add(CommonConstant.SKILL_PRODUCT_FAMILY + caseRec.Campaign__r.Product__r.Family);   
                        }
                    }
                }

                //get the preferred language of the contact
                if(caseRec.ContactId != null && caseRec.Contact.PreferredLanguage__c != null) {
                    skillSet.add(CommonConstant.SKILL_LANGUAGE + caseRec.Contact.PreferredLanguage__r.Name);
                }

                if(!skillSet.isEmpty()){
                    callSkillsToReturn.put(caseRec.Id, skillSet);
                }
            }
        }
        
        return callSkillsToReturn;
    }
}