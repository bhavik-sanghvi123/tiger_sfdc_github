public class ContactEventHandler {

    public static void processEvent(List<ContactChangeEvent> events) {

        Set<Id> updateAccount = new Set<Id>();
        Set<Id> primaryCarer = new Set<Id>();
        Set<Id> verifiedIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(ContactChangeEvent event: events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;

            // CREATE
            if(header.changeType == 'CREATE') {
                //updateAccount.add(header.recordIds[0]);

                if(event.PrimaryCarer__c != null){
                    primaryCarer.add(header.recordIds[0]);
                }
                if(event.Phone != null){
                    contactIds.add(header.recordIds[0]);
                }
            }

            // UPDATE
            else if(header.changeType == 'UPDATE') {

                // update account
                /*if(header.changedFields.contains('PrimaryContact__c')
                    || header.changedFields.contains('Type__c')
                    || header.changedFields.contains('MilkCodeRestriction__c')
                    || header.changedFields.contains('HouseHoldHistoryId__c')
                    || header.changedFields.contains('FirstName')
                    || header.changedFields.contains('LastName')
                    || header.changedFields.contains('Email')
                    || header.changedFields.contains('Phone')) {
                    //updateAccount.add(header.recordIds[0]);
                }*/

                // primary carer
                if(header.changedFields.contains('PrimaryCarer__c')) {
                    primaryCarer.add(header.recordIds[0]);
                }

                // verified
                if(header.changedFields.contains('Verified__c')
                    && event.Verified__c) {
                    
                    verifiedIds.add(header.recordIds[0]);
                }
                if(header.changedFields.contains('Phone')){
                    contactIds.add(header.recordIds[0]);
                }
            }
        }

        if(!updateAccount.isEmpty()) updateAccountTrackingFields(updateAccount);
        if(!primaryCarer.isEmpty()) checkPrimaryCarer(primaryCarer);
        if(!verifiedIds.isEmpty()) checkSampleRequest(verifiedIds);
        if(!contactIds.isEmpty()) updatePhoneforContact(contactIds);
    }

    public static void checkSampleRequest(Set<Id> conIds) {

        List<BrandRelationship__c> brList = new List<BrandRelationship__c>([SELECT Id FROM BrandRelationship__c WHERE PrimaryContact__c IN: conIds]);
        List<ChannelResponse__c> CRForSampleOrder = new List<ChannelResponse__c>();
        for(ChannelResponse__c cr: [SELECT BrandRelationship__r.PrimaryContact__c, BrandRelationship__r.PrimaryContact__r.Verified__c, BrandRelationship__r.PrimaryContact__r.Market__c,
                                        DeliveryAddress__c, OrderCreationStatus__c , SampleProductCode__c, ProductSampleRequested__c, IsSample_Requested__c,BrandRelationship__r.User__c, Campaign__c ,
                                        ProductSampleRequested__r.KeyBrand__c, ProductSampleRequested__r.Stage1PaidSample__c, ProductSampleRequested__r.Stage3PaidSample__c, SampleGivenOnGround__c,
                                        BrandRelationship__r.User__r.RecordType.DeveloperName, BrandRelationship__r.User__r.AgeinMonths__c, BrandRelationship__r.User__r.MilkCodeRestriction__c, PromoterCode__c
                                    FROM ChannelResponse__c
                                    WHERE BrandRelationship__c IN: brList]){

            if(cr.IsSample_Requested__c
                && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING
                && cr.DeliveryAddress__c != null){
                CRForSampleOrder.add(cr);
            }
            else if(!cr.IsSample_Requested__c && cr.SampleGivenOnGround__c && cr.ProductSampleRequested__c != null
                && cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDING){
                CRForSampleOrder.add(cr);
            }
        }

        if(!CRForSampleOrder.isEmpty()){
            //CreateSampleOrder.executeSampleCreation(CRForSampleOrder);
            System.enqueueJob(new CreateSampleOrderQueueable(CRForSampleOrder));
        }
    }

    /*
    Author: Jericson Mercado
    Description: check for primary carer - ANZ Only
    */
    public static void checkPrimaryCarer(Set<Id> contactIds){

        Map<Id, Contact> primaryCarerForUpdate = new Map<Id, Contact>();
        Set<Id> contactForChecking = new Set<Id>();

        // get account
        Set<Id> accountIds = new Set<Id>();
        for(Contact c: [SELECT AccountId
                          FROM Contact
                         WHERE ID IN: contactIds
                           AND Account.Market__c = 'ANZ']) {
            accountIds.add(c.AccountId);
        }

        Map<Id, Contact> primaryContactMap = new Map<Id, Contact>();
        Map<Id, Contact> primaryCarerMap = new Map<Id, Contact>();

        for(Account acc: [SELECT (SELECT PrimaryCarer__c, PrimaryCarer__r.PrimaryContact__c, PrimaryContact__c
                                    FROM Contacts
                                   WHERE PrimaryContact__c = true
                                      OR PrimaryCarer__c != null)
                            FROM Account
                           WHERE ID IN (SELECT AccountId
                                          FROM Contact
                                         WHERE ID IN: contactIds
                                           AND Account.Market__c = 'ANZ')]) {

            for(Contact con: acc.Contacts) {

                // set current to primary contact = false
                if(con.PrimaryContact__c) {
                    con.PrimaryContact__c = false;
                    primaryContactMap.put(con.Id, con);
                }

                if(con.PrimaryCarer__c != null) {

                    // set primary carer to primary contact
                    Contact con2 = new Contact( Id = con.PrimaryCarer__c,
                                                PrimaryContact__c = true);

                    if(!primaryCarerMap.containsKey(con2.Id))
                        primaryCarerMap.put(con2.Id, con2);

                    primaryContactMap.remove(con2.Id);
                }
            }
        } 

        if(!primaryCarerMap.isEmpty()) {
            // remove existing primary contact first
            if(!primaryContactMap.isEmpty()) UtilityClass.updateList(primaryContactMap.values());
            UtilityClass.updateList(primaryCarerMap.values());
        }
    }

    public static void updateAccountTrackingFields(Set<Id> contactIds){

        Set<Id> accountIds = new Set<Id>();
        for(Contact c: [SELECT AccountId FROM Contact WHERE Id IN: contactIds]){
            accountIds.add(c.AccountId);
        }

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
        if(!accountList.isEmpty()) UtilityClass.updateList(accountList);
    }
    /*****************************************************************************************
    * @author           Monika Parihar
    * @date             06/10/2021
    * @description      For TW Market add country code to phone no.
    * @revision(s)

    * 
      @Modified by      Narence valencia
    * @date             11/29/2021
    * @description      Added logic to remove the first character from CountryCodeMobile__c                 
    *********************************************************************************************/
    public static void updatePhoneforContact(Set<Id> contactIds){
        Map<String,String> mapCountryCode = new Map<String,String>();
        List<Contact> conList = new List<Contact>();
        
        //custom metadata to get country phone code out of country code
        Country_Code__mdt[] countryCodeList = [SELECT MasterLabel, Country_Code__c FROM Country_Code__mdt];
        for(Country_Code__mdt record: countryCodeList) {
            mapCountryCode.put(record.MasterLabel,record.Country_Code__c);
        }
        //get contact of TW
        List<Contact> lstContact = [SELECT Id,Market__c,Phone,CountryCodeMobile__c FROM CONTACT WHERE ID IN : contactIds and Market__c =: CommonConstant.Market_TW ];
  
        For(Contact con : lstContact){
            if(mapCountryCode.containskey(con.Market__c) && mapCountryCode !=  null){
                con.CountryCodeMobile__c = con.Phone.startsWith('0') ? mapCountryCode.get(con.Market__c)+con.Phone.substring(1):mapCountryCode.get(con.Market__c)+con.Phone;

                //added by Narence Valencia
                con.CountryCodeMobile__c = con.CountryCodeMobile__c.substring(1);
            }
            conList.add(con);
        }
        if(!conList.isEmpty()) UtilityClass.updateList(conList);
    }
}