/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Helper class for Contact object
                  - Get map of Account related to the contacts from ContactHandler
History
01/09/2019   vmirandilla   Created
02/08/2019   raustral - Added checkMultiplePrimary and checkMultiplePrimary method
02/11/2019   raustral - Added household history condition in the updateTrackingFields method
02/26/2019   malviz - Added calculateCountOnContact and calculateCountOnAccount method
03/08/2019   vmirandilla - Added enableMilkRestrictionCode method
04/12/2019   mocillos - Added fetchMarketFromHousehold method
11/06/2019   jermercado - deleted methods calculateTrackingFields, updateTrackingFields, updateHouseholdPrimaryContact, calculateCountOnContact, calculateCountOnAccount
                          and consolidated all account/contact/address update on calculateTrackingFields2 method
May.22.2020 jmercado - code clean up. moved all commented methods below, moved functionality to ContactEventHandler
Jan.21.2021  emontesa - added checkMCEligibility
Sept.30.2021  mparihar - added logic for TW Market

10/28/2021  navalencia - added "TW - child" logic in checkMCEligibility method 
11/19/2021  navalencia - added updateParentEdd function. 
11/24/2021  navalencia - update updateParentEdd logic.
-------------------------------------------------------------------------------------------*/

public class ContactTriggerHelper {

    public static void checkMultiplePrimary(List<Contact> contactList, Map<Id, sObject> oldContactMap) {
        List<Contact> primaryContactList = new List<Contact>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Contact con : contactList) { 
            
            Boolean oldValue = false;
            if (Trigger.isUpdate && oldContactMap.containsKey(con.Id)) {
                Contact oldCon = (Contact) oldContactMap.get(con.Id);
                oldValue = oldCon.PrimaryContact__c;
            }

            if( (Trigger.IsInsert && con.PrimaryContact__c == true && con.AccountId != null) ||
                (Trigger.isUpdate && con.PrimaryContact__c == true && con.PrimaryContact__c != oldValue) ) {
                accIdSet.add(con.AccountId);
                contactIds.add(con.Id);
                primaryContactList.add(con);
            }
        }

        // US-0620: improve trigger efficiency, do not run if not needed
        if(!accIdSet.isEmpty()){
            Map<Id,Account> accMap = new Map<Id,Account>([Select (SELECT Id FROM Contacts
                                                                   WHERE PrimaryContact__c = true
                                                                     AND Id NOT IN: contactIds)
                                                                FROM Account 
                                                                WHERE Id IN :accIdSet]);
            for (Contact con : primaryContactList) {
                if (accMap.containsKey(con.AccountId)) {
                    Account acc = accMap.get(con.AccountId);
                    if(!acc.Contacts.isEmpty()) {
                        System.debug('Error');
                        con.addError('There is already a primary contact');
                    }
                }
            }
        }
    }

    public static void preventDeletion(List<Contact> oldContactList) {        
        Set<Contact> invalidContact = new Set<Contact>();
        Id userId = UserInfo.getProfileId();
        
        for (Contact con : oldContactList) {
            //prevent any deleting of record in the contact aside when a merge happen
            //when there is a value of masterrecordid it means that the record has been merge to another account
            if (con.MasterRecordId  == null)                
                invalidContact.add(con);
        }
        if (!invalidContact.isEmpty()) {
            String profileName;
            List<PermissionSetAssignment> permissionSetList =  [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND 
                                                                (PermissionSet.Name =: CommonConstant.PERMISSIONSET_SGADDITIONAL OR PermissionSet.Name =: CommonConstant.PERMISSIONSET_MYADDITIONAL)];
            for (Profile pName : [Select Name from Profile where Id =: userId]) {
                profileName = pName.Name;
            }
            if (profileName != CommonConstant.PROFILE_ADMIN && permissionSetList.size() == 0) {
                for (Contact con : invalidContact) {                
                    con.addError('You have no access to delete this record');
                }
            }
        }
    }

    //method that will update milk restriction code to TRUE
    public static void enableMilkRestrictionCode(List<Contact> contactList){
        List<Contact> contactToUpdate = New List<Contact>();
        List<AffiliateMetadata__mdt> amList = [SELECT MasterLabel, MilkCodeRestrictionPeriod__c FROM AffiliateMetadata__mdt];
        Map<String, String> acs = UtilityClass.convertObjToMap(amList, CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_MILKRESTRICTION);
        
        for(Contact con : contactList) {
            if(con.Type__c  == CommonConstant.CONTACT_CHILD_TYPE && con.Birthdate != null) {
                if(acs.containsKey(con.Market__c)) {
                    String settings = acs.get(con.Market__c);
                    Date computedDate = con.Birthdate.addMonths(Integer.valueOf(settings));

                    // US-0620: improve trigger efficiency, change 2 ifs to else if since it is one way or the other
                    if (Date.Today() >= con.Birthdate && Date.Today() <= computedDate) {
                        con.MilkCodeRestriction__c = true;
                    } else if (Date.today() > computedDate) {
                        con.MilkCodeRestriction__c = false;
                    }   
                }
            }
        }
    }
    
    /* Method to fetch the market from household to trigger the duplicate rule for contact with same phone 
    in the same Market*/
    public static void fetchMarketFromHousehold(List<Contact> newList, Map<Id, SObject> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        List<Contact> consWithHousehold = new List<Contact>();
        List<Contact> consToProcess = new List<Contact>();
        
        if(oldMap != null) {
            for(Contact conRec : newList) {
                Contact oldCon = (Contact)oldMap.get(conRec.Id);
                if(oldCon.MarketForDuplicate__c == null || oldCon.MarketForDuplicate__c == '') {
                    consToProcess.add(conRec);
                }
            }
        } else {
            consToProcess = newList;
        }
        
        for(Contact conRec : consToProcess) {
            if(conRec.AccountId != null) {
                accountIds.add(conRec.AccountId);
                consWithHousehold.add(conRec);
            }
        }
        
        if(!accountIds.isEmpty()) {
            Map<Id, Account> accountMap = new Map<Id, Account>([select Id, Market__c from Account where Id in :accountIds]);
            
            for(Contact conRec : consWithHousehold) {
                if(accountMap.get(conRec.AccountId).Market__c != null && accountMap.get(conRec.AccountId).Market__c != '') {
                    conRec.MarketForDuplicate__c = accountMap.get(conRec.AccountId).Market__c;   
                }
            }
        }
    }
    
    // Method to populate age range of child contacts on update
    public static void populateAgeRangeOnUpdate(List<Contact> newList, Map<Id, SObject> oldMap) {
        Id childRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Child').getRecordTypeId();
        
        List<Contact> filteredContactsToUpdate = new List<Contact>();
        for(Contact conRec : newList) {
            if(conRec.RecordTypeId == childRTId) {
                Contact oldConRec = (Contact)oldMap.get(conRec.Id);
                if(conRec.AgeRange__c != oldConRec.AgeRange__c && conRec.AgeRangeUpdatedDate__c == null && conRec.Birthdate == null) {
                    filteredContactsToUpdate.add(conRec);
                } else if(conRec.Birthdate != oldConRec.Birthdate) {
                    filteredContactsToUpdate.add(conRec);
                }
            }
        }
        
        if(!filteredContactsToUpdate.isEmpty()) {
            populateAgeRange(filteredContactsToUpdate);
        }
    }
    
    // Method to populate age range of child contacts based on birthdate
    public static void populateAgeRange(List<Contact> newList) {
        Id childRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Child').getRecordTypeId();
        
        for(Contact conRec : newList) {
            if(conRec.RecordTypeId == childRTId) {
                if(conRec.Birthdate != null) {
                    Integer ageInMonths = conRec.Birthdate.monthsBetween(System.today());
                    if(ageInMonths >= 0 && ageInMonths < 6) {
                        conRec.AgeRange__c = '0-6 Months';
                    } else if(ageInMonths >= 6 && ageInMonths < 12) {
                        conRec.AgeRange__c = '6-12 Months';
                    } else if(ageInMonths >= 12 && ageInMonths < 24) {
                        conRec.AgeRange__c = '1-2 Years';
                    } else if(ageInMonths >= 24 && ageInMonths < 36) {
                        conRec.AgeRange__c = '2-3 Years';
                    } else if(ageInMonths >= 36 && ageInMonths < 48) {
                        conRec.AgeRange__c = '3-4 Years';
                    } else if(ageInMonths >= 48 && ageInMonths < 60) {
                        conRec.AgeRange__c = '4-5 Years';
                    } else if(ageInMonths >= 60 && ageInMonths < 72) {
                        conRec.AgeRange__c = '5-6 Years';
                    } else if(ageInMonths >= 72) {
                        conRec.AgeRange__c = '6 Years and Above';
                    }
                } else if(conRec.AgeRange__c != null) {
                    Integer ageInMonths = 0;
                    if(conRec.AgeRange__c == '0-6 Months') {
                        ageInMonths = 0;
                    } else if(conRec.AgeRange__c == '6-12 Months') {
                        ageInMonths = 6;
                    } else if(conRec.AgeRange__c == '1-2 Years') {
                        ageInMonths = 12;
                    } else if(conRec.AgeRange__c == '2-3 Years') {
                        ageInMonths = 24;
                    } else if(conRec.AgeRange__c == '3-4 Years') {
                        ageInMonths = 36;
                    } else if(conRec.AgeRange__c == '4-5 Years') {
                        ageInMonths = 48;
                    } else if(conRec.AgeRange__c == '5-6 Years') {
                        ageInMonths = 60;
                    } else if(conRec.AgeRange__c == '6 Years and Above') {
                        ageInMonths = 72;
                    }
                    
                    if(ageInMonths > 0) {
                        conRec.AgeRangeUpdatedDate__c = System.today().addMonths(-ageInMonths); 
                    }
                }
            }
        }
    }

    // now works only for delete
    public static void calculaterackingFields2(List<Contact> conList, Map<Id, SObject> oldMap){
        Set<Id> accIds = new Set<Id>();
        List<Contact> addressUpdate = new List<Contact>();

        for(Contact con: conList){
            Contact old = new Contact();

            if(oldMap != null){
                old = (Contact) oldMap.get(con.Id);
            }   
            accIds.add(con.AccountId);
        }

        accIds.remove(null);

        if(!accIds.isEmpty()){ updateAccountTrackingFields(accIds); }
        if(!addressUpdate.isEmpty()){ updateAddress(addressUpdate); }
    }

    private static void updateAccountTrackingFields(Set<Id> accountIds){
        List<Account> accountList = new List<Account>();
        for(Account a: [SELECT NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, NumberOfAdults__c, NumberOfChildren__c, ChildrenUnderMilkCodeRestriction__c,
                               PrimaryContact__c, PrimaryContactEmail__c, PrimaryContactPhone__c,
                               (SELECT Name, Email, Phone, PrimaryContact__c, Type__c, MilkCodeRestriction__c, HouseHoldHistoryId__c
                                  FROM Contacts)
                          FROM Account
                         WHERE Id IN: accountIds]) {

            // set original value of the tracked fields here
            Integer NumberOfHouseholdMembers = (Integer) a.NumberOfHouseholdMembers__c;
            Integer NumberOfPrimaryContacts = (Integer) a.NumberOfPrimaryContacts__c;
            Integer NumberOfAdults = (Integer) a.NumberOfAdults__c;
            Integer NumberOfChildren = (Integer) a.NumberOfChildren__c;
            Integer ChildrenUnderMilkCodeRestriction = (Integer) a.ChildrenUnderMilkCodeRestriction__c;
            String PrimaryContact = a.PrimaryContact__c;
            String PrimaryContactEmail = a.PrimaryContactEmail__c;
            String PrimaryContactPhone = a.PrimaryContactPhone__c;

            a.NumberOfHouseholdMembers__c = 0;
            a.NumberOfPrimaryContacts__c = 0;
            a.NumberOfAdults__c = 0;
            a.NumberOfChildren__c = 0;
            a.ChildrenUnderMilkCodeRestriction__c = 0;
            a.PrimaryContact__c = '';
            a.PrimaryContactEmail__c = '';
            a.PrimaryContactPhone__c = '';

            // Do calculation of child contacts
            for(Contact c: a.Contacts){
                
                // add member
                a.NumberOfHouseholdMembers__c++;

                // add primary contact
                if(c.PrimaryContact__c){
                    a.NumberOfPrimaryContacts__c++;
                    a.PrimaryContact__c = c.Name;
                    a.PrimaryContactEmail__c = c.Email;
                    a.PrimaryContactPhone__c = c.Phone;
                }
                
                // add adult
                if(c.Type__c == CommonConstant.CONTACT_ADULT_TYPE){
                    a.NumberOfAdults__c++;
                }

                // add child
                if(c.Type__c == CommonConstant.CONTACT_CHILD_TYPE){
                    a.NumberOfChildren__c++;
                }

                // add child with milk restriction
                if(c.MilkCodeRestriction__c){
                    a.ChildrenUnderMilkCodeRestriction__c++;
                }
            }

            // see if there is any changes
            if(NumberOfHouseholdMembers != a.NumberOfHouseholdMembers__c
                || NumberOfPrimaryContacts != a.NumberOfPrimaryContacts__c
                || NumberOfChildren != a.NumberOfChildren__c
                || ChildrenUnderMilkCodeRestriction != a.ChildrenUnderMilkCodeRestriction__c
                || PrimaryContact != a.PrimaryContact__c
                || PrimaryContactEmail != a.PrimaryContactEmail__c
                || PrimaryContactPhone != a.PrimaryContactPhone__c) {
                accountList.add(a);
            }
        }
        
        // Do an update if there is any
        if(!accountList.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            Database.update(accountList, dml); 
        }
    }

    private static void updateAddress(List<Contact> contactList){
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
        List<Address__c> addressList = new List<Address__c>();

        for(Address__c ad: [SELECT Id, ParentContact__c, ParentHousehold__c FROM Address__c WHERE ParentContact__c IN :contactList]){
            ad.ParentHousehold__c = contactMap.get(ad.ParentContact__c).AccountId;
            addressList.add(ad);
        }

        if(!addressList.isEmpty()){
            Database.update(addressList, false);
        }
    }
    
    /*
    Author: Ezzel Montesa
    Description: checks the eligibility fields of the Contact records
    Date: Jan.21.2021
    */
    public static void checkMCEligibility(List<Contact> contactList){
        
        /* TKT-014200 - Remove VN Child Contact Sync Logic
        Set<Id> vnParentIds = new Set<Id>();
        for(Contact con : contactList){
            if(con.Market__c == CommonConstant.MARKET_VN && con.Type__c == CommonConstant.CONTACT_CHILD_TYPE){
                if(con.Parent__c != null){
                    vnParentIds.add(con.Parent__c);
                }
            }
        }

        Map<Id,Contact> vnParentMap = new Map<Id, Contact>([SELECT Id,MC_Sync_Eligibility_VN__c FROM Contact WHERE Id IN :vnParentIds]);
        */

        for(Contact con : contactList){
            Boolean checker = false;
            if(con.Active__c){ //checks if Contact is Active
                if((con.Phone <> null || con.Email <> null) && con.Market__c != CommonConstant.MARKET_TW){ //checks if contact has phone or email
                    checker = true;
                }
                //added check for TW Market by Monika
                if((con.Phone <> null || con.Email <> null || con.LineUIDAdult__c<> null || con.LineUIDPediatric__c <> null) && con.Market__c == CommonConstant.MARKET_TW && !con.LineOptOut__c){ 
                    checker = true;
                }
            }
            
            if(checker){
                if(con.Market__c == CommonConstant.MARKET_ANZ){
                    con.MC_Sync_Eligibility_ANZ__c = true;
                }else if(con.Market__c == CommonConstant.MARKET_ID){
                    con.MC_Sync_Eligibility_ID__c = true;
                }else if(con.Market__c == CommonConstant.MARKET_IN){
                    con.MC_Sync_Eligibility_IN__c = true;
                }else if(con.Market__c == CommonConstant.MARKET_MY){
                    con.MC_Sync_Eligibility_MY__c = true;
                }else if(con.Market__c == CommonConstant.MARKET_PH){
                    con.MC_Sync_Eligibility_PH__c = true;
                }else if(con.Market__c == CommonConstant.MARKET_SG){
                    con.MC_Sync_Eligibility_SG__c = true;
                }else if(con.Market__c == CommonConstant.MARKET_TH){
                    con.MC_Sync_Eligibility_TH__c = true;
                }else if(con.Market__c == CommonConstant.MARKET_VN){
                    con.MC_Sync_Eligibility_VN__c = true;
                }else if(con.Market__c == CommonConstant.MARKET_TW){  //added check for TW Market by Monika
                    con.MC_Sync_Eligibility_TW__c = true;
                }
            }

            // VN Only : Update child contact mc filter based on parent
            /* TKT-014200 - Remove VN Child Contact Sync Logic
            if(con.Market__c == CommonConstant.MARKET_VN && con.Type__c == CommonConstant.CONTACT_CHILD_TYPE){
                if(con.Parent__c != null && vnParentMap.containsKey(con.Parent__c)){
                    con.MC_Sync_Eligibility_VN__c = vnParentMap.get(con.Parent__c).MC_Sync_Eligibility_VN__c;
                }
                
            }
            */

            /* 
               added by Narence Valencia 
               TW Only : All Child records for TW MC SYNC should be marked as true upon creation
            */
            else if(con.Market__c == CommonConstant.MARKET_TW && con.Type__c == CommonConstant.CONTACT_CHILD_TYPE){ 
                con.MC_Sync_Eligibility_TW__c = true;
            }
        }
    }

    /*
    Author: Jericson Mercado
    Description: prepopulates contact
    */
    public static void prepopulateContact(List<Contact> conList, Map<Id, sObject> conMap){
        Id childRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Child').getRecordTypeId();
        Id adultRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Adult').getRecordTypeId();
        Set<Id> institutionIdSet = new Set<Id>();
        Map<Id, Id> relatedHospitalMap = new Map<Id, Id>();
        
        for(Contact con: (List<Contact>) conList) {
            if(con.AfterBirthCareCenter__c != null) {
                institutionIdSet.add(con.AfterBirthCareCenter__c);
            }
            if(con.BirthHospital__c != null) {
                institutionIdSet.add(con.BirthHospital__c);
            }

            
        }
        
        if(!institutionIdSet.isEmpty()) {
            for(RelatedHospital__c cr: [SELECT Id, AbbottPartner__c, Institution__c
                                    FROM RelatedHospital__c 
                                    WHERE Institution__c IN: institutionIdSet
                                    ORDER By CreatedDate]) {  

                if(!relatedHospitalMap.containsKey(cr.Institution__c)){
                    relatedHospitalMap.put(cr.Institution__c, cr.AbbottPartner__c);                 
                }
            }
        }
        
        for(Contact c: (List<Contact>) conList) {
            Contact old = new Contact();

            if(Trigger.isUpdate) old = (Contact) conMap.get(c.Id);

            // has data
            if(c.Phone != null){
                if( Trigger.isInsert || ( Trigger.isUpdate && c.Phone != old.Phone ) ) {
                    c.Phone_Hashed__c = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(c.Phone)));
                }
            } else {
                c.Phone_Hashed__c = '';
            }
            if(c.Email != null) {
                if( Trigger.isInsert || ( Trigger.isUpdate && c.Phone != old.Phone ) ) {
                    c.Email_Hashed__c = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(c.Email)));
                }
            } else {
                c.Email_Hashed__c = '';
            }

            // Initial Estimated Due Date
            if(c.EstimatedDueDate__c != null
                && ( c.Initial_Estimated_Due_Date_IEDD__c == null
                    || (c.Initial_Estimated_Due_Date_IEDD__c != null && c.EstimatedDueDate__c > c.Initial_Estimated_Due_Date_IEDD__c.addDays(280)) )
                ) {
                c.Initial_Estimated_Due_Date_IEDD__c = c.EstimatedDueDate__c;
            }

            // nullify birthday if @future
            if(c.Birthdate != null && c.Birthdate > Date.Today())
                //c.Birthdate = null;
            
            // Assign Service Sales Person
            if(c.AfterBirthCareCenter__c != null && c.RecordTypeId == adultRTId) {
                if((Trigger.isInsert || (Trigger.isUpdate && c.AfterBirthCareCenter__c != old.AfterBirthCareCenter__c)) && !relatedHospitalMap.isEmpty()) {
                    c.ServiceSalesPerson__c = relatedHospitalMap.get(c.AfterBirthCareCenter__c);
                }
            } else if (c.BirthHospital__c != null && c.RecordTypeId == childRTId) {
                if((Trigger.isInsert || (Trigger.isUpdate && c.BirthHospital__c != old.BirthHospital__c)) && !relatedHospitalMap.isEmpty()) {
                    c.ServiceSalesPerson__c = relatedHospitalMap.get(c.BirthHospital__c);
                }
            }
            
        }
    }
    
    public static void appendDescription(List<Contact> conList, Map<Id, sObject> conMap){
        for(Contact c : conList){
            Contact oldCon = (Contact) conMap.get(c.Id);
            if(Trigger.isUpdate && String.isNotBlank(c.Integration_Src__c) && c.Integration_Src__c == 'TW_MANUAL' && 
               String.isNotBlank(c.Description) && String.isNotBlank(oldCon.Description) && c.Description != oldCon.Description)
            {
                if(oldCon.Description.contains('//')){
                    List<String> oldConDescriptionSplit = oldCon.Description.split('//');
                    String oldConStringToCompare = oldConDescriptionSplit[oldConDescriptionSplit.size()-1].trim();
                    if(oldConStringToCompare != c.Description){
                        String appendedDesc = oldCon.Description + ' // ' + c.Description;
                        if(appendedDesc.length() <= 32000){
                            c.Description = appendedDesc; 
                        }
                        else{
                            c.Description.addError('Description field is limited to only 32000 characters.');
                        }
                    } else{
                        c.Description = oldCon.Description;
                    }
                } else {
                    String appendedDesc = oldCon.Description + ' // ' + c.Description;
                    if(appendedDesc.length() <= 32000){
                        c.Description = appendedDesc; 
                    }
                    else{
                        c.Description.addError('Description field is limited to only 32000 characters.');
                    }
                }
                
                   
            }
        }
    }
    /*====================================================================================
    Method Name: createChildContactTW
    Author Name: Monika Parihar
    Description: This method creates child contact when EDD is updated from blank to value on mother record
    Parameters: List<Contact> contactList
    ======================================================================================*/
    public static void createChildContactTW(List<Contact> contactList) {
        Id childRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_CHILD_RECORDTYPE).getRecordTypeId();
        List<Contact> listContactInsert = new List<Contact>();
        for(Contact con : contactList){
            Contact childContact = createChild(con, childRecordTypeId);
            listContactInsert.add(childContact);
        }
        if(!listContactInsert.isEmpty()){
            insert listContactInsert;
        }
     
    }
    /*====================================================================================
    Method Name: createChild
    Author Name: Monika Parihar
    Description: This method is called from createChildContactTW and create child record
    Parameters: Contact con, String childRecordTypeId
    ======================================================================================*/
    public static Contact createChild(Contact con, String childRecordTypeId) {
        Contact childContact = new Contact();
        childContact.AccountId = con.AccountId;
        childContact.Birthdate = con.EstimatedDueDate__c;
        childContact.LastName = '('+CommonConstant.CONTACT_CHILD_TYPE +')'+' '+con.LastName;
        childContact.Type__c = CommonConstant.CONTACT_CHILD_TYPE;
        childContact.RecordTypeId = childRecordTypeId;
        childContact.Parent__c = con.Id;
        childContact.MilkCodeRestriction__c = true;
        childContact.EstimatedBirthdate__c = con.EstimatedDueDate__c;
        childContact.OwnerId = con.OwnerId;

        return childContact;
    }
    /*====================================================================================
    Method Name: updateChildContactDOBTW
    Author Name: Monika Parihar
    Description: This method update DOB of child contact when EDD is updated on Mother contact
    Parameters: List<Contact> contactList
    ======================================================================================*/
    public static void updateChildContactDOBTW(Set<Id> setContactId) {
       List<Contact> conList = [Select Id,EstimatedDueDate__c,(Select id from Parents__r order by createdDate DESC  Limit 1 ) from Contact where id in : setContactId ];
       List<Contact> updateContactList = new  List<Contact>();
       
           for(Contact motherCon : conList){
               if(motherCon.Parents__r!=null){
                   for(Contact con : motherCon.Parents__r){
                       if(motherCon.EstimatedDueDate__c != null) {
                           con.Birthdate =  motherCon.EstimatedDueDate__c;
                       }   
                       updateContactList.add(con);
                   }
               }
           }
          
       if(!updateContactList.isEmpty()){
           update updateContactList;
       }
    }

    /*====================================================================================
    Method Name: updateParentEdd
    Author Name: Narence Valencia
    Description: This method update EDD of parents
    ======================================================================================*/
    public static void updateParentEdd( Map<Id, SObject> oldContactMap, List<Contact> contactList) {
        
        Set<Id> conIds = new Set<Id>();
        for(Contact conRecord : contactList){
            conIds.add(conRecord.Parent__c);
        }
        List<Contact> conList = [Select Id,EstimatedDueDate__c,EDDCertificateStatus__c from Contact where Id IN :conIds];
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact c : conList){
            contactMap.put(c.Id, c);
        }

        List<Contact> updateParentContactList = new  List<Contact>();

        if(Trigger.isUpdate){
            for(Contact con : contactList){
                Contact oldCon = (Contact)oldContactMap.get(con.Id);
                 
                if(con.Birthdate != oldCon.Birthdate ){
                    if(con.Market__c == CommonConstant.MARKET_TW && con.Type__c == CommonConstant.CONTACT_CHILD_TYPE){
                        if(contactMap.containsKey(con.Parent__c) && !contactMap.get(con.Parent__c).EDDCertificateStatus__c) {
                            contactMap.get(con.Parent__c).EstimatedDueDate__c = con.Birthdate;
                            updateParentContactList.add(contactMap.get(con.Parent__c));
                        }
                    }
                }
            }
            if(!updateParentContactList.isEmpty()){
                update updateParentContactList;
            }
        }

        if(Trigger.isInsert){
            for(Contact con : contactList){
                if(con.Market__c == CommonConstant.MARKET_TW && con.Type__c == CommonConstant.CONTACT_CHILD_TYPE){
                    if(contactMap.containsKey(con.Parent__c) && !contactMap.get(con.Parent__c).EDDCertificateStatus__c) {
                        if(contactMap.get(con.Parent__c).EstimatedDueDate__c == null){
                            contactMap.get(con.Parent__c).EstimatedDueDate__c = con.Birthdate;
                            updateParentContactList.add(contactMap.get(con.Parent__c));
                        }
                    }
                }
            }
            if(!updateParentContactList.isEmpty()){
                update updateParentContactList;
            }
        }
    }

    /*====================================================================================
    Method Name: resetEmailBounced
    Author Name: Frank Gomendoza
    Description: Reset Email Bounced field when Email is changed
    ======================================================================================*/
    public static void resetEmailBounced( List<Contact> contactList, Map<Id, SObject> oldContactMap ) {
        for(Contact con : contactList){
            if(con.EmailBounced__c){
                Contact oldCon = (Contact) oldContactMap.get(con.Id);
                if(con.Email != oldCon.Email){
                    con.EmailBounced__c = false;
                }
            }
        }
    }

    /* This method will handle the incremental or decremental changes of Contact's Household tracking fields 
    * during Contact creation and deletion.
    public static void calculateTrackingFields(List<Contact> contactList, Boolean isNew) {
        Map<Id,Account> accMap = getAccountIds(contactList);
        set<ID> accountIdSet=new set<ID>();
        set<ID> contactIdSet=new set<ID>();
        List<Account> accountList = new List<Account>();

        for(Contact con : contactList) {

            if(accMap.containsKey(con.AccountId)) {
                accMap.get(con.AccountId).NumberOfHouseholdMembers__c = accMap.get(con.AccountId).NumberOfHouseholdMembers__c == null ? 0 : accMap.get(con.AccountId).NumberOfHouseholdMembers__c;
                accMap.get(con.AccountId).NumberOfPrimaryContacts__c = accMap.get(con.AccountId).NumberOfPrimaryContacts__c == null ? 0 : accMap.get(con.AccountId).NumberOfPrimaryContacts__c;
                accMap.get(con.AccountId).NumberOfAdults__c = accMap.get(con.AccountId).NumberOfAdults__c == null ? 0 : accMap.get(con.AccountId).NumberOfAdults__c;
                accMap.get(con.AccountId).NumberOfChildren__c = accMap.get(con.AccountId).NumberOfChildren__c == null ? 0 : accMap.get(con.AccountId).NumberOfChildren__c;
                accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c = accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c == null ? 0 : accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c;                
                
                if(con.PrimaryContact__c == TRUE) {
                    if(isNew) {
                        accMap.get(con.AccountId).NumberOfPrimaryContacts__c++;
                    } else {
                        accMap.get(con.AccountId).NumberOfPrimaryContacts__c--;

                        Account acc = new Account();
                        acc.Id = con.AccountId;
                        acc.PrimaryContact__c = null;
                        acc.PrimaryContactEmail__c = null;
                        acc.PrimaryContactPhone__c = null;                
                        accountList.add(acc);
                    }
                }   
                
                if(con.Type__c == 'Adult') {
                    if(isNew) {
                        accMap.get(con.AccountId).NumberOfAdults__c++;
                    } else {
                        accMap.get(con.AccountId).NumberOfAdults__c--;
                    }

                }
                
                else if(con.Type__c == 'Child') {
                    if(isNew) {
                        accMap.get(con.AccountId).NumberOfChildren__c++;
                    } else {
                        accMap.get(con.AccountId).NumberOfChildren__c--;
                    }

                    if(isNew && con.MilkCodeRestriction__c == true) {
                        accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c++;
                    } else if(!isNew && con.MilkCodeRestriction__c == true){
                        accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c--;
                    }
                }
                
                if(isNew) {
                    accMap.get(con.AccountId).NumberOfHouseholdMembers__c++;
                } else {
                    accMap.get(con.AccountId).NumberOfHouseholdMembers__c--;
                }
                       
            }
            
 
            //if(con.AccountId!=null){
            //        accountIdSet.add(con.AccountId);
            //}
            
            if(con.Parent__c!=null && con.MilkCodeRestriction__c == true){
                contactIdSet.add(con.Parent__c);
            }
        }

        update accMap.values();
       
        //if(!accountIdSet.isEmpty()){
        //    calculateCountOnAccount(accountIdSet);
        //}
        
        if(!contactIdSet.isEmpty()){
            calculateCountOnContact(contactIdSet);
        }

        if(!accountList.isEmpty()) {
            update accountList;
        }
    }

    /* This method will handle the incremental or decremental changes of Contact's Household tracking fields during Contact update.
    public static void updateTrackingFields(Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {
        Map<Id,Account> accMap = getAccountIds(newMap.values());
        set<ID> accountIdSet=new set<ID>();
        set<ID> contactIdSet=new set<ID>();
        set<ID> contactIdOLdSet=new set<ID>();
        List<Account> toUpdateAccountList = new List<Account>();

        for(Contact con : (List<Contact>)newMap.values()) {
            Boolean accountHasChanges = false;
            if(accMap.containsKey(con.AccountId)) {    

                accMap.get(con.AccountId).NumberOfHouseholdMembers__c = accMap.get(con.AccountId).NumberOfHouseholdMembers__c == null ? 0 : accMap.get(con.AccountId).NumberOfHouseholdMembers__c;
                accMap.get(con.AccountId).NumberOfPrimaryContacts__c = accMap.get(con.AccountId).NumberOfPrimaryContacts__c == null ? 0 : accMap.get(con.AccountId).NumberOfPrimaryContacts__c;
                accMap.get(con.AccountId).NumberOfAdults__c = accMap.get(con.AccountId).NumberOfAdults__c == null ? 0 : accMap.get(con.AccountId).NumberOfAdults__c;
                accMap.get(con.AccountId).NumberOfChildren__c = accMap.get(con.AccountId).NumberOfChildren__c == null ? 0 : accMap.get(con.AccountId).NumberOfChildren__c;           
                Contact oldRecord = (Contact) oldMap.get(con.Id);                
                
                if(con.PrimaryContact__c != oldRecord.PrimaryContact__c  ) { 
                    //02.11.2019   raustral 
                    //prevent changing of primary contact when merge happen
                    //add '&& oldRecord.HouseHoldHistoryId__c == con.AccountId'
                    if(con.PrimaryContact__c == FALSE && oldRecord.HouseHoldHistoryId__c == con.AccountId) {
                        accMap.get(con.AccountId).NumberOfPrimaryContacts__c--;
                        accountHasChanges = true;
                    } else if(con.PrimaryContact__c == TRUE){
                        accMap.get(con.AccountId).NumberOfPrimaryContacts__c++;
                        accountHasChanges = true;
                    }
                }
                
                if(con.Type__c != oldRecord.Type__c) {
                    if(con.Type__c == 'Adult') {
                        accMap.get(con.AccountId).NumberOfAdults__c++;

                        if(oldRecord.Type__c == 'Child') {
                            accMap.get(con.AccountId).NumberOfChildren__c--;
                        }

                        accountHasChanges = true;
                    } 

                    else if(con.Type__c == 'Child') {
                        accMap.get(con.AccountId).NumberOfChildren__c++;

                        if(oldRecord.Type__c == 'Adult') {
                            accMap.get(con.AccountId).NumberOfAdults__c--;
                        }

                        accountHasChanges = true;
                    }

                    else {
                        if(oldRecord.Type__c == 'Adult') {
                            accMap.get(con.AccountId).NumberOfAdults__c--;
                            accountHasChanges = true;
                        }
                        else if(oldRecord.Type__c == 'Child') {
                            accMap.get(con.AccountId).NumberOfChildren__c--;
                            accountHasChanges = true;
                        }
                    }
                }
                
                //02.28.2019 malviz
                //count Children with Milk Code Restriction on Account when a contact's Parent Household or MilkCodeRestriction__c is changed 
                if(con.AccountId !=null ){
                    if(con.AccountId!=oldRecord.AccountId){
                        accountIdSet.add(con.AccountId);
                        accountIdSet.add(oldRecord.AccountId);
                    }else if(con.MilkCodeRestriction__c != oldRecord.MilkCodeRestriction__c){
                        accountIdSet.add(con.AccountId);
                    }
                }

                //02.11.2019   raustral 
                //used for duplicate management when the household has been merge, update the latest house hold details                
                if(con.HouseHoldHistoryId__c != oldRecord.HouseHoldHistoryId__c && con.HouseHoldHistoryId__c == con.AccountId && String.isNotEmpty(oldRecord.HouseHoldHistoryId__c)) {
                    if(con.Type__c == 'Adult') {
                        accMap.get(con.AccountId).NumberOfAdults__c++;
                    } else {
                        accMap.get(con.AccountId).NumberOfChildren__c++;
                    }
                    accMap.get(con.AccountId).NumberOfHouseholdMembers__c++;   
                    accountHasChanges = true;    
                    //primary contact from the old houshold will be set to false            
                }
            }
            
            //02.28.2019 malviz
            //count Children with Milk Code Restriction on Contact when a Child's MilkCodeRestriction__c is changed
            Contact oldRecord = (Contact) oldMap.get(con.Id);
            if(con.Parent__c!=null){
                if(con.MilkCodeRestriction__c != oldRecord.MilkCodeRestriction__c){
                    contactIdSet.add(con.Parent__c);
                }
            }

            if(accountHasChanges) {
                toUpdateAccountList.add( accMap.get(con.AccountId) );
            }
                    
            
        }           
        //update accMap.values();

        //04.04.2019   raustral 
        //change from normaul up to database update
        //by pass the error for duplicate management system
        if (!toUpdateAccountList.isEmpty()) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(accMap.values(), dml); 
        }
        
        
        //02.28.2019 malviz
        if(!accountIdSet.isEmpty()){
            calculateCountOnAccount(accountIdSet);
        }
        
        if(!contactIdSet.isEmpty()){
            calculateCountOnContact(contactIdSet);
        }
        
    }

    public static Map<Id,Account> getAccountIds(List<Contact> contactList) {
        Set<Id> accIdSet = new Set<Id>();
        
        for(Contact con : contactList) {
            if(con.AccountId != null) {
                accIdSet.add(con.AccountId);
            }
        }
        
        Map<Id,Account> accMap = new Map<Id,Account>([Select NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                                                            NumberOfAdults__c, NumberOfChildren__c,ChildrenUnderMilkCodeRestriction__c
                                                            FROM Account 
                                                            WHERE Id IN :accIdSet]);

        return accMap ;
    }

    public static void updateHouseholdPrimaryContact(List<Contact> contactList, Map<Id, sObject> oldContactMap) {
        List<Account> toUpdateList = new List<Account>();
        List<Address__c> addresstoUpdateList = new List<Address__c>();
        List<Address__c> addressList = [SELECT Id, ParentContact__c, ParentHousehold__c FROM Address__c WHERE ParentContact__c IN :contactList];

        for(Contact con : contactList) {
            Boolean oldValue = false;
            String oldEmail, oldPhone, oldName, firstName, oldHousehold;

            if (Trigger.isUpdate && oldContactMap.containsKey(con.Id)) {
                Contact oldCon = (Contact) oldContactMap.get(con.Id);
                oldValue = oldCon.PrimaryContact__c;
                oldEmail = oldCon.Email;
                oldPhone = oldCon.Phone;
                oldName = oldCon.FirstName + ' ' + oldCon.LastName;
                oldHousehold = oldCon.AccountId;
            }

            if ( (con.PrimaryContact__c == true && Trigger.IsInsert) || 
                  (con.PrimaryContact__c == true && con.PrimaryContact__c != oldValue &&  Trigger.isUpdate) ) {
                firstName = con.FirstName == null? '' : con.FirstName;
                
                Account acc = new Account();
                acc.Id = con.AccountId;
                acc.PrimaryContact__c = firstName + ' ' + con.LastName;
                acc.PrimaryContactEmail__c = con.Email;
                acc.PrimaryContactPhone__c = con.Phone;                
                toUpdateList.add(acc);
            } else if (con.PrimaryContact__c == true && Trigger.isUpdate && 
                      (oldEmail != con.Email || oldPhone != con.Phone || (oldName != con.FirstName + ' ' + con.LastName))) {
                firstName = con.FirstName == null? '' : con.FirstName;

                Account acc = new Account();
                acc.Id = con.AccountId;
                acc.PrimaryContact__c = firstName + ' ' + con.LastName;
                acc.PrimaryContactEmail__c = con.Email;
                acc.PrimaryContactPhone__c = con.Phone;                
                toUpdateList.add(acc);
            } else if (Trigger.isUpdate && oldHousehold != con.AccountId) {
                if (!addressList.isEmpty()) {
                    for(Address__c address : addressList ) {
                        if(address.ParentContact__c == con.Id) {
                            address.ParentHousehold__c = con.AccountId;
                            addresstoUpdateList.add(address);
                        }
                    }
                }
            }
        }

        if(!toUpdateList.isEmpty()) {
            //02.11.2019   raustral 
            //change from normaul up to database update
            //by pass the error for duplicate management system
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(toUpdateList, dml); 
            //Update toUpdateList;
        }
        
        if(!addresstoUpdateList.isEmpty()){
            update addresstoUpdateList;
        }
    }
    */

    /*
    //02.28.2019 malviz
    //method will calculate count of all child contacts with Milk Code Restriction related to Account
    public static void calculateCountOnAccount(set<Id> accountIdSet){
        list<Account> updateAccountList=new list<Account>();
        list<Account> accountContactList= new list<Account>([Select Id, ChildrenUnderMilkCodeRestriction__c, (SELECT Id,MilkCodeRestriction__c from Contacts WHERE MilkCodeRestriction__c = TRUE ) FROM Account WHERE ID in: accountIdSet]);
        
        //Parent to child query : Getting Accounts and their related Contacts
        for(Account account: accountContactList){
            
            Integer mcrCount = account.contacts.size();
            system.debug('==========count: ' + mcrCount);
            /*for(Contact contact: account.Contacts){
                if(contact.MilkCodeRestriction__c == TRUE){
                    mcrCount++;
                }
            }
            account.ChildrenUnderMilkCodeRestriction__c = mcrCount;
            updateAccountList.add(account);
        }
        if(!updateAccountList.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(updateAccountList, dml);
            //update updateAccountList;
        }
    }
    
    //method will calculate count of all child contacts with Milk Code Restriction related to a Parent Contact
    public static void calculateCountOnContact(set<Id> contactIdSet){
       
        list<Contact> updateContactList = new list<Contact>();
        list<Contact> parentContactsList = new list<Contact>([Select Id, Parent__c,ChildrenUnderMilkCodeRestriction__c ,MilkCodeRestriction__c FROM Contact WHERE Id in: contactIdSet]);
        list<Contact> childContactsList = new list<Contact>([Select Id, Parent__c,MilkCodeRestriction__c FROM Contact WHERE Parent__c in: contactIdSet]);
        
        for(Contact parent: parentContactsList){
            Integer mcrCount = 0;
            for(Contact child:childContactsList){
                if(child.MilkCodeRestriction__c == TRUE && child.parent__c == parent.id){
                    mcrCount++;
                    
                }
            }
            
            parent.ChildrenUnderMilkCodeRestriction__c = mcrCount;
            updateContactList.add(parent);
        }
        if(!updateContactList.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(updateContactList, dml);
            //update updateContactList;
        }
    }
    */

    /*
    Author: Jericson Mercado
    Description: check for primary carer - ANZ Only
    */
    // public static void checkPrimaryCarer(List<Contact> conList, Map<Id, sObject> oldMap){

    //     Map<Id, Contact> primaryCarerForUpdate = new Map<Id, Contact>();
    //     Set<Id> contactForChecking = new Set<Id>();

    //     // get market
    //     Set<Id> accountIds = new Set<Id>();
    //     for(Contact c: (List<Contact>) conList) {
    //         accountIds.add(c.AccountId);
    //     }
    //     Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Market__c
    //                                                           FROM Account
    //                                                          WHERE Id IN: accountIds]);
    //     accountIds = new Set<Id>();
    //     for(Contact c: (List<Contact>) conList) {
    //         Contact old = new Contact();
    //         if(Trigger.isUpdate) old = (Contact) oldMap.get(c.Id);

    //         // check if ANZ
    //         if(accountMap.containsKey(c.AccountId)
    //             && accountMap.get(c.AccountId).Market__c == 'ANZ'){
    //             if(c.PrimaryCarer__c != null
    //                 &&  ( (Trigger.isInsert)
    //                     || (Trigger.isUpdate
    //                         && c.PrimaryCarer__c != old.PrimaryCarer__c)
    //                     )
    //                 ) {
    //                 primaryCarerForUpdate.put(c.PrimaryCarer__c, new Contact(Id = c.PrimaryCarer__c, PrimaryContact__c = true));
    //                 accountIds.add(c.AccountId);
    //             }
    //         }
    //     }
    //     List<Contact> primaryContacts = new List<Contact>();
    //     // get old primary contact
    //     if(!accountIds.isEmpty()){
    //         for(Contact c: [SELECT Id
    //                           FROM Contact
    //                          WHERE AccountId IN: accountIds
    //                            AND ID NOT IN: primaryCarerForUpdate.keySet()
    //                            AND PrimaryContact__c = true]) {
    //             c.PrimaryContact__c = false;
    //             primaryContacts.add(c);
    //         }
    //     }

    //     if(!primaryCarerForUpdate.isEmpty()){
    //         Database.update(primaryContacts); // remove primary contact first
    //         Database.update(primaryCarerForUpdate.values()); // set primary contact
    //     }
    // }

    // public static void checkSampleRequest(List<Contact> newList, Map<Id, SObject> oldMap) {
    //     Set<Id> conIds = new Set<Id>();
    //     for(Contact c: newList){
    //         Contact old = (Contact) oldMap.get(c.Id);

    //         //check if Contact has been verified
    //         if(c.Verified__c && !old.Verified__c){
    //             conIds.add(c.Id);
    //         }
    //     }

    //     //get channel response sample request
    //     if(!conIds.isEmpty()){
    //         List<BrandRelationship__c> brList = new List<BrandRelationship__c>([SELECT Id FROM BrandRelationship__c WHERE PrimaryContact__c IN: conIds]);
    //         List<ChannelResponse__c> CRForSampleOrder = new List<ChannelResponse__c>();
    //         for(ChannelResponse__c cr: [SELECT BrandRelationship__r.PrimaryContact__c, BrandRelationship__r.PrimaryContact__r.Verified__c, BrandRelationship__r.PrimaryContact__r.Market__c,
    //                                         DeliveryAddress__c, OrderCreationStatus__c , SampleProductCode__c, ProductSampleRequested__c, IsSample_Requested__c,BrandRelationship__r.User__c, Campaign__c ,
    //                                      ProductSampleRequested__r.KeyBrand__c,BrandRelationship__r.User__r.RecordType.DeveloperName, BrandRelationship__r.User__r.AgeinMonths__c, BrandRelationship__r.User__r.MilkCodeRestriction__c
    //                                     FROM ChannelResponse__c
    //                                     WHERE BrandRelationship__c IN: brList]){

    //             if(cr.IsSample_Requested__c
    //                 && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING
    //                 && cr.DeliveryAddress__c != null){
    //                 CRForSampleOrder.add(cr);
    //             }
    //         }

    //         //ChannelResponseTriggerHandler crTrigger = new ChannelResponseTriggerHandler();
    //         if(!CRForSampleOrder.isEmpty()){
    //             //crTrigger.executeSampleCreation(CRForSampleOrder);
    //          CreateSampleOrder.executeSampleCreation(CRForSampleOrder);
    //         }
    //     }
    // }
}