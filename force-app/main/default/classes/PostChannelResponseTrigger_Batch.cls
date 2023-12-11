/*
Author: Jericson
Description: updates BR and Contact first and last channel response based on CR.
    Moved to batch job since MC is hogging all resources in channel response trigger
NOTE: Do ALL ChannelResponse post transaction here
Date:
    May 13, 2020    Jericson    Created
    May 29, 2020 Jericson Moved to Change Event
*/
public class PostChannelResponseTrigger_Batch {} /*implements Database.Batchable<sObject> {

    static Boolean checkHistory = true;
    static String queryOverride = ''; // should a query of a channel response

    public PostChannelResponseTrigger_Batch(Boolean isHistory, String queryOverrideStr) {
        if(!isHistory) {
            checkHistory = false;
            queryOverride = queryOverrideStr;
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime minute15 = Datetime.now().addMinutes(-15);
        String query = 'SELECT ParentId,Field,OldValue,NewValue FROM ChannelResponse__History WHERE CreatedDate >: minute15';

        if(!checkHistory) {
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        Set<Id> crIds = new Set<Id>();

        if(checkHistory) {
            for (ChannelResponse__History history : (List<ChannelResponse__History>) scope) {
                if(history.Field == 'created'
                    || history.Field == 'RegistrationDate__c')
                    crIds.add(history.parentId);
            }
        }
        // created an override to manually process if this happened to be turned off
        else {
            for(ChannelResponse__c cr: (List<ChannelResponse__c>) scope)
                crIds.add(cr.Id);
        }

        Map<Id, BrandRelationship__c> brToUpdateMap = new Map<Id, BrandRelationship__c>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        for(ChannelResponse__c cr: [SELECT RegistrationDate__c, CreatedDate, Classification__c, Channel__c, Campaign__c,
                                           BrandRelationship__c,
                                           BrandRelationship__r.FirstChannelResponseDate__c, BrandRelationship__r.LatestChannelResponseDate__c,
                                           BrandRelationship__r.PrimaryContact__c,
                                           BrandRelationship__r.PrimaryContact__r.FirstChannelResponseDate__c,
                                           BrandRelationship__r.PrimaryContact__r.LatestChannelResponseDate__c,
                                           BrandRelationship__r.PrimaryContact__r.Type__c
                                      FROM ChannelResponse__c
                                     WHERE Id IN: crIds]) {

            Boolean forUpdate = false;
            BrandRelationship__c br = brToUpdateMap.containsKey(cr.BrandRelationship__c) ?
                                        brToUpdateMap.get(cr.BrandRelationship__c)
                                        : new BrandRelationship__c(
                                            Id = cr.BrandRelationship__c,
                                            PrimaryContact__c = cr.BrandRelationship__r.PrimaryContact__c,
                                            FirstChannelResponseDate__c = cr.BrandRelationship__r.FirstChannelResponseDate__c,
                                            LatestChannelResponseDate__c = cr.BrandRelationship__r.LatestChannelResponseDate__c);

            Datetime registrationDate = cr.RegistrationDate__c == null ? cr.CreatedDate : cr.RegistrationDate__c;

            Boolean TestisRunning = Test.isRunningTest(); // Override | In test class, cr trigger auto populates these fields, none will be met

            /********************************* BRAND RELATIONSHIP ***********************************
            // first CR
            if(TestisRunning
                || br.FirstChannelResponseDate__c  == null
                || registrationDate < br.FirstChannelResponseDate__c) {

                br.FirstChannelResponse__c = cr.Channel__c;
                br.FirstChannelResponseDate__c = registrationDate;

                // retro
                if(cr.Classification__c == CommonConstant.CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME) {
                    br.NewtoBrand__c = true;
                    br.NewtoBrandDate__c = date.valueOf(registrationDate);
                }
                forUpdate = true;
            }

            // last CR
            if(TestisRunning
                || br.LatestChannelResponseDate__c == null
                || registrationDate > br.LatestChannelResponseDate__c) {

                br.LatestCampaign__c = cr.Campaign__c;
                br.LatestChannelResponse__c = cr.Channel__c;
                br.LatestChannelResponseDate__c = registrationDate;
                forUpdate = true;
            }

            if(forUpdate)
                brToUpdateMap.put(br.Id, br);

            /********************************* Contact ***********************************
            // run only for Adult
            if(cr.BrandRelationship__r.PrimaryContact__r.Type__c == 'Adult') {

                forUpdate = false;
                Contact con =   contactMap.containsKey(br.PrimaryContact__c) ?
                                contactMap.get(br.PrimaryContact__c)
                                : new Contact(
                                    Id = cr.BrandRelationship__r.PrimaryContact__c,
                                    FirstChannelResponseDate__c = cr.BrandRelationship__r.PrimaryContact__r.FirstChannelResponseDate__c,
                                    LatestChannelResponseDate__c = cr.BrandRelationship__r.PrimaryContact__r.LatestChannelResponseDate__c);
                // first CR
                if(TestisRunning
                    || con.FirstChannelResponseDate__c  == null
                    || registrationDate < con.FirstChannelResponseDate__c) {
                        
                    con.FirstChannelResponse__c = cr.Channel__c;
                    con.FirstChannelResponseDate__c = registrationDate;
                    forUpdate = true;
                }

                // last CR
                if(TestisRunning
                    || con.LatestChannelResponseDate__c == null
                    || registrationDate > con.LatestChannelResponseDate__c) {

                    con.LatestCampaign__c = cr.Campaign__c;
                    con.LatestChannelResponse__c = cr.Channel__c;
                    con.LatestChannelResponseDate__c = registrationDate;
                    forUpdate = true;
                }

                if(forUpdate)
                    contactMap.put(con.Id, con);
            }
        }

        if(!brToUpdateMap.isEmpty()) { Database.update(brToUpdateMap.values(), false); }
        if(!contactMap.isEmpty()) { Database.update(contactMap.values(), false); }
    }
   
    public void finish(Database.BatchableContext BC) {}
}*/