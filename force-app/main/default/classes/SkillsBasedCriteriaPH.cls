/*
Date:
Nov-04-2019 Jericson    changed post-conversion reference from contact to brand specific
*/
public class SkillsBasedCriteriaPH {
	
	/*
    Consolidated to SkillsBaseCriteria class - Jeric
    public static Map<Id, Set<String>> determineRequiredSkills(List<Case> casesToDetermine) {
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
    }*/
}