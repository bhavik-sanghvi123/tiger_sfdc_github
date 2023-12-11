public class SkillsBasedCriteriaIN {
    
	/*
    Consolidated to SkillsBaseCriteria class - Jeric
    public static Map<Id, Set<String>> determineRequiredSkills(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        
        for(Case caseRec : casesToDetermine) {
            Set<String> skillSet = new Set<String>();

            if(!callSkillsToReturn.containsKey(caseRec.Id)) {
                if(caseRec.Campaign__c != null) {
                    skillSet.add(CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c);
                    //callSkillsToReturn.put(caseRec.Id, new Set<String>{CommonConstant.SKILL_MARKET + caseRec.Campaign__r.Market__c});
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
    }*/
}