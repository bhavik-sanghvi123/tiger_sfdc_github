/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Controller Class for HouseholdAndContactCreatePage

History
01/28/2019   vmirandilla   Created
07/23/2019   vmirandilla   Updated: Added Primary and Secondary Purchase Channel 
                            on Adult Contact section
07/30/2019   vmirandilla   Updated: Added getProductDetails method
08/05/2019	 vmirandilla   Updated: Added getAddressDetails method
-------------------------------------------------------------------------------------------*/

public without sharing class HouseholdAndContactCreatePage_CC {

    /**
    * Fetch current user's role to restrict page access
    **/
    @AuraEnabled
    public static User fetchUser () {
       User currentUser = [SELECT Id, UserRole.Name, Market__c FROM User WHERE Id =: userInfo.getUserId()];
      
       return currentUser;
    }

    @AuraEnabled
    public static String fetchUserRole() {
        String userMarket;
        User currentUser = [SELECT Id, UserRole.Name FROM User WHERE Id =: userInfo.getUserId()];

        if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_MALAYSIA) {
            userMarket = CommonConstant.MARKET_MY;
        }
        else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_PHILIPPINES) {
            userMarket = CommonConstant.MARKET_PH;
        }
        else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_SINGAPORE) {
            userMarket = CommonConstant.MARKET_SG;
        }
        else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_THAILAND) {
            userMarket = CommonConstant.MARKET_TH;
        }
        else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_VIETNAM) {
            userMarket = CommonConstant.MARKET_VN;
        } 
        else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_INDIA) {
            userMarket = CommonConstant.MARKET_IN;
        }
        else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_ANZ) {
            userMarket = CommonConstant.MARKET_ANZ;
        }
        else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_INDONESIA) {
            userMarket = CommonConstant.MARKET_ID;
        }
        else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_ASEAPAC) {
            userMarket = CommonConstant.MARKET_ASEAPAC;
        }

        return userMarket;
    }

    /**
    * Return picklist values for Standard objects due as a workaround for current 
    * lightning issue when inputField is inside nested divs.
    **/
    @AuraEnabled
    public static List<String> getRelationshipTypePicklistValues (SObject obj, String fld) {
        List<String> options = new List<String> ();
        Schema.sObjectType objType = obj.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();   
        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        

        for( Schema.PicklistEntry f : values) {
            options.add(f.getValue());
        }       
       return options;
    }

    /**
    * This method is responsible for creating the Main Contact on the wizard
    * RecordType and Type is equal to Adult
    **/
    @AuraEnabled
    public static String savePrimaryContactAndHousehold(String params, String accountId) 
    {
        //Contact Record Type Ids
        Id adultRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_ADULT_RECORDTYPE).getRecordTypeId();
        String userRoleName = fetchUserRole();
        CommonObjectWrapper.cls_PrimaryContact conWrapper = (CommonObjectWrapper.cls_PrimaryContact)JSON.deserialize(params, CommonObjectWrapper.cls_PrimaryContact.class);
        String customError; 
        List<Contact> contactDupList = [SELECT Id, FirstName, LastName, Phone 
                                        FROM Contact
                                        WHERE Phone = :conWrapper.primaryMobilePhone AND Market__c = :userRoleName];

        Contact primaryCon = new Contact();
        Account household = new Account();

        if(!contactDupList.isEmpty()) {
            customError = 'isError';
            return customError;
        }
        
        if (conWrapper != null){
            //Account id is null if wizard entry point is the Add Main Contact tab
            if(accountId == null) {
                household.Name = conWrapper.primaryLastName;

                try {
                    insert household;
                }
                catch (DmlException e){
                    throw new AuraHandledException(e.getDmlMessage(0));
                }
            }

            if(accountId != null) {
                primaryCon.AccountId = accountId;
            } else {
                primaryCon.AccountId = household.Id;
            }

            primaryCon.Type__c  = CommonConstant.CONTACT_ADULT_TYPE;
            primaryCon.PrimaryContact__c = conWrapper.primaryTagging;
            primaryCon.RecordTypeId = adultRecType;
            primaryCon.Salutation = conWrapper.primarySalutation;
            primaryCon.FirstName = conWrapper.primaryFirstName;
            primaryCon.MiddleName = conWrapper.primaryMiddleName;
            primaryCon.LastName = conWrapper.primaryLastName;
            primaryCon.Suffix = conWrapper.primarySuffix;
            primaryCon.Profession__c = conWrapper.primaryProfession;
            primaryCon.Email = conWrapper.primaryEmail;
            primaryCon.HomePhone = conWrapper.primaryHomePhone;
            primaryCon.Gender__c = conWrapper.primaryGender;
            primaryCon.Ethnicity__c = conWrapper.primaryEthnicity;
            primaryCon.PreferredLanguage__c = conWrapper.primaryLanguage;
            // primaryCon.AfterBirthCareCenter__c = conWrapper.primaryAfterBirthCareCenter;
            primaryCon.BirthHospital__c = conWrapper.primaryAfterBirthCareCenter;
            primaryCon.EnrolledBy__c = conWrapper.primaryEnrolledBy;
            primaryCon.Phone = conWrapper.primaryMobilePhone;
            primaryCon.PrimaryPurchaseChannel__c = conWrapper.primaryPurchaseChannel;
            primaryCon.SecondaryPurchaseChannel__c = conWrapper.primarySecondaryPurchaseChannel;
            primaryCon.MasterOptOut__c = conWrapper.primaryMasterOptOut;
            primaryCon.HasOptedOutOfEmail = conWrapper.primaryEmailOptOut;
            primaryCon.DoNotCall = conWrapper.primaryDoNotCall;
            primaryCon.SMSOptOut__c = conWrapper.primarySMSOptOut;
            primaryCon.DataSharingWithThirdPartyOptOut__c = conWrapper.primaryDataShareOptOut;
            primaryCon.PreferredPaymentMethod__c = conWrapper.primaryPreferredPaymentMethod;
            primaryCon.KCalDay__c = conWrapper.primaryCaloriesDay;
            primaryCon.Birthdate = conWrapper.primaryBirthdate; 
            primaryCon.Height__c = conWrapper.primaryHeight;
            primaryCon.EstimatedDueDate__c  = conWrapper.primaryEstimatedDueDate;
            primaryCon.Weight__c = conWrapper.primaryWeight;
            primaryCon.MembershipStartDate__c = conWrapper.primaryMembershipStartDate;
            primaryCon.PreferredContactTime__c = conWrapper.primaryPreferredContactTime;
            primaryCon.OtherPhone = conWrapper.primaryOtherPhone;
            primaryCon.Office_Phone__c = conWrapper.primaryOfficePhone;
            primaryCon.PreferredPhone__c = conWrapper.primaryPreferredPhone;
            primaryCon.Verified__c = conWrapper.primaryVerified;
            primaryCon.CarerPhone__c = conWrapper.primaryCarerPhone;
            primaryCon.Occupation__c = conWrapper.primaryOccupation;
            primaryCon.ExternalLoyaltyID__c = conWrapper.primaryExternalLoyaltyID;
            primaryCon.SourceCreatedDate__c = conWrapper.primarySourceCreatedDate;
            primaryCon.ExternalReferenceNumber__c = conWrapper.primaryExternalReferenceNumber;
            primaryCon.Consumer_Response__c = conWrapper.primaryConsumerResponse;
            primaryCon.Education_Level__c = conWrapper.primaryEducationLevel;
            primaryCon.Monthly_Expense__c = conWrapper.primaryMonthlyExpense;
            primaryCon.WhatsappOptOut__c = conWrapper.primaryWhatsAppOptOut;
            primaryCon.FamilyDiabetesHistory__c = conWrapper.primaryFamilyDiabetesHistory;
            primaryCon.LungDiseaseName__c = conWrapper.primaryLungDiseaseName;
            primaryCon.RenalDiseaseType__c = conWrapper.primaryRenalDiseaseType;
        }

        try {
            insert primaryCon;
            return primaryCon.Id;
        } 
        catch (DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    /**
    * This method is responsible for creating Address linked to the Main Contact
    * RecordType and Type is equal to Adult
    **/
    @AuraEnabled
    public static String saveAddress(String params, String primaryContactId) {
        CommonObjectWrapper.cls_Address addressWrapper = (CommonObjectWrapper.cls_Address)JSON.deserialize(params, CommonObjectWrapper.cls_Address.class);
    
        Address__c address = new Address__c();

        if (addressWrapper != null){
            address.Street1__c = addressWrapper.addressStreet1;
            address.Street2__c = addressWrapper.addressStreet2;
            address.City2__c = addressWrapper.addressCity;
            address.StateProvince__c = addressWrapper.addressStateProvince;
            address.PostalCode__c = addressWrapper.addressPostalCode;
            address.Country__c = addressWrapper.addressCountry;
            address.DefaultAddress__c = addressWrapper.addressDefaultAddress;
            address.AddressType__c = addressWrapper.addressType;
            address.Region__c = addressWrapper.addressRegion;
            address.District__c = addressWrapper.addressDistrict;
            address.Ward2__c = addressWrapper.addressWard;
            address.ParentContact__c = primaryContactId;
            address.SubDistrict__c = addressWrapper.addressSubDistrict;
            address.Building__c = addressWrapper.addressBuilding;
            address.VillageNo__c= addressWrapper.addressVillageNo;
            address.VillageName__c = addressWrapper.addressVillageName;
            address.Road__c = addressWrapper.addressRoad;
            address.AddressValidationStatus__c = addressWrapper.addressValidationStatus;
            address.UnitNumber__c = addressWrapper.addressUnitNo;
            address.State__c = addressWrapper.addressState;
            address.SuburbTown__c = addressWrapper.addressSuburbTown;
        }

        try {
            insert address;
        }
        catch (DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }

        return address.Id;
    }

    /**
    * This method is responsible for creating Secondary Contact linked to the Main Contact
    * RecordType and Type can either be Adult or Child depending on user's selection on the wizard.
    **/
    @AuraEnabled
    public static String saveAdditionalContact(String params, String primaryContactId, Boolean isAdult, Boolean isChild) 
    {
        //Contact Record Type Ids
        Id adultRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_ADULT_RECORDTYPE).getRecordTypeId();
        Id childRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_CHILD_RECORDTYPE).getRecordTypeId();
        
        List<Contact> householdList = new List<Contact>();
        Contact additionalCon = new Contact();
        List<Contact> contactDupList = new List<Contact>();

        if(isAdult) {
            CommonObjectWrapper.cls_AdultContact adultWrapper = (CommonObjectWrapper.cls_AdultContact)JSON.deserialize(params, CommonObjectWrapper.cls_AdultContact.class);

            if (adultWrapper != null){
                if(primaryContactId != null && primaryContactId != '') {
                    additionalCon.AccountId = [SELECT Id, AccountId FROM Contact WHERE Id = :primaryContactId].AccountId;
                    additionalCon.Parent__c = primaryContactId;
                } else {
                    additionalCon.AccountId = [SELECT Id, AccountId FROM Contact WHERE Id =: adultWrapper.adultMainContact].AccountId;
                    additionalCon.Parent__c = adultWrapper.adultMainContact;
                }
                additionalCon.Type__c   = CommonConstant.CONTACT_ADULT_TYPE;
                additionalCon.RecordTypeId = adultRecType;
                additionalCon.Salutation = adultWrapper.adultSalutation;
                additionalCon.FirstName = adultWrapper.adultFirstName;
                additionalCon.MiddleName = adultWrapper.adultMiddleName;
                additionalCon.LastName = adultWrapper.adultLastName;
                additionalCon.Suffix = adultWrapper.adultSuffix;
                additionalCon.Profession__c = adultWrapper.adultProfession;
                additionalCon.Email = adultWrapper.adultEmail;
                additionalCon.HomePhone = adultWrapper.adultHomePhone;                
                additionalCon.Gender__c = adultWrapper.adultGender;
                //additionalCon.NationalID__c = adultWrapper.adultNationalId;
                additionalCon.Ethnicity__c  = adultWrapper.adultEthnicity;
                additionalCon.PreferredLanguage__c  = adultWrapper.adultLanguage;
                // additionalCon.AfterBirthCareCenter__c  = adultWrapper.adultAfterBirthCareCenter;
                additionalCon.BirthHospital__c  = adultWrapper.adultAfterBirthCareCenter;
                additionalCon.EnrolledBy__c  = adultWrapper.adultEnrolledBy;
                additionalCon.PrimaryPurchaseChannel__c = adultWrapper.adultPrimaryPurchaseChannel;
                additionalCon.SecondaryPurchaseChannel__c = adultWrapper.adultSecondaryPurchaseChannel;
                //additionalCon.Phone = adultWrapper.adultMobilePhone;
                additionalCon.MasterOptOut__c = adultWrapper.adultMasterOptOut;
                additionalCon.HasOptedOutOfEmail = adultWrapper.adultEmailOptOut;
                additionalCon.DoNotCall = adultWrapper.adultDoNotCall;
                additionalCon.SMSOptOut__c  = adultWrapper.adultSMSOptOut;
                additionalCon.DataSharingWithThirdPartyOptOut__c = adultWrapper.adultDataShareOptOut;
                additionalCon.PreferredPaymentMethod__c = adultWrapper.adultPreferredPaymentMethod;
                //additionalCon.MainMedicalCondition__c   = adultWrapper.adultMainMedicalCondition;
                additionalCon.KCalDay__c = adultWrapper.adultCaloriesDay;
                additionalCon.Birthdate = adultWrapper.adultBirthdate;  
                additionalCon.Height__c = adultWrapper.adultHeight;
                additionalCon.EstimatedDueDate__c   = adultWrapper.adultEstimatedDueDate;
                additionalCon.Weight__c = adultWrapper.adultWeight;
                additionalCon.MembershipStartDate__c = adultWrapper.adultMembershipStartDate;  
                additionalCon.PreferredContactTime__c = adultWrapper.adultPreferredContactTime;           
                additionalCon.Verified__c = adultWrapper.adultSecondaryVerified;      
                additionalCon.CustomerRelationship__c = adultWrapper.adultCustomerRelationship;
                additionalCon.Occupation__c = adultWrapper.adultOccupation;
                additionalCon.Phone = adultWrapper.adultMobilePhone;
                additionalCon.Consumer_Response__c = adultWrapper.adultConsumerResponse;
                additionalCon.Education_Level__c = adultWrapper.adultEducationLevel;
                additionalCon.Monthly_Expense__c = adultWrapper.adultMonthlyExpsense;
                additionalCon.FamilyDiabetesHistory__c = adultWrapper.adultFamilyDiabetesHistory;
                additionalCon.LungDiseaseName__c = adultWrapper.adultLungDiseaseName;
                additionalCon.RenalDiseaseType__c = adultWrapper.adultRenalDiseaseType;
            }
        }

        else if(isChild) {
            CommonObjectWrapper.cls_ChildContact childWrapper = (CommonObjectWrapper.cls_ChildContact)JSON.deserialize(params, CommonObjectWrapper.cls_ChildContact.class);
            
            if (childWrapper != null){
                if(primaryContactId != null && primaryContactId != '' ) {
                    additionalCon.AccountId = [SELECT AccountId FROM Contact WHERE Id =: String.valueOf(primaryContactId)].AccountId;
                    additionalCon.Parent__c = Id.valueOf(primaryContactId);
                } else {
                    additionalCon.AccountId = [SELECT AccountId FROM Contact WHERE Id =: childWrapper.childMainContact].AccountId;
                    additionalCon.Parent__c = childWrapper.childMainContact;
                }
                additionalCon.Type__c   = CommonConstant.CONTACT_CHILD_TYPE;
                additionalCon.RecordTypeId = childRecType;
                additionalCon.Salutation = childWrapper.childSalutation;
                additionalCon.FirstName = childWrapper.childFirstName;
                additionalCon.MiddleName = childWrapper.childMiddleName;
                additionalCon.LastName = childWrapper.childLastName;
                additionalCon.Suffix = childWrapper.childSuffix;
                additionalCon.Gender__c = childWrapper.childGender;
                additionalCon.Birthdate = childWrapper.childBirthdate;
                additionalCon.BirthHospital__c = childWrapper.childBirthHospital;
                additionalCon.EnrolledBy__c = childWrapper.childEnrolledBy;
                //additionalCon.NationalID__c = childWrapper.childNationalId;
                additionalCon.Height__c = childWrapper.childHeight;
                additionalCon.HeightForAge__c = childWrapper.childHeightForAge;
                additionalCon.MainMedicalCondition__c   = childWrapper.childMainMedicalCondition;
                additionalCon.Weight__c = childWrapper.childWeight;
                additionalCon.WeightForAge__c = childWrapper.childWeightForAge;
                additionalCon.WeightForHeight__c = childWrapper.childWeightForHeight;
                additionalCon.KCalDay__c = childWrapper.childCaloriesDay;
                additionalCon.Verified__c = childWrapper.childVerified;
                additionalCon.AgeRange__c = childWrapper.childAgeRange;
                additionalCon.CustomerRelationship__c = childWrapper.childCustomerRelationship;
            }
        }

        try {
            insert additionalCon;
        }
        catch (DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }
            
        return additionalCon.Id;
    }

    /**
    * This method is responsible for creating Brand Relationship linked to the Main Contact and/or Secondary Contact
    * User can choose wether the End User is the Main Contact or the Secondary Contact in the wizard.
    **/
    @AuraEnabled
    public static String saveBrandRelationship(String params, String primaryContactId, String additionalContactId, Boolean noSecondaryContact, Boolean mapToPrimaryContact, Boolean mapToSecondaryContact, String mainContactId) {
        
        CommonObjectWrapper.cls_BrandRelationship brWrapper = (CommonObjectWrapper.cls_BrandRelationship)JSON.deserialize(params, CommonObjectWrapper.cls_BrandRelationship.class);
        List<Contact> householdList = new List<Contact>();

        BrandRelationship__c br = new BrandRelationship__c();

        if (brWrapper != null){

            if(mapToPrimaryContact || noSecondaryContact) {
                br.User__c = primaryContactId;
            } 
            else if(mapToSecondaryContact) {
                br.User__c = additionalContactId;
            }

            if(primaryContactId != null && primaryContactId != '') {
                br.Household__c = [SELECT Id, AccountId FROM Contact WHERE Id =: primaryContactId].AccountId;
                br.PrimaryContact__c = primaryContactId;
            }
            else if(mainContactId != null) {
                br.Household__c = [SELECT Id, AccountId FROM Contact WHERE Id =: mainContactId].AccountId;
                br.PrimaryContact__c = mainContactId;
            }
            
            br.Active__c = TRUE;
            br.BrandRelationship__c = brWrapper.brBrandRelationship;
            br.BrandSwitchReason__c = brWrapper.brBrandSwitchReason;
            br.Type__c = brWrapper.brType;
            br.WinBack__c = brWrapper.brWinBack;
            br.ProductLoyaltyLength__c = brWrapper.brProductLoyaltyLength;
            br.ProductExperience__c = brWrapper.brProductExperience;
            br.CurrentBrand__c = brWrapper.brCurrentPreviousBrand;
            br.Status__c = brWrapper.brStatus;
            br.DateFirstUsed__c = brWrapper.brDateFirstUsed;
            br.SKU__c = brWrapper.brSKU;
            br.ServingSchedule__c = brWrapper.brServingSchedule;
            br.Servingsperday__c = brWrapper.brServingPerDay;
            br.PreferredFlavour__c = brWrapper.brPreferredFlavor;
            br.MilkWaterMixturePercentage__c = brWrapper.brMilkWaterMixture;
            br.ScoopsPerServing__c = brWrapper.brScoopPerServing;
            br.RouteOfFeeding__c = brWrapper.brRouteOfFeeding;
            br.CansPerMonth__c = brWrapper.brCanPerMonth;
            br.BrandOptOut__c = brWrapper.brBrandOptOut;
            br.IsProductBenefitsExplained__c = brWrapper.brProductBenefitsExplained;
            br.Rating__c = brWrapper.brRating;
            br.Remarks__c = brWrapper.brRemarks;
            br.PreviousBrand__c = brWrapper.brPreviousBrand;
            br.CareGiver__c = brWrapper.brCareGiver;
            br.GiftGiver__c = brWrapper.brGiftGiver;
            br.EndUser__c = brWrapper.brEndUser;
            br.Brand_Usage_Reason__c = brWrapper.brBrandUsageReason;
        }

        try {
            //insert br;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        
            Database.insert(br, dml);

        }
        catch (DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }

        return br.Id;
    }

    /**
    * This method is responsible for creating Channel Response linked to Brand Relationshi[]
    **/
    @AuraEnabled
    public static String saveChannelResponse(String params, String brandRelationshipId) {
        
        CommonObjectWrapper.cls_ChannelResponse crWrapper = (CommonObjectWrapper.cls_ChannelResponse)JSON.deserialize(params, CommonObjectWrapper.cls_ChannelResponse.class);

        ChannelResponse__c cr = new ChannelResponse__c();

        if (crWrapper != null){
            cr.BrandRelationship__c = brandRelationshipId;
            cr.Channel__c = crWrapper.crChannel;
            cr.Campaign__c = crWrapper.crCampaign;
            cr.RegistrationDate__c = crWrapper.crRegistrationDate;
            cr.PromoterName__c = crWrapper.crPromoterName;
            cr.PromoterCode__c = crWrapper.crPromoterCode;
            cr.SupervisorName__c = crWrapper.crSupervisorName;
            cr.SupervisorCode__c = crWrapper.crSupervisorCode;
            cr.IsSample_Requested__c = crWrapper.crSampleRequested;
            cr.OrderCreationStatus__c = crWrapper.crOrderCreationStatus;
            cr.DeliveryAddress__c = crWrapper.crDeliveryAddress;
            cr.ProductSampleRequested__c = crWrapper.crProductSampleRequested;
            cr.HCPClassification__c = crWrapper.crHCPClassification;
            cr.HCPName__c = crWrapper.crHCPName;
            cr.CustomerSpeciality__c = crWrapper.crCustomerSpecialty;
            cr.GrowthGuideAppSubmitted__c = crWrapper.crGrowthGuideAppSubmitted;
            cr.BirthHospital__c = crWrapper.crBirthHospital;
            cr.AfterBirthCareCenter__c = crWrapper.crAfterBirthCareCenter;
            cr.EnrolledBy__c = crWrapper.crEnrolledBy;
            cr.ItemTypeRequested__c = crWrapper.crItemTypeRequested;
            cr.SampleRedemptionMethod__c = crWrapper.crSampleRedemptionMethod;
            cr.NonDeliveryRedemptionResult__c = crWrapper.crNonDeliveryRedemptionResult;
            cr.NonDeliveryRedemptionDate__c = crWrapper.crNonDeliveryRedemptionDate;
            cr.DrugStoreRedemptionChoice__c = crWrapper.crDrugStoreRedemptionChoice;
        }

        try {
            insert cr;
        }
        catch (DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }

        return cr.Id;
    }

    /**
    * This method is responsible for creating the Case Inquiry related to the call record
    * RecordType is Inquiry
    **/

    @AuraEnabled
    public static String saveCaseRecord(String params, String primaryContactId, String accountId, String recTypeName) 
    {   
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
        CommonObjectWrapper.cls_Case caseWrapper = (CommonObjectWrapper.cls_Case)JSON.deserialize(params, CommonObjectWrapper.cls_Case.class);
        
        Case caseRecord = new Case();
        
        if (caseWrapper != null){
            caseRecord.ContactId = primaryContactId;
            caseRecord.RecordTypeId = caseRecTypeId;
            caseRecord.Classification__c = caseWrapper.caseClassification;
            caseRecord.Status = caseWrapper.caseStatus;
            caseRecord.AccountId = accountId;
            caseRecord.Priority = caseWrapper.casePriority;
            caseRecord.SubClassification__c = caseWrapper.caseSubClassification;
            caseRecord.IsSocialCase__c = caseWrapper.caseSocialCase;
            caseRecord.Origin = caseWrapper.caseOrigin;
            caseRecord.Subject = caseWrapper.caseSubject;
            caseRecord.Description = caseWrapper.caseDescription;
            caseRecord.Order__c = caseWrapper.caseOrder;
            caseRecord.ParentId = caseWrapper.caseParentId;
            caseRecord.EscalatedTo__c = caseWrapper.caseEscalatedTo;
            caseRecord.Product__c = caseWrapper.caseProduct;
            caseRecord.BatchNumber__c = caseWrapper.caseBatchNumber;
            caseRecord.ProductPackageSize__c = caseWrapper.casePackageSize;
            caseRecord.ResolutionNotes__c= caseWrapper.caseResolutionNotes;
            caseRecord.ReopenCount__c = caseWrapper.caseReopenCount;
            caseRecord.ReopenNotes__c = caseWrapper.caseReopenNotes;
            caseRecord.ResolvedUponOpening__c = caseWrapper.caseResolved;
            caseRecord.FollowUpCallRequired__c = caseWrapper.caseFollowUpCall;
            caseRecord.PreferredDateTimeofCallback__c = caseWrapper.casePreferredDateTime;
            caseRecord.ReasonofRequestforCallback__c = caseWrapper.caseReasonForCallback;
            caseRecord.SuppliedEmail = caseWrapper.caseWebEmail;
            caseRecord.SourceCreatedDate__c = caseWrapper.caseSourceCreatedDate;
            caseRecord.CaseRegarding__c = caseWrapper.caseCaseRegarding;
            caseRecord.ReplyVia__c = caseWrapper.caseReplyVia;
            caseRecord.EnquirerType__c = caseWrapper.caseEnquirerType;
            caseRecord.Complexity__c = caseWrapper.caseComplexity;
            caseRecord.ReviewedBy__c = caseWrapper.caseReviewedBy;
            caseRecord.ReviewedDate__c = caseWrapper.caseReviewedDate;
            caseRecord.MedicalDiagnosis__c = caseWrapper.caseNutritionHistory;
            caseRecord.ReminderStatus__c = caseWrapper.caseReminderStatus;

            if(recTypeName == CommonConstant.CASE_INQUIRY_RECORDTYPE) {
                caseRecord.EndUserName__c = caseWrapper.caseEndUserName;
                caseRecord.CurrentBrandUsed__c = caseWrapper.caseCurrentBrandUsed;
                caseRecord.ConsumptionperMonthNoofCans__c = caseWrapper.caseConsumption;
                caseRecord.CaregiverName__c = caseWrapper.caseCaregiverName;
                caseRecord.LoyaltyCardNumber__c = caseWrapper.caseLoyaltyCardNumber;
            }
            
            else if(recTypeName == CommonConstant.CASE_FEEDBACK_RECORDTYPE) {
                caseRecord.Retention__c = caseWrapper.caseRetention;
                caseRecord.ProductReplacementRequired__c = caseWrapper.caseProductReplacement;
                caseRecord.CustomerCertificationAttached__c = caseWrapper.caseCustomerCertification;
                caseRecord.ProductReplacementStatus__c = caseWrapper.caseProductReplacementStatus;
                caseRecord.StoreWherePurchased__c = caseWrapper.caseStoreWherePurchased;
                caseRecord.ManufacturingDate__c = caseWrapper.caseManufacturingDate;
                caseRecord.DatePurchased__c = caseWrapper.caseDatePurchased;
                caseRecord.FiletoTrackwise__c = caseWrapper.caseFileToTrackwise;
                caseRecord.Variant__c = caseWrapper.caseVariant;
                caseRecord.LotNumber__c = caseWrapper.caseLotNumber;
                caseRecord.ExpiryDate__c = caseWrapper.caseExpiryDate;
                caseRecord.DateOpenedUsed__c = caseWrapper.caseDateOpenedUsed;
                caseRecord.ReplacementProduct__c = caseWrapper.caseReplacementProduct;
                caseRecord.AbbottAwarenessDate__c = caseWrapper.caseAbbottAwarenessDate;
                caseRecord.DateofPackaging__c = caseWrapper.caseDateofPackaging;
                caseRecord.TimeCode__c = caseWrapper.caseTimeCode;
                caseRecord.DateofIncident__c = caseWrapper.caseDateofIncident;
                caseRecord.PackCondition__c = caseWrapper.casePackCondition;
                caseRecord.TrackwiseID__c = caseWrapper.caseTrackwiseID;
                caseRecord.RecommendedBy__c = caseWrapper.caseRecommendedBy;
                caseRecord.AdditionalObservation__c = caseWrapper.caseAdditionalObservation;
                caseRecord.SampleAvailability__c = caseWrapper.caseSampleAvailability;
                caseRecord.ResponseLetterisRequired__c = caseWrapper.caseResponseLetterisRequired;
                caseRecord.UsageDetails__c = caseWrapper.caseUsageDetails;
                caseRecord.LevelofEscalation__c = caseWrapper.caseLevelofEscalation;
                caseRecord.State__c = caseWrapper.caseState;
                caseRecord.Quantity__c = caseWrapper.caseQuantity;
                caseRecord.ProductReplacementDeliveredDate__c = caseWrapper.caseProductReplacementDeliveredDate;
            }
        }

        try {
            insert caseRecord;
        } 
        catch (DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        
        return caseRecord.Id;
    }

    /**
    * This method is responsible for updated Case Feedback or Case Inquiry when Contact and related records are created
    **/
    @AuraEnabled
    public static void updateCaseRecord(String caseRecordId, String conRecordId) {
        Id accountId = [SELECT Id, AccountId FROM Contact WHERE Id =: conRecordId].AccountId;
		
        Case caseRec = new Case();
        caseRec.Id = caseRecordId;
        caseRec.ContactId = conRecordId;
        caseRec.AccountId = accountId;

        try {
            update caseRec;

        }
        catch (DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }
    

    /**
    * This method will identify if the Product hierarchy is a Competitor
    **/

    @AuraEnabled
    public static Boolean getProductHierarchyLevel(String productId) {
        Boolean isBrand = false;
        List<Product2> productList = [SELECT ID , ProductHierarchyLevel__c FROM Product2 WHERE ID =: productId];
        if(productList[0].ProductHierarchyLevel__c == 'Brand'){
            isBrand = true;
        }
        return isBrand;
    }

    
    
    /**
    * This method will identify if the Product is a Competitor
    **/
    @AuraEnabled
    public static String getProductDetails(String productId) {
        Boolean competitorBrand = [SELECT Id, CompetitorProduct__c FROM Product2 WHERE Id =: productId].CompetitorProduct__c;
		return String.valueOf(competitorBrand);
    }
    
    /**
    * Get Address details (text fields) by making an API Call
    **/
    @AuraEnabled
    public static CommonObjectWrapper.cls_ExperianAddress getAddressDetails(String postalCode, String unitNumber) {
		HttpResponse formatResponse =  ExperianCallout.getInfoFromExternalService(postalCode, unitNumber);
        CommonObjectWrapper.cls_ExperianAddress expAddress = ExperianResponseProcessor.processReponse(formatResponse);    
        return expAddress;
    }

    /**
    * Get Experian token
    **/
    @AuraEnabled
    public static String getExperianToken() {
		String token = [SELECT MasterLabel, DeveloperName, Token__c FROM AuthenticationToken__mdt WHERE DeveloperName = 'Experian_Token'].Token__c; 
        return token;
    }
    
    /**
    * Get Singapore City Affiliate Value
    **/
    @AuraEnabled
    public static String getAffiliateSingaporeCity() {
		Id singaporeId = [SELECT Id FROM Affiliate_Value__c WHERE RecordType.Name = :CommonConstant.AFFILIATE_CITY_RECORDTYPE AND Active__c = TRUE AND Name = 'Singapore' AND Market__c = :CommonConstant.MARKET_SG].Id; 
        return singaporeId;
    }

    /**
    * Get Metro Manila City Affiliate Value
    **/
    @AuraEnabled
    public static String getAffiliateCityName(String cityId) {
		String cityName = [SELECT Id,Name FROM Affiliate_Value__c WHERE Id = :cityId].Name; 
        String city;
        if(Label.PH_Cities.containsIgnoreCase(cityName)){
            city = 'Metro Manila';
        }
        return city;
    }
}