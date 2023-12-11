/**
* @author        Rey Austral
* @date          1.10.2019
* @description   Class primarily responsible in handling trigger execution per object.
* @revision(s)
                 2.12.2019 - raustral - change primarybrandrelationships__r to MainBrandRelationships__r
                 6.18.2019 - rustral - add updateClassification
         		 6.25.2019 - mocillos - updated createSampleOrder for Contacts with milk restriction
				 7.30.2019 - malviz - add populateContact
                 5.12.2020 - jericson - code enhancement,
                 5.13.2020 - jericson - MOVED ALL OTHER DML OF to POSTChannelResponseTrigger
                 5.19.2020 - jericson - Moved after insert and after update processes to Change Event
                 7.20.2020 - malviz - bypass delete when To be Archived is true
                 3.31.2021 - malviz - added updateMCEligibility
                 12.14.2021 - fgomendoza - Moved CreateSampleOrder to Queueable class
*/
public class ChannelResponseTriggerHandler implements ITriggerHandler{
    public void BeforeInsert(List<SObject> newList) { 
    	Set<Id> contactIdSet = populateContactAndRegistrationDate(newList);
        updateClassification(newList, contactIdSet);
        updateMCEligibility(newList);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
    	populateContactAndRegistrationDate(newList);
    }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
        List<ChannelResponse__c> crList = (List<ChannelResponse__c>) newList;
        Set<Id> crIds = new Set<Id>();
        
        for(ChannelResponse__c cr : crList) {
            if (cr.IsSample_Requested__c && cr.ProductSampleRequested__c != null
                && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING) {
                crIds.add(cr.Id);
            }
            else if(!cr.IsSample_Requested__c && cr.SampleGivenOnGround__c && cr.ProductSampleRequested__c != null
                && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING){
                crIds.add(cr.Id);
            }
        }
        
        if(!crIds.isEmpty()) createSampleOrder(crIds);
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){
        List<ChannelResponse__c> crList = (List<ChannelResponse__c>) newList;
        Set<Id> crIds = new Set<Id>();
        
        for(ChannelResponse__c cr : crList) {
            ChannelResponse__c oldRec = (ChannelResponse__c)oldMapItems.get(cr.Id);
            
            if (cr.IsSample_Requested__c && (cr.DeliveryAddress__c != null || cr.SampleGivenOnGround__c) && cr.ProductSampleRequested__c != null && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING
                && (cr.IsSample_Requested__c != oldRec.IsSample_Requested__c || cr.OrderCreationStatus__c != oldRec.OrderCreationStatus__c || cr.DeliveryAddress__c != oldRec.DeliveryAddress__c)) {
                crIds.add(cr.Id); 
			}
            else if(!cr.IsSample_Requested__c && cr.SampleGivenOnGround__c && (cr.DeliveryAddress__c != null || cr.SampleGivenOnGround__c) && cr.ProductSampleRequested__c != null && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING
                && (cr.IsSample_Requested__c != oldRec.IsSample_Requested__c || cr.SampleGivenOnGround__c != oldRec.SampleGivenOnGround__c || cr.OrderCreationStatus__c != oldRec.OrderCreationStatus__c || cr.DeliveryAddress__c != oldRec.DeliveryAddress__c)) {
                crIds.add(cr.Id);
            }
        }
        
        if(!crIds.isEmpty()) createSampleOrder(crIds);
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        List<ChannelResponse__c> oldCR = (List<ChannelResponse__c>) oldList;
        List<ChannelResponse__c> crToProcess = new List<ChannelResponse__c>();
       
        for(ChannelResponse__c cr: oldCR ){
           If(cr.To_be_Archived__c == false){
               crToProcess .add(cr);
           }
        }
        
        if(!crToProcess.isEmpty()) deletedChannelResponse(crToProcess);
    }
    
    // @author        Rey Austral
    // @date          1.10.2019
    // @description   Method that will update the field first and latest response date from the brandrelationship and contact object
    //                when the record has been deleted
    // @revision(s)      
    public void deletedChannelResponse(List<ChannelResponse__c> oldList) {
        Set<Id> brIdSet = New Set<Id>();
        
        for(ChannelResponse__c oldCr : oldList) {            
            brIdSet.add(oldCr.BrandRelationship__c);
        }       
        
        List<BrandRelationship__c> brList = [select Id, FirstChannelResponse__c, FirstChannelResponseDate__c, 
                                                    LatestChannelResponse__c, LatestChannelResponseDate__c,
                                                    PrimaryContact__c, User__c,LatestCampaign__c,
                                             (Select Id,RegistrationDate__c,Channel__c,Campaign__c,CreatedDate From  Channel_Responses__r) 
                                             From BrandRelationship__c Where Id IN: brIdSet]; 
        Set<Id> conIdSet = New Set<Id>();
        for(BrandRelationship__c br : brList) {
            DateTime firstDate, lastDate;
            Id firstRecord, latestRecord, latestCampaign;
            //empty the field if the user deletes all the channel response
            conIdSet.add(br.PrimaryContact__c);     
            conIdSet.add(br.User__c);     
            if (br.Channel_Responses__r == null || br.Channel_Responses__r.size() == 0) {
                br.FirstChannelResponseDate__c = null;
                br.FirstChannelResponse__c = null;
                br.LatestChannelResponseDate__c = null;
                br.LatestChannelResponse__c = null;
                br.LatestCampaign__c = null;
            } else {
                //get the first and latest date from the existing records
                for(ChannelResponse__c cr : br.Channel_Responses__r) {                
                    Datetime registrationDate = cr.RegistrationDate__c == null ? cr.CreatedDate : cr.RegistrationDate__c;

                    if (firstDate  == null) {
                        firstDate = registrationDate;
                        firstRecord = cr.Channel__c;
                        lastDate = registrationDate;
                        latestRecord = cr.Channel__c;
                        latestCampaign = cr.Campaign__c;
                    } else {
                        //Update First Channel with the earliest date                       
                        firstRecord = firstDate >  registrationDate ?  cr.Channel__c : firstRecord;
                        firstDate = firstDate >  registrationDate ?  registrationDate : firstDate;                        
                        //Update Latest Channel with the  most recently created
                        latestRecord = lastDate < registrationDate ?  cr.Channel__c : latestRecord;
                        latestCampaign = lastDate < registrationDate ?  cr.Campaign__c : latestRecord;    
                        lastDate = lastDate < registrationDate ?  registrationDate : lastDate; 
                                                         

                    }
                }
                br.FirstChannelResponse__c = firstRecord;
                br.FirstChannelResponseDate__c = firstDate;
                br.LatestChannelResponse__c = latestRecord;
                br.LatestChannelResponseDate__c = lastDate;
                br.LatestCampaign__c = latestCampaign;                
            }
        }
        if (brList.size() != 0 ){
            //Update brList;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        
            List<Database.SaveResult> sr = Database.update(brList, dml);
        }
        //get all related brand relationship related to contact (primary and not primary)
        List<Contact> contactList = [Select Id, FirstChannelResponse__c,FirstChannelResponseDate__c, LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c,
                                     (Select Id,FirstChannelResponse__c,FirstChannelResponseDate__c,LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c from MainBrandRelationships__r) ,
                                     (Select Id,FirstChannelResponse__c,FirstChannelResponseDate__c,LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c from BrandRelationships__r) 
                                     From Contact Where Id IN: conIdSet];
        for(Contact con : contactList) {
            DateTime firstDate, lastDate;
            Id firstRecord,latestRecord,latestCampaign;
            //get the first and latest date from the existing records
            //For primary brand relationship
             for(BrandRelationship__c br : con.MainBrandRelationships__r) {                
                if (firstDate  == null) {
                    firstDate = br.FirstChannelResponseDate__c;
                    firstRecord = br.FirstChannelResponse__c;
                } else if (firstDate >  br.FirstChannelResponseDate__c ) {
                    firstDate = br.FirstChannelResponseDate__c;
                    firstRecord = br.FirstChannelResponse__c;
                }
                //Update Contact Latest Channel with the  most recently created
                if (lastDate == null) {
                    lastDate = br.LatestChannelResponseDate__c;
                    latestRecord = br.LatestChannelResponse__c;
                    latestCampaign = br.LatestCampaign__c;
                } else if (lastDate < br.LatestChannelResponseDate__c) {
                    lastDate = br.LatestChannelResponseDate__c;
                    latestRecord = br.LatestChannelResponse__c;
                    latestCampaign = br.LatestCampaign__c;
                }
            }
            
            for(BrandRelationship__c br : con.BrandRelationships__r) {                
                if (firstDate  == null) {
                    firstDate = br.FirstChannelResponseDate__c;
                } else if (firstDate >  br.FirstChannelResponseDate__c ) {
                    firstDate = br.FirstChannelResponseDate__c;
                }
                //Update Contact Latest Channel with the  most recently created
                if (lastDate == null) {
                    lastDate = br.LatestChannelResponseDate__c;
                    latestRecord = br.LatestChannelResponse__c;
                    latestCampaign = br.LatestCampaign__c;
                } else if (lastDate < br.LatestChannelResponseDate__c) {
                    lastDate = br.LatestChannelResponseDate__c;
                    latestRecord = br.LatestChannelResponse__c;
                    latestCampaign = br.LatestCampaign__c;
                }
            }
            con.FirstChannelResponseDate__c = firstDate;
            con.FirstChannelResponse__c = firstRecord;
            con.LatestChannelResponseDate__c = lastDate;
            con.LatestChannelResponse__c = latestRecord;
            con.LatestCampaign__c = latestCampaign;
        }
        
        if (contactList.size() != 0 ){
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(contactList, dml);
            //Update contactList;
        }        
    }

    public static Set<Id> populateContactAndRegistrationDate(List<ChannelResponse__c> crList){
        Set<Id> brIdSet = new Set<Id>();
        for(ChannelResponse__c cr : crList){
            if(cr.RegistrationDate__c == null) {
                cr.RegistrationDate__c = System.now();
            }

            //if (cr.BrandRelationship__c != null) 
            brIdSet.add(cr.BrandRelationship__c);
        }
        Set<Id> contactIdSet = new Set<Id>();
        //if (!brIdSet.isEmpty()) {
        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>([select Id, PrimaryContact__c from BrandRelationship__c where Id in :brIdSet]);
        //List<ChannelResponse__c> crToUpdate = new List<ChannelResponse__c>();
        for(ChannelResponse__c cr : crList){
            BrandRelationship__c br = brMap.get(cr.BrandRelationship__c);
            cr.Contact__c = br.PrimaryContact__c;
            contactIdSet.add(cr.Contact__c);
        }
        //}
        return contactIdSet;
    }

    // 5.12.2020 | moved BR update to updateFirstChannelResponse method
    public void updateClassification(List<ChannelResponse__c> newList, Set<Id> contactIds) {
        List<AffiliateMetadata__mdt> am = [Select MasterLabel, ChannelNewRegistrationValidity__c 
                                        From AffiliateMetadata__mdt Where ChannelNewRegistrationValidity__c != NULL];
        Map<String, String> acs = UtilityClass.convertObjToMap(am, CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_NEWREG);
        
        //get all the brand type for each cr
        Map<Id, Set<String>> existingBRType = new Map<Id, Set<String>>();
        //get the latest brand type of each contact
        Map<String, ChannelWrapper> latestContactCR = new Map<String, ChannelWrapper>();
        Map<Id, Set<Id>> brCampaignMap = new Map<Id, Set<Id>>();

        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>([Select Id, PrimaryContact__c,KeyBrand__c,BrandRelationshipType__c,BrandRelationship__r.ParentProduct__c, 
                                                                                    PrimaryContact__r.Market__c, User__c, BrandRelationship__c, BrandRelationship__r.ProductCode,
                                                                                    (Select RegistrationDate__c, PreviousRegistrationAdult__c, PreviousRegistrationPediatric__c, Campaign__c
                                                                                    From Channel_Responses__r Order By RegistrationDate__c asc )
                                                                                    From BrandRelationship__c Where PrimaryContact__c IN: contactIds]);
        //this will handle duplicate BR, get only the latest cr across duplicate all BR even duplicate
        //no need for this if they will not allow duplicate br
        for(BrandRelationship__c br : brMap.values() ) {                
            ChannelWrapper existingChannel = latestContactCR.get(br.BrandRelationship__r.ProductCode + br.PrimaryContact__c + br.User__c);
            Integer crSize = br.Channel_Responses__r.size();
            if (existingChannel != null && crSize != 0 ) {
                ChannelResponse__c currentFirstCR =  br.Channel_Responses__r.get(0);   
                if (existingChannel.firstRegistrationDate > currentFirstCR.RegistrationDate__c) {                        
                    existingChannel.firstRegistrationDate = currentFirstCR.RegistrationDate__c;                        
                } 
                //if size = 1 get the fist record which is also the currentfirstcr
                ChannelResponse__c currentLastCR = crSize == 1 ? currentFirstCR : br.Channel_Responses__r.get(crSize - 1);                                        
                if (existingChannel.latestRegistrationDate < currentLastCR.RegistrationDate__c) {                        
                    existingChannel.latestRegistrationDate = currentLastCR.RegistrationDate__c;                        
                }                      
            } else if (existingChannel == null && crSize != 0) {    
                ChannelWrapper currentCR = new ChannelWrapper();  
                currentCR.firstRegistrationDate =  br.Channel_Responses__r.get(0).RegistrationDate__c;
                currentCR.latestRegistrationDate = crSize == 1 ? currentCR.firstRegistrationDate : br.Channel_Responses__r.get(crSize - 1).RegistrationDate__c;  
                latestContactCR.put(br.BrandRelationship__r.ProductCode + br.PrimaryContact__c + br.User__c, currentCR);
            }

            if (crSize != 0) {
                Set<String> brandTypeSet = existingBRType.get(br.PrimaryContact__c);
                if (brandTypeSet == null) {
                    brandTypeSet = new Set<String>();
                    brandTypeSet.add(br.BrandRelationshipType__c);
                    existingBRType.put(br.PrimaryContact__c, brandTypeSet);
                } else {
                    brandTypeSet.add(br.BrandRelationshipType__c);
                }
            } 

            brCampaignMap.put(br.Id, new Set<Id>());
            for(ChannelResponse__c cr2: br.Channel_Responses__r)
                if(cr2.Campaign__c != null) brCampaignMap.get(br.Id).add(cr2.Campaign__c);
        }
        //process the new inserted records
        for(ChannelResponse__c cr : newList) {                
            BrandRelationship__c br = brMap.get(cr.BrandRelationship__c); 
            ChannelWrapper existingCR = br != null ? latestContactCR.get(br.BrandRelationship__r.ProductCode + br.PrimaryContact__c + br.User__c) : null;
            Boolean isRetroRecord = false;
            cr.Classification__c = CommonConstant.CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME;
            if (br != null && existingCR != null) {
                String validMonthStr = acs.containsKey(br.PrimaryContact__r.Market__c) ? acs.get(br.PrimaryContact__r.Market__c) : '0';    
                if (existingCR.firstRegistrationDate > cr.RegistrationDate__c) {
                    isRetroRecord = true; //there is already an existing first registration but the inserted cr is much older
                } else if ( (String.isEmpty(validMonthStr) || validMonthStr == '0')
                            || (existingCR.latestRegistrationDate.addMonths( Integer.valueOf(validMonthStr) ) >= cr.RegistrationDate__c) ) {
                        cr.Classification__c = CommonConstant.CHANNELRESPONSE_CLASSIFICATION_SAMEBRAND;   
                }            
            }
                
            Set<String> brandTypeSet = br != null ? existingBRType.get(br.PrimaryContact__c) : null;
            if (brandTypeSet != null && !isRetroRecord) {
                cr.PreviousRegistrationAdult__c = brandTypeSet.contains('Adult');               
                cr.PreviousRegistrationPediatric__c = brandTypeSet.contains('Pediatric');
            }
            
            // US-0883 check if there is existing cr from same campaign
            cr.PreviousRegistration_SameCampaign__c = cr.Campaign__c != null && brCampaignMap.get(cr.BrandRelationship__c).contains(cr.Campaign__c);
        }
    }

    public class ChannelWrapper {
        public DateTime latestRegistrationDate { get; set; }
        public DateTIme firstRegistrationDate { get; set; }
    }

    // Update MC Eligibility fields
    public static void updateMCEligibility(List<ChannelResponse__c> crList) {
        
        Set<Id> conIds = new Set<Id>();
        for(ChannelResponse__c cr : crList){
            if(cr.Contact__c != null){
                conIds.add(cr.Contact__c);
            }
        }

      	Map<Id, Contact> contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                                           MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                                           MC_Sync_Eligibility_VN__c
                                                           FROM Contact 
                                                           WHERE Id IN :conIds]);
        
        for(ChannelResponse__c cr: crList) {
            if(cr.Contact__c != null){               
                String Market = contactMap.get(cr.Contact__c).Market__c;
                            
                if(Market == CommonConstant.MARKET_ANZ){
                    cr.MC_Sync_Eligibility_ANZ__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_ANZ__c;
                }else if(Market == CommonConstant.MARKET_ID){
                    cr.MC_Sync_Eligibility_ID__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_ID__c;
                }else if(Market == CommonConstant.MARKET_IN){
                    cr.MC_Sync_Eligibility_IN__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_IN__c;
                }else if(Market == CommonConstant.MARKET_MY){
                    cr.MC_Sync_Eligibility_MY__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_MY__c;
                }else if(Market == CommonConstant.MARKET_PH){
                    cr.MC_Sync_Eligibility_PH__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_PH__c;
                }else if(Market == CommonConstant.MARKET_SG){
                    cr.MC_Sync_Eligibility_SG__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_SG__c;
                }else if(Market == CommonConstant.MARKET_TH){
                    cr.MC_Sync_Eligibility_TH__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_TH__c;
                }else if(Market == CommonConstant.MARKET_VN){
                    cr.MC_Sync_Eligibility_VN__c = contactMap.get(cr.Contact__c).MC_Sync_Eligibility_VN__c;
                }
            }
        }
    }
    
    public static void createSampleOrder(Set<Id> crIdSet) {
        List<ChannelResponse__c> crToProcessList = [SELECT Id, IsSample_Requested__c, ProductSampleRequested__c, OrderCreationStatus__c, DeliveryAddress__c,
                                                    BrandRelationship__r.PrimaryContact__c, BrandRelationship__r.PrimaryContact__r.Market__c,
                                                    BrandRelationship__r.PrimaryContact__r.Verified__c, SampleProductCode__c, BrandRelationship__r.User__c,
                                                    BrandRelationship__r.User__r.RecordType.DeveloperName, ProductSampleRequested__r.Stage1PaidSample__c, 
                                                    ProductSampleRequested__r.Stage3PaidSample__c, Campaign__c, PromoterCode__c, SampleGivenOnGround__c
                                                    FROM ChannelResponse__c
                                                    WHERE Id IN :crIdSet AND BrandRelationship__r.PrimaryContact__r.Market__c = 'TW'];
        
        
        if (!crToProcessList.isEmpty()) {
            /*TKT-004556 FG: moved to queueable*/
            //CreateSampleOrder.executeSampleCreation(crToProcessList);
            System.enqueueJob(new CreateSampleOrderQueueable(crToProcessList));
        }
        
    }
    
    // @author        Rey Austral
    // @date          1.10.2019
    // @description   Method that will update the field first and latest response date from the brandrelationship and contact object
    // @revision(s)    
    // public void updateFirstResponse(List<ChannelResponse__c> newList, Map<Id, SObject> oldMap) {
        
    //     //List<ChannelResponse__c> newTriggerList = [Select Id, BrandRelationship__c from ChannelResponse__c];
    //     Set<Id> brIdSet = New Set<Id>();
    //     List<ChannelResponse__c> crList = new List<ChannelResponse__c>();
        
    //     for(ChannelResponse__c cr : newList) {
    //         if (Trigger.isInsert) {
    //             brIdSet.add(cr.BrandRelationship__c);
    //             crList.add(cr);
    //         } else {
    //             ChannelResponse__c oldRec = (ChannelResponse__c) oldMap.get(cr.Id);
    //             if (cr.RegistrationDate__c != oldRec.RegistrationDate__c) {
    //                 brIdSet.add(cr.BrandRelationship__c);
    //                 crList.add(cr);
    //             }
    //         }
    //     }       
    //     if (!brIdSet.isEmpty()) {
    //         Set<Id> conIdSet = New Set<Id>();

    //         Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>(
    //                                             [SELECT Id, FirstChannelResponse__c, FirstChannelResponseDate__c, 
    //                                                     LatestChannelResponse__c, LatestChannelResponseDate__c,
    //                                                     PrimaryContact__c, User__c, LatestCampaign__c,
    //                                                     PrimaryContact__r.FirstChannelResponseDate__c, PrimaryContact__r.LatestChannelResponseDate__c,
    //                                                     PrimaryContact__r.Type__c
    //                                                FROM BrandRelationship__c
    //                                               WHERE Id IN: brIdSet]);

    //         Map<Id, BrandRelationship__c> brToUpdateMap = new Map<Id, BrandRelationship__c>();
    //         Map<Id, Contact> contactMap = new Map<Id, Contact>();

    //         for(ChannelResponse__c cr: crList) {
    //             Boolean forUpdate = false;
    //             BrandRelationship__c br = brToUpdateMap.containsKey(cr.BrandRelationship__c) ?
    //                                       brToUpdateMap.get(cr.BrandRelationship__c)
    //                                       : brMap.get(cr.BrandRelationship__c);

    //             Datetime registrationDate = cr.RegistrationDate__c == null ? cr.CreatedDate : cr.RegistrationDate__c;

    //             /********************************* BRAND RELATIONSHIP ***********************************/
    //             // first CR
    //             if(br.FirstChannelResponseDate__c  == null
    //                 || registrationDate < br.FirstChannelResponseDate__c) {

    //                 br.FirstChannelResponse__c = cr.Channel__c;
    //                 br.FirstChannelResponseDate__c = registrationDate;

    //                 // retro
    //                 if(cr.Classification__c == CommonConstant.CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME) {
    //                     br.NewtoBrand__c = true;
    //                     br.NewtoBrandDate__c = date.valueOf(registrationDate);
    //                 }
    //                 forUpdate = true;
    //             }

    //             // last CR
    //             if(br.LatestChannelResponseDate__c == null
    //                 || registrationDate > br.LatestChannelResponseDate__c) {

    //                 br.LatestChannelResponse__c = cr.Channel__c;
    //                 br.LatestCampaign__c = cr.Campaign__c;
    //                 br.LatestChannelResponseDate__c = registrationDate;
    //                 forUpdate = true;
    //             }

    //             if(forUpdate)
    //                 brToUpdateMap.put(br.Id, br);

    //             /********************************* Contact ***********************************/
    //             // run only for Adult
    //             if(br.PrimaryContact__r.Type__c == 'Adult') {

    //                 forUpdate = false;
    //                 Contact con = contactMap.containsKey(br.PrimaryContact__c) ?
    //                             contactMap.get(br.PrimaryContact__c) :
    //                             new Contact(Id = br.PrimaryContact__c,
    //                                         FirstChannelResponseDate__c = br.PrimaryContact__r.FirstChannelResponseDate__c,
    //                                         LatestChannelResponseDate__c = br.PrimaryContact__r.LatestChannelResponseDate__c);
    //                 // first CR
    //                 if(con.FirstChannelResponseDate__c  == null
    //                     || registrationDate < con.FirstChannelResponseDate__c) {

    //                     con.FirstChannelResponse__c = cr.Channel__c;
    //                     con.FirstChannelResponseDate__c = registrationDate;
    //                     forUpdate = true;
    //                 }

    //                 // last CR
    //                 if(con.LatestChannelResponseDate__c == null
    //                     || registrationDate > con.LatestChannelResponseDate__c) {

    //                     con.LatestChannelResponse__c = cr.Channel__c;
    //                     con.LatestCampaign__c = cr.Campaign__c;
    //                     con.LatestChannelResponseDate__c = registrationDate;
    //                     forUpdate = true;
    //                 }

    //                 if(forUpdate)
    //                     contactMap.put(con.Id, con);
    //             }
    //         }

    //         if(!brToUpdateMap.isEmpty()) { Database.update(brToUpdateMap.values(), false); }
    //         if(!contactMap.isEmpty()) { Database.update(contactMap.values(), false); }

    //         /*
    //         5.12.2020 jericson | used different approach above
    //         List<BrandRelationship__c> brList = [select Id, FirstChannelResponse__c, FirstChannelResponseDate__c, 
    //                                              LatestChannelResponse__c, LatestChannelResponseDate__c,
    //                                              PrimaryContact__c,User__c,LatestCampaign__c,
    //                                              (Select Id,RegistrationDate__c,Channel__c,Campaign__c,CreatedDate From  Channel_Responses__r) 
    //                                              From BrandRelationship__c Where Id IN: brIdSet]; 
    //         Set<Id> conIdSet = New Set<Id>();    
    //         List<BrandRelationship__c> brToUpdateList = new List<BrandRelationship__c>();
    //         for(BrandRelationship__c br : brList) {
    //             //get the first and latest date from the existing records including the new added record      
    //             Datetime oldFirst = br.FirstChannelResponseDate__c;
    //             Datetime oldLast = br.LatestChannelResponseDate__c;      
    //             for(ChannelResponse__c cr : br.Channel_Responses__r) {                
    //                 conIdSet.add(br.PrimaryContact__c);
    //                 conIdSet.add(br.User__c);
    //                 Datetime registrationDate = cr.RegistrationDate__c == null ? cr.CreatedDate : cr.RegistrationDate__c;
    //                 if (br.FirstChannelResponseDate__c  == null || br.LatestChannelResponseDate__c == null) {
    //                     br.FirstChannelResponse__c = br.FirstChannelResponseDate__c  == null ? cr.Channel__c : br.FirstChannelResponse__c;
    //                     br.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c  == null ? registrationDate : br.FirstChannelResponseDate__c;
    //                     //update latest channel record and date
    //                     br.LatestChannelResponse__c = br.LatestChannelResponseDate__c == null ? cr.Channel__c : br.LatestChannelResponse__c;
    //                     br.LatestCampaign__c = br.LatestChannelResponseDate__c == null ? cr.Campaign__c : br.LatestCampaign__c;
    //                     br.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c == null ? registrationDate : br.LatestChannelResponseDate__c;                        
    //                 } else {
    //                     //Update First Channel with the earliest date
    //                     br.FirstChannelResponse__c = br.FirstChannelResponseDate__c >  registrationDate ?  cr.Channel__c : br.FirstChannelResponse__c;
    //                     br.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c >  registrationDate ? registrationDate : br.FirstChannelResponseDate__c;                    
    //                     //Update Latest Channel with the  most recently created
    //                     br.LatestChannelResponse__c = br.LatestChannelResponseDate__c < registrationDate ?  cr.Channel__c : br.LatestChannelResponse__c;
    //                     br.LatestCampaign__c = br.LatestChannelResponseDate__c < registrationDate ?  cr.Campaign__c : br.LatestCampaign__c;
    //                     br.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c < registrationDate ?  registrationDate : br.LatestChannelResponseDate__c;
    //                 }

    //                 if (cr.Classification__c == CommonConstant.CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME && !isRetroRecord) {
    //                     BrandRelationship__c brUpdate = new BrandRelationship__c();
    //                     brUpdate.Id = cr.BrandRelationship__c;
    //                     brUpdate.NewtoBrand__c = true;
    //                     brUpdate.NewtoBrandDate__c = date.valueOf( cr.RegistrationDate__c );
    //                     brToUpdateMap.put(brUpdate.Id, brUpdate);
    //                 }
    //             }
    //             if (oldFirst != br.FirstChannelResponseDate__c || oldLast != br.LatestChannelResponseDate__c)
    //                 brToUpdateList.add(br);   
    //         }
            
    //         if(!brToUpdateMap.isEmpty()){
    //             //Update brList;
    //             Database.DMLOptions dml = new Database.DMLOptions();
    //             dml.DuplicateRuleHeader.allowSave = true;
    //             dml.DuplicateRuleHeader.runAsCurrentUser = true; 
                
    //             List<Database.SaveResult> sr = Database.update(brToUpdateMap.values(), dml);
                
    //             //get all related brand relationship related to contact (primary and not primary)
    //             List<Contact> contactList = [Select Id, FirstChannelResponse__c,FirstChannelResponseDate__c, LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c,
    //                                          (Select Id,FirstChannelResponse__c,FirstChannelResponseDate__c,LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c from MainBrandRelationships__r) ,
    //                                          (Select Id, FirstChannelResponse__c,FirstChannelResponseDate__c,LatestChannelResponseDate__c, LatestChannelResponse__c,LatestCampaign__c from BrandRelationships__r)
    //                                          From Contact Where Id IN: conIdSet AND Type__c =: CommonConstant.CONTACT_ADULT_TYPE];
    //             List<Contact> toUpdateContactList = new List<Contact>();
    //             for(Contact con : contactList) {
    //                 Datetime oldFirst = con.FirstChannelResponseDate__c;
    //                 Datetime oldLast = con.LatestChannelResponseDate__c;
                    
    //                 List<BrandRelationship__c> brList2 = new List<BrandRelationship__c>();
    //                 if(!con.MainBrandRelationships__r.isEmpty()) brList2.addAll(con.MainBrandRelationships__r);
    //                 if(!con.BrandRelationships__r.isEmpty()) brList2.addAll(con.BrandRelationships__r);

    //                 for(BrandRelationship__c br : brList2) {                
    //                     //Update Contact First Channel with the earliest date
    //                     if (con.FirstChannelResponseDate__c  == null) {
    //                         con.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c;
    //                         con.FirstChannelResponse__c = br.FirstChannelResponse__c;
    //                     } else if (con.FirstChannelResponseDate__c >  br.FirstChannelResponseDate__c ) {
    //                         con.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c;
    //                         con.FirstChannelResponse__c = br.FirstChannelResponse__c;
    //                     }
    //                     //Update Contact Latest Channel with the  most recently created
    //                     if (con.LatestChannelResponseDate__c  == null) {
    //                         con.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c;
    //                         con.LatestChannelResponse__c = br.LatestChannelResponse__c;
    //                         con.LatestCampaign__c = br.LatestCampaign__c;
    //                     } else if (con.LatestChannelResponseDate__c < br.LatestChannelResponseDate__c) {
    //                         con.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c;
    //                         con.LatestChannelResponse__c = br.LatestChannelResponse__c;
    //                         con.LatestCampaign__c = br.LatestCampaign__c;
    //                     }
    //                 }
    //                 /*
    //                 for(BrandRelationship__c br : con.BrandRelationships__r) {                
    //                     //Update Contact First Channel with the earliest date
    //                     if (con.FirstChannelResponseDate__c  == null) {
    //                         con.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c;
    //                     } else if (con.FirstChannelResponseDate__c >  br.FirstChannelResponseDate__c ) {
    //                         con.FirstChannelResponseDate__c = br.FirstChannelResponseDate__c;
    //                     }
    //                     //Update Contact Latest Channel with the  most recently created
    //                     if (con.LatestChannelResponseDate__c  == null) {
    //                         con.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c;
    //                         con.LatestChannelResponse__c = br.LatestChannelResponse__c;
    //                         con.LatestCampaign__c = br.LatestCampaign__c;
    //                     } else if (con.LatestChannelResponseDate__c < br.LatestChannelResponseDate__c) {
    //                         con.LatestChannelResponseDate__c = br.LatestChannelResponseDate__c;
    //                         con.LatestChannelResponse__c = br.LatestChannelResponse__c;
    //                         con.LatestCampaign__c = br.LatestCampaign__c;
    //                     }
    //                 }
    //                 ///
    //                 if (oldFirst != con.FirstChannelResponseDate__c || oldLast != con.LatestChannelResponseDate__c)
    //                     toUpdateContactList.add(con);   
    //             }
                
    //             if (toUpdateContactList.size() != 0 ){
    //                 Database.DMLOptions dmlContact = new Database.DMLOptions();
    //                 dmlContact.DuplicateRuleHeader.allowSave = true;
    //                 dmlContact.DuplicateRuleHeader.runAsCurrentUser = true; 
                    
    //                 List<Database.SaveResult> srContact = Database.update(toUpdateContactList, dmlContact);
    //                 //Update contactList;
    //             }            
    //         } */              
    //     }             
    // }
/*
    public void createSampleOrder(List<ChannelResponse__c> newList, Map<Id, SObject> oldMap) {
        List<ChannelResponse__c> crToProcess = new List<ChannelResponse__c>();
        Set<Id> initialValidChannelSet = new Set<Id>();
        
       
        //filter first to reduce number of sql call
        for(ChannelResponse__c cr : newList) {
            if (trigger.isUpdate) {
                ChannelResponse__c oldRec = (ChannelResponse__c)oldMap.get(cr.Id);
                
                /*
                JERICSON
                if(cr.IsSample_Requested__c && !oldRec.IsSample_Requested__c) {
                    if(cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING) {
                        initialValidChannelSet.add(cr.Id);
                    }
                } else if(cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING && oldRec.OrderCreationStatus__c != CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING) {
                    if(cr.IsSample_Requested__c) {
                        initialValidChannelSet.add(cr.Id);
                    }
                }* // comment until here

                if(cr.IsSample_Requested__c
                    && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING
                    && cr.DeliveryAddress__c != null
                    && (cr.IsSample_Requested__c != oldRec.IsSample_Requested__c
                        || cr.OrderCreationStatus__c != oldRec.OrderCreationStatus__c
                        || cr.DeliveryAddress__c != oldRec.DeliveryAddress__c)) {
                    initialValidChannelSet.add(cr.Id);
                }
            } else {
                if (cr.IsSample_Requested__c && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING) {
                    initialValidChannelSet.add(cr.Id);
                }
            }
        }

        if (!initialValidChannelSet.isEmpty()) {
            List<ChannelResponse__c>  initialValidChannelList = [Select 
                                        BrandRelationship__r.PrimaryContact__c, BrandRelationship__r.PrimaryContact__r.Verified__c, BrandRelationship__r.PrimaryContact__r.Market__c, ProductSampleRequested__r.KeyBrand__c,
                                        DeliveryAddress__c, OrderCreationStatus__c , SampleProductCode__c, ProductSampleRequested__c, BrandRelationship__r.User__r.RecordType.DeveloperName, BrandRelationship__r.User__r.AgeinMonths__c,
                                        BrandRelationship__r.User__c, Campaign__c, BrandRelationship__r.User__r.MilkCodeRestriction__c
                                        From ChannelResponse__c Where Id IN: initialValidChannelSet];
            CreateSampleOrder.executeSampleCreation(initialValidChannelList);
        }
        
    }
*/
	
	/*public static void populateContact(List<ChannelResponse__c> crList){
        List<ChannelResponse__c> detailedList = [Select Contact__c, BrandRelationship__r.PrimaryContact__c from ChannelResponse__c where Id IN: crList];
        List<ChannelResponse__c> crToUpdate = new List<ChannelResponse__c>();
        for(ChannelResponse__c cr : detailedList){
            if((Trigger.IsInsert) || (Trigger.IsUpdate && cr.Contact__c != cr.BrandRelationship__r.PrimaryContact__c)){
                cr.Contact__c = cr.BrandRelationship__r.PrimaryContact__c;
                crToUpdate.Add(cr);
            }
        }
        if(!crToUpdate.isEmpty()){
            update crToUpdate;
        }
    }*/
    
    
    // public static void populateRegistrationDate(List<ChannelResponse__c> newList) {
    //     for(ChannelResponse__c crRec : newList) {
    //         if(crRec.RegistrationDate__c == null) {
    //             crRec.RegistrationDate__c = System.now();
    //         }
    //     }
    // }
}