/*----------------------------------------------------------------------------------------
Author:      Rey Austral
Description: Relicate the function of CR trigger

History
10/14/2019   raustral   Created
-------------------------------------------------------------------------------------------*/
// for deletion
global class ChannelResponseBatch {} /* implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID ,  PrimaryContact__c'                       
            + ' FROM BrandRelationship__c '
            + ' WHERE'
            + ' (LastModifiedDate = THIS_MONTH OR LastModifiedDate = LAST_MONTH)'
            + ' AND (FirstChannelResponse__c = null or LatestChannelResponse__c = null)'
            + ' AND PrimaryContact__r.Market__c = \'SG\'';
            
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BrandRelationship__c> scope) {
        List<BrandRelationship__c> brList = [Select Id, FirstChannelResponse__c, FirstChannelResponseDate__c, LatestChannelResponse__c, LatestChannelResponseDate__c, LatestCampaign__c,PrimaryContact__c,User__c,
                                            (Select Id,RegistrationDate__c,Channel__c,Campaign__c,CreatedDate,Name,Classification__c From  Channel_Responses__r order by RegistrationDate__c,Name) 
                                            From BrandRelationship__c Where Id IN: scope];
        List<BrandRelationship__c> toUpdateList = new List<BrandRelationship__c>();
        Set<Id> conIdSet = New Set<Id>();    
        for (BrandRelationship__c br : brList) {
            Integer ctr=0;
            for (ChannelResponse__c cr:  br.Channel_Responses__r) {
                if (ctr == 0) {
                    br.FirstChannelResponse__c = cr.Channel__c;
                    br.FirstChannelResponseDate__c = cr.RegistrationDate__c;
                }
                ctr = ctr +1;
                 
                br.LatestChannelResponse__c = cr.Channel__c;
                br.LatestChannelResponseDate__c = cr.RegistrationDate__c;
                if (cr.Campaign__c != null) {
                    br.LatestCampaign__c = cr.Campaign__c;
                }                

                if (cr.Classification__c == CommonConstant.CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME) {
                    br.NewtoBrand__c = true;
                    br.NewtoBrandDate__c = date.valueOf( cr.RegistrationDate__c );                    
                }
            }  
            if (ctr != 0) {
                conIdSet.add(br.PrimaryContact__c);
                conIdSet.add(br.User__c);
                toUpdateList.add(br);            
            }            
        }
        if (!toUpdateList.isEmpty()) {
            Update toUpdateList;
            List<Contact> contactList = [Select Id, FirstChannelResponse__c,FirstChannelResponseDate__c, LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c,
                                             (Select Id,FirstChannelResponse__c,FirstChannelResponseDate__c,LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c from MainBrandRelationships__r) ,
                                             (Select Id, FirstChannelResponse__c,FirstChannelResponseDate__c,LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c from BrandRelationships__r)
                                             From Contact Where Id IN: conIdSet AND Type__c =: CommonConstant.CONTACT_ADULT_TYPE];
            List<Contact> toUpdateContactList = new List<Contact>();
            for(Contact con : contactList) {
                Datetime oldFirst = con.FirstChannelResponseDate__c;
                Datetime oldLast = con.LatestChannelResponseDate__c;
                
                for(BrandRelationship__c br : con.MainBrandRelationships__r) {                
                    //Update Contact First Channel with the earliest date
                    if (con.FirstChannelResponseDate__c  == null) {
                        con.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c;
                        con.FirstChannelResponse__c = br.FirstChannelResponse__c;
                    } else if (con.FirstChannelResponseDate__c >  br.FirstChannelResponseDate__c ) {
                        con.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c;
                        con.FirstChannelResponse__c = br.FirstChannelResponse__c;
                    }
                    //Update Contact Latest Channel with the  most recently created
                    if (con.LatestChannelResponseDate__c  == null) {
                        con.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c;
                        con.LatestChannelResponse__c = br.LatestChannelResponse__c;
                        con.LatestCampaign__c = br.LatestCampaign__c;
                    } else if (con.LatestChannelResponseDate__c < br.LatestChannelResponseDate__c) {
                        con.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c;
                        con.LatestChannelResponse__c = br.LatestChannelResponse__c;
                        con.LatestCampaign__c = br.LatestCampaign__c == null ? con.LatestCampaign__c : br.LatestCampaign__c;
                    }
                }
                
                for(BrandRelationship__c br : con.BrandRelationships__r) {                
                    //Update Contact First Channel with the earliest date
                    if (con.FirstChannelResponseDate__c  == null) {
                        con.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c;
                    } else if (con.FirstChannelResponseDate__c >  br.FirstChannelResponseDate__c ) {
                        con.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c;
                    }
                    //Update Contact Latest Channel with the  most recently created
                    if (con.LatestChannelResponseDate__c  == null) {
                        con.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c;
                        con.LatestChannelResponse__c = br.LatestChannelResponse__c;
                        con.LatestCampaign__c = br.LatestCampaign__c;
                    } else if (con.LatestChannelResponseDate__c < br.LatestChannelResponseDate__c) {
                        con.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c;
                        con.LatestChannelResponse__c = br.LatestChannelResponse__c;                        
                        con.LatestCampaign__c = br.LatestCampaign__c == null ? con.LatestCampaign__c : br.LatestCampaign__c;
                    }
                }
                if (oldFirst != con.FirstChannelResponseDate__c || oldLast != con.LatestChannelResponseDate__c)
                    toUpdateContactList.add(con);   
            }

            if (toUpdateContactList.size() != 0 ){
                update toUpdateContactList;
            }
        }
    }
   
    global void finish(Database.BatchableContext BC) {
        
    }
}*/