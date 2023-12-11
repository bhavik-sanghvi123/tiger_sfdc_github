/**
* @author        Marlon Ocillos
* @date          2.20.2019
* @description   Class primarily responsible in handling trigger logic for Case
* @revision(s)
3.27.2019 - RAustral - Added checkChangeOwnership
6.11.2019 - VMirandilla - Updated updateCallCompletedDate to clear out Successful/Unsuccessful Reason depending on Call Outcome value.
7.30.2019 - mocillos - Added populateRelatedBRandCR
8.07.2019 - malviz - Added updateNextAttemptDueDate
8.27.2019 - vmirandilla - Added populateCampaign and getChannelResponseDetails to auto-populate Call's Campaign Based on Related Channel Response value
9.06.2019 - malviz - updated populateCampaign to allow users manually enter related campaign when related cr is blank
10.02.2019 - raustral - add populateLatestCallDate
10.25.2019 - jmercado - updated populateCampaign to pre populate previous current brand and switch reason
03.31.2019 - vmirandilla - populate First Call Attempt Date
05.11.2020 - jmercado - trigger enhancement | make all record be filtered outside each methods
05.11.2020 - jmercado - trigger enhancement | moved Skill-based Process builders functionality to trigger | omniChannelRouting method
05.22.2020 - jmercado - move all DMLs to related records to Change Event (after insert, after update) | moved all commented methods to bottom
06.22.2020 - malviz - updated populateRelatedBRandCR to add campaign brand for matching
07.20.2020 - malviz - bypass delete when To be Archived is true
03.30.2021 - malviz - added updateMCEligibility
07.19.2021 - scordova - Added a condition to exclude the TW Market in populateCampaign and populateRelatedBRandCR functions
07/26/2021 - malviz - TKT-004699 Updated checkChangeOwnership
08/31/2021 - mparihar - removed populate related campaign logic from Case for Taiwan Market(populating it from Marketing cloud)
09/23/2021 - malviz - comment out updateMCEligibility
11.26.2021 - alfrancisco - added new logic when CR is blank and different Campaign/BR brand populate related cr with BR's CR
12/16/2021 - platoja - [TKT-006678] Added logic for current and previous number of scoop in calls for Ensure/Glucerna Campaign BrandProduct(SG Market) - can be found in populateFieldsFromContact() method
01/05/2022 - navalencia - [TKT-006647] added ValidateCallOutcome method for call outcome validation
04.01.2022 - hazng - [TKT-007234] added logic inside AfterUpdate to update Discharge Date on Channel Response with value of Discharge Date from Case when Case is Completed
*/
public class CaseTriggerHandler implements ITriggerHandler {
    public static Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
    public static Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
    public static Map<String, AffiliateMetadata__mdt> affiliateMetadataMap = UtilityClass.getAffiliateMetadataMap();
    
    public void BeforeInsert(List<SObject> newList) { 
        
        // email-to-case
        List<Case> checkEmailToCaseList = new List<Case>();
        Set<String> emailList = new Set<String>();
        
        // populateRelatedBRandCR
        List<Case> populateRelatedBRandCRList = new List<Case>();
        Set<Id> campaignIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        // populateBrandUsed 
        List<Case> populateBrandUsedList = new List<Case>();
        Set<Id> brIdSet = new Set<Id>();
        
        // populateFieldsFromContact
        // updateMCEligibility
        List<Case> populateFieldsFromContactList = new List<Case>();
        Set<Id> contactIds2 = new Set<Id>();
        
        // updateCallCompletedDate
        List<Case> updateCallCompletedDateList = new List<Case>();
        
        // feedbackEscalation
        List<Case> feedbackEscalationList = new List<Case>();
        
        // collect Case with no contact attached for India
        List<String> MobileNum = new List<String>();
        Map<String,Id> MobileContactIdmap = new Map<String,Id>();
        
        // collect Case with no contact attached for Indonesia
        List<String> MobileNumIndo = new List<String>();
        Map<String,Id> MobileContactIdmapIndo = new Map<String,Id>();
        
        //Collect case with blank CR
        List<Case> populateRelatedCRList = new List<Case>();
        Set<Id> crBRIdSet = new Set<Id>();
        
        // prepopulate market
        Set<Id> accountIds = new Set<Id>();
        for(Case c: (List<Case>) newList)
            accountIds.add(c.AccountId);
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Market__c FROM Account WHERE Id IN: accountIds]);
        
        for(Case c: (List<Case>) newList){
            
            // pre populate market
            if(c.AccountId != null)
                c.Market__c = accountMap.get(c.AccountId).Market__c;
            
            /**** MOVED FROM WORKFLOW ***********/
            c.Description_List_View__c = c.Description;
            
            c.ResolvedUponOpening__c = c.Status == 'Closed-Resolved';
            /**** MOVED FROM WORKFLOW ***********/
            
            if(c.ContactId != null) {
                contactIds2.add(c.ContactId);
                populateFieldsFromContactList.add(c);
            }
            
            // email-to-case | // assumption is that email to case will be assigned to queues
            if(c.Origin == CommonConstant.CASE_ORIGIN_EMAIL
               && String.isNotBlank(c.SuppliedEmail)){
                   c.Market__c = c.CaseOwnerReadOnly__c.split(' - ')[1];
                   emailList.add(c.SuppliedEmail);
                   checkEmailToCaseList.add(c);
               }
            
            // RECORDTYPE = CALL
            if(c.RecordTypeId == callRTId) {
                
                // populateRelatedBRandCR
                contactIds.add(c.ContactId);
                campaignIds.add(c.Campaign__c);
                populateRelatedBRandCRList.add(c);
                
                // populatpopulateRelatedBRandCRListeBrandUsed
                if(c.ConvertedBR__c != null) {
                    brIdSet.add(c.ConvertedBR__c);
                    populateBrandUsedList.add(c);
                }
                if(c.RelatedBrandRelationship__c != null && c.RelatedChannelResponse__c == null){
                   populateRelatedCRList.add(c); 
                   crBRIdSet.add(c.RelatedBrandRelationship__c);
                } 
                // updateCallCompletedDate
                updateCallCompletedDateList.add(c);
            }
            
            // RECORDTYPE = FEEDBACK
            if(c.RecordTypeId == feedbackRTId) {
                feedbackEscalationList.add(c);
            }
            
            //check if contact is tagged or not For India
            if(c.ContactId == null && c.Origin == Label.WHATSAPP_ORIGIN && c.Market_MessageBird__c == 'IN'){
                MobileNum.add('+' + c.ContactPhone__c); 
            }
            
            //check if contact is tagged or not For Indonesia
            if(c.ContactId == null && c.Origin == Label.WHATSAPP_ORIGIN && c.Market_MessageBird__c == 'ID'){
                MobileNumIndo.add('+' + c.ContactPhone__c); 
            }

            if(c.Survey_Link__c != null){
                c.Is_Survey_Link_Populated__c = true;
            }

            //added by narence (for SG only)

            if(c.Market__C == CommonConstant.MARKET_SG){
                if(c.CallOutcome__c == 'Successful' || c.CallOutcome__c == 'Unsuccessful'){
                    ValidateCallOutcome(c);
                }
            }
        }
        
        if(!updateCallCompletedDateList.isEmpty()) updateCallCompletedDate(updateCallCompletedDateList, null);
        if(!populateRelatedBRandCRList.isEmpty()) populateRelatedBRandCR(populateRelatedBRandCRList, contactIds, campaignIds);
        if(!newList.isEmpty()) updateNextAttemptDueDate(newList, null);
        //populateCampaign(newList, null);
        if(!populateBrandUsedList.isEmpty()) populateBrandUsed(populateBrandUsedList, brIdSet);
        if(!populateFieldsFromContactList.isEmpty()) populateFieldsFromContact(populateFieldsFromContactList, contactIds2);
        if(!checkEmailToCaseList.isEmpty()) checkEmailToCase(checkEmailToCaseList, emailList);
        if(!feedbackEscalationList.isEmpty()) feedbackEscalation(feedbackEscalationList, null);
        if(!populateRelatedCRList.isEmpty()) populateRelatedCR(populateRelatedCRList, crBRIdSet);
        
        //if(!populateFieldsFromContactList.isEmpty()) updateMCEligibility(populateFieldsFromContactList,contactIds2);
        
        /*Added by Deloitte - 14th July 2021*-Start*/
        if(!MobileNum.isEmpty()){
            for(Contact contSin : [SELECT Id,MB_Mobile__c from Contact WHERE MB_Mobile__c IN :MobileNum AND
                                  RecordType.name=: CommonConstant.CONTACT_ADULT_RECORDTYPE AND
                                  MB_Mobile__c!= null AND
                                  Active__c = TRUE AND
                                  PrimaryContact__c = TRUE LIMIT 50]){
                MobileContactIdmap.put(contSin.MB_Mobile__c,contSin.Id);
            }
            for (Case caseSin : (List<Case>) newList) { 
                Id contFind = MobileContactIdmap.get('+' + caseSin.ContactPhone__c);
                if(!String.isblank(contFind)){
                    caseSin.ContactId = contFind;
                }
            }
        }
         /*Added by Deloitte - 14th July 2021*-End*/
         
         /*Added by Deloitte - 20th Sep 2021*-Start*/
        if(!MobileNumIndo.isEmpty()){
            for(Contact contSin : [SELECT Id,MB_Mobile1__c from Contact WHERE MB_Mobile1__c IN :MobileNumIndo AND
                                  RecordType.name=: CommonConstant.CONTACT_ADULT_RECORDTYPE AND
                                  MB_Mobile1__c!= null AND
                                  MB_Mobile__c= null AND
                                  Active__c = TRUE AND
                                  PrimaryContact__c = TRUE LIMIT 50]){
                MobileContactIdmapIndo.put(contSin.MB_Mobile1__c,contSin.Id);
            }
            for (Case caseSin : (List<Case>) newList) { 
                Id contFind = MobileContactIdmapIndo.get('+' + caseSin.ContactPhone__c);
                if(!String.isblank(contFind)){
                    caseSin.ContactId = contFind;
                }
            }
        }
         /*Added by Deloitte - 20th Sep 2021*-End*/
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
        
        // populateCampaign
        List<Case> populateCampaignList = new List<Case>();
        
        // populateBrandUsed
        List<Case> populateBrandUsedList = new List<Case>();
        Set<Id> brIdSet = new Set<Id>();
        
        // feedbackEscalation
        List<Case> feedbackEscalationList = new List<Case>();
        
        // updateCallCompletedDate
        List<Case> updateCallCompletedDateList = new List<Case>();
        
        // checkChangeOwnership
        List<Case> checkChangeOwnershipList = new List<Case>();
        
        // populateReminderDate
        Set<String> reminderwithEmailStatus = new Set<String> {'Initial Response','First Reminder','Second Reminder','Pending - Uncontactable'};
            
            Set<String> caseStatus = new Set<String> {'Closed-Resolved','Closed-Unresolved','Completed','Cancelled'};
                
                for(Case c: (List<Case>) newList){
                    Case old = (Case) oldMapItems.get(c.Id);
                    
                    /**** MOVED FROM WORKFLOW ***********/
                    
                    if(c.Status != old.Status) {
                        
                        if(c.Status == 'Closed - Reviewed')
                            c.ReviewedDate__c = Date.Today();
                        
                        if(c.ReopenNotes__c != ''
                           && !caseStatus.contains(old.Status))
                            c.ReopenNotes__c = '';
                    }
                    
                    if(c.Description != old.Description)
                        c.Description_List_View__c = c.Description;
                    
                    /**** MOVED FROM WORKFLOW ***********/
                    
                    // checkChangeOwnership
                    if(c.OwnerId != old.OwnerId)
                        checkChangeOwnershipList.add(c);
                    
                    // RECORDTYPE = CALL
                    if(c.RecordTypeId == callRTId) {
                        
                        // populateCampaign
                        populateCampaignList.add(c);
                        
                        // populateBrandUsed
                        if(c.ConvertedBR__c != old.ConvertedBR__c) {
                            brIdSet.add(c.ConvertedBR__c);
                            populateBrandUsedList.add(c);
                        }
                        
                        // updateCallCompletedDate
                        updateCallCompletedDateList.add(c);
                    }
                    
                    // RECORDTYPE = FEEDBACK
                    if(c.RecordTypeId == feedbackRTId) {
                        feedbackEscalationList.add(c);
                    }
                    
                    // populateReminderDate
                    if(c.ReminderStatus__c != old.ReminderStatus__c
                       && reminderwithEmailStatus.contains(c.ReminderStatus__c)) {
                           c.LastReminderSentDate__c = Date.Today();
                       }

                    //added by narence (for SG only)

                    if((c.Market__C == CommonConstant.MARKET_SG) && (c.CallOutcome__c != old.CallOutcome__c)){
                        if(c.CallOutcome__c == 'Successful' || c.CallOutcome__c == 'Unsuccessful'){
                            ValidateCallOutcome(c);
                        }
                    }

                    if(c.Survey_Link__c != old.Survey_Link__c){
                        if(c.Survey_Link__c != null){
                            c.Is_Survey_Link_Populated__c = true;
                        }
                        else{
                            c.Is_Survey_Link_Populated__c = false;
                        }
                    }
                }
        
        //populateReminderDate(newList, oldMapItems);
        if(!checkChangeOwnershipList.isEmpty()) checkChangeOwnership(checkChangeOwnershipList, oldMapItems);
        if(!updateCallCompletedDateList.isEmpty()) updateCallCompletedDate(updateCallCompletedDateList, oldMapItems);
        updateNextAttemptDueDate(newList, oldMapItems);
        if(!populateCampaignList.isEmpty()) populateCampaign(populateCampaignList, oldMapItems);
        if(!populateBrandUsedList.isEmpty()) populateBrandUsed(populateBrandUsedList, brIdSet);
        if(!feedbackEscalationList.isEmpty()) feedbackEscalation(feedbackEscalationList, oldMapItems);
    }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){
        
        // // updateContactCallDates
        // //List<Case> updateContactCallDatesList = new List<Case>();
        
        // // feedbackEscalation
        // // List<Case> feedbackEscalationList = new List<Case>();
        
        // // omni channel routing
        // // List<Case> omniChannelRoutingList = new List<Case>();
        // // Set<Id> campaignIds = new Set<Id>();
        
        // for(Case c: (List<Case>) newList){
        
        //     // RECORDTYPE = CALL
        //     if(c.RecordTypeId == callRTId) {
        //         //updateContactCallDatesList.add(c);
        
        //         // // omni channel
        //         // if(c.Campaign__c != null) {
        //         //     omniChannelRoutingList.add(c);
        //         //     campaignIds.add(c.Campaign__c);
        //         // }
        //     }
        
        //     // RECORDTYPE = FEEDBACK
        //     // if(c.RecordTypeId == feedbackRTId) {
        //     //     feedbackEscalationList.add(c);
        //     // }
        // }
        
        // //if(!updateContactCallDatesList.isEmpty()) updateContactCallDates(updateContactCallDatesList, null);
        // //populateLatestCallDate(newList, null);
        // //if(!feedbackEscalationList.isEmpty()) feedbackEscalation(feedbackEscalationList, null);
        // //if(!omniChannelRoutingList.isEmpty()) omniChannelRouting(omniChannelRoutingList, campaignIds);
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){

        
        //     // updateContactCallDates
        //     //List<Case> updateContactCallDatesList = new List<Case>();
        
        //     // Remove in omni channel
        //     //Set<Id> removeInOmniChannel = new Set<Id>();
        
        //     // checkUncontactable
        //     List<Case> checkUncontactableList = new List<Case>();
        
        //     for(Case c: (List<Case>) newList){
               //Case old = (Case) oldMapItems.get(c.Id);
        
        //         // RECORDTYPE = CALL
        //         if(c.RecordTypeId == callRTId) {
        //             //updateContactCallDatesList.add(c);
        
        //             // Remove in omni channel
        //             // if(c.CallAccepted__c && !old.CallAccepted__c){
        //             //     removeInOmniChannel.add(c.Id);
        //             // }
         
               
             
        //         }
        
        //         if(c.ReminderStatus__c == 'Pending - Uncontactable'
        //             && c.ReminderStatus__c != old.ReminderStatus__c) {
        //             checkUncontactableList.add(c);
        //         }
          // }
        
        //  //if(!updateContactCallDatesList.isEmpty()) updateContactCallDates(updateContactCallDatesList, oldMapItems);
        //     //populateLatestCallDate(newList, oldMapItems);
        //     updateRelatedBR(newList, oldMapItems);
        //     //if(!removeInOmniChannel.isEmpty()) CaseTriggerHander_AdminMode.removeInOmniChannel(removeInOmniChannel);
        //     //if(!checkUncontactableList.isEmpty()) checkUncontactable(checkUncontactableList);
        
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        List<Case> oldCase = (List<Case>) oldList;
        List<Case> caseToProcess = new List<Case>();
        
        for(Case c : oldCase ){
            If(c.To_be_Archived__c == false){
                caseToProcess .add(c);
            }
        }
        
        if(!caseToProcess.isEmpty()){
            updateContactCallDatesAfterDelete(caseToProcess);
            populateLatestCallDateDeleted(caseToProcess);
        }
    }
    
/**
* @author           Marlon Ocillos
* @date             2.21.2019
* @description      Method is called to update the Call Completed Date field when a call is set to Complete
* @revision(s)
5.15.2019 - Raustral - add addtional filter
7.1.2019 - Raustral - add external date
*/
    public static void updateCallCompletedDate(List<Case> newList, Map<Id, SObject> oldMapItems) {
        
        Set<Id> callRegardingIds = new Set<Id>();
        for(Case c: newList) {
            if(trigger.isUpdate) {
                Case oldCase = (Case) oldMapItems.get(c.Id);
                if(c.Status == 'Completed' && oldCase.Status != 'Completed') {
                    callRegardingIds.add(c.CallRegarding__c);
                }
            }
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT WeeksOfPregnancy__c, EstimatedDueDate__c FROM Contact WHERE Id IN: callRegardingIds]);
        
        for(Case caseRec : newList) {
            
            //US-0359
            if(caseRec.CallOutcome__c == 'Successful') {
                caseRec.UnsuccessfulReason__c = null;
                caseRec.UncontactableReason__c = null;
                caseRec.InvalidReason__c = null;
            }
            else if(caseRec.CallOutcome__c == 'Unsuccessful') {
                caseRec.UncontactableReason__c = null;
                caseRec.SuccessfulReason__c = null;
                caseRec.InvalidReason__c = null;
            }
            else if(caseRec.CallOutcome__c == 'Uncontactable') {
                caseRec.UnsuccessfulReason__c = null;
                caseRec.SuccessfulReason__c = null;
                caseRec.InvalidReason__c = null;
            }
            else if(caseRec.CallOutcome__c == 'Invalid') {
                caseRec.UnsuccessfulReason__c = null;
                caseRec.UncontactableReason__c = null;
                caseRec.SuccessfulReason__c = null;
            }
            
            if (trigger.isUpdate) {
                Case oldCase = (Case)oldMapItems.get(caseRec.Id);
                if(caseRec.RecordTypeId == callRTId) {
                    if(caseRec.Status == 'Completed' && oldCase.Status != 'Completed') {
                        //add callcompeltedexternal -us - 0488 
                        caseRec.CallCompletedDate__c = caseRec.CallCompletedDateExternal__c == null ? System.now() :  caseRec.CallCompletedDateExternal__c;
                        
                        if(contactMap.containsKey(caseRec.CallRegarding__c)){
                            Contact callRegarding = contactMap.get(caseRec.CallRegarding__c);
                            caseRec.EstimatedDueDate_Completed__c = callRegarding.EstimatedDueDate__c;
                            caseRec.WeeksofPregnancy_Completed__c = callRegarding.WeeksOfPregnancy__c;
                        }
                    }
                    
                    if(caseRec.Status != oldCase.Status && caseRec.FirstCallAttemptDate__c == null) {
                        caseRec.FirstCallAttemptDate__c = System.Now();
                    }
                }
            }
            else if(caseRec.RecordTypeId == callRTId) {
                if(caseRec.Status == 'Completed') {
                    //add callcompeltedexternal -us - 0488 
                    caseRec.CallCompletedDate__c = caseRec.CallCompletedDateExternal__c == null ? System.now() :  caseRec.CallCompletedDateExternal__c;
                }
            }
        }
    }
    
    /**
* @author           Marlon Ocillos
* @date             2.21.2019
* @description      Method is called to update the First and Last Contact Dates/Lookup when a call is deleted
* @revision(s)
*/
    public static void updateContactCallDatesAfterDelete(List<Case> oldList) {
        Set<Id> contactSet = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>();
        // Loop through deleted Calls to get their Contac Ids
        for(Case caseRec : oldList) {
            if(caseRec.RecordTypeId == callRTId && caseRec.CallCompletedDate__c != null) {
                contactSet.add(caseRec.ContactId);
            }
        }
        // Query Contacts and their existing (if any) completed Calls
        contactList = [select Id,  FirstCallDate__c, FirstCall__c, LastCallDate__c, LatestCall__c, 
                       (select Id, CallCompletedDate__c from Cases where RecordTypeId = :callRTId and CallCompletedDate__c != null) 
                       from Contact where Id in :contactSet];
        
        if(!contactList.isEmpty()) {
            for(Contact conRec : contactList) {
                // Process only Contacts where First/Last calls have been deleted and First/Last Call dates have values
                // Means that their First/Last call were included in the deleted Calls
                if((conRec.FirstCallDate__c != null && conRec.FirstCall__c == null) || (conRec.LastCallDate__c != null && conRec.LatestCall__c == null ) || Test.isRunningTest()) {
                    // Set First Call Date to null
                    if(conRec.FirstCall__c == null) {
                        conRec.FirstCallDate__c = null;
                    }
                    // Set Last Call Date to null
                    if(conRec.LatestCall__c == null) {
                        conRec.LastCallDate__c = null;
                    }
                    // Determine if there are existing Calls under the Contacts
                    if(!conRec.Cases.isEmpty()) {
                        for(Case caseRec : conRec.Cases) {
                            // Process Calls to set new First Date if Necessary
                            if(conRec.FirstCallDate__c == null) {
                                conRec.FirstCallDate__c = caseRec.CallCompletedDate__c;
                                conRec.FirstCall__c = caseRec.Id;
                            } else {
                                if(caseRec.CallCompletedDate__c < conRec.FirstCallDate__c) {
                                    conRec.FirstCallDate__c = caseRec.CallCompletedDate__c;
                                    conRec.FirstCall__c = caseRec.Id;
                                }
                            }
                            // Process Calls to set new Last Date if Necessary
                            if(conRec.LastCallDate__c == null) {
                                conRec.LastCallDate__c = caseRec.CallCompletedDate__c;
                                conRec.LatestCall__c = caseRec.Id;
                            } else {
                                if(caseRec.CallCompletedDate__c > conRec.LastCallDate__c) {
                                    conRec.LastCallDate__c = caseRec.CallCompletedDate__c;
                                    conRec.LatestCall__c = caseRec.Id;
                                }
                            }
                        }
                        // Put in map to update
                        contactsToUpdateMap.put(conRec.Id, conRec);
                    } else {
                        // Put in map to update
                        contactsToUpdateMap.put(conRec.Id, conRec);
                    }
                }
            }
        }
        // Update Contacts
        if(!contactsToUpdateMap.isEmpty()) {
            update contactsToUpdateMap.values();
        }
    }
    
    public void checkChangeOwnership(List<Case> newList, Map<Id, SObject> oldMapItems) {
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() and Name like '%Agent%'];
        List<UserRole> roleList = [select Id, DeveloperName from UserRole where DeveloperName = 'ANI_Singapore'];
        
        if (!profileList.isEmpty() || Test.isRunningTest()) {
            for(Case caseRec : newList) {
                Case oldCase = (Case)oldMapItems.get(caseRec.Id);
                if( (caseRec.RecordTypeId != callRTId && !caseRec.IsSocialCase__c)
                   || (caseRec.RecordTypeId == callRTId
                       && caseRec.CallTransferReason__c == null
                       && (UserInfo.getUserRoleId() != roleList[0].Id
                           || UserInfo.getUserRoleId() == roleList[0].Id
                           && !profileList[0].Name.contains('ANI Call Center Agent')
                          )
                       //&& (caseRec.Market__c != 'IN')
                       && !System.Label.Allow_Case_Owner_Change.contains(caseRec.Market__c)
                      )
                  ) {
                      caseRec.addError('You have no access to change the owner');
                  }
            }
        }
    }
    
    // Method that populates BR and CR in Call records depending on the latest CR (Registration Date)
    public void populateRelatedBRandCR(List<Case> newList, Set<Id> contactIds, Set<Id> campaignIds) {
        Map<Id, Map<String, ChannelResponse__c>> conAndCRMap = new Map<Id, Map<String, ChannelResponse__c>>();
        Map<Id, Map<String, ChannelResponse__c>> conAndCrProductMap = new Map<Id, Map<String, ChannelResponse__c>>();
        
        Map<Id,ChannelResponse__c> channelResponseMap = getChannelResponseDetails(newList);
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([select Brand__c, Product__c, Product__r.Name,Product__r.ParentProduct__c from Campaign where Id in :campaignIds]);
        
        Set<String> brandList = new Set<String>();
        for(Campaign c: campaignMap.values())
            brandList.add(c.Brand__c);
        
        // get all the BR related to CR within the campaign, get the latest CR based on registration date and created date.
        for(BrandRelationship__c br: [SELECT PrimaryContact__c, KeyBrand__c,BrandRelationship__r.ParentProduct__c,
                                      (SELECT RegistrationDate__c, BrandRelationship__c, Channel__c, BrandRelationship__r.PrimaryContact__c,
                                       BrandRelationship__r.KeyBrand__c, BrandRelationship__r.CurrentBrand__c, CreatedDate, Campaign__c,
                                       BrandRelationship__r.PreviousBrand__c, BrandRelationship__r.BrandSwitchReason__c, BrandRelationship__r.SKU__c
                                       FROM Channel_Responses__r
                                       ORDER BY RegistrationDate__c DESC, CreatedDate DESC
                                       LIMIT 1)
                                      FROM BrandRelationship__c
                                      WHERE PrimaryContact__c IN: contactIds
                                      AND KeyBrand__c IN: brandList
                                      ORDER BY LastModifiedDate DESC]) {
                                          
                                          if(!br.Channel_Responses__r.isEmpty()) {
                                              String contactId = br.PrimaryContact__c;
                                              String keyBrand = br.KeyBrand__c;
                                              
                                              if(!conAndCRMap.containsKey(contactId))
                                                  conAndCRMap.put(contactId, new Map<String, ChannelResponse__c>());
                                              
                                              // only get the latest CR per key brand
                                              if(conAndCRMap.get(contactId).containsKey(keyBrand)) {
                                                  if(br.Channel_Responses__r[0].RegistrationDate__c > conAndCRMap.get(contactId).get(keyBrand).RegistrationDate__c
                                                     || (br.Channel_Responses__r[0].RegistrationDate__c == conAndCRMap.get(contactId).get(keyBrand).RegistrationDate__c
                                                         && br.Channel_Responses__r[0].createdDate > conAndCRMap.get(contactId).get(keyBrand).createdDate))
                                                      conAndCRMap.get(contactId).put(keyBrand, br.Channel_Responses__r[0]);
                                              } else {
                                                  conAndCRMap.get(contactId).put(keyBrand, br.Channel_Responses__r[0]);
                                              }
                                          }
                                      }
        
        Set<String> productBrandList = new Set<String>();
        for(Campaign c: campaignMap.values())
            productBrandList.add(c.Product__c);
        
        
        
        // get all the BR related to CR within the campaign, get the latest CR based on registration date and created date.
        for(BrandRelationship__c br: [SELECT PrimaryContact__c, KeyBrand__c,BrandRelationship__c,BrandRelationship__r.ParentProduct__c,
                                      (SELECT RegistrationDate__c, BrandRelationship__c, Channel__c, BrandRelationship__r.PrimaryContact__c,
                                       BrandRelationship__r.KeyBrand__c, BrandRelationship__r.CurrentBrand__c, CreatedDate, Campaign__c,
                                       BrandRelationship__r.PreviousBrand__c, BrandRelationship__r.BrandSwitchReason__c, BrandRelationship__r.SKU__c
                                       FROM Channel_Responses__r
                                       ORDER BY RegistrationDate__c DESC, CreatedDate DESC
                                       LIMIT 1)
                                      FROM BrandRelationship__c
                                      WHERE PrimaryContact__c IN: contactIds
                                      AND (BrandRelationship__c IN: productBrandList OR BrandRelationship__r.ParentProduct__c IN: productBrandList)
                                      ORDER BY LastModifiedDate DESC]) {
                                          
                                          if(!br.Channel_Responses__r.isEmpty()) {
                                              String contactId = br.PrimaryContact__c;
                                              String brProduct = br.BrandRelationship__c;
                                              String parentProduct = br.BrandRelationship__r.ParentProduct__c;
                                              
                                              if(!conAndCrProductMap.containsKey(contactId))
                                                  conAndCrProductMap.put(contactId, new Map<String, ChannelResponse__c>());
                                              
                                              // only get the latest CR per Product Brand
                                              if(conAndCrProductMap.get(contactId).containsKey(parentProduct)) {
                                                  if(br.Channel_Responses__r[0].RegistrationDate__c > conAndCrProductMap.get(contactId).get(parentProduct).RegistrationDate__c
                                                     || (br.Channel_Responses__r[0].RegistrationDate__c == conAndCrProductMap.get(contactId).get(parentProduct).RegistrationDate__c
                                                         && br.Channel_Responses__r[0].createdDate > conAndCrProductMap.get(contactId).get(parentProduct).createdDate)){
                                                             
                                                             conAndCrProductMap.get(contactId).put(brProduct, br.Channel_Responses__r[0]);
                                                             conAndCrProductMap.get(contactId).put(parentProduct, br.Channel_Responses__r[0]);
                                                         }
                                              } else {
                                                  conAndCrProductMap.get(contactId).put(brProduct, br.Channel_Responses__r[0]);
                                                  conAndCrProductMap.get(contactId).put(parentProduct, br.Channel_Responses__r[0]);
                                              }
                                          }
                                      }
        
        
        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>();
        for(Case c : newList) {
            // CR already given
            if(c.RelatedChannelResponse__c != null) {
                ChannelResponse__c cr = channelResponseMap.get(c.RelatedChannelResponse__c);
                c.RelatedBrandRelationship__c = cr.BrandRelationship__c;
                c.Channel__c = cr.Channel__c;
                
                //added by Monika - Populating the related campaign field from Market Cloud on Case Creating
                if(c.Market__c != CommonConstant.MARKET_TW){ 
                    c.RelatedCampaign__c = cr.Campaign__c;
                }
                
                BrandRelationship__c br = new BrandRelationship__c(Id = cr.BrandRelationship__c);
                
                if(c.CurrentBrandUsed__c == null){
                    c.CurrentBrandUsed__c = cr.BrandRelationship__r.CurrentBrand__c;
                }
                
                if(c.PreviousBrandUsed__c == null) {
                    c.PreviousBrandUsed__c = cr.BrandRelationship__r.PreviousBrand__c;
                }
                
                if(c.BrandSwitchReason__c == null) {
                    c.BrandSwitchReason__c = cr.BrandRelationship__r.BrandSwitchReason__c;
                }
                
                if(c.SKU__c == null) {
                    c.SKU__c = cr.BrandRelationship__r.SKU__c;
                }
                continue; 
            } 
            
            // populate BR CR Channel based on the latest CR of the Campaign brand
            if(c.Campaign__c != null && c.ProductCampaign__c == null) {
                String campaignBrand = campaignMap.get(c.Campaign__c).Brand__c;
                
                if(conAndCRMap.containsKey(c.ContactId)
                    && conAndCRMap.get(c.ContactId).containsKey(campaignBrand)) {
                        ChannelResponse__c cr = conAndCRMap.get(c.ContactId).get(campaignBrand);
                        c.RelatedChannelResponse__c = cr.Id;
                        c.RelatedBrandRelationship__c = cr.BrandRelationship__c;
                        c.Channel__c = cr.Channel__c;
                        c.CurrentBrandUsed__c = cr.BrandRelationship__r.CurrentBrand__c;
                        c.PreviousBrandUsed__c = cr.BrandRelationship__r.PreviousBrand__c;
                        c.BrandSwitchReason__c = cr.BrandRelationship__r.BrandSwitchReason__c;
                        c.SKU__c = cr.BrandRelationship__r.SKU__c;
                        //added by Monika - Populating the related campaign field from Market Cloud on Case Creating
                        if(c.Market__c != CommonConstant.MARKET_TW){ 
                            c.RelatedCampaign__c = cr.Campaign__c;
                        }
                    }
                
            }
            
            if(c.Campaign__c != null && c.ProductCampaign__c != null) {
                String campaignProductBrand = campaignMap.get(c.Campaign__c).Product__c;
                
                if(conAndCrProductMap.containsKey(c.ContactId)
                    && conAndCrProductMap.get(c.ContactId).containsKey(campaignProductBrand)) {
                        
                        ChannelResponse__c cr = conAndCrProductMap.get(c.ContactId).get(campaignProductBrand);
                        c.RelatedChannelResponse__c = cr.Id;
                        c.RelatedBrandRelationship__c = cr.BrandRelationship__c;
                        c.Channel__c = cr.Channel__c;
                        c.CurrentBrandUsed__c = cr.BrandRelationship__r.CurrentBrand__c;
                        c.PreviousBrandUsed__c = cr.BrandRelationship__r.PreviousBrand__c;
                        c.BrandSwitchReason__c = cr.BrandRelationship__r.BrandSwitchReason__c;
                        c.SKU__c = cr.BrandRelationship__r.SKU__c;
                        //added by Monika - Populating the related campaign field from Market Cloud on Case Creating
                        if(c.Market__c != CommonConstant.MARKET_TW){ 
                            c.RelatedCampaign__c = cr.Campaign__c;
                        }
                        
                    } else {
                        String campaignBrand = campaignMap.get(c.Campaign__c).Brand__c;
                        
                        if(conAndCRMap.containsKey(c.ContactId)
                            && conAndCRMap.get(c.ContactId).containsKey(campaignBrand)) {
                                ChannelResponse__c cr = conAndCRMap.get(c.ContactId).get(campaignBrand);
                                c.RelatedChannelResponse__c = cr.Id;
                                c.RelatedBrandRelationship__c = cr.BrandRelationship__c;
                                c.Channel__c = cr.Channel__c;
                                c.CurrentBrandUsed__c = cr.BrandRelationship__r.CurrentBrand__c;
                                c.PreviousBrandUsed__c = cr.BrandRelationship__r.PreviousBrand__c;
                                c.BrandSwitchReason__c = cr.BrandRelationship__r.BrandSwitchReason__c;
                                c.SKU__c = cr.BrandRelationship__r.SKU__c;
                                //added by Monika - Populating the related campaign field from Market Cloud on Case Creating
                                if(c.Market__c != CommonConstant.MARKET_TW){ 
                                    c.RelatedCampaign__c = cr.Campaign__c;                               
                                }
                        }
                    }
        }
    }
    }
    public void updateNextAttemptDueDate(List<Case> caseList,Map<id, sObject> oldMap){
        Map<String, String> acs = UtilityClass.convertObjToMap(affiliateMetadataMap.values(), CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_NEXTATTEMPT);
        
        for(Case c : caseList){
            String oldStatus;
            if(Trigger.IsUpdate && oldMap.containsKey(c.Id)){
                Case oldCase = (Case) oldMap.get(c.Id);
                oldStatus = oldCase.Status;
            }
            
            if((Trigger.IsInsert && (c.Status == 'Pending Second Attempt' || c.Status == 'Pending Third Attempt')) || 
               ((Trigger.IsUpdate && c.Status != oldStatus)) && (c.Status == 'Pending Second Attempt' || c.Status == 'Pending Third Attempt')){
                   if(acs.containsKey(c.Market__c)) {
                       String nextattemptdays= acs.get(c.Market__c);
                       c.NextAttemptDueDate__c = date.today().addDays(Integer.valueOf(nextattemptdays));
                   }
               }
        }
    }
    
    public void populateCampaign(List<Case> newList, Map<Id, SObject> oldMapItems) {
        List<Case> caseList = new List<Case>();
        Map<Id,ChannelResponse__c> channelResponseMap = getChannelResponseDetails(newList);
        List<BrandRelationship__c> brandRelationshipList = new List<BrandRelationship__c>();
        
        for(Case caseRec : newList) {
            Case oldCase = (Case)oldMapItems.get(caseRec.Id);
            ChannelResponse__c relatedCR = new ChannelResponse__c();
            if(caseRec.RelatedChannelResponse__c != null)
                relatedCR = channelResponseMap.get(caseRec.RelatedChannelResponse__c);
            
            if(caseRec.RelatedChannelResponse__c != null) {
                if(caseRec.RelatedChannelResponse__c != oldCase.RelatedChannelResponse__c
                    || caseRec.RelatedCampaign__c != oldCase.RelatedCampaign__c) {
                        //added by Monika - Populating the related campaign field from Market Cloud on Case Creating
                        if(caseRec.Market__c != CommonConstant.MARKET_TW){
                            caseRec.RelatedCampaign__c = relatedCR.Campaign__c;
                        }
                    }
                if(caseRec.RelatedChannelResponse__c != oldCase.RelatedChannelResponse__c
                    || caseRec.Channel__c != oldCase.Channel__c) {
                        caseRec.Channel__c = relatedCR.Channel__c;
                    }
                if(caseRec.RelatedChannelResponse__c != oldCase.RelatedChannelResponse__c
                    || caseRec.RelatedBrandRelationship__c != oldCase.RelatedBrandRelationship__c) {
                        caseRec.RelatedBrandRelationship__c = relatedCR.BrandRelationship__c;
                    }
            } 
            else if(oldCase.RelatedChannelResponse__c != null && caseRec.RelatedChannelResponse__c == null) {
                //added by Monika - Populating the related campaign field from Market Cloud on Case Creating
                if(caseRec.Market__c != CommonConstant.MARKET_TW){
                    caseRec.RelatedCampaign__c = null;
                }
                caseRec.Channel__c = null;
                caseRec.RelatedBrandRelationship__c = null;
                
            }
        }
    }
    
    public static Map<Id,ChannelResponse__c> getChannelResponseDetails(List<Case> caseList) {
        Set<Id> crIdSet = new Set<Id>();
        
        for(Case caseRec : caseList) {
            if(caseRec.RelatedChannelResponse__c != null) {
                crIdSet.add(caseRec.RelatedChannelResponse__c);
            }
        }
        
        Map<Id,ChannelResponse__c> channelResponseMap = new Map<Id,ChannelResponse__c>([Select Campaign__c, Channel__c, BrandRelationship__c,
                                                                                        BrandRelationship__r.CurrentBrand__c, BrandRelationship__r.PreviousBrand__c,
                                                                                        BrandRelationship__r.BrandSwitchReason__c, BrandRelationship__r.SKU__c
                                                                                        FROM ChannelResponse__c WHERE Id IN :crIdSet]);
        return channelResponseMap;
    }
    
    public static void populateBrandUsed(List<Case> filteredCases, Set<Id> brIdSet) {
        
        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>([select Id, CurrentBrand__c, PreviousBrand__c from BrandRelationship__c where Id in :brIdSet]);
        
        for(Case cRec : filteredCases) {
            if(cRec.ConvertedBR__c == null) {
                cRec.CurrentBrandUsed__c = null;
                cRec.PreviousBrandUsed__c = null;
            } else {
                BrandRelationship__c brRec = brMap.get(cRec.ConvertedBR__c);
                if(brRec != null) {
                    cRec.CurrentBrandUsed__c = brRec.CurrentBrand__c;
                    cRec.PreviousBrandUsed__c = brRec.PreviousBrand__c;
                }
            }
        }
    }
    
    public static void populateLatestCallDateDeleted(List<Case> newList) {
        Set<Id> validContactIds = new Set<Id>();
        for(Case caseRec : newList) {
            if (caseRec.CallOutcome__c == 'Successful' || caseRec.CallOutcome__c == 'Unsuccessful') {
                validContactIds.add(caseRec.ContactId);
            }
        }
        
        if (!validContactIds.isEmpty()) {
            Map<Id,Contact> toUpdateContactMap = new Map<Id, Contact>();            
            
            Map<Id, Case> existingCaseMap = New Map<Id, Case>( [Select Id,ContactId, LastModifiedDate,
                                                                (Select NewValue,CreatedDate From Histories where Field = 'CallOutcome__c' Order by CreatedDate Desc Limit 1) 
                                                                From Case where ContactId IN: validContactIds and (CallOutcome__c = 'Successful' or CallOutcome__c = 'Unsuccessful') ]);
            
            for (Contact con : [Select Id,LatestOpenCallDate__c, (Select Id from Cases Where CallOutcome__c = 'Successful' or CallOutcome__c = 'Unsuccessful') from Contact where Id IN: validContactIds]) {
                DateTime oldValue = con.LatestOpenCallDate__c;
                if (!con.Cases.isEmpty()) {                   
                    con.LatestOpenCallDate__c = null;
                    for (Case c: con.Cases) {
                        List<CaseHistory> histList = existingCaseMap.get(c.Id).Histories;
                        if (histList.size() != 0 && con.LatestOpenCallDate__c == null) {                            
                            con.LatestOpenCallDate__c = histList.get(0).CreatedDate;                            
                        } else if (histList.size() != 0 && con.LatestOpenCallDate__c < histList.get(0).CreatedDate) {
                            con.LatestOpenCallDate__c = histList.get(0).CreatedDate;
                        }
                    }  
                } else {
                    con.LatestOpenCallDate__c = null;
                }
                
                if (oldValue != con.LatestOpenCallDate__c)
                    toUpdateContactMap.put(con.Id, con);
            }
            
            if (!toUpdateContactMap.isEmpty()) {
                Update toUpdateContactMap.values();
            }
        }
    }
    
    public static void populateFieldsFromContact(List<Case> newList, Set<Id> contactIds) {
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Default_Address__r.City2__r.Name, Default_Address__r.District__r.Name, LatestCall__r.CallOutcome__c,
                                                            Default_Address__r.FullAddress__c, LatestCall__c, LatestCall__r.RelatedCampaign__c, LatestCall__r.RelatedCampaign__r.Brand__c,
                                                            LatestCall__r.Previous_No_Of_Scoop__c, LatestCall__r.No_Of_Scoop__c, Market__c
															FROM Contact Where Id in: contactIds]);
        for (Case c: newList) {
            Contact con = contactMap.get(c.ContactId);
            if (con != null) {
                if(con.Default_Address__c != null) {
                    // c.Address__c = con.Default_Address__r.FullAddress__c.replace('<br>','\n');
                    c.Address__c = con.Default_Address__r.FullAddress__c;
                    
                    if (con.Default_Address__r.City2__c != null)
                        c.City__c = con.Default_Address__r.City2__r.Name;
                    
                    if (con.Default_Address__r.District__c != null)
                        c.District__c = con.Default_Address__r.District__r.Name;
                    
                }

                if(con.LatestCall__c != null && con.LatestCall__r.CallOutcome__c == 'Successful' && con.Market__c.equals(CommonConstant.MARKET_SG) && con.LatestCall__r.RelatedCampaign__c != null &&
                    (con.LatestCall__r.RelatedCampaign__r.Brand__c == 'Glucerna' || con.LatestCall__r.RelatedCampaign__r.Brand__c == 'Ensure')){
                    c.Previous_No_Of_Scoop__c = con.LatestCall__r.No_Of_Scoop__c;
                }

                if (con.LatestCall__c != null)
                    c.LatestCallOutcome__c = con.LatestCall__r.CallOutcome__c;
            }
        }
    }
    
    private static void checkEmailToCase(List<Case> caseList, Set<String> emailList){
        
        // link case to existing contact, if any
        for(Contact con: [SELECT AccountId, Email FROM Contact WHERE Email IN: emailList]){
            for(Case c: caseList){
                //get the first one in the list
                if(con.AccountId != null
                   && c.SuppliedEmail == con.Email){
                       c.AccountId = con.AccountId;
                       c.ContactId = con.Id;
                   }
            }
        }
    }
    
    //US- Feedback Case Escalation - India
    // May 22 2020 - updated to do prepopulation of the escalated to, Change Event will do the actual email sending
    private static void feedbackEscalation(List<Case> newList, Map<Id, SObject> oldMap) {
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Map<String, OrgWideEmailAddress> orgWideMap = new Map<String, OrgWideEmailAddress>();
        
        Set<Id> stateIDs = new Set<Id>();
        List<Case> escalatedFeedback = new List<Case>();
        Set<Id> storeIDs = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for(Case c: newList){
            accountIds.add(c.AccountId);
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Market__c FROM Account WHERE Id IN: accountIds]);
        
        for(Case c: newList) {
            Case old = new Case();
            
            if(Trigger.isUpdate) {
                old = (Case) oldMap.get(c.Id);
            }
            
            // get market
            String market = String.isNotBlank(c.Market__c) ?
                c.Market__c : '';
            if(market == '' && c.AccountId != null) {
                market = accountMap.get(c.AccountId).Market__c;
            }
            
            // verify case is feedback market is IN and being escalated and not manually being escalated
            if(c.RecordTypeId == feedBackRTId
               && market != ''
               && market == CommonConstant.MARKET_IN
               && c.StoreWherePurchased__c != null
               && ( (Trigger.isInsert
                     && c.Status == CommonConstant.CASE_STATUS_ESCALATED)
                   || (Trigger.isUpdate
                       && c.Status == CommonConstant.CASE_STATUS_ESCALATED
                       && c.Status != old.Status)
                  )
              ) {
                  escalatedFeedback.add(c);
                  stateIDs.add(c.State__c);
                  storeIDs.add(c.StoreWherePurchased__c);
              }
        }
        
        if(!escalatedFeedback.isEmpty()) {
            
            //get store
            Map<Id, Channel__c> storeMap = new Map<Id, Channel__c>([SELECT Type__c FROM Channel__c WHERE Id IN: storeIDs]);
            
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
            
            // Key --> state|product|channelType|escalationLevel -- always level 1, create dynamic utility for this
            Map<String, Affiliate_Value__c> escalationMap = new Map<String, Affiliate_Value__c>();
            
            For(Affiliate_Value__c state: [SELECT (SELECT MainEscalationPointEmail__c, MainEscalationPointEmail2__c, EscalationLevel__c, ChannelType__c, Product__c,
                                                   AdditionalEscalationPointEmail1__c, AdditionalEscalationPointEmail2__c, AdditionalEscalationPointEmail3__c,
                                                   AdditionalEscalationPointEmail4__c, AdditionalEscalationPointEmail5__c, AdditionalEscalationPointEmail6__c
                                                   FROM Affiliate_Values__r
                                                   WHERE Active__c = true
                                                   AND EscalationLevel__c = '1')
                                           FROM Affiliate_Value__c
                                           WHERE Id IN: stateIDs]) {
                                               for(Affiliate_Value__c d: state.Affiliate_Values__r) {
                                                   String key = state.Id + '|' + d.product__c + '|' + d.ChannelType__c;
                                                   escalationMap.put(key, d);
                                               }
                                           }
            
            EmailTemplate escalationEmail = [SELECT DeveloperName, Body, Subject FROM EmailTemplate WHERE DeveloperName =: CommonConstant.EMAILTEMPLATE_CASE_ESCALATION];
            
            for(Case c: escalatedFeedback) {
                
                String key = c.State__c + '|' + c.Product__c + '|' + storeMap.get(c.StoreWherePurchased__c).Type__c;
                if(escalationMap.containsKey(key)) {
                    c.EscalatedTo__c =  escalationMap.get(key).Id;
                    c.LevelofEscalation__c = 'Level 1';
                }
            }
        }
    }
    private static void populateRelatedCR(List<Case> newList, Set<Id> crBRSetId){
        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>([SELECT Id, (SELECT Id FROM Channel_Responses__r ORDER BY CreatedDate DESC LIMIT 1)
                                  				FROM BrandRelationship__c WHERE Id =:  crBRSetId]);
        
        for(Case c: newList){
            if(!brMap.get(c.RelatedBrandRelationship__c).Channel_Responses__r.isEmpty()){
                c.RelatedChannelResponse__c = brMap.get(c.RelatedBrandRelationship__c).Channel_Responses__r[0].Id;
            }
        }
     
    } 
    //added by narence 
    public void ValidateCallOutcome(Case c){
        
            if(c.PreviousBrandUsed__c == null){
                c.PreviousBrandUsed__c.adderror('Previous Brand is mandatory if Call Outcome is equal to Successful or unsuccessful');
            }
            if(c.CurrentBrandUsed__c == null){
                c.CurrentBrandUsed__c.adderror('Current Brand is mandatory if Call Outcome is equal to Successful or unsuccessful');
            }
            if(c.BrandSwitchReason__c == null){
                c.BrandSwitchReason__c.adderror('Brand Switch Reason is mandatory if Call Outcome is equal to Successful or unsuccessful');
            }
            if(c.Channel__c == null){
                c.Channel__c.adderror('Channel is mandatory if Call Outcome is equal to Successful or unsuccessful');
            }
            if(c.PrimaryProductDiscussed__c == null){
                c.PrimaryProductDiscussed__c.adderror('Primary product discussed is mandatory if Call Outcome is equal to Successful or unsuccessful');
            }
    }
    
    /*
    // Moved update process to Scheduled Batch Job
    // Update MC Eligibility fields
    public static void updateMCEligibility(List<Case> caseList, Set<Id> conIds) {
        
        Map<Id, Contact> contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                                           MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                                           MC_Sync_Eligibility_VN__c
                                                           FROM Contact 
                                                           WHERE Id IN :conIds]);
        
        for(Case c: caseList) {  
            if(contactMap.containsKey(c.ContactId)){          
                String Market = contactMap.get(c.ContactId).Market__c;
                
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
                }
            }
            
        }
    }*/
    
    // public static void omniChannelRouting(List<Case> newList, Set<Id> campaignIds) {
    //     Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([SELECT Id, AutoAssignCalls__c, Market__c
    //                                                              FROM Campaign
    //                                                             WHERE Id IN: campaignIds]);
    //     List<Id> casesForRouting = new List<Id>();
    //     for(Case c: newList) {
    //         Campaign camp = campaignMap.get(c.Campaign__c);
    //         if(camp.AutoAssignCalls__c
    //             && affiliateMetadataMap.get(camp.Market__c).RouteviaOmniChannel__c) {
    //             casesForRouting.add(c.Id);
    //         }
    //     }
    
    //     if(!casesForRouting.isEmpty())
    //         SkillsBasedRouting.routeUsingSkills(casesForRouting);
    // }
    
    /**
* @author           Jericson Mercado
* @date             10.22.2019
* @description      Method is called to update the Current and Previous Brand of the Related Brand Relationship whenever the call is updated.
* @revision(s)
May 22, 2020 - Moved to Change Event
*/
    // public static void updateRelatedBR(List<Case> newList, Map<Id, Sobject> oldMapItems) {
    //     Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>();
    
    //     // reference for lapsed
    //     Set<Id> brIds = new Set<Id>();
    //     Set<Id> currentProductIds = new Set<Id>();
    //     for(Case c: newList){
    //         Case old = (Case) oldMapItems.get(c.Id);
    
    //         if(c.RelatedBrandRelationship__c != null) { 
    //             brIds.add(c.RelatedBrandRelationship__c);
    
    //             if(c.CurrentBrandUsed__c != null
    //                && c.CurrentBrandUsed__c != old.CurrentBrandUsed__c) {
    //                    currentProductIds.add(c.CurrentBrandUsed__c);
    //             }
    //         }
    //     }
    
    //     // reference for lapsed
    //     Map<Id, BrandRelationship__c> brReferenceMap = new Map<Id, BrandRelationship__c>();
    //     if(!brIds.isEmpty()) {
    //         brReferenceMap = new Map<Id, BrandRelationship__c>([SELECT Id, Type__c
    //                                                               FROM BrandRelationship__c
    //                                                              WHERE Id IN: brIds]);
    //     }
    
    //     // get product check if competitor
    //     Map<Id, Product2> productMap = new Map<Id, Product2>();
    //     if(!currentProductIds.isEmpty()) {
    //         productMap = new Map<Id, Product2>([SELECT Id, CompetitorProduct__c
    //                                               FROM Product2
    //                                              WHERE Id IN: currentProductIds]);
    //     }
    
    //     for(Case c: newList){
    //         Case old = (Case) oldMapItems.get(c.Id);
    //         if(c.RelatedBrandRelationship__c != null
    //             && c.Market__c != CommonConstant.MARKET_VN){
    
    //             //check if current brand is updated
    //             if(c.CurrentBrandUsed__c != old.CurrentBrandUsed__c){
    //                 if(!brMap.containsKey(c.RelatedBrandRelationship__c)){
    //                     brMap.put(c.RelatedBrandRelationship__c, new BrandRelationship__c(Id = c.RelatedBrandRelationship__c));
    //                 }
    //                 brMap.get(c.RelatedBrandRelationship__c).CurrentBrand__c = c.CurrentBrandUsed__c;
    
    //                 // TKT-1970 change status to lapsed if current brand is a competitor product
    //                 if(c.CurrentBrandUsed__c != null
    //                      && productMap.get(c.CurrentBrandUsed__c).CompetitorProduct__c
    //                     && brReferenceMap.get(c.RelatedBrandRelationship__c).Type__c == CommonConstant.BRAND_TYPE_USER ) {
    //                     brMap.get(c.RelatedBrandRelationship__c).Status__c = CommonConstant.BRAND_STATUS_LAPSED;
    //                 }
    //             }
    
    //             //check if previous brand is updated
    //             if(c.PreviousBrandUsed__c != old.PreviousBrandUsed__c){
    //                 if(!brMap.containsKey(c.RelatedBrandRelationship__c)){
    //                     brMap.put(c.RelatedBrandRelationship__c, new BrandRelationship__c(Id = c.RelatedBrandRelationship__c));
    //                 }
    //                 brMap.get(c.RelatedBrandRelationship__c).PreviousBrand__c = c.PreviousBrandUsed__c;
    //             }
    
    //             //check if brand switch reason is updated
    //             if(c.BrandSwitchReason__c != old.BrandSwitchReason__c){
    //                 if(!brMap.containsKey(c.RelatedBrandRelationship__c)){
    //                     brMap.put(c.RelatedBrandRelationship__c, new BrandRelationship__c(Id = c.RelatedBrandRelationship__c));
    //                 }
    //                 brMap.get(c.RelatedBrandRelationship__c).BrandSwitchReason__c = c.BrandSwitchReason__c;
    //             }
    
    //             //check if SKU is updated
    //             if(c.SKU__c != old.SKU__c){
    //                 if(!brMap.containsKey(c.RelatedBrandRelationship__c)){
    //                     brMap.put(c.RelatedBrandRelationship__c, new BrandRelationship__c(Id = c.RelatedBrandRelationship__c));
    //                 }
    //                 brMap.get(c.RelatedBrandRelationship__c).SKU__c = c.SKU__c;
    //             }
    //         }
    //     }
    
    //     if(!brMap.isEmpty()){
    //         update BRMap.values();
    //     }
    // }
    
    /**
* @author           Marlon Ocillos
* @date             2.21.2019
* @description      Method is called to update the First and Last Contact Dates/Lookup when a Call's Call Completed Date is updated
* @revision(s)
* 10-29-19 Jericson - refactored and added populateLatestCallDate inside
May 22, 2020 - moved to change Event
*/
    // public static void updateContactCallDates(List<Case> newList, Map<Id, SObject> oldMapItems) {
    //     Map<Id, Case> conCaseFirstMap = new Map<Id, Case>();
    //     Map<Id, Case> conCaseLastMap = new Map<Id, Case>();
    //     Map<Id, Case> conCaseLastOutcomeMap = new Map<Id, Case>();
    //     Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
    //     Map<Id, List<Case>> recalculateContactMap = new Map<Id, List<Case>>();
    //     Map<Id, List<Case>> caseCancelledMap = new Map<Id, List<Case>>();
    
    //         for(Case caseRec : newList) {
    
    //         Case oldCase = new Case();
    
    //         // populate old map on update transaction
    //         if(Trigger.isUpdate){
    //             oldCase = (Case) oldMapItems.get(caseRec.Id);
    //         }
    
    //         // run only for call cases
    //         if(caseRec.RecordTypeId == callRTId) {
    //             /*
    //             Process only Calls where it has Call Completed Date
    //             is newly inserted OR during update it is changed from null
    //             */
    //             // if(caseRec.CallCompletedDate__c != null
    //             //     &&  oldCase.CallCompletedDate__c == null
    //             //     ) {
    
    //             //     // Put Call Completed Date in a map where the Key is the Contact and the value is the oldest Completed Call
    //             //   if(!conCaseFirstMap.containsKey(caseRec.ContactId)) {
    //             //         conCaseFirstMap.put(caseRec.ContactId, caseRec);
    //             //     } else {
    //             //         Case currentOldestCall = conCaseFirstMap.get(caseRec.ContactId);
    //             //         if(caseRec.CallCompletedDate__c < currentOldestCall.CallCompletedDate__c) {
    //             //             conCaseFirstMap.put(caseRec.ContactId, caseRec);
    //             //         }
    //             //     }
    
    //             //     // Put Call Completed Date in a map where the Key is the Contact and the value is the lates Completed Call
    //             //     if(!conCaseLastMap.containsKey(caseRec.ContactId)) {
    //             //         conCaseLastMap.put(caseRec.ContactId, caseRec);
    //             //     } else {
    //             //         Case currentOldestCall = conCaseLastMap.get(caseRec.ContactId);
    //             //         if(caseRec.CallCompletedDate__c > currentOldestCall.CallCompletedDate__c) {
    //             //             conCaseLastMap.put(caseRec.ContactId, caseRec);
    //             //         }
    //             //     }
    //          // }   
    
    //             // US-0883 first/last call based on created date if not status cancelled
    
    //             if(Trigger.isInsert && caseRec.Status != CommonConstant.CASE_STATUS_CANCELLED
    //                 || (Trigger.isUpdate && caseRec.Status != CommonConstant.CASE_STATUS_ESCALATED && caseRec.Status != oldCase.Status)) {
    
    //                 if(!recalculateContactMap.containsKey(caseRec.ContactId)) {
    //                     recalculateContactMap.put(caseRec.ContactId, new List<Case>());
    //                 }
    //                 recalculateContactMap.get(caseRec.ContactId).add(caseRec);
    //             }
    
    //             if(Trigger.isInsert && caseRec.Status == CommonConstant.CASE_STATUS_CANCELLED
    //                 || (Trigger.isUpdate && caseRec.Status == CommonConstant.CASE_STATUS_CANCELLED && caseRec.Status != oldCase.Status)
    //                 || (Trigger.isDelete && caseRec.Status != CommonConstant.CASE_STATUS_CANCELLED)
    //                 ) {
    //                 if(!caseCancelledMap.containsKey(caseRec.ContactId)) {
    //                     caseCancelledMap.put(caseRec.ContactId, new List<Case>());
    //                 }
    //                 caseCancelledMap.get(caseRec.ContactId).add(caseRec);
    //             }
    
    //             // Put Call Open date once Call outcome has been changed to un/successful
    //             if( (caseRec.CallOutcome__c == 'Successful' || caseRec.CallOutcome__c == 'Unsuccessful') 
    //                     && caseRec.CallOutcome__c != oldCase.CallOutcome__c
    //                 ) {
    //                 if(!conCaseLastOutcomeMap.containsKey(caseRec.ContactId)){
    //                     conCaseLastOutcomeMap.put(caseRec.ContactId, caseRec);
    //                 }
    
    //                 Case currentOldestCall = conCaseLastOutcomeMap.get(caseRec.ContactId);
    //                 if(caseRec.LastModifiedDate > currentOldestCall.LastModifiedDate){
    //                     conCaseLastOutcomeMap.put(caseRec.ContactId, caseRec);
    //                 }
    //             }
    //         }
    //     }
    
    //     Set<Id> conIds = new Set<Id>();
    //     //if(!conCaseFirstMap.isEmpty()) { conIds.addAll(conCaseFirstMap.keySet()); }
    //     //if(!conCaseLastMap.isEmpty()) { conIds.addAll(conCaseLastMap.keySet()); }
    //     if(!conCaseLastOutcomeMap.isEmpty()) { conIds.addAll(conCaseLastOutcomeMap.keySet()); }
    //     if(!recalculateContactMap.isEmpty()) { conIds.addAll(recalculateContactMap.keySet()); }
    //     if(!caseCancelledMap.isEmpty()) { conIds.addAll(caseCancelledMap.keySet()); }
    
    //     if(!conIds.isEmpty()) {
    
    //         // retrieve all related contact that needs updating
    //         for(Contact conRec : [SELECT FirstCallDate__c, FirstCall__c, LastCallDate__c, LatestCall__c, LatestOpenCallDate__c,
    //                                       (SELECT Status, CreatedDate, RecordTypeId
    //                                          FROM Cases
    //                                      ORDER BY CreatedDate)
    //                                 FROM Contact
    //                                WHERE Id IN : conIds]) {
    
    //             // US-0883 first/last call based on created date if not status cancelled
    //             // remove if cancelled
    //             if(!caseCancelledMap.isEmpty()) {
    //                 for(Case c: caseCancelledMap.get(conRec.Id)) {
    //                     if(conRec.FirstCall__c == null
    //                         || conRec.FirstCall__c == c.Id) {
    //                         conRec.FirstCall__c = null;
    //                         conRec.FirstCallDate__c = null;
    //                     }
    //                     if(conRec.LatestCall__c == null
    //                         || conRec.LatestCall__c == c.Id) {
    //                         conRec.LatestCall__c = null;
    //                         conRec.LastCallDate__c = null;
    //                     }
    //                 }
    //             }
    
    //             List<Case> cases = new List<Case>();
    //             cases.addAll(conRec.Cases);
    //             if(recalculateContactMap.containsKey(conRec.Id)) { cases.addAll(recalculateContactMap.get(conRec.Id)); }
    
    //             for(Case c: cases) {
    
    //                 if(c.RecordTypeId == callRTId
    //                     && c.Status != CommonConstant.CASE_STATUS_CANCELLED) {
    
    //                     if(conRec.FirstCall__c == null
    //                         || conRec.FirstCallDate__c > c.CreatedDate) {
    //                         conRec.FirstCallDate__c = c.CreatedDate;
    //                         conRec.FirstCall__c = c.Id;
    //                     }
    //                     if(conRec.LatestCall__c == null
    //                         || conRec.LastCallDate__c < c.CreatedDate) {
    //                         conRec.LastCallDate__c = c.CreatedDate;
    //                     conRec.LatestCall__c = c.Id;
    //                     }
    //                 }
    //             }
    //             contactToUpdateMap.put(conRec.Id, conRec); 
    
    //             // // Process all Contacts where the First Calls needs to be updated
    //             // if(conCaseFirstMap.containsKey(conRec.Id)) {
    //             //     Case c = conCaseFirstMap.get(conRec.Id);
    //             //     if( conRec.FirstCallDate__c == null ||
    //             //         (conRec.FirstCallDate__c != null && c.CallCompletedDate__c < conRec.FirstCallDate__c)
    //             //         ) {
    //             //       conRec.FirstCallDate__c = c.CallCompletedDate__c;
    //             //         conRec.FirstCall__c = c.Id;
    //             //       if(contactToUpdateMap.containsKey(conRec.Id)) {
    //             //             contactToUpdateMap.get(conRec.Id).FirstCallDate__c = conRec.FirstCallDate__c;
    //             //             contactToUpdateMap.get(conRec.Id).FirstCall__c = conRec.FirstCall__c;
    //             //         } else {
    //             //           contactToUpdateMap.put(conRec.Id, conRec);   
    //             //         }
    //             //     }
    //             // }
    
    //             // // Process all Contacts where the Last Calls needs to be updated
    //             // if(conCaseLastMap.containsKey(conRec.Id)) {
    //             //     Case c = conCaseLastMap.get(conRec.Id);
    //             //     if( conRec.LastCallDate__c == null || 
    //             //         (conRec.LastCallDate__c != null && c.CallCompletedDate__c > conRec.LastCallDate__c)
    //             //         ) {
    //             //       conRec.LastCallDate__c = c.CallCompletedDate__c;
    //             //         conRec.LatestCall__c = c.Id;
    //             //       if(contactToUpdateMap.containsKey(conRec.Id)) {
    //             //             contactToUpdateMap.get(conRec.Id).LastCallDate__c = conRec.LastCallDate__c;
    //             //             contactToUpdateMap.get(conRec.Id).LatestCall__c = conRec.LatestCall__c;
    //             //         } else {
    //             //           contactToUpdateMap.put(conRec.Id, conRec);   
    //             //         }
    //             //     }
    //             // }
    
    //             // Process all Contacts where Latest OpenCall date needs to be updated
    //             if(conCaseLastOutcomeMap.containsKey(conRec.Id)){
    //                 Case c = conCaseLastOutcomeMap.get(conRec.Id);
    
    //                 if( conRec.LatestOpenCallDate__c == null || conRec.LatestOpenCallDate__c < c.LastModifiedDate) {
    //                     conRec.LatestOpenCallDate__c = c.LastModifiedDate;
    //                  if(contactToUpdateMap.containsKey(conRec.Id)) {
    //                         contactToUpdateMap.get(conRec.Id).LatestOpenCallDate__c = c.LastModifiedDate;
    //                     } else {
    //                      contactToUpdateMap.put(conRec.Id, conRec);   
    //                     }
    //                 }
    //             }
    //         }
    //     }
    
    //     // Update Contacts
    //     if(!contactToUpdateMap.isEmpty()) {
    //         update contactToUpdateMap.values();
    //     }
    // }
    
    /* US-0620 - jericson - included functionality in updateContactCallDates for trigger enhancement
public static void populateLatestCallDate(List<Case> newList, Map<Id, SObject> oldMapItems) {
List<Case> validCaseList = new List<Case>();
Set<Id> validContactIds = new Set<Id>();
for(Case caseRec : newList) {
if (Trigger.isUpdate) {
Case oldCase = (Case)oldMapItems.get(caseRec.Id);
if (caseRec.CallOutcome__c != oldCase.CallOutcome__c && (caseRec.CallOutcome__c == 'Successful' || caseRec.CallOutcome__c == 'Unsuccessful')) {
validCaseList.add(caseRec);
validContactIds.add(caseRec.ContactId);
}
} else {
if (caseRec.CallOutcome__c == 'Successful' || caseRec.CallOutcome__c == 'Unsuccessful') {
validCaseList.add(caseRec);
validContactIds.add(caseRec.ContactId);
}
}
}

if (!validCaseList.isEmpty()) {
List<Contact> toUpdateContactList = new List<Contact>();

Map<Id, Contact> contactMap = new Map<Id, Contact> ([Select Id,LatestOpenCallDate__c from Contact where Id IN: validContactIds]);
for (Case c : validCaseList) {
Contact con = contactMap.get(c.ContactId);                
if (con != null && (con.LatestOpenCallDate__c == null || con.LatestOpenCallDate__c < c.LastModifiedDate)) {
con.LatestOpenCallDate__c = c.LastModifiedDate;
toUpdateContactList.add(con);
}
}

if (!toUpdateContactList.isEmpty()) {
Update toUpdateContactList;
}
}
}
*/
    
    /*
Moved to main loop
public void populateReminderDate(List<Case> newList, Map<Id, SObject> oldMap) {
Set<String> reminderwithEmailStatus = new Set<String> {'Initial Response','First Reminder','Second Reminder','Pending - Uncontactable'};

for(Case c: newList){
Case old = (Case) oldMap.get(c.Id);
if(c.ReminderStatus__c != old.ReminderStatus__c
&& reminderwithEmailStatus.contains(c.ReminderStatus__c)) {
c.LastReminderSentDate__c = Date.Today();
}
}
}
*/
    // May 22, 2020 moved to Change Event
    // public void checkUncontactable(List<Case> uncontactableCases) {
    
    //     /*
    //     Filter Moved to Main Method
    //     List<Case> uncontactableCases = new List<Case>();
    //     for(Case c: newList){
    //         Case old = (Case) oldMap.get(c.Id);
    //         if(c.ReminderStatus__c == 'Pending - Uncontactable'
    //             && c.ReminderStatus__c != old.ReminderStatus__c) {
    //             uncontactableCases.add(c);
    //         }
    //     }*/
    
    //     //if(!uncontactableCases.isEmpty()) {
    
    //         Set<String> countryEmails = new Set<String>();
    //         Map<String, AffiliateMetadata__mdt>  countryMap = new Map<String, AffiliateMetadata__mdt>();
    //         Map<String, String> countryEmailMap = new Map<String, String>();
    //         for(AffiliateMetadata__mdt country: affiliateMetadataMap.values()) {
    //             countryMap.put(country.MasterLabel, country);
    
    //             if(country.EmailToCaseOrgWideEmailAddress__c != ''){
    //                 countryEmails.add(country.EmailToCaseOrgWideEmailAddress__c);
    //                 countryEmailMap.put(country.EmailToCaseOrgWideEmailAddress__c, country.MasterLabel);
    //             }
    //         }
    
    //         Map<Id, EmailMessage> messageMap = new Map<Id, EmailMessage>();
    //         for(EmailMessage message: [SELECT MessageDate, Subject, HtmlBody, ParentId FROM EmailMessage WHERE Incoming = false AND ParentId IN: uncontactableCases]){
    //             messageMap.put(message.ParentId, message);
    //         }
    
    //         Map<String, OrgWideEmailAddress> orgWideMap = new Map<String, OrgWideEmailAddress>();
    //         for(OrgWideEmailAddress owea :[SELECT Address, DisplayName FROM OrgWideEmailAddress WHERE Address IN: countryEmailMap.keySet()] ) {
    //             orgWideMap.put(countryEmailMap.get(owea.Address), owea);
    //         }
    
    //         List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
    //         EmailTemplate tempTemplate = [SELECT Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'InquiryFeedbackUncontactable_HTML'];
    //         Map<Id, Case> caseMap = new Map<Id, Case>([SELECT SuppliedEmail, Market__c, (SELECT HtmlBody, Subject FROM EmailMessages) FROM Case WHERE Id IN: uncontactableCases]);
    
    //         for(Case c: uncontactableCases){
    
    //             // check if there is an org wide address for the market
    //             if(orgWideMap.containsKey(c.Market__c)) {
    //                 String sub = Test.isRunningTest() ? 'test subject' : caseMap.get(c.Id).EmailMessages[0].Subject;
    //                 String bod = Test.isRunningTest() ? 'test subject' : tempTemplate.HtmlValue  + '\n\n' + caseMap.get(c.Id).EmailMessages[0].HtmlBody;
    
    //                 // add email
    //                 Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    //                 message.toAddresses = new String[] { c.SuppliedEmail };
    //                 message.setWhatId(c.Id);
    //                 message.setSubject(sub);
    //                 message.setHtmlBody(bod);
    //                 message.setOrgWideEmailAddressId(orgWideMap.get(c.Market__c).Id);
    //                 message.saveAsActivity = true;
    //                 messages.add(message);
    //             }
    //         }
    
    //         if(!messages.isEmpty()) {
    //             Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    //         }
    //     //}
    // }
}