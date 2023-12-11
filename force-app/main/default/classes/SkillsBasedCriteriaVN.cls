public class SkillsBasedCriteriaVN {

	/*
    Consolidated to SkillsBaseCriteria class - Jeric
    public static Map<Id, Set<String>> determineRequiredSkills(List<Case> casesToDetermine) {
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
    }*/
}