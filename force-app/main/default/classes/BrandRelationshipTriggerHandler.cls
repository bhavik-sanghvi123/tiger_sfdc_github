/**
* @author        Rey Austral
* @date          3.11.2019
* @description   Class primarily responsible in handling trigger execution per object.
* @revision(s)
                 3.19.2019 - added functionality for us:356
                 4.11.2019 - added populateDuplicateChecker  
				 7.25.2019 - mocillos - added functionality for US-0564
                 5.14.2020 - jericson - trigger enhancement, filter all records to be processed
                 5.14.2020 - jericson - populateTransactionDate remove, let batch job do it.
                 5.14.2020 - jericson - delete currentBrandUpdate method, moved to updateMarketingCloudFields method since its updates 1 field only
                 5.19.2020 - jericson - move all after transaction to BrandRelationshipEventHandler to lessen trigger processing for integration hitting cpu time limit
                 7.20.2020 - malviz - bypass delete when To be Archived is true
                 3.31.2021 - malviz - added updateMCEligibility
                 9.10.2021 - scordova - added populateHousehold function for TKT-005625
                 11.23.2021 - navalencia - Added updateBirthHospital function in beforeInsert and beforeUpdate
                 02.03.2022 - navalencia - Added updateCrFields function on AfterUpdate
*/
public class BrandRelationshipTriggerHandler implements ITriggerHandler {
    
    public void BeforeInsert(List<SObject> newList){
        Set<Id> conIds = new Set<Id>();
        for(BrandRelationship__c brCon: (List<BrandRelationship__c>) newList){
            conIds.add(brCon.PrimaryContact__c);
        }
        Map<Id, Contact> brConMap = new Map<Id, Contact>([SELECT Id, AccountId, Market__c FROM Contact WHERE Id IN :conIds]);
        for(BrandRelationship__c br: (List<BrandRelationship__c>) newList) {
            br.Active__c = true; // always set to active when insert
            if(br.User__c == null && brConMap.containsKey(br.PrimaryContact__c) && brConMap.get(br.PrimaryContact__c).Market__c == 'SG'){
                br.User__c = br.PrimaryContact__c;
            }
            // duplicate check
            populateDuplicateChecker(br);
        }
        
        populateHousehold(newList);
        populateTransactionDate(newList);
        updateMCEligibility(newList);

        //added by narence valencia
        updateBirthHospital(newList);
    }
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){

        Set<Id> contactIds = new Set<Id>();
        List<BrandRelationship__c> statusChangeList = new List<BrandRelationship__c>();
        List<BrandRelationship__c> birthHospitalDescList = new List<BrandRelationship__c>();
        for(BrandRelationship__c br: (List<BrandRelationship__c>) newList) {
            BrandRelationship__c old = (BrandRelationship__c) oldMapItems.get(br.Id);
            // duplicate check
            populateDuplicateChecker(br);

            // currentBrandUpdate
            if(br.CurrentBrand__c != old.CurrentBrand__c) {
                br.BrandSwitchDate__c = System.now();
            }

            // move from workflows to trigger
            if(br.Status__c != old.Status__c
                || br.Type__c != old.Type__c) {
                br.StatusTypeUpdatedDate__c = Date.Today();
            }

            // lead with transaction
            if(br.Type__c == 'Lead'
                && br.FirstTransactionDate__c != null) {
                contactIds.add(br.PrimaryContact__c);
                statusChangeList.add(br);
            }

            if(br.User__c != null && br.Birth_Hospital_Description__c == null) {
                birthHospitalDescList.add(br);
            }
        }

        if(!statusChangeList.isEmpty()) checkANZ(statusChangeList, contactIds);
        //currentBrandUpdate(newList, oldMapItems);

        //added by narence valencia
        if(!birthHospitalDescList.isEmpty()) updateBirthHospital(birthHospitalDescList);
    }
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ 
        Map<Id,BrandRelationship__c> oldBR = (Map<Id,BrandRelationship__c>) oldItems;
        Map<Id,BrandRelationship__c> brToProcess = new Map<Id,BrandRelationship__c>();
       
        for(BrandRelationship__c br: oldBR.values()){
           If(br.To_be_Archived__c == false){
               brToProcess .put(br.Id,br);
           }
        }
        
        if(!brToProcess.isEmpty()) populateBrandUsedOnCase( (Map<Id, BrandRelationship__c>) brToProcess );
    }

    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){
    	//updateMarketingCloudFields(newList, null);
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){

        // // populateBrandUsedOnCase
        // Map<Id, BrandRelationship__c> populateBrandUsedOnCaseMap = new Map<Id, BrandRelationship__c>();

        // // currentBrandUpdate
        // Map<Id, BrandRelationship__c> currentBrandUpdateMap = new Map<Id, BrandRelationship__c>();

        // for(BrandRelationship__c br: (List<BrandRelationship__c>) newList) {
        //     BrandRelationship__c old = (BrandRelationship__c) oldMapItems.get(br.Id);

        //     // populateBrandUsedOnCase
        //     if(br.CurrentBrand__c != old.CurrentBrand__c || br.PreviousBrand__c != old.PreviousBrand__c) {
        //         populateBrandUsedOnCaseMap.put(br.Id, br);
        //     }

        //     // currentBrandUpdate
        //     if(br.CurrentBrand__c != old.CurrentBrand__c) {
        //         if(br.User__c != null) {
        //             currentBrandUpdateMap.put(br.User__c, br);
        //         }
        //     }
        // }

        // updateMarketingCloudFields(newList, oldMapItems);
        // if(!currentBrandUpdateMap.isEmpty()) currentBrandUpdate(currentBrandUpdateMap);
		// if(!populateBrandUsedOnCaseMap.isEmpty()) populateBrandUsedOnCase(populateBrandUsedOnCaseMap);
        

        //added by narence

        List<BrandRelationship__c> brList = new  List<BrandRelationship__c>();
        List<BrandRelationship__c> brEndUserCountList = new  List<BrandRelationship__c>();
        
        for(BrandRelationship__c br: (List<BrandRelationship__c>) newList) {
            BrandRelationship__c old = (BrandRelationship__c) oldMapItems.get(br.Id);

            // updateCrFields
            if((br.status__c != old.status__c) || (br.type__c != old.type__c)) {
                brList.add(br);
            }
            if(br.User__c != old.User__c){
                brEndUserCountList.add(br);
            }
        }

        if(!brList.isEmpty()) updateCrFields(brList);
        if(!brEndUserCountList.isEmpty()) updateChildEndUserCount(brEndUserCountList, oldMapItems);
    }
    
     public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){
        List<BrandRelationship__c> oldBR = (List<BrandRelationship__c>) oldList;
        List<BrandRelationship__c> brToProcess = new List<BrandRelationship__c>();
        List<BrandRelationship__c> brEndUserCountList = new List<BrandRelationship__c>();

        for(BrandRelationship__c br: oldBR){
            If(br.To_be_Archived__c == false){
                brToProcess .add(br);
            }
            if(br.User__c != null){
                brEndUserCountList.add(br);
            }
        }
        
        if(!brToProcess.isEmpty()){
            updateMarketingCloudFields(brToProcess, null);
            updateUserLatestBrandSwitchOnDelete(brToProcess);
            updateChildEndUserCount(brEndUserCountList, null);
        }
    }

    public void checkANZ(List<BrandRelationship__c> newList, Set<Id> contactIds) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE ID IN: contactIds AND Account.Market__c = 'ANZ']);
        for(BrandRelationship__c br: newList) {
            if(contactMap.containsKey(br.PrimaryContact__c)){
                br.Type__c = 'User';
                br.Status__c = 'New';
            }
        }
    }

    //us-305 : need to checkboxes in the contact that is needed for the marketing cloud
    // May 19 2020 - Jericson updated to run only for delete, create and update will be handled in change event rather than CR trigger
    public void updateMarketingCloudFields(List<BrandRelationship__c> newList, Map<Id, SObject> oldMap) {
    	List<BrandRelationship__c> validBrandList = new List<BrandRelationship__c>();
        Set<Id> contactIdSet = new Set<Id>();

        
    	for (BrandRelationship__c brand : newList) {
            validBrandList.add(brand);

            if(brand.User__c != null) {
                contactIdSet.add(brand.User__c);
            }
            if(brand.PrimaryContact__c != null) {
                contactIdSet.add(brand.PrimaryContact__c);
            }
    	}
    	if (!validBrandList.isEmpty()) {
    		Map<Id, Contact> toUpdate = new Map<Id, Contact>();
            List<BrandRelationship__c> allRelatedList = new List<BrandRelationship__c>();
            if (!contactIdSet.isEmpty()) {
                allRelatedList = [Select Id, KeyBrand__c, ConsumingCompetitorBrand__c, User__c from BrandRelationship__c 
                                   where (User__c IN : contactIdSet OR PrimaryContact__c IN: contactIdSet) AND Active__c = true];
            }
    		for (BrandRelationship__c brand : validBrandList) {    			
    			
                if (brand.PrimaryContact__c == brand.User__c) {
                    Contact con = New Contact();
                    con.Id = brand.PrimaryContact__c;
                    con.UserLatestBrandSwitch__c = brand.Id; // add from currentBrandUpdate method
                    con = procesMarketEndUserBrand(brand, con, allRelatedList, oldMap);
                    con = procesMarketPrimaryContactBrand(brand, con, allRelatedList, oldMap);
                    toUpdate.put(con.Id, con);
                } else {
                    Contact conEndUser = New Contact();
                    conEndUser.Id = brand.User__c;
                    conEndUser.UserLatestBrandSwitch__c = brand.Id; // add from currentBrandUpdate method
                    conEndUser = procesMarketEndUserBrand(brand, conEndUser, allRelatedList, oldMap);
                    toUpdate.put(conEndUser.Id, conEndUser);

                    Contact con = New Contact();
                    con.Id = brand.PrimaryContact__c;
                    con = procesMarketPrimaryContactBrand(brand, con, allRelatedList, oldMap);
                    toUpdate.put(con.Id, con);
                }                
    			
    		}

    		if (!toUpdate.isEmpty()) {
                Database.DMLOptions dml = new Database.DMLOptions();
            	dml.DuplicateRuleHeader.allowSave = true;
            	dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            	List<Database.SaveResult> sr = Database.update(toUpdate.values(), dml);
    		}
    	}
    }

    public Contact procesMarketEndUserBrand(BrandRelationship__c brand, Contact con, List<BrandRelationship__c> allRelatedList, Map<Id, SObject> oldMap) {
        //deleting the record should make the check to false, 
        //for update and insert,  it dependes if the active is true or false
        Boolean activeValue = trigger.isDelete ? false : brand.Active__c; 

        //this condtion will override the value of activeValue
        if ((trigger.isUpdate && brand.Active__c == false) || trigger.isDelete) {
            //if there is still active brand relationship with the same keybrand under the same contact. DO NOT change the value to false
            activeValue = checkforExistingKeybrand(allRelatedList, brand.Id, brand.KeyBrand__c, brand.User__c) ? true  : false;
        }
        //update the previous checkbox if the keybrand was changed
        if (trigger.isUpdate) {
            BrandRelationship__c oldvalue = (BrandRelationship__c)oldMap.get(brand.Id);
            if( oldvalue.CurrentBrand__c != brand.CurrentBrand__c && oldvalue.KeyBrand__c != brand.KeyBrand__c) {
                Boolean oldActiveValue = false;
                //if there is still active brand relationship with the same keybrand under the same contact. DO NOT change the value to false
                oldActiveValue = checkforExistingKeybrand(allRelatedList, brand.Id, brand.KeyBrand__c, brand.User__c) ? true  : false;
            }
        }

        con = updateEndUserMarketField(con, brand.KeyBrand__c, activeValue);

        return con;
    }

    public Contact procesMarketPrimaryContactBrand(BrandRelationship__c brand, Contact con, List<BrandRelationship__c> allRelatedList, Map<Id, SObject> oldMap) {
        //deleting the record should make the check to false, 
        //for update and insert,  it dependes if the active is true or false
        Boolean activeValuePrimary = trigger.isDelete ? false : brand.Active__c;
        Boolean hasActiveCompetitorPrimary = brand.ConsumingCompetitorBrand__c;
        //this condtion will override the value of activeValue

        if ((trigger.isUpdate && brand.Active__c == false) || trigger.isDelete) {
            //if there is still active brand relationship with the same keybrand under the same contact. DO NOT change the value to false
            activeValuePrimary = checkforExistingKeybrand(allRelatedList, brand.Id, brand.KeyBrand__c, brand.PrimaryContact__c) ? true  : false;
        }
        if ((trigger.isUpdate && (brand.Active__c == false || brand.ConsumingCompetitorBrand__c == false)) || trigger.isDelete) {
            //if there is still active brand relationship with competitor is true under the same contact. DO NOT change the value to false
            hasActiveCompetitorPrimary = checkforExistingCompetitor(allRelatedList, brand.Id,  brand.PrimaryContact__c) ? true  : false;
        }
        //update the previous checkbox if the keybrand was changed
        if (trigger.isUpdate) {
            BrandRelationship__c oldvalue = (BrandRelationship__c)oldMap.get(brand.Id);
            if( oldvalue.CurrentBrand__c != brand.CurrentBrand__c && oldvalue.KeyBrand__c != brand.KeyBrand__c) {
                Boolean oldActiveValue = false;
                //if there is still active brand relationship with the same keybrand under the same contact. DO NOT change the value to false
                oldActiveValue = checkforExistingKeybrand(allRelatedList, brand.Id, brand.KeyBrand__c, brand.PrimaryContact__c) ? true  : false;
                con = updatePrimaryContactMarketField(con, oldvalue.KeyBrand__c, oldActiveValue);
            }
        }

        con = updatePrimaryContactMarketField(con, brand.KeyBrand__c, activeValuePrimary);
        
        con.MCConversionAttemptRequired__c = hasActiveCompetitorPrimary;

        return con;
    }

    public Boolean checkforExistingKeybrand(List<BrandRelationship__c> relatedList, Id currentId, String currentBrand, String currentUser)  {
        Boolean hasActive = false;
        for(BrandRelationship__c brandRec : relatedList) {
            if (brandRec.Id != currentId && brandRec.KeyBrand__c == currentBrand && brandRec.User__c == currentUser) {
                hasActive = true;
                break;
            }
        }
        return hasActive;
    }

    public Boolean checkforExistingCompetitor(List<BrandRelationship__c> relatedList, Id currentId, String currentUser)  {
        Boolean hasActive = false;
        for(BrandRelationship__c brandRec : relatedList) {
            if (brandRec.Id != currentId && brandRec.ConsumingCompetitorBrand__c == true && brandRec.User__c == currentUser) {
                hasActive = true;
                break;
            }
        }
        return hasActive;
    }

    public void populateDuplicateChecker(BrandRelationship__c brandRec)  {
        brandRec.DuplicateChecker__c = null;
        if (brandRec.Active__c && brandRec.User__c != null) {
            brandRec.DuplicateChecker__c = brandRec.BrandRelationship__c + String.valueOf(brandRec.User__c) + String.valueOf(brandRec.Active__c);
        }
    }

    public Contact updateEndUserMarketField(Contact con, String keyBrand, Boolean activeValue) {
        if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_SIMILAC) {
            con.MCSimilacEndUser__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_GROW) {
            con.MCGrowEndUser__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_PEDIASURE) {
            con.MCPediasureEndUser__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_ENSURE) {
            con.MCEnsureEndUser__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_GLUCERNA) {
            con.MCGlucernaEndUser__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_OTHERS) {
            con.MCOthersEndUser__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_SIMILACMOM) {
            con.MCSimilacMomEndUser__c = activeValue;
        } 

        return con;
    }

    public Contact updatePrimaryContactMarketField(Contact con, String keyBrand, Boolean activeValue) {
        if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_SIMILAC) {
            con.MCSimilacMainContact__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_GROW) {
            con.MCGrowMainContact__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_PEDIASURE) {
            con.MCPediasureMainContact__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_ENSURE) {
            con.MCEnsureMainContact__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_GLUCERNA) {
            con.MCGlucernaMainContact__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_OTHERS) {
            con.MCOthersMainContact__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_SIMILACMOM) {
            con.MCSimilacMomMainContact__c = activeValue;
        }

        return con;
    }
    
    // Metnod that updates the Latest Brand Switch as User field in the Contact (User) if its current BR in the lookup field has been deleted
    // Populates the lookup field with the next latest BR that switched
    public void updateUserLatestBrandSwitchOnDelete(List<BrandRelationship__c> oldList) {
        Set<Id> conIds = new Set<Id>();
        List<Contact> contactsWithDeletedBrAsUser = new List<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for(BrandRelationship__c brRec : oldList) {
            conIds.add(brRec.User__c);
        }
        
        if(!conIds.isEmpty()) {
            contactsWithDeletedBrAsUser = [select Id, UserLatestBrandSwitch__c, (select Id from BrandRelationships__r where BrandSwitchDate__c != null order by BrandSwitchDate__c desc) 
                                           from Contact where Id in :conIds and UserLatestBrandSwitch__c = null];
            
            if(!contactsWithDeletedBrAsUser.isEmpty()) {
                for(Contact conRec : contactsWithDeletedBrAsUser) {
                    List<BrandRelationship__c> existingBRs = conRec.BrandRelationships__r;
                    if(!existingBRs.isEmpty()) {
                        conRec.UserLatestBrandSwitch__c = existingBRs[0].Id;
                        contactsToUpdate.add(conRec);
                    }
                }
                
                if(!contactsToUpdate.isEmpty()) {
                    update contactsToUpdate;
                }
            }
        }
    }
	
	public static void populateBrandUsedOnCase(Map<Id, BrandRelationship__c> brMap) {
        List<Case> casesToUpdate = new List<Case>();
        for(Case cRec : [SELECT ConvertedBR__c, CurrentBrandUsed__c, PreviousBrandUsed__c
                                   FROM Case
                                  WHERE ConvertedBR__c in :brMap.keySet()
                                    AND Status = 'New']) {
            cRec.CurrentBrandUsed__c = null;
            cRec.PreviousBrandUsed__c = null;
            if(Trigger.isUpdate) {
                cRec.CurrentBrandUsed__c = brMap.get(cRec.ConvertedBR__c).CurrentBrand__c;
                cRec.PreviousBrandUsed__c = brMap.get(cRec.ConvertedBR__c).PreviousBrand__c;
            }
            casesToUpdate.add(cRec);
        }

        if(!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    // Update MC Eligibility fields
    public static void updateMCEligibility(List<BrandRelationship__c> brList) {
        
        Set<Id> conIds = new Set<Id>();
        for(BrandRelationship__c br : brList){
            if(br.PrimaryContact__c != null){
                conIds.add(br.PrimaryContact__c);
            }
        }

      	Map<Id, Contact> contactMap = new Map<Id,Contact>([SELECT Id, Market__c,MC_Sync_Eligibility_ANZ__c,MC_Sync_Eligibility_ID__c,MC_Sync_Eligibility_IN__c, 
                                                           MC_Sync_Eligibility_MY__c, MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c,
                                                           MC_Sync_Eligibility_VN__c
                                                           FROM Contact 
                                                           WHERE Id IN :conIds]);
        
        for(BrandRelationship__c br: brList) {
            if(br.PrimaryContact__c != null){                
                String Market = contactMap.get(br.PrimaryContact__c).Market__c;
                    
                if(Market == CommonConstant.MARKET_ANZ){
                    br.MC_Sync_Eligibility_ANZ__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_ANZ__c;
                }else if(Market == CommonConstant.MARKET_ID){
                    br.MC_Sync_Eligibility_ID__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_ID__c;
                }else if(Market == CommonConstant.MARKET_IN){
                    br.MC_Sync_Eligibility_IN__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_IN__c;
                }else if(Market == CommonConstant.MARKET_MY){
                    br.MC_Sync_Eligibility_MY__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_MY__c;
                }else if(Market == CommonConstant.MARKET_PH){
                    br.MC_Sync_Eligibility_PH__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_PH__c;
                }else if(Market == CommonConstant.MARKET_SG){
                    br.MC_Sync_Eligibility_SG__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_SG__c;
                }else if(Market == CommonConstant.MARKET_TH){
                    br.MC_Sync_Eligibility_TH__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_TH__c;
                }else if(Market == CommonConstant.MARKET_VN){
                    br.MC_Sync_Eligibility_VN__c = contactMap.get(br.PrimaryContact__c).MC_Sync_Eligibility_VN__c;
                } 
            }  
        }
    }

    private static void populateTransactionDate(List<BrandRelationship__c> brList){
        Set<Id> conIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        // get all contact and product ids
        for(BrandRelationship__c br: brList){
            conIds.add(br.PrimaryContact__c);
            productIds.add(br.BrandRelationship__c);
        }

        // create map of contact and products
        Map<String, List<OrderItem>> contactProductMap = new Map<String, List<OrderItem>>();
        for(OrderItem oi: [SELECT Order.EndDate, Order.OrderedBy__c, Product2.BrandRelationshipLink__c, BrandRelationshipLinkStatus__c
                             FROM OrderItem
                            WHERE Order.Status =: CommonConstant.ORDER_STATUS_COMPLETED
                              AND Order.OrderedBy__c IN: conIds
                              AND Product2.BrandRelationshipLink__c IN: productIds]) {
            String key = oi.Order.OrderedBy__c + '-' + oi.Product2.BrandRelationshipLink__c;
            if(!contactProductMap.containsKey(key)){
                contactProductMap.put(key, new List<OrderItem>());
            }
            contactProductMap.get(key).add(oi);
        }

        List<OrderItem> oiList = new List<OrderItem>();
        for(BrandRelationship__c br: brList){
            String key = br.PrimaryContact__c + '-' + br.BrandRelationship__c;
            if(contactProductMap.containsKey(key)){
                for(OrderItem oi: contactProductMap.get(key)){

                    // check first transaction date
                    if(br.FirstTransactionDate__c == null
                        || (br.FirstTransactionDate__c != null 
                            && br.FirstTransactionDate__c > oi.Order.EndDate)){
                        br.FirstTransactionDate__c = oi.Order.EndDate;
                    }

                    // check latest transaction date
                    if(br.LatestTransactionDate__c == null
                        || (br.LatestTransactionDate__c != null 
                            && br.LatestTransactionDate__c < oi.Order.EndDate)
                        ){
                        br.LatestTransactionDate__c = oi.Order.EndDate;
                    }
                }
            }
        }
    }

    public void populateHousehold(List<BrandRelationship__c> brList) {
        Set<Id> cIds = new Set<Id>();

        for(BrandRelationship__c br : brList) {
            cIds.add(br.PrimaryContact__c);
        }

        Map<Id, Contact> con = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :cIds]);

        for(BrandRelationship__c br : brList) {
            br.Household__c = con.get(br.PrimaryContact__c).AccountId;
        }
    }
    /*====================================================================================
    Method Name: updateBirthHospital
    Author Name: Narence Valencia
    Description: This method update Birth_Hospital_Description__c.
    ======================================================================================*/

    public static void updateBirthHospital(List<BrandRelationship__c> brlist){
        
        Set<Id> Cid = new Set<Id>();
        for(BrandRelationship__c br : brlist){
            Cid.add(br.User__c);
        }

        Map<Id, Contact> cLst = new Map<Id, Contact>([Select Id,BirthHospital__r.Description__c from Contact where id in :Cid]);
        
        for(BrandRelationship__c br : brlist){
            if(br.User__c != null){
               contact cs = cLst.get(br.User__c);
               br.Birth_Hospital_Description__c = cs.BirthHospital__r.Description__c;
            }
            else{
                br.Birth_Hospital_Description__c = null;
            }
        }
    }


    /*====================================================================================
    Method Name: updateCrFields
    Author Name: Narence Valencia
    Description: This method update br related cr.
    ======================================================================================*/

    public static void updateCrFields(List<BrandRelationship__c> brlist){

        Set<Id> Bid = new Set<Id>();
        Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>();
        for(BrandRelationship__c br : brlist){
            Bid.add(br.Id);
            brMap.put(br.Id, br);
        }

        List<ChannelResponse__c> crList = [Select Id,BR_Last_Status__c,BR_last_Type__c,BR_Last_Updated_Date__c,BrandRelationship__c from ChannelResponse__c 
        where BrandRelationship__c in :Bid 
        ORDER BY RegistrationDate__c DESC, CreatedDate DESC LIMIT 1];

        List<ChannelResponse__c> updateCrList = new  List<ChannelResponse__c>();

        for(ChannelResponse__c cr : crList){
            cr.BR_Last_Status__c = brMap.get(cr.BrandRelationship__c).status__c;
            cr.BR_last_Type__c = brMap.get(cr.BrandRelationship__c).Type__c;
            cr.BR_Last_Updated_Date__c = String.valueOf(date.today());
            updateCrList.add(cr);
        }

        if(!updateCrList.isEmpty()){
            update updateCrList;
        }
    }

    public static void updateChildEndUserCount(List<BrandRelationship__c> brlist, Map<Id, SObject> oldMapItems){
        Id conChildRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        Map<Id, Contact> conUpdateMap = new Map<Id, Contact>();
        Set<Id> endUserId = new Set<Id>();
        for(BrandRelationship__c br : brlist){
            endUserId.add(br.User__c);
            if(Trigger.isUpdate){
                BrandRelationship__c old = (BrandRelationship__c) oldMapItems.get(br.Id);
                endUserId.add(old.User__c);
            }
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