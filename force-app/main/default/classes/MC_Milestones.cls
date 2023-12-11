/*
Author: Jericson Mercado
Description: updates the record just to change modified date so SC and MC will sync, because marketing cloud was not able to pick up changes in formula field.
NOTE: if there is a scheduled job for the country but there is no active filter specified in the milestone object, this job will just throw an error.
This is designed to handle 1 milestone at a time, salesforce is unable to handle too many records
*/
public class MC_Milestones implements Database.Batchable<sObject>, Database.Stateful {
    
    /* UPDATE THIS IN CASE THERE IS A NEW RECORD TYPE */
    Static Id RTAgeInMonths = Schema.SObjectType.Milestone__c.getRecordTypeInfosByDeveloperName().get('AgeInMonths').getRecordTypeId();
    Static Id RTWeeksofPregnancy = Schema.SObjectType.Milestone__c.getRecordTypeInfosByDeveloperName().get('WeeksofPregnancy').getRecordTypeId();
    Static Id RTLoyaltyLength = Schema.SObjectType.Milestone__c.getRecordTypeInfosByDeveloperName().get('LoyaltyLength').getRecordTypeId();
    Static Id conAdultRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
    Static Id conChildRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
    
    Map<Id, String> apiMap = new Map<Id, String>();
    
    String queryParam;
    String Market;
    
    Map<String, List<Milestone__c>> milestoneMap;
    Map<String, Set<String>> milestoneNames;
    
    public MC_Milestones(Set<Id> ids){
        
        // set field map
        apiMap.put(RTAgeInMonths, 'User__r.AgeinMonths__c');
        apiMap.put(RTWeeksofPregnancy, 'User__r.WeeksOfPregnancy__c');
        apiMap.put(RTLoyaltyLength, 'Loyalty_Length_in_Months__c');
        
        milestoneMap = new Map<String, List<Milestone__c>>();
        milestoneNames = new Map<String, Set<String>>();
        
        for(Milestone__c ms: [SELECT Name, MilestoneValue__c, RecordTypeId, Market__c
                              FROM Milestone__c
                              WHERE Id IN: ids])
        {
            if(!milestoneMap.containsKey(ms.Market__c)){
                milestoneMap.put(ms.Market__c, new List<Milestone__c>());
                milestoneNames.put(ms.Market__c, new Set<String>());
            }
            milestoneMap.get(ms.Market__c).add(ms);
            milestoneNames.get(ms.Market__c).add(ms.Name);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        Boolean isFirst = true;
        String queryStr2 = '';
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        List<String> conQueryStringList = new List<String>();
        Map<Id,String> mileStoneConQueryMap = new Map<Id,String>();
        Map<Id,List<Contact>> mileStoneConListMap = new Map<Id,List<Contact>>();
        List<Contact> msConQueryList1 = new List<Contact>();
        List<Contact> msConQueryList2 = new List<Contact>();

        //Contact Query - TW Market not optimized due to PrimaryContact__c in filter
        for(String market: milestoneMap.keySet()){
            if(market != CommonConstant.MARKET_TW){
                for(Milestone__c m: milestoneMap.get(market)){
                    // precaution not to break the query incase a new recordtype suddenly pops up
                    String conQueryString;
                    if(apiMap.containsKey(m.RecordTypeId)) {
                        if(apiMap.get(m.RecordTypeId).contains('User__r')){
                            conQueryString = 'SELECT Id FROM Contact WHERE Active__c = true'
                                + ' AND Account.Market__c = \'' + market + '\'';
                            if(apiMap.get(m.RecordTypeId).contains('AgeinMonths__c')){
                                conQueryString += ' AND RecordTypeId =: conChildRecType'
                                    + ' AND Parent__r.Active__c = true'
                                    + ' AND (Brand_Relationship_EndUser_Child_Count__c > 0 OR BrandRelationshipCount__c > 0)'
                                    + ' AND AgeinMonths__c = ' + m.MilestoneValue__c;
                            }
                            else{
                                conQueryString += ' AND RecordTypeId =: conAdultRecType'
                                    + ' AND WeeksOfPregnancy__c = ' + m.MilestoneValue__c;
                            }
                        }
                    }
                    if(conQueryString != null){
                        mileStoneConQueryMap.put(m.Id, conQueryString);
                    }
                }
            }
        }
        
        if(!mileStoneConQueryMap.keySet().isEmpty()){
            for(Id msId : mileStoneConQueryMap.keySet()){
                System.debug(mileStoneConQueryMap.get(msId));
                List<Contact> msConList = new List<Contact>();
                msConList = Database.query(mileStoneConQueryMap.get(msId));
                if(!msConList.isEmpty()){
                    mileStoneConListMap.put(msId, msConList); 
                }
            }
        }
        
        String queryStr = 'SELECT Id'
            + ' FROM BrandRelationship__c'
            + ' WHERE Active__c = true'
            + ' AND BrandRelationship__c != null'
            + ' AND BrandOptOut__c = false';
        
        //BR Query
        for(String market: milestoneMap.keySet()){
            
            for(Milestone__c m: milestoneMap.get(market)){
                
                // precaution not to break the query incase a new recordtype suddenly pops up
                if(apiMap.containsKey(m.RecordTypeId)) {
                    if(market == CommonConstant.MARKET_TW){
                        if(queryStr2 != ''){
                            queryStr2 += ' OR ';
                        }
                        if(queryStr2 == ''){
                            queryStr2 += ' AND (';
                        }
                        queryStr2 += '( Household__r.Market__c = \'' + market + '\'';
                        if(apiMap.get(m.RecordTypeId).contains('User__r')){
                            if(apiMap.get(m.RecordTypeId).contains('AgeinMonths__c')){
                                queryStr2 += ' AND User__r.RecordTypeId =: conChildRecType AND User__r.Birthdate < '+todaysDateStr+' ';
                            }
                            else{
                                queryStr2 += ' AND User__r.RecordTypeId =: conChildRecType AND User__r.Birthdate > '+todaysDateStr+' ';
                            }
                            
                            if(apiMap.get(m.RecordTypeId).contains('AgeinMonths__c')){
                                queryStr2 += ' AND ' + apiMap.get(m.RecordTypeId) + ' = ' + m.MilestoneValue__c + ' AND (NOT LatestMilestone__c LIKE \'%' + String.escapeSingleQuotes(m.Name) + '%\')';
                            }
                            else{
                                queryStr2 += ' AND PrimaryContact__r.WeeksOfPregnancy__c = ' + m.MilestoneValue__c + ' AND (NOT LatestMilestone__c LIKE \'%' + String.escapeSingleQuotes(m.Name) + '%\')';
                            }
                        }
                        queryStr2 += ')';
                    }
                    else{
                        if(apiMap.get(m.RecordTypeId).contains('User__r')){
                            if(!mileStoneConListMap.keySet().isEmpty() && mileStoneConListMap.containsKey(m.Id)){
                                if(queryStr2 != ''){
                                    queryStr2 += ' OR ';
                                }
                                if(queryStr2 == ''){
                                    queryStr2 += ' AND (';
                                }
                                //Placeholder variables for Contact query (2 milestone at a time)
                                if(msConQueryList1.isEmpty()){
                                    msConQueryList1 = mileStoneConListMap.get(m.Id);
                                    queryStr2 += '( User__c IN: msConQueryList1';
                                }
                                else if(msConQueryList2.isEmpty()){
                                    msConQueryList2 = mileStoneConListMap.get(m.Id);
                                    queryStr2 += '( User__c IN: msConQueryList2';
                                }
                                queryStr2 += ' AND (NOT LatestMilestone__c LIKE \'%' + String.escapeSingleQuotes(m.Name) + '%\') )';
                            }
                        }
                    }
                    
                }
            }
        }
        if(queryStr2 != ''){
            queryStr2 += ')';
            queryStr += queryStr2;
            System.debug(queryStr);
            return Database.getQueryLocator(queryStr);
        }
        else{
            return Database.getQueryLocator('SELECT Id FROM BrandRelationship__c LIMIT 0');
        }
    }
    
    public void execute(Database.BatchableContext BC, List<BrandRelationship__c> brList){
        Map<Id, Set<String>> milestoneHistoryMap = new Map<Id, Set<String>>();
        
        List<BrandRelationship__c> execBRList = [SELECT Id, PrimaryContact__c, PrimaryContact__r.WeeksOfPregnancy__c, Household__r.Market__c, User__c, 
                                                 User__r.AgeinMonths__c, User__r.WeeksOfPregnancy__c, User__r.Birthdate, User__r.RecordType.Name, 
                                                 Loyalty_Length_in_Months__c, LatestMilestone__c FROM BrandRelationship__c WHERE Id IN: brList AND Household__r.Market__c != null];
        if(!execBRList.isEmpty()){
            // create map of all the milestone that has already been sent for the last 2 months
            // changed to last 7 days, EDD/Birthdate can change and may need to revert to old milestone value
            for(BrandRelationship__History history: [SELECT ParentId, NewValue, Field FROM BrandRelationship__History
                                                     WHERE Field =: 'LatestMilestone__c'
                                                     AND ParentId IN: execBRList
                                                     AND CreatedDate = LAST_N_DAYS:1])
            {
                if(history.NewValue != null){
                    if(!milestoneHistoryMap.containsKey(history.ParentId)){
                        milestoneHistoryMap.put(history.ParentId, new Set<String>());
                    }
                    milestoneHistoryMap.get(history.ParentId).add( (String) history.NewValue);
                }
            }
            
            Map<Id, BrandRelationship__c> brForUpdate = new Map<Id, BrandRelationship__c>();
            for(BrandRelationship__c br: execBRList){
                // check milestones being tracked in the market
                for(Milestone__c m: milestoneMap.get(br.Household__r.Market__c)){
                    
                    // check if milestone not yet set before
                    if( !milestoneHistoryMap.containsKey(br.Id)
                       || (milestoneHistoryMap.containsKey(br.Id)
                           && !milestoneHistoryMap.get(br.Id).contains(m.Name)) ){
                               
                               // get field to check
                               String fieldToCheck = apiMap.get(m.RecordTypeId);
                               String fieldToCheck2 = 'PrimaryContact__r.WeeksOfPregnancy__c';
                               Double brValue;
                               Double brValue2;
                               
                               if(fieldToCheck.contains('.')){
                                   brValue = (Double) br.getSobject(fieldToCheck.split('\\.')[0]).get(fieldToCheck.split('\\.')[1]);
                               }
                               else {
                                   brValue = (Double) br.get(fieldToCheck);
                               }
                               
                               if(brValue < 0 && m.RecordTypeId == RTAgeInMonths) {
                                   continue;
                               }
                               
                               if(fieldToCheck2.contains('.')){
                                   brValue2 = (Double) br.getSobject(fieldToCheck2.split('\\.')[0]).get(fieldToCheck2.split('\\.')[1]);
                               }
                               else {
                                   brValue2 = (Double) br.get(fieldToCheck2);
                               }
                               
                               // compare fields
                               if(m.MilestoneValue__c == brValue || m.MilestoneValue__c == brValue2) {
                                   Boolean isForUpdate = false;
                                   if(br.Household__r.Market__c == CommonConstant.MARKET_TW){
                                       if(br.User__r.RecordType.Name == CommonConstant.CONTACT_CHILD_RECORDTYPE) {
                                           if(m.MilestoneValue__c == brValue2
                                              && Date.today() < br.User__r.Birthdate
                                              && m.RecordTypeId == RTWeeksofPregnancy) {
                                                  isForUpdate = true;
                                              }
                                           else if(m.MilestoneValue__c == brValue
                                                   && Date.today() >= br.User__r.Birthdate
                                                   && m.RecordTypeId == RTAgeInMonths) {
                                                       isForUpdate = true;
                                                   }
                                       }
                                       else {
                                           isForUpdate = true;
                                       }
                                   }
                                   else {
                                       isForUpdate = true;
                                   }
                                   
                                   if(isForUpdate){
                                       br.LatestMilestone__c = m.Name;
                                       br.MilestoneStatus__c = 'Ready to Send';
                                       brForUpdate.put(br.Id, br);
                                       break;
                                   }
                               }
                           }
                    else {
                        // get field to check
                        String fieldToCheck = apiMap.get(m.RecordTypeId);
                        String fieldToCheck2 = 'PrimaryContact__r.WeeksOfPregnancy__c';
                        Double brValue;
                        Double brValue2;
                        
                        if(fieldToCheck.contains('.')){
                            brValue = (Double) br.getSobject(fieldToCheck.split('\\.')[0]).get(fieldToCheck.split('\\.')[1]);
                        }
                        else {
                            brValue = (Double) br.get(fieldToCheck);
                        }
                        
                        if(brValue < 0 && m.RecordTypeId == RTAgeInMonths) {
                            continue;
                        }
                        
                        if(fieldToCheck2.contains('.')){
                            brValue2 = (Double) br.getSobject(fieldToCheck2.split('\\.')[0]).get(fieldToCheck2.split('\\.')[1]);
                        }
                        else {
                            brValue2 = (Double) br.get(fieldToCheck2);
                        }
                        
                        if(m.MilestoneValue__c == brValue || m.MilestoneValue__c == brValue2){
                            Boolean isForUpdate = false;
                            if(br.Household__r.Market__c == CommonConstant.MARKET_TW){
                                if(br.User__r.RecordType.Name == CommonConstant.CONTACT_CHILD_RECORDTYPE) {
                                    if(m.MilestoneValue__c == brValue2
                                       && Date.today() < br.User__r.Birthdate
                                       && m.RecordTypeId == RTWeeksofPregnancy) {
                                           isForUpdate = true;
                                       }
                                    else if(m.MilestoneValue__c == brValue
                                            && Date.today() >= br.User__r.Birthdate
                                            && m.RecordTypeId == RTAgeInMonths) {
                                                isForUpdate = true;
                                            }
                                }
                            }
                            else {
                                isForUpdate = true;
                            }
                            
                            if(isForUpdate){
                                br.LatestMilestone__c = m.Name;
                                br.MilestoneStatus__c = 'Ready to Send';
                                brForUpdate.put(br.Id, br);
                                break;
                            }
                        }
                    }
                }
            }
            
            if(!brForUpdate.isEmpty()) Utilityclass.updateList(brForUpdate.values());
        }
    }
    
    public void finish(Database.BatchableContext BC){}
}