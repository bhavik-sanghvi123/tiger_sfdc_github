/*------------------------------------------------------------
Author:      Jericson Mercado
Description: Change Event class for Case object

History
11/21/2021   malviz     Added updateMCEligibility
03/31/2021   malviz     Moved updateMCEligibility to CaseTriggerHandler 
11/12/2021   malviz     updated updateRelatedBR, added updateCase
-------------------------------------------------------------------------------------------*/

public class CaseEventHandler {

    public static Map<String, AffiliateMetadata__mdt> affiliateMetadataMap = UtilityClass.getAffiliateMetadataMap();
    public static Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
    public static Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback').getRecordTypeId();

    public static void processEvent(List<CaseChangeEvent> events) {

        Set<Id> routingIds = new Set<Id>();
        Set<Id> verifiedIds = new Set<Id>();
        Map<Id, CaseChangeEvent> contactUpdateMap = new Map<Id, CaseChangeEvent>();
        Set<Id> removeInOmnichannel = new Set<Id>();
        Set<Id> feedBackForEscalation = new Set<Id>();
        Set<Id> uncontactableCases = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> vnCaseIds = new Set<Id>(); //TKT-007234
        MaP<Id, CaseChangeEvent> updateBR = new MaP<Id, CaseChangeEvent>();
        MaP<Id, CaseChangeEvent> updateSGDetailsMap = new MaP<Id, CaseChangeEvent>();
        //Set<Id> updateMCEligibilityIds = new Set<Id>();
        Set<Id> setcreateNHCase = new Set<Id>();//added by Monika
    
        for(CaseChangeEvent event: events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;

            // CREATE
            if(header.changeType == 'CREATE') {

                // Record Type  = Call
                if(event.RecordTypeId == callRTId) {

                    // Omni Channel
                    if(event.Campaign__c != null) {
                        routingIds.add(header.recordIds[0]);
                    } 

                    // update contact call dates
                    if(event.Status != 'Cancelled') {
                        contactUpdateMap.put(header.recordIds[0], event);
                    }

                   // update SG Related BR
                    if((event.End_User__c || event.Care_Giver__c || event.FSL_User__c) && event.Market__c == 'SG') {
                        updateBR.put(header.recordIds[0], event);
                    }
                    
                    // update SG Related CR and Contact
                    if(event.CallOutcome__c == 'Invalid' && event.Market__c == 'SG') {
                        updateSGDetailsMap.put(header.recordIds[0], event);
                    }
                    //case created for TW Market
                    if(event.Market__c == CommonConstant.MARKET_TW) {
                        setcreateNHCase.add(header.recordIds[0]);
                    } 

                    // update case
                    if(event.Market__c == 'SG') {
                        caseIdSet.add(header.recordIds[0]);
                    }
                }

                // Record Type = Feedback
                if(event.RecordTypeId == feedbackRTId
                    && event.Market__c == 'IN'
                    && event.Status == 'Escalated'
                    && event.EscalatedTo__c != null) {
                    feedBackForEscalation.add(header.recordIds[0]);
                }
                
                /*// Update MC Eligibility Fields
                if(event.ContactId != null){
                    updateMCEligibilityIds.add(header.recordIds[0]);
                }*/

            }

            // UPDATE
            else if(header.changeType == 'UPDATE') {

                if(header.changedFields.contains('CallOutcome__c')
                    || header.changedFields.contains('Status')) {
                    contactUpdateMap.put(header.recordIds[0], event);
                }

                 if(header.changedFields.contains('CallOutcome__c')
                    && event.CallOutcome__c == 'Invalid') {
                    updateSGDetailsMap.put(header.recordIds[0], event);
                }

                if(header.changedFields.contains('CallAccepted__c')
                    && event.CallAccepted__c) {
                    removeInOmnichannel.add(header.recordIds[0]);
                }

                // TKT-006389, SG
                if(header.changedFields.contains('Status')
                    && event.Status == 'Completed') {
                    updateBR.put(header.recordIds[0], event);
                }

                // Record Type = Feedback
                if(event.RecordTypeId == feedbackRTId
                    && event.Market__c == 'IN'
                    && event.Status == 'Escalated'
                    && header.changedFields.contains('Status')
                    && event.EscalatedTo__c != null) {
                    feedBackForEscalation.add(header.recordIds[0]);
                }

                if(event.ReminderStatus__c == 'Pending - Uncontactable'
                    && event.Market__c != 'TW'
                    && header.changedFields.contains('ReminderStatus__c') ){
                    uncontactableCases.add(header.recordIds[0]);
                }

                // update BR if current brand has been changed, not for VN
                // update BR if care giver/end user is updated, only for SG
                if(header.changedFields.contains('CurrentBrandUsed__c')
                    || header.changedFields.contains('PreviousBrandUsed__c')
                    || header.changedFields.contains('BrandSwitchReason__c')
                    || header.changedFields.contains('SKU__c')
                    || header.changedFields.contains('Care_Giver__c')
                    || header.changedFields.contains('End_User__c')
                    || header.changedFields.contains('FSL_User__c')){
                    updateBR.put(header.recordIds[0], event);
                }
                
                //TKT-007234
                if(header.changedFields.contains('Status')
                   && event.Status == 'Completed') {
                    vnCaseIds.add(header.recordIds[0]);
                }
            }
        }

        if(!routingIds.isEmpty()) omniChannelRouting(routingIds);
        if(!contactUpdateMap.isEmpty()) updateContactCallDates(contactUpdateMap);
        if(!removeInOmnichannel.isEmpty()) CaseTriggerHander_AdminMode.removeInOmniChannel(removeInOmniChannel);
        if(!feedBackForEscalation.isEmpty()) feedbackEscalation(feedBackForEscalation);
        if(!uncontactableCases.isEmpty()) checkUncontactable(uncontactableCases);
        if(!updateBR.isEmpty()) updateRelatedBR(updateBR);
        if(!updateSGDetailsMap.isEmpty()){
            updateSGContact(updateSGDetailsMap);
            updateRelatedCR(updateSGDetailsMap);
        }
        //if(!updateMCEligibilityIds.isEmpty()) updateMCEligibility(updateMCEligibilityIds);
        if(!setcreateNHCase.isEmpty()) createNHRecords(setcreateNHCase); //added by Monika
        if(!caseIdSet.isEmpty()) updateCase(caseIdSet);
        if(!vnCaseIds.isEmpty()) updateCRDischargeDate(vnCaseIds); //TKT-007234
        
    }

    // ONLY FOR SG
    public static void updateRelatedCR(MaP<Id, CaseChangeEvent> caseEventMap) {
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, RelatedChannelResponse__r.Invalid__c
                                                     FROM Case
                                                    WHERE Id IN: caseEventMap.keySet()
                                                      AND Market__c = 'SG'
                                                      AND CallOutcome__c = 'Invalid'
                                                      AND RelatedChannelResponse__c != null]);
        
        Map<Id, ChannelResponse__c> crMap = new Map<Id, ChannelResponse__c>();
        
        for(Case c: caseMap.values()){
            
             ChannelResponse__c cr = crMap.containsKey(c.RelatedChannelResponse__c) ?
                                      crMap.get(c.RelatedChannelResponse__c) :
                                      new ChannelResponse__c(
                                          Id = c.RelatedChannelResponse__c,
                                          Invalid__c = c.RelatedChannelResponse__r.Invalid__c
                                          
                                      );
            cr.Invalid__c = true;
            crMap.put(cr.Id,cr);

        }
        if(!crMap.isEmpty()) UtilityClass.updateList(crMap.values());
    }

    // NOT APPLICABLE TO VIETNAM
    public static void updateRelatedBR(MaP<Id, CaseChangeEvent> caseEventMap) {
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT CurrentBrandUsed__c,
                                                          CurrentBrandUsed__r.CompetitorProduct__c,
                                                          PreviousBrandUsed__c,
                                                          BrandSwitchReason__c,
                                                          SKU__c,
                                                          End_user__c,
                                                          Care_Giver__c,
                                                          FSL_User__c,
                                                          Status,
                                                          Sample_Influence__c,
                                                          KeyMessageDriverforTrial__c,
                                                          Reason_for_HCP_s_recommendation__c,
                                                          What_HCP_Shared__c,
                                                          Sample_provided_in_Clinic__c,
                                                          RelatedBrandRelationship__c,
                                                          RelatedBrandRelationship__r.Type__c,
                                                          RelatedBrandRelationship__r.Status__c,
                                                          RelatedBrandRelationship__r.CurrentBrand__c,
                                                          RelatedBrandRelationship__r.PreviousBrand__c,
                                                          RelatedBrandRelationship__r.BrandSwitchReason__c,
                                                          RelatedBrandRelationship__r.SKU__c,
                                                          RelatedBrandRelationship__r.CareGiver__c,
                                                          RelatedBrandRelationship__r.EndUser__c,
                                                          RelatedBrandRelationship__r.FSL_User__c,
                                                          RelatedBrandRelationship__r.Sample_Influence__c,
                                                          RelatedBrandRelationship__r.KeyMessageDriverforTrial__c,
                                                          RelatedBrandRelationship__r.Reason_for_HCP_s_recommendation__c,
                                                          RelatedBrandRelationship__r.What_HCP_Shared__c,
                                                          RelatedBrandRelationship__r.Sample_provided_in_Clinic__c,
                                                          Market__c
                                                     FROM Case
                                                    WHERE Id IN: caseEventMap.keySet()
                                                      AND Market__c != 'VN'
                                                      AND RelatedBrandRelationship__c != null]);
        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>();

        for(Case c: caseMap.values()){
            CaseChangeEvent event = caseEventMap.get(c.Id);
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            Boolean forUpdate = false;

            BrandRelationship__c br = brMap.containsKey(c.RelatedBrandRelationship__c) ?
                                      brMap.get(c.RelatedBrandRelationship__c) :
                                      new BrandRelationship__c(
                                          Id = c.RelatedBrandRelationship__c,
                                          Type__c = c.RelatedBrandRelationship__r.Type__c,
                                          Status__c = c.RelatedBrandRelationship__r.Status__c,
                                          CurrentBrand__c = c.RelatedBrandRelationship__r.CurrentBrand__c,
                                          PreviousBrand__c = c.RelatedBrandRelationship__r.PreviousBrand__c,
                                          BrandSwitchReason__c = c.RelatedBrandRelationship__r.BrandSwitchReason__c,
                                          SKU__c = c.RelatedBrandRelationship__r.SKU__c,
                                          CareGiver__c = c.RelatedBrandRelationship__r.CareGiver__c,
                                          EndUser__c = c.RelatedBrandRelationship__r.EndUser__c,
                                          FSL_User__c = c.RelatedBrandRelationship__r.FSL_User__c,
                                          What_HCP_Shared__c = c.RelatedBrandRelationship__r.What_HCP_Shared__c,
                                          Reason_for_HCP_s_recommendation__c = c.RelatedBrandRelationship__r.Reason_for_HCP_s_recommendation__c,
                                          Sample_Influence__c = c.RelatedBrandRelationship__r.Sample_Influence__c,
                                          KeyMessageDriverforTrial__c = c.RelatedBrandRelationship__r.KeyMessageDriverforTrial__c,
                                          Sample_provided_in_Clinic__c = c.RelatedBrandRelationship__r.Sample_provided_in_Clinic__c
                                      );

            //check if current brand is updated
            if(header.changedFields.contains('CurrentBrandUsed__c')
                && c.CurrentBrandUsed__c != br.CurrentBrand__c){
                br.CurrentBrand__c = c.CurrentBrandUsed__c;
                forUpdate = true;

                // TKT-1970 change status to lapsed if current brand is a competitor product
                if(c.CurrentBrandUsed__c != null
                    && c.CurrentBrandUsed__r.CompetitorProduct__c
                    && br.Type__c == 'User') {
                    br.Status__c = 'Lapsed';
                }
            }

            //check if previous brand is updated
            if(header.changedFields.contains('PreviousBrandUsed__c')
                && c.PreviousBrandUsed__c != br.PreviousBrand__c){
                br.PreviousBrand__c = c.PreviousBrandUsed__c;
                forUpdate = true;
            }

            //check if brand switch reason is updated
            if(header.changedFields.contains('BrandSwitchReason__c')
                && c.BrandSwitchReason__c != br.BrandSwitchReason__c){
                br.BrandSwitchReason__c = c.BrandSwitchReason__c;
                forUpdate = true;
            }

            //check if SKU is updated
            if(header.changedFields.contains('SKU__c')
                && c.SKU__c != br.SKU__c){
                br.SKU__c = c.SKU__c;
                forUpdate = true;
            }

            //check if Caregiver is updated, only for SG
            if(header.changedFields.contains('Care_Giver__c')
              && c.Market__c == 'SG'){
                br.CareGiver__c = c.Care_Giver__c;
                forUpdate = true;
            }
            
            //check if End User is updated, only for SG
            if(header.changedFields.contains('End_User__c')
              && c.Market__c == 'SG'){
                br.EndUser__c = c.End_User__c;
                forUpdate = true;
            }
            
            //check if FSL User is updated, only for SG
            if(header.changedFields.contains('FSL_User__c')
              && c.Market__c == 'SG'){
                br.FSL_User__c = c.FSL_User__c;
                forUpdate = true;
            }

            //TKT-006389 check if Status is Completed, only for SG
            //Store Call 1 details on BR technical fields
            if(header.changedFields.contains('Status')
              && c.Market__c == 'SG'
              && c.Status == 'Completed'){
                
                if(br.Sample_Influence__c == null){
                    br.Sample_Influence__c = c.Sample_Influence__c;
                    forUpdate = true;
                }

                if(br.KeyMessageDriverforTrial__c == null){
                    br.KeyMessageDriverforTrial__c = c.KeyMessageDriverforTrial__c;
                    forUpdate = true;
                }

                if(br.Reason_for_HCP_s_recommendation__c == null){
                    br.Reason_for_HCP_s_recommendation__c = c.Reason_for_HCP_s_recommendation__c;
                    forUpdate = true;
                }

                if(br.What_HCP_Shared__c == null){
                    br.What_HCP_Shared__c = c.What_HCP_Shared__c;
                    forUpdate = true;
                }
                
                if(br.Sample_provided_in_Clinic__c == null){
                    br.Sample_provided_in_Clinic__c = c.Sample_provided_in_Clinic__c;
                    forUpdate = true;
                } 
            }

            if(header.changeType == 'CREATE' && c.Market__c == 'SG') {
                If(c.Care_Giver__c){
                    br.CareGiver__c = c.Care_Giver__c;
                    forUpdate = true;
                }
                
                If(c.End_User__c){
                    br.EndUser__c = c.End_User__c;
                    forUpdate = true;
                }
                
                if(c.FSL_User__c){
                    br.FSL_User__c = c.FSL_User__c;
                    forUpdate = true;
                }
            }

            if(forUpdate) brMap.put(br.Id, br);
        }

        if(!brMap.isEmpty()) UtilityClass.updateList(brMap.values());
    }

    // sends uncontactable notice, reminderstatus field is mainly used for Email-to-Case only
    public static void checkUncontactable(Set<Id> caseIds) {
        Map<String, AffiliateMetadata__mdt>  countryMap = new Map<String, AffiliateMetadata__mdt>();
        Map<String, String> countryEmailMap = new Map<String, String>();
        for(AffiliateMetadata__mdt country: affiliateMetadataMap.values()) {
            countryMap.put(country.MasterLabel, country);

            if(country.EmailToCaseOrgWideEmailAddress__c != ''){
                countryEmailMap.put(country.EmailToCaseOrgWideEmailAddress__c, country.MasterLabel);
            }
        }

        Map<String, OrgWideEmailAddress> orgWideMap = new Map<String, OrgWideEmailAddress>();
        for(OrgWideEmailAddress owea :[SELECT Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: countryEmailMap.keySet()] ) {
            orgWideMap.put(countryEmailMap.get(owea.Address), owea);
        }

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate tempTemplate = [SELECT Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'InquiryFeedbackUncontactable_HTML'];

        for(Case c: [SELECT SuppliedEmail, Market__c, Subject, Description,
                            (SELECT HtmlBody, Subject FROM EmailMessages)
                       FROM Case
                      WHERE Id IN: caseIds]) {

            // check if there is an org wide address for the market
                String sub = Test.isRunningTest() ? 'test subject' : c.EmailMessages.isEmpty() ? c.Subject : c.EmailMessages[0].Subject;
                String bod = Test.isRunningTest() ? 'test subject' : c.EmailMessages.isEmpty() ? c.Description : tempTemplate.HtmlValue  + '\n\n' + c.EmailMessages[0].HtmlBody;

                // add email
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { c.SuppliedEmail };
                message.setWhatId(c.Id);
                message.setSubject(sub);
                message.setHtmlBody(bod);

                // set default
                if(orgWideMap.containsKey(c.Market__c))
                    message.setOrgWideEmailAddressId(orgWideMap.get(c.Market__c).Id);

                message.saveAsActivity = true;
                messages.add(message);
        }

        if(!messages.isEmpty()) Messaging.sendEmail(messages);
    }
    
    // special email escalation for India, pre population of the escalated to is done in the trigger
    public static void feedbackEscalation(Set<Id> caseIds) {

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Map<String, OrgWideEmailAddress> orgWideMap = new Map<String, OrgWideEmailAddress>();

        Contact dummyContact = new Contact();
        try{
            dummyContact = [SELECT Id FROM Contact WHERE LastName =: 'Dummy Contact'];
        } catch (exception e) {
            dummyContact.LastName = 'Dummy Contact';
            insert dummyContact;
        }

        Map<String, AffiliateMetadata__mdt>  countryMap = new Map<String, AffiliateMetadata__mdt>();
        Map<String, String> countryEmailMap = new Map<String, String>();

        for(AffiliateMetadata__mdt country: affiliateMetadataMap.values()) {
            countryMap.put(country.MasterLabel, country);

            if(country.FeedbackEscalationOrgWideEmail__c != ''){
                countryEmailMap.put(country.FeedbackEscalationOrgWideEmail__c, country.MasterLabel);
            }
        }

        for(OrgWideEmailAddress owea :[SELECT Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: countryEmailMap.keySet()] ) {
            orgWideMap.put(countryEmailMap.get(owea.Address), owea);
        }

        EmailTemplate escalationEmail = [SELECT DeveloperName, Body, Subject FROM EmailTemplate WHERE DeveloperName =: CommonConstant.EMAILTEMPLATE_CASE_ESCALATION];

        for(Case c: [SELECT Market__c,
                            EscalatedTo__r.MainEscalationPointEmail__c,
                            EscalatedTo__r.MainEscalationPointEmail2__c,
                            EscalatedTo__r.AdditionalEscalationPointEmail1__c,
                            EscalatedTo__r.AdditionalEscalationPointEmail2__c,
                            EscalatedTo__r.AdditionalEscalationPointEmail3__c,
                            EscalatedTo__r.AdditionalEscalationPointEmail4__c,
                            EscalatedTo__r.AdditionalEscalationPointEmail5__c,
                            EscalatedTo__r.AdditionalEscalationPointEmail6__c
                       FROM Case
                      WHERE ID IN: caseIds
                        AND EscalatedTo__r.Product__c != null
                        AND Market__c = 'IN']) {

            //set all emails addresses to send to
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            if(c.EscalatedTo__r.MainEscalationPointEmail__c != null) toAddresses.add(c.EscalatedTo__r.MainEscalationPointEmail__c);
            if(c.EscalatedTo__r.MainEscalationPointEmail2__c != null) toAddresses.add(c.EscalatedTo__r.MainEscalationPointEmail2__c);
            if(c.EscalatedTo__r.AdditionalEscalationPointEmail1__c != null) ccAddresses.add(c.EscalatedTo__r.AdditionalEscalationPointEmail1__c);
            if(c.EscalatedTo__r.AdditionalEscalationPointEmail2__c != null) ccAddresses.add(c.EscalatedTo__r.AdditionalEscalationPointEmail2__c);
            if(c.EscalatedTo__r.AdditionalEscalationPointEmail3__c != null) ccAddresses.add(c.EscalatedTo__r.AdditionalEscalationPointEmail3__c);
            if(c.EscalatedTo__r.AdditionalEscalationPointEmail4__c != null) ccAddresses.add(c.EscalatedTo__r.AdditionalEscalationPointEmail4__c);
            if(c.EscalatedTo__r.AdditionalEscalationPointEmail5__c != null) ccAddresses.add(c.EscalatedTo__r.AdditionalEscalationPointEmail5__c);
            if(c.EscalatedTo__r.AdditionalEscalationPointEmail6__c != null) ccAddresses.add(c.EscalatedTo__r.AdditionalEscalationPointEmail6__c);

            // add email
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(toAddresses);
            message.setccAddresses(ccAddresses);
            message.setTargetObjectId(dummyContact.Id);
            message.setWhatId(c.Id);
            message.setTemplateId(escalationEmail.Id);
            message.setTreatTargetObjectAsRecipient(false);
            message.saveAsActivity = true;

            // set default
            if(orgWideMap.containsKey(c.Market__c))
                message.setOrgWideEmailAddressId(orgWideMap.get(c.Market__c).Id);

            messages.add(message);
        }

        if(!messages.isEmpty()) Messaging.sendEmail(messages);
    }

    // populate first / last call date if call is not cancelled
    // update contact.LatestOpenCallDate__c if call outcome is change to successfull/unsuccessful (last modified date)
    // update contact.Latest_Contacted_Date__c if call outcome is successfull/unsuccessful (call completed date)
    public static void updateContactCallDates(Map<Id, CaseChangeEvent> caseMap) {
        Set<Id> ContactIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();

        for(Contact con: [SELECT FirstCallDate__c, FirstCall__c, LastCallDate__c, LatestCall__c, LatestOpenCallDate__c,Latest_Contacted_Date__c,
                                          (SELECT Status, CreatedDate, LastModifiedDate,CallCompletedDate__c,CallOutcome__c 
                                             FROM Cases
                                            WHERE Status != 'Cancelled'
                                              AND RecordType.Name = 'Call'
                                         ORDER BY CreatedDate)
                                    FROM Contact
                                   WHERE Id IN (SELECT ContactId FROM Case WHERE ID IN: caseMap.keySet() )] ) {
            Boolean forUpdate = false;

            // reset if only call got cancelled
            if(con.Cases.isEmpty()
                && con.FirstCallDate__c != null) {
                con.FirstCall__c = null;
                con.FirstCallDate__c = null;
                con.LatestCall__c = null;
                con.LastCallDate__c = null;
                con.LatestOpenCallDate__c = null;
                con.Latest_Contacted_Date__c  = null;
                forUpdate = true;
            } else {
                for(Case c: con.Cases) {

                    // first call
                    if(con.FirstCallDate__c == null
                        || c.createdDate < con.FirstCallDate__c) {
                        con.FirstCall__c = c.Id;
                        con.FirstCallDate__c = c.CreatedDate;

                        forUpdate = true;
                    }

                    // last call
                    if(con.LastCallDate__c == null
                        || c.createdDate > con.LastCallDate__c) {
                        con.LatestCall__c = c.Id;
                        con.LastCallDate__c = c.CreatedDate;

                        forUpdate = true;
                    }

                    // update the lastest call date
                    if(caseMap.containsKey(c.Id)) {
                        CaseChangeEvent event = caseMap.get(c.Id);
                        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                        if(header.changeType == 'UPDATE'
                            && (event.CallOutcome__c == 'Successful' 
                                || event.CallOutcome__c == 'Unsuccessful')
                            && (con.LatestOpenCallDate__c == null
                                || con.LatestOpenCallDate__c < c.LastModifiedDate)
                            ) {

                            con.LatestOpenCallDate__c = c.LastModifiedDate;
                            forUpdate = true;
                        }
                    }

                    // TKT-002254 - latest contacted date
                    if((con.Latest_Contacted_Date__c == null || c.CallCompletedDate__c > con.Latest_Contacted_Date__c)
                        && (c.CallOutcome__c == 'Successful' || c.CallOutcome__c == 'Unsuccessful' )) {
                        con.Latest_Contacted_Date__c = c.CallCompletedDate__c;

                        forUpdate = true;
                    }
                }
            }

            if(forUpdate) conList.add(con);
        }

        if(!conList.isEmpty()) UtilityClass.updateList(conList);
    }

    //update SG contact when call outcome is Invalid
    public static void updateSGContact(Map<Id, CaseChangeEvent> caseMap) {
        List<Contact> conList = new List<Contact>();
      
        for(Contact con: [SELECT Verified__c,MasterOptOut__c
                                    FROM Contact
                                   WHERE Id IN (SELECT ContactId FROM Case WHERE ID IN: caseMap.keySet()) AND Market__c = 'SG' ] ) {                                      
                                       
                con.Verified__c = false;
                con.MasterOptOut__c = true;
                
                conList.add(con);  
        }
        
        if(!conList.isEmpty()) UtilityClass.updateList(conList);
    }

    public static void updateCase(Set<Id> caseIds) {
        List<Case> caseList = new List<Case>();
       
        for(Case c: [SELECT Id,Subject,Market__c,RelatedBrandRelationship__c, 
                    RelatedBrandRelationship__r.Sample_Influence__c,  RelatedBrandRelationship__r.KeyMessageDriverforTrial__c, 
                    RelatedBrandRelationship__r.What_HCP_Shared__c,  RelatedBrandRelationship__r.Reason_for_HCP_s_recommendation__c, 
                    RelatedBrandRelationship__r.Sample_provided_in_Clinic__c, 
                    Sample_Influence__c, KeyMessageDriverforTrial__c, Reason_for_HCP_s_recommendation__c, What_HCP_Shared__c,Sample_provided_in_Clinic__c
                    FROM Case WHERE Id IN: caseIds]) {        

            Boolean forUpdate = false;

            //update SG Call 2 when BR has Call 1 relevant details
            if(c.Market__c == CommonConstant.MARKET_SG && c.Subject.containsIgnoreCase(Label.SG_Call_2)){
                if(c.RelatedBrandRelationship__r.Sample_Influence__c != null){
                    c.Sample_Influence__c = c.RelatedBrandRelationship__r.Sample_Influence__c;
                    forUpdate = true;
                }

                if(c.RelatedBrandRelationship__r.KeyMessageDriverforTrial__c != null){
                    c.KeyMessageDriverforTrial__c = c.RelatedBrandRelationship__r.KeyMessageDriverforTrial__c;
                    forUpdate = true;
                }

                if(c.RelatedBrandRelationship__r.Reason_for_HCP_s_recommendation__c != null){
                    c.Reason_for_HCP_s_recommendation__c = c.RelatedBrandRelationship__r.Reason_for_HCP_s_recommendation__c;
                    forUpdate = true;
                }
                
                if(c.RelatedBrandRelationship__r.What_HCP_Shared__c != null){
                    c.What_HCP_Shared__c = c.RelatedBrandRelationship__r.What_HCP_Shared__c;
                    forUpdate = true;
                }

                if(c.RelatedBrandRelationship__r.Sample_provided_in_Clinic__c != null){
                    c.Sample_provided_in_Clinic__c = c.RelatedBrandRelationship__r.Sample_provided_in_Clinic__c;
                    forUpdate = true;
                }
            }

            if(forUpdate) caseList.add(c);
        }
        if(!caseList.isEmpty()) UtilityClass.updateList(caseList);
    }
    
    /*
    // Update MC Eligibility fields
    public static void updateMCEligibility(Set<Id> caseIds) {
        List<Case> casesToUpdate = new List<Case>();
        Map<Id, Contact> contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                                           MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                                           MC_Sync_Eligibility_VN__c
                                                           FROM Contact 
                                                           WHERE Id IN (SELECT ContactId FROM Case WHERE Id IN: caseIds)]);
        
        for(Case c: [SELECT Id,ContactId,Contact.Phone,Contact.Email,Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,
                     MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,MC_Sync_Eligibility_VN__c
                     FROM Case
                     WHERE Id IN: caseIds] ) {  
            
            if(c.Contact.Phone != null || c.Contact.Email != null) {              
                String Market = contactMap.get(c.ContactId).Market__c;
                Boolean forUpdate = true; 
                            
                if(Market == CommonConstant.MARKET_ANZ){
                    c.MC_Sync_Eligibility_ANZ__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_ANZ__c;
                }else if(Market == CommonConstant.MARKET_ID){
                    c.MC_Sync_Eligibility_ID__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_ID__c;
                }else if(Market == CommonConstant.MARKET_IN){
                    c.MC_Sync_Eligibility_IN__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_IN__c;
                }else if(Market == CommonConstant.MARKET_MY){
                    c.MC_Sync_Eligibility_MY__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_MY__c;
                }else if(Market == CommonConstant.MARKET_PH){
                    c.MC_Sync_Eligibility_PH__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_PH__c;
                }else if(Market == CommonConstant.MARKET_SG){
                    c.MC_Sync_Eligibility_SG__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_SG__c;
                }else if(Market == CommonConstant.MARKET_TH){
                    c.MC_Sync_Eligibility_TH__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_TH__c;
                }else if(Market == CommonConstant.MARKET_VN){
                    c.MC_Sync_Eligibility_VN__c = contactMap.get(c.ContactId).MC_Sync_Eligibility_VN__c;
                }else{
                    forUpdate = false;
                }
                
                if(forUpdate) casesToUpdate.add(c);
            }
        }
        
        if(!casesToUpdate.isEmpty()) UtilityClass.updateList(casesToUpdate);
    }*/

    // route to omni channel
    public static void omniChannelRouting (Set<Id> caseIds) {
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Market__c, CreatedById,AutoAssignCalls__c
                                                     FROM Case
                                                    WHERE Id IN: caseIds]);
        //query abbott administrator user
        User usr = [Select Id from User where Username='admin@tiger.deloitte.com.prod' LIMIT 1];
        
        List<Id> casesForRouting = new List<Id>();
        for(Case c: caseMap.values()) {
            if(c.AutoAssignCalls__c
                && affiliateMetadataMap.get(c.Market__c).RouteviaOmniChannel__c && 
                (c.Market__c != CommonConstant.Market_TW  || (c.Market__c == CommonConstant.Market_TW && c.CreatedById != usr.Id))){ 
                casesForRouting.add(c.Id);
           }
        }

        if(!casesForRouting.isEmpty()) SkillsBasedRouting.routeUsingSkills(casesForRouting);
    }
    // createNHRecord whenever the case (call recordtype) created for TW Market
    public static void createNHRecords(Set<Id> caseIds) {
        List<Medical_Diagnosis__c> createNHRecordsList = new List<Medical_Diagnosis__c>();
        Medical_Diagnosis__c recNH ;
        List<Case> caseObj =[SELECT Id,CallRegarding__r.Id,CallRegarding__c,ContactId from Case where ID IN : caseIds];
        For(Case cs:caseObj){
            recNH = new  Medical_Diagnosis__c();
            if(cs.CallRegarding__c != null){
                recNH.Contact__c  = cs.CallRegarding__r.Id; // child contact
            }else{
                recNH.Contact__c  = cs.ContactId;//adult contact
            }
            recNH.Related_Case__c  = cs.Id;
            recNH.CreatedforIntegration__c = true ;
            createNHRecordsList.add(recNH);
        }
        if(!createNHRecordsList.isEmpty()) UtilityClass.insertList(createNHRecordsList);
    }
    
    // TKT-007234
    public static void updateCRDischargeDate(Set<Id> caseIds){
        Map<Id, ChannelResponse__c> channelResponseMap = new Map<Id, ChannelResponse__c>();
        
        for(Case caseRec : [SELECT Id, Status, Discharge_Date__c, RelatedChannelResponse__c, Market__c 
                            FROM Case 
                            WHERE ID IN: caseIds AND RelatedChannelResponse__c != null AND Discharge_Date__c != null AND Market__c = 'VN' AND Status = 'Completed']){
            if(!channelResponseMap.keySet().contains(caseRec.RelatedChannelResponse__c)){
                ChannelResponse__c crRec = new ChannelResponse__c(Id = caseRec.RelatedChannelResponse__c, Discharge_Date__c = caseRec.Discharge_Date__c);
                channelResponseMap.put(crRec.Id, crRec);    
            }
        }

        if(!channelResponseMap.values().isEmpty()) UtilityClass.updateList(channelResponseMap.values());
    }
    
}