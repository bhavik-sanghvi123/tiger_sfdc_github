public class SkillsBasedCriteriaTH {
    
	/*
    Consolidated to SkillsBaseCriteria class - Jeric
    public static Map<Id, Set<String>> determineRequiredSkills(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        Map<Id, String> channelMap = new Map<Id, String>();
        Set<Id> channelIds = new Set<Id>();
        
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
                }
            }
        }
        
        return callSkillsToReturn;
    }*/
}