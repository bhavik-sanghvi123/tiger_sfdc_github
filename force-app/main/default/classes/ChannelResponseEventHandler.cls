/*
Author: Jericson 
Description: Channel Response post transactional process
Date:
    May 14, 2020 Jericson - Created
	Jan	21, 2021 Jennifer - Added updateMCEligibility
    Mar 31, 2021 Jennifer - Moved updateMCEligibility to ChannelResponseTriggerHandler
    Jun 03, 2021 Jennifer - Added updateANZContact 
	Jan 14, 2022 Paolo - Added re-opt in calls via new channel response [TKT-007465] = Made some updates
*/
public class ChannelResponseEventHandler {

    public static void processEvent(List<ChannelResponse__ChangeEvent> events) {

        Set<Id> crIds = new Set<Id>();
        Set<Id> anzIds = new Set<Id>();

        for(ChannelResponse__ChangeEvent event: events) {

            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            // CREATE
            if(header.changeType == 'CREATE') {
                crIds.add(header.recordIds[0]);
                if(event.Channel__c != null) {
                    anzIds.add(header.recordIds[0]);
                } 
            }

            // UPDATE
            else if(header.changeType == 'UPDATE') {
                if(header.changedFields.contains('RegistrationDate__c')) {
                    crIds.add(header.recordIds[0]);
                }
            }
        }

        if(!crIds.isEmpty()) updateBRandContact(crIds);
        if(!anzIds.isEmpty()) updateANZContact(anzIds);
    }

    public static void updateBRandContact(Set<Id> crIds) {

        Map<Id, BrandRelationship__c> brToUpdateMap = new Map<Id, BrandRelationship__c>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, ChannelResponse__c> crMap = new Map<Id, ChannelResponse__c>();

        for(ChannelResponse__c cr: [SELECT  Id, Channel__c, Channel__r.Name, Channel__r.Channel_Ref_No__c,
                                            Campaign__c,
                                            CreatedDate,
                                            Classification__c, 
                                            PreviousRegistration_SameCampaign__c,
                                            PreviousRegistrationAdult__c,
                                            PreviousRegistrationPediatric__c,
                                            RegistrationDate__c,
                                            BrandRelationship__c,
                                            BrandRelationship__r.FirstChannelResponseDate__c, 
                                            BrandRelationship__r.LatestChannelResponseDate__c,
                                            BrandRelationship__r.PrimaryContact__c,
                                            BrandRelationship__r.PrimaryContact__r.FirstChannelResponseDate__c,
                                            BrandRelationship__r.PrimaryContact__r.LatestChannelResponseDate__c,
                                            BrandRelationship__r.PrimaryContact__r.Type__c,
                                    		BrandRelationship__r.PrimaryContact__r.DoNotCall,
                                    		BrandRelationship__r.PrimaryContact__r.SMSOptOut__c,
                                    		BrandRelationship__r.PrimaryContact__r.HasOptedOutOfEmail,
											BrandRelationship__r.PrimaryContact__r.Market__c,
                                            BrandRelationship__r.BrandRelationship__r.AvailableBrandRelationship__c,
                                            BrandRelationship__r.BrandRelationship__r.isActive,
                                            BrandRelationship__r.BrandRelationship__r.Market__c,
                                            BrandRelationship__r.BrandRelationship__r.CompetitorProduct__c
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

            /********************************* BRAND RELATIONSHIP ***********************************/
            // first CR
            if(br.FirstChannelResponseDate__c  == null
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
            if(br.LatestChannelResponseDate__c == null
                || registrationDate > br.LatestChannelResponseDate__c) {
                br.LatestChannelResponse__c = cr.Channel__c;
                br.LatestCampaign__c = cr.Campaign__c;
                br.LatestChannelResponseDate__c = registrationDate;
                forUpdate = true;
            }

            if(forUpdate)
                brToUpdateMap.put(br.Id, br);

            /********************************* Contact ***********************************/
            // run only for Adult
            if(cr.BrandRelationship__r.PrimaryContact__r.Type__c == 'Adult') {
                forUpdate = false;
                Contact con = contactMap.containsKey(br.PrimaryContact__c) ?
                            contactMap.get(br.PrimaryContact__c) :
                            new Contact(Id = br.PrimaryContact__c,
                                        FirstChannelResponseDate__c = cr.BrandRelationship__r.PrimaryContact__r.FirstChannelResponseDate__c,
                                        LatestChannelResponseDate__c = cr.BrandRelationship__r.PrimaryContact__r.LatestChannelResponseDate__c);

                // first CR
                if(con.FirstChannelResponseDate__c  == null
                    || registrationDate < con.FirstChannelResponseDate__c) {

                    con.FirstChannelResponse__c = cr.Channel__c;
                    con.FirstChannelResponseDate__c = registrationDate;
                    forUpdate = true;
                }

                // last CR
                if(con.LatestChannelResponseDate__c == null
                    || registrationDate > con.LatestChannelResponseDate__c) {

                    con.LatestChannelResponse__c = cr.Channel__c;
                    con.LatestCampaign__c = cr.Campaign__c;
                    con.LatestChannelResponseDate__c = registrationDate;
                    forUpdate = true;
                }

                //TKT-007963 - HCP_Sampling_T2_PED
                if(cr.Channel__c != null && cr.Channel__r.Channel_Ref_No__c != null && cr.Channel__r.Channel_Ref_No__c.equalsIgnoreCase('TW_HCP_Sampling_T2') ){
                    con.Have_Purchased_Paid_Sample__c = true;
                    forUpdate = true;
                }

                //TKT-009281 - TW_HCP_Sampling_T3_PED
                if(cr.Channel__c != null && cr.Channel__r.Channel_Ref_No__c != null && cr.Channel__r.Channel_Ref_No__c.equalsIgnoreCase('TW_HCP_Sampling_T3') ){
                    con.Have_Purchased_Paid_Sample__c = true;
                    forUpdate = true;
                }

                //TKT-009072 - Abbott Family Rewards SG channel
                if(cr.Channel__c != null && cr.Channel__r.Channel_Ref_No__c != null && cr.Channel__r.Channel_Ref_No__c.equalsIgnoreCase('SG-AFR') ) {
                    cr.Classification__c = '';
                    cr.PreviousRegistration_SameCampaign__c = false;
                    cr.PreviousRegistrationAdult__c = false;
                    cr.PreviousRegistrationPediatric__c = false;
                    crMap.put(cr.Id, cr);
                    forUpdate = true;
                }

				// added by paolo - [TKT-007465]
                if(cr.BrandRelationship__r.PrimaryContact__r.Market__c.equals(CommonConstant.MARKET_TW) && cr.BrandRelationship__r.PrimaryContact__r.DoNotCall == True){
					con.DoNotCall = False;
                    con.SMSOptOut__c = False;
                    con.HasOptedOutOfEmail = False;
                    forUpdate = True;
				}

                if(forUpdate)
                    contactMap.put(con.Id, con);
            }
        }

        if(!brToUpdateMap.isEmpty()) UtilityClass.updateList(brToUpdateMap.values()); 
        if(!contactMap.isEmpty()) UtilityClass.updateList(contactMap.values());
        if(!crMap.isEmpty()) UtilityClass.updateList(crMap.values());
    }

    // TKT-004312: update ANZ contact when HENS And Consumer CR is created
    public static void updateANZContact(Set<Id> crIds) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
      
        for(ChannelResponse__c cr: [SELECT Id, is_Hens__c,is_Consumer__c, Contact__c, BrandRelationship__c, 
                                    BrandRelationship__r.PrimaryContact__c,
                                    BrandRelationship__r.PrimaryContact__r.is_HENS__c,
                                    BrandRelationship__r.PrimaryContact__r.is_Consumer__c
                                    FROM ChannelResponse__c 
                                    WHERE Id IN: crIds AND Contact__r.Market__c = 'ANZ']) {   
                                
            Boolean forUpdate = false; 

            Contact con = contactMap.containsKey(cr.Contact__c) ?
            contactMap.get(cr.Contact__c) :
            new Contact(Id = cr.BrandRelationship__r.PrimaryContact__c,
                        is_Hens__c = cr.BrandRelationship__r.PrimaryContact__r.is_HENS__c,
                        is_Consumer__c = cr.BrandRelationship__r.PrimaryContact__r.is_Consumer__c);

            if(cr.is_Hens__c && !con.is_Hens__c){
                con.is_Hens__c = cr.is_Hens__c;
                forUpdate = true;      
            }
            else if(cr.is_Consumer__c && !con.is_Consumer__c){
                con.is_Consumer__c = cr.is_Consumer__c;
                forUpdate = true;   
            }

            if(forUpdate){  
                contactMap.put(con.Id, con);
            }
    	}

        if(!contactMap.isEmpty()) UtilityClass.updateList(contactMap.values());
    }
}