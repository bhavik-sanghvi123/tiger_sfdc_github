/*
Author: Jericson Mercado
Description: Batch job that is created to link all existing cases to the latest channel response based on contact at the time it was created

History
05/17/2021   Binh   	Created
06/09/2021   Jennifer   Comment out entire code, one-time use only
-------------------------------------------------------------------------------------------*/
// for deletion
public class CaseCleanup {} /* implements Database.Batchable<sObject> {
global class CaseCleanup implements Database.Batchable<sObject>, Database.Stateful {
    
    User datamigration;
    global CaseCleanup(){
        String dataStr = Test.isRunningTest() ?  'datamigration@tigerani.abbott.comtest' : 'datamigration@tigerani.abbott.com';
        datamigration = [SELECT Id FROM User WHERE Username =: dataStr];
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        Id callRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        String queryStr = 'SELECT Id, ContactId, CreatedDate, Channel__c, Campaign__r.Brand__c FROM Case WHERE RecordTypeId =: callRecordType and lastmodifieddate > 2019-09-15T10:00:00Z and lastmodifieddate <= 2019-09-24T23:00:00Z and channel__c = null and Campaign__c != null';
        if(System.Test.isRunningTest()) { 
            queryStr = 'SELECT Id, ContactId, CreatedDate, Channel__c, Campaign__r.Brand__c FROM Case WHERE RecordTypeId =: callRecordType';
        }
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList){
        
        //get contact ids and create a map out of it.
        Map<Id, List<Case>> contactCaseMap = new Map<Id, List<Case>>();
        for(Case c: caseList){
            if(c.ContactId != null){
                if(!contactCaseMap.containsKey(c.ContactId)){
                    contactCaseMap.put(c.ContactId, new List<Case>());
                }
                contactCaseMap.get(c.ContactId).add(c);
            }
        }

        //get channel from channel response through brand relationship
        Map<Id, Map<String, List<ChannelResponse__c>>> contactChannelMap = new Map<Id, Map<String, List<ChannelResponse__c>>>();

        //exclude from data migration here
        for(BrandRelationship__c br: [SELECT PrimaryContact__c, KeyBrand__c,
                                             (SELECT Id, Name, CreatedDate, Channel__c,BrandRelationship__c
                                                FROM Channel_Responses__r
                                               WHERE Channel__c != null)
                                        FROM BrandRelationship__c
                                       WHERE PrimaryContact__c IN: contactCaseMap.keySet()
                                         AND KeyBrand__c != null]){
            if(!br.Channel_Responses__r.isEmpty()){
                if(!contactChannelMap.containsKey(br.PrimaryContact__c)){
                    contactChannelMap.put(br.PrimaryContact__c, new Map<String, List<ChannelResponse__c>>());
                }
                if(!contactChannelMap.get(br.PrimaryContact__c).containsKey(br.KeyBrand__c)){
                    contactChannelMap.get(br.PrimaryContact__c).put(br.KeyBrand__c, new List<ChannelResponse__c>());
                }
                contactChannelMap.get(br.PrimaryContact__c).get(br.KeyBrand__c).addAll(br.Channel_Responses__r);
            }
        }

        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(Case c: caseList){

            //remove initial
            if(c.Channel__c != null || c.Campaign__c == null || String.isBlank(c.Campaign__r.Brand__c)){
                c.Channel__c = null;
                caseMap.put(c.Id, c);
            }
            //check if the contact has a channel response
            if(contactChannelMap.containsKey(c.ContactId)
                && contactChannelMap.get(c.ContactId).containsKey(c.Campaign__r.Brand__c)){
                
                ChannelResponse__c createdBefore = new ChannelResponse__c();
                ChannelResponse__c createdAfter = new ChannelResponse__c();
                for(ChannelResponse__c cr: contactChannelMap.get(c.ContactId).get(c.Campaign__r.Brand__c)){
                    
                    if(c.CreatedDate > cr.CreatedDate){
                        createdBefore = cr;
                    }
                    else if(c.CreatedDate < cr.CreatedDate
                        && createdAfter.Id == null) {
                        createdAfter = cr;
                    }
                }

                ChannelResponse__c correctCR = createdBefore.createdDate == getNearestDate(c.CreatedDate, createdBefore.createdDate, createdAfter.createdDate)
                                ? createdBefore : createdAfter;
                c.Channel__c = correctCR.Channel__c;
                c.RelatedChannelResponse__c = correctCR.Id;
                c.RelatedBrandRelationship__c = correctCR.BrandRelationship__c;

                caseMap.put(c.Id, c);
            }
        }

        if(!caseMap.isEmpty()) Database.update(caseMap.values(), false);
    }
    
    global void finish(Database.BatchableContext BC){}

    public DateTime getNearestDate(DateTime call, DateTime crBefore, DateTime crAfter) {

        DateTime b = DateTime.Now();

        // no CR after case creation
        if(crBefore != null
            && crAfter == null){
            b = crBefore;
        }
        // no CR before case creation
        else if(crBefore == null
            && crAfter != null){
            b = crAfter;
        }
        // there are CR both before and after case creation
        else {

            // set previous CR as default
            b = crBefore;

            Integer daysBetweenBefore = Math.ABS(Date.valueOf(call).DaysBetween(Date.valueOf(crBefore)));
            Integer daysBetweenAfter = Math.ABS(Date.valueOf(call).DaysBetween(Date.valueOf(crAfter)));

            // check if both CR is created as same day of the case
            if(call.isSameDay(crBefore)
                && call.isSameDay(crAfter)){
                
                Long caseTime = call.getTime();
                Long crBeforeTime = crBefore.getTime();
                Long crAfterTime = crAfter.getTime();

                Long crTimeDiffBefore = Math.ABS(caseTime - crBeforeTime);
                Long crTimeDiffAfter = Math.ABS(caseTime - crAfterTime);

                b = crTimeDiffBefore < crTimeDiffAfter ? crBefore : crAfter;
            } else if(daysBetweenBefore > daysBetweenAfter) {
                b = crAfter;
            }
        }

        return b;
    }
}*/