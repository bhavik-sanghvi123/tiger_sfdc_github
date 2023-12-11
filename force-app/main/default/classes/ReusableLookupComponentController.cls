/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Controller Class for ReusableLookupComponent

History
07/03/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/

public without sharing class ReusableLookupComponentController {

    @AuraEnabled
    public static List<sObject> fetchLookupValues(String objName, String userMarket, String searchKey, String contactLanguage) {
    	Id currentUserId = [SELECT Id, UserRole.Name FROM User WHERE Id =: userInfo.getUserId()].Id;
        List<sObject> returnList = new List<sObject>();
        List<ServiceResourceSkill> serviceResouceSkillList = new List<ServiceResourceSkill>();
        List<ServiceResource> serviceResouceList = new List<ServiceResource>();
        Set<Id> serviceResourceIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        String searchInput;

        String language = '%'+contactLanguage+'%';

        if(objName == CommonConstant.CASE_OBJECT) {
            serviceResouceSkillList = [SELECT Id, ServiceResourceId, Skill.MasterLabel FROM ServiceResourceSkill WHERE Skill.MasterLabel LIKE :language];

            for(ServiceResourceSkill srs : serviceResouceSkillList) {
            	serviceResourceIds.add(srs.ServiceResourceId);
            }

            if(!serviceResourceIds.isEmpty()) {
            	serviceResouceList = [SELECT Id, RelatedRecordId, RelatedRecord.IsActive, RelatedRecord.Market__c 
            							FROM ServiceResource 
            							WHERE RelatedRecord.IsActive = TRUE AND RelatedRecord.Market__c = :userMarket AND Id IN :serviceResourceIds];
            }

            for(ServiceResource sr : serviceResouceList) {
            	userIds.add(sr.RelatedRecordId);
            }

            if(!userIds.isEmpty()) {
                if(searchKey == null || searchKey == '') {
            	   returnList = [SELECT Id, Name, Market__c FROM User WHERE Id IN :userIds AND Id != :currentUserId];
                } else {
                    searchInput = '%'+searchKey+'%';
                    returnList = [SELECT Id, Name, Market__c FROM User WHERE Id IN :userIds AND Id != :currentUserId AND Name LIKE :searchInput];   
                }
            }
        }
        
        if(objName == CommonConstant.SKILL_OBJECT) {
            if(searchKey == null || searchKey == '') {
                returnList = [SELECT Id, MasterLabel FROM Skill];
            } else {
                searchInput = '%'+searchKey+'%';
                returnList = [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel LIKE :searchInput];
            }
        }
        

        return returnList;
    }
}