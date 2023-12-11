/*------------------------------------------------------------
Author:      Jericson Mercado
Description: Change Event class for BrandRelationship object

History
06/01/2020   jericson   Created
11/16/2020   malviz     updated updateMarketingCloudFields 
                        Fixed MC Main Contact/End User field Update logic to accomodate bulk creation of BR with same contact
11/21/2021   malviz     Added updateMCEligibility
03/31/2021   malvoz     moved updateMCEligibility t0 BrandRelationshipTriggerHandler
-------------------------------------------------------------------------------------------*/

public class BrandRelationshipEventHandler {

    private static Map<String, String> primaryContactFieldMap = new Map<String, String> {
                                                    CommonConstant.PRODUCT_KEYBRAND_SIMILAC => 'MCSimilacMainContact__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_GROW => 'MCGrowMainContact__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_PEDIASURE => 'MCPediasureMainContact__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_ENSURE => 'MCEnsureMainContact__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_GLUCERNA => 'MCGlucernaMainContact__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_OTHERS => 'MCOthersMainContact__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_SIMILACMOM => 'MCSimilacMomMainContact__c'};

    private static Map<String, String> endUserFieldMap = new Map<String, String> {
                                                    CommonConstant.PRODUCT_KEYBRAND_SIMILAC => 'MCSimilacEndUser__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_GROW => 'MCGrowEndUser__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_PEDIASURE => 'MCPediasureEndUser__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_ENSURE => 'MCEnsureEndUser__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_GLUCERNA => 'MCGlucernaEndUser__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_OTHERS => 'MCOthersEndUser__c',
                                                    CommonConstant.PRODUCT_KEYBRAND_SIMILACMOM => 'MCSimilacMomEndUser__c'};


    public static void processEvent(List<BrandRelationship__ChangeEvent> events) {

        Set<Id> newIds = new Set<Id>();
        Map<Id, BrandRelationship__ChangeEvent> marketing = new Map<Id, BrandRelationship__ChangeEvent>();
        Set<Id> changeProductIds = new Set<Id>();
        Map<Id, BrandRelationship__ChangeEvent> inactive = new Map<Id, BrandRelationship__ChangeEvent>();
        Map<Id, BrandRelationship__ChangeEvent> enduser = new Map<Id, BrandRelationship__ChangeEvent>();
        Map<Id, BrandRelationship__ChangeEvent> enduserCountMap = new Map<Id, BrandRelationship__ChangeEvent>();
        Set<Id> updateMCEligibilityIds = new Set<Id>();

        for(BrandRelationship__ChangeEvent event: events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            // CREATE
            if(header.changeType == 'CREATE') {
                newIds.add(header.recordIds[0]);

                // marketing cloud
                if(event.Active__c) {
                    marketing.put(header.recordIds[0], event);
                }

                // flag End User on non primary contacts
                if(event.User__c != null &&
                   (event.CareGiver__c || event.GiftGiver__c)){
                    enduser.put(header.recordIds[0], event);
                }
                
                if(event.User__c != null){
                    enduserCountMap.put(header.recordIds[0], event);
                }
            }

            // UPDATE
            else if(header.changeType == 'UPDATE') {

                // changeProduct
                if(header.changedFields.contains('CurrentBrand__c')
                    || header.changedFields.contains('PreviousBrand__c')) {
                    changeProductIds.add(header.recordIds[0]);
                }

                // marketing cloud
                if(header.changedFields.contains('Active__c')
                    || header.changedFields.contains('CurrentBrand__c')) {
                    marketing.put(header.recordIds[0], event);
                }

                // only for SG
                if(header.changedFields.contains('Active__c')) {
                    inactive.put(header.recordIds[0], event);
                }

                // flag End User on non primary contacts
                if(header.changedFields.contains('CareGiver__c') 
                    || header.changedFields.contains('GiftGiver__c')
                    || header.changedfields.contains('User__c')){
                    enduser.put(header.recordIds[0], event);
                }
            }
        }

        if(!newIds.isEmpty()) linkOrderItem(newIds);
        if(!changeProductIds.isEmpty()) populateBrandUsedOnCase(changeProductIds);
        if(!marketing.isEmpty()) updateMarketingCloudFields(marketing);
        if(!inactive.isEmpty()) updateCRs(inactive);
        if(!enduser.isEmpty()) updateEndUser(enduser);
        if(!enduserCountMap.keySet().isEmpty()) updateChildEndUserCount(enduserCountMap);
    }
    
    //us-305 : need to checkboxes in the contact that is needed for the marketing cloud
    public static void updateMarketingCloudFields(Map<Id, BrandRelationship__ChangeEvent> brChangeMap) {

        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>(
                                                    [SELECT Id, BrandRelationship__c, Active__c,
                                                            User__c, PrimaryContact__c, Keybrand__c, ConsumingCompetitorBrand__c
                                                       FROM BrandRelationship__c
                                                      WHERE ID IN: brChangeMap.keySet()]);

        Set<Id> contactIdSet = new Set<Id>();

        for (BrandRelationship__c brand : brMap.values()) {
            if(brand.User__c != null) contactIdSet.add(brand.User__c);
            if(brand.PrimaryContact__c != null) contactIdSet.add(brand.PrimaryContact__c);
        }
        
        //create map of contact id, list of new BR
        Map<Id, List<Brandrelationship__c>> contactBrandRelationshipMap = new Map<Id, List<Brandrelationship__c>> ();
        for (BrandRelationship__c brand : brMap.values()) {
            if(brand.User__c != null && brand.User__c == brand.PrimaryContact__c){
                if(!contactBrandRelationshipMap.containsKey(brand.PrimaryContact__c)){
                    contactBrandRelationshipMap.put(brand.PrimaryContact__c,new List<BrandRelationship__c>());
                }
                contactBrandRelationshipMap.get(brand.PrimaryContact__c).add(brand);
            } else if(brand.User__c != null){
                if(!contactBrandRelationshipMap.containsKey(brand.PrimaryContact__c)){
                    contactBrandRelationshipMap.put(brand.PrimaryContact__c,new List<BrandRelationship__c>());
                }
                contactBrandRelationshipMap.get(brand.PrimaryContact__c).add(brand);

                if(!contactBrandRelationshipMap.containsKey(brand.User__c)){
                    contactBrandRelationshipMap.put(brand.User__c,new List<BrandRelationship__c>());
                }
                contactBrandRelationshipMap.get(brand.User__c).add(brand); 
            } else {
                if(!contactBrandRelationshipMap.containsKey(brand.PrimaryContact__c)){
                    contactBrandRelationshipMap.put(brand.PrimaryContact__c,new List<BrandRelationship__c>());
                }
                contactBrandRelationshipMap.get(brand.PrimaryContact__c).add(brand);
            }
    	}

        Map<Id, Contact> toUpdate = new Map<Id, Contact>();
        List<BrandRelationship__c> allRelatedList = new List<BrandRelationship__c>();
        Map<Id, Map<String, List<BrandRelationship__c>>> contactUserBRMap = new Map<Id, Map<String, List<BrandRelationship__c>>>();
        Map<Id, Map<String, List<BrandRelationship__c>>> contactPrimaryBRMap = new Map<Id, Map<String, List<BrandRelationship__c>>>();

        // create set of active Keybrands
        for(BrandRelationship__c br: [SELECT KeyBrand__c, ConsumingCompetitorBrand__c, User__c, PrimaryContact__c
                                    FROM BrandRelationship__c 
                                    WHERE Active__c = true
                                        AND (User__c IN : contactIdSet
                                            OR PrimaryContact__c IN: contactIdSet)
                                        AND ID NOT IN: brMap.KeySet()]) {
            // User
            if(br.User__c != null) {
                if(!contactUserBRMap.containsKey(br.User__c)) {
                    contactUserBRMap.put(br.User__c, new Map<String, List<BrandRelationship__c>>());
                }
                if(!contactUserBRMap.get(br.User__c).containsKey(br.KeyBrand__c)){
                    contactUserBRMap.get(br.User__c).put(br.KeyBrand__c, new List<BrandRelationship__c>());
                }
                contactUserBRMap.get(br.User__c).get(br.KeyBrand__c).add(br);
            }

            // Primary Contact
            if(br.PrimaryContact__c != null) {
                if(!contactPrimaryBRMap.containsKey(br.PrimaryContact__c)) {
                    contactPrimaryBRMap.put(br.PrimaryContact__c, new Map<String, List<BrandRelationship__c>>());
                }
                if(!contactPrimaryBRMap.get(br.PrimaryContact__c).containsKey(br.KeyBrand__c)){
                    contactPrimaryBRMap.get(br.PrimaryContact__c).put(br.KeyBrand__c, new List<BrandRelationship__c>());
                }
                contactPrimaryBRMap.get(br.PrimaryContact__c).get(br.KeyBrand__c).add(br);
            }
        }

        /*for (BrandRelationship__c brand : brMap.values()) {
            
            // set brands of contact per user / primary
            Map<String, List<BrandRelationship__c>> endUserBrands = new Map<String, List<BrandRelationship__c>>();
            Map<String, List<BrandRelationship__c>> primaryContactBrands = new Map<String, List<BrandRelationship__c>>();

            if(brand.User__c != null
                && contactUserBRMap.containsKey(brand.User__c)) {
                endUserBrands = contactUserBRMap.get(brand.User__c);
            }
            if(brand.PrimaryContact__c != null
                && contactPrimaryBRMap.containsKey(brand.PrimaryContact__c)) {
                primaryContactBrands = contactPrimaryBRMap.get(brand.PrimaryContact__c);
            }

            if (brand.PrimaryContact__c == brand.User__c) {
                Contact con = New Contact();
                con = processContact(true, brand, con, endUserBrands);
                con = processContact(false, brand, con, primaryContactBrands);
                con.Id = brand.PrimaryContact__c;
                con.UserLatestBrandSwitch__c = brand.Id;
                toUpdate.put(con.Id, con);
            } else {
                Contact conEndUser = New Contact();
                conEndUser = processContact(true, brand, conEndUser, endUserBrands);
                conEndUser.Id = brand.User__c;
                conEndUser.UserLatestBrandSwitch__c = brand.Id;
                toUpdate.put(conEndUser.Id, conEndUser);

                Contact con = New Contact();
                con = processContact(false, brand, con, primaryContactBrands);
                con.Id = brand.PrimaryContact__c;
                toUpdate.put(con.Id, con);
            }
        }
        if (!toUpdate.isEmpty()) UtilityClass.updateList(toUpdate.values());*/

        for(Id contactId : contactBrandRelationshipMap.keySet()){
            Contact con = New Contact(Id = contactId);
            
            for(BrandRelationship__c br : contactBrandRelationshipMap.get(con.Id)){
                // set brands of contact per user / primary
                Map<String, List<BrandRelationship__c>> endUserBrands = new Map<String, List<BrandRelationship__c>>();
                Map<String, List<BrandRelationship__c>> primaryContactBrands = new Map<String, List<BrandRelationship__c>>();
    
                if(br.User__c != null
                    && contactUserBRMap.containsKey(br.User__c)) {
                    endUserBrands = contactUserBRMap.get(br.User__c);
                }
                if(br.PrimaryContact__c != null
                    && contactPrimaryBRMap.containsKey(br.PrimaryContact__c)) {
                    primaryContactBrands = contactPrimaryBRMap.get(br.PrimaryContact__c);
                }
                
                //process contact
                if (br.PrimaryContact__c == br.User__c) {
    				con = processContact(true, br, con, endUserBrands);
                    con = processContact(false, br, con, primaryContactBrands);
                    con.UserLatestBrandSwitch__c = br.Id;
                    toUpdate.put(con.Id, con);
            	} else if(con.Id == br.PrimaryContact__c){
                    con = processContact(false, br, con, primaryContactBrands);
                    con.UserLatestBrandSwitch__c = br.Id;
                    toUpdate.put(con.Id, con);
                }
                else if(con.Id == br.User__c){
                    con = processContact(true, br, con, endUserBrands);
                    con.UserLatestBrandSwitch__c = br.Id;
                    toUpdate.put(con.Id, con);
                    system.debug('==================' + contactBrandRelationshipMap);
                }
            }
		}
        if (!toUpdate.isEmpty()) UtilityClass.updateList(toUpdate.values());
    }

    // updates MC fields in contact
    public static Contact processContact(Boolean isEndUser, BrandRelationship__c brand, Contact con, Map<String, List<BrandRelationship__c>> brandMap) {

        // check if this is old brand
        if(endUserFieldMap.containsKey(brand.KeyBrand__c)) {

            Boolean isActive = brand.Active__c;

            // if inactive, check if there is the same brand active for the contact
            if(!isActive) {
                isActive = brandMap.containsKey(brand.KeyBrand__c);
            }

            String fieldStr = isEndUser ?
                                endUserFieldMap.get(brand.KeyBrand__c) :
                                primaryContactFieldMap.get(brand.KeyBrand__c);

            con.put(fieldStr, isActive);

            // conversion needed for primary
            if(!isEndUser) {
                Boolean needsConversion = isActive && brand.ConsumingCompetitorBrand__c;

                // check if needs conversion is false
                if(!needsConversion){
                    // look for all the brands
                    for(String KeyBrand: brandMap.keySet()){
                        for(BrandRelationship__c br: brandMap.get(KeyBrand)){
                            if(br.ConsumingCompetitorBrand__c) needsConversion = true;
                        }
                        if(needsConversion) break;
                    }
                }
                con.MCConversionAttemptRequired__c = needsConversion;
            }
        }
        return con;
    }

    // updates flag in order item, it means it was linked to BR
    public static void linkOrderItem(Set<Id> recordIds) {
        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>(
                                                    [SELECT Id, PrimaryContact__c, BrandRelationship__c
                                                       FROM BrandRelationship__c
                                                      WHERE ID IN: recordIds]);

        Set<Id> conIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        // get all contact and product ids
        for(BrandRelationship__c br: brMap.values()){
            conIds.add(br.PrimaryContact__c);
            productIds.add(br.BrandRelationship__c);
        }

        // create map of contact and products
        Map<String, List<OrderItem>> contactProductMap = new Map<String, List<OrderItem>>();
        for(OrderItem oi: [SELECT Order.EndDate, Order.OrderedBy__c, Product2.BrandRelationshipLink__c, BrandRelationshipLinkStatus__c
                             FROM OrderItem
                            WHERE Order.Status =: CommonConstant.ORDER_STATUS_COMPLETED
                              AND Order.OrderedBy__c IN: conIds
                              AND BrandRelationshipLinkStatus__c = false
                              AND Product2.BrandRelationshipLink__c IN: productIds]) {
            String key = oi.Order.OrderedBy__c + '-' + oi.Product2.BrandRelationshipLink__c;
            if(!contactProductMap.containsKey(key)){
                contactProductMap.put(key, new List<OrderItem>());
            }
            contactProductMap.get(key).add(oi);
        }

        List<OrderItem> oiList = new List<OrderItem>();
        for(BrandRelationship__c br: brMap.values()){
            String key = br.PrimaryContact__c + '-' + br.BrandRelationship__c;
            if(contactProductMap.containsKey(key)){
                for(OrderItem oi: contactProductMap.get(key)){
                    oi.BrandRelationshipLinkStatus__c = true;
                    oiList.add(oi);
                }
            }
        }

        if(!oiList.isEmpty()) UtilityClass.updateList(oiList);
    }

    // updates case where these BR is the converted BR
    public static void populateBrandUsedOnCase(Set<Id> recordIds) {
        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>(
                                                    [SELECT Id, PrimaryContact__c, BrandRelationship__c,
                                                            CurrentBrand__c, PreviousBrand__c
                                                       FROM BrandRelationship__c
                                                      WHERE ID IN: recordIds]);

        List<Case> casesToUpdate = new List<Case>();
        for(Case c : [SELECT ConvertedBR__c, CurrentBrandUsed__c, PreviousBrandUsed__c
                                   FROM Case
                                  WHERE ConvertedBR__c in :brMap.keySet()
                                    AND Status = 'New'
                                    AND RecordType.Name = 'Call']) {

            if(c.CurrentBrandUsed__c != brMap.get(c.ConvertedBR__c).CurrentBrand__c
                || c.PreviousBrandUsed__c != brMap.get(c.ConvertedBR__c).PreviousBrand__c) {

                c.CurrentBrandUsed__c = brMap.get(c.ConvertedBR__c).CurrentBrand__c;
                c.PreviousBrandUsed__c = brMap.get(c.ConvertedBR__c).PreviousBrand__c;
                casesToUpdate.add(c);
            }
        }

        if(!casesToUpdate.isEmpty()) UtilityClass.updateList(casesToUpdate);
    }

    // update all child channel responses, only for SG
    public static void updateCRs(Map<Id, BrandRelationship__ChangeEvent> brChangeMap){
        List<ChannelResponse__c> crList = new List<ChannelResponse__c>();
    	Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>(
                                                    [SELECT Id,Active__c,(SELECT Id, Inactive__c FROM Channel_Responses__r)
                                                       FROM BrandRelationship__c
                                                     WHERE ID IN: brChangeMap.keySet() AND PrimaryContact__r.Market__c = 'SG']);    
    	
        
    	for(BrandRelationship__c brand : brMap.values()) {
            if(!brand.Channel_Responses__r.isEmpty()){
                for(ChannelResponse__c cr : brand.Channel_Responses__r){
                    if(brand.Active__c){
                    	cr.Inactive__c = false;
                    }else{
                        cr.Inactive__c = true;
                    }
                    crList.add(cr);
                }
            }
    	}
        if(!crList.isEmpty()) UtilityClass.updateList(crList);
    }

    // update End User to true if BR End User is not the primary contact
    public static void updateEndUser(Map<Id, BrandRelationship__ChangeEvent> brChangeMap){
        List<Contact> conList = new List<Contact>();
    	Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>(
                                                    [SELECT Id,Active__c,CareGiver__c, GiftGiver__c, User__c, User__r.EndUser_NonPrimary__c
                                                       FROM BrandRelationship__c
                                                     WHERE ID IN: brChangeMap.keySet() AND User__r.PrimaryContact__c = false]);   
        
        If(!brMap.isEmpty()){                                            
            Map<Id, Contact> conMap = new  Map<Id, Contact>([Select id,EndUser_NonPrimary__c from Contact where Id IN (SELECT User__c FROM BrandRelationship__c WHERE ID IN: brChangeMap.keySet())]);
            
            for(BrandRelationship__c brand : brMap.values()) {            
                if(brand.CareGiver__c || brand.GiftGiver__c){
                    conMap.get(brand.User__c).EndUser_NonPrimary__c = true;
                }else{
                    conMap.get(brand.User__c).EndUser_NonPrimary__c = false;
                }
                
                conlist.add(conMap.get(brand.User__c));
            }
        }   
        if(!conList.isEmpty()) UtilityClass.updateList(conList);
    }
    
    public static void updateChildEndUserCount(Map<Id, BrandRelationship__ChangeEvent> enduserCountMap){
        Id conChildRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        Map<Id, Contact> conUpdateMap = new Map<Id, Contact>();
        Set<Id> endUserId = new Set<Id>();
        for(BrandRelationship__ChangeEvent brEvent : enduserCountMap.values()){
            endUserId.add(brEvent.User__c);
        }
        for(Contact con : [SELECT Id, Brand_Relationship_EndUser_Child_Count__c, (SELECT Id FROM BrandRelationships__r WHERE Active__c = true) 
                           FROM Contact WHERE Id IN: endUserId AND RecordTypeId =: conChildRecType])
        {
            if(!con.BrandRelationships__r.isEmpty()){
                Contact conRec = new Contact();
                conRec.Id = con.Id;
                conRec.Brand_Relationship_EndUser_Child_Count__c = con.BrandRelationships__r.size();
                conUpdateMap.put(con.Id, conRec);
            }
        }
        
        if(!conUpdateMap.keySet().isEmpty()) UtilityClass.updateList(conUpdateMap.values());
    }

}