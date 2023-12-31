public class CommonObjectWrapper {

    public class cls_PrimaryContact{
        //@AuraEnabled public String primaryMarket{get;set;}
        @AuraEnabled public String primarySalutation{get;set;}
        @AuraEnabled public String primaryFirstName{get;set;}
        @AuraEnabled public String primaryMiddleName{get;set;}
        @AuraEnabled public String primaryLastName{get;set;}
        @AuraEnabled public String primarySuffix{get;set;}
        @AuraEnabled public Date primaryBirthdate{get;set;}
        @AuraEnabled public String primaryProfession{get;set;}
        @AuraEnabled public String primaryEmail{get;set;}
        @AuraEnabled public String primaryHomePhone{get;set;}
        @AuraEnabled public String primaryGender{get;set;}
        @AuraEnabled public Id primaryEthnicity{get;set;}
        @AuraEnabled public Id primaryLanguage{get;set;}
        @AuraEnabled public Id primaryAfterBirthCareCenter{get;set;}
        @AuraEnabled public Id primaryEnrolledBy{get;set;}
        @AuraEnabled public String primaryMobilePhone{get;set;}
        @AuraEnabled public String primaryOfficePhone{get;set;}
        @AuraEnabled public String primaryOtherPhone{get;set;}
        @AuraEnabled public String primaryPurchaseChannel{get;set;}
        @AuraEnabled public String primarySecondaryPurchaseChannel{get;set;}
        @AuraEnabled public Boolean primaryMasterOptOut{get;set;}
        @AuraEnabled public Boolean primaryEmailOptOut{get;set;}
        @AuraEnabled public Boolean primaryWhatsAppOptOut{get;set;}
        @AuraEnabled public Boolean primaryDoNotCall{get;set;}
        @AuraEnabled public Boolean primarySMSOptOut{get;set;}
        @AuraEnabled public Boolean primaryDataShareOptOut{get;set;}
        @AuraEnabled public String primaryPreferredPaymentMethod{get;set;}
        @AuraEnabled public Integer primaryHeight{get;set;}
        //@AuraEnabled public String primaryMainMedicalCondition{get;set;}
        @AuraEnabled public Date primaryEstimatedDueDate{get;set;}
        @AuraEnabled public Integer primaryWeight{get;set;}
        @AuraEnabled public Decimal primaryCaloriesDay{get;set;}
        //@AuraEnabled public String primaryMembershipID{get;set;}
        @AuraEnabled public Date primaryMembershipStartDate{get;set;}
        @AuraEnabled public Boolean primaryTagging{get;set;}
        @AuraEnabled public String primaryPreferredContactTime{get;set;}
        @AuraEnabled public String primaryPreferredPhone{get;set;}
        @AuraEnabled public Boolean primaryVerified{get;set;}
        @AuraEnabled public String primaryCarerPhone{get;set;}
        @AuraEnabled public String primaryOccupation{get;set;}
        @AuraEnabled public String primaryExternalLoyaltyID{get;set;}
        @AuraEnabled public Datetime primarySourceCreatedDate{get;set;}
        @AuraEnabled public String primaryExternalReferenceNumber{get;set;}
        @AuraEnabled public String primaryConsumerResponse{get;set;}
        @AuraEnabled public String primaryEducationLevel{get;set;}
        @AuraEnabled public String primaryMonthlyExpense{get;set;}
        @AuraEnabled public String primaryFamilyDiabetesHistory{get;set;}
        @AuraEnabled public String primaryLungDiseaseName{get;set;}
        @AuraEnabled public String primaryRenalDiseaseType{get;set;}
    }

    public class cls_Address{
        @AuraEnabled public String addressStreet1{get;set;}
        @AuraEnabled public String addressStreet2{get;set;}
        @AuraEnabled public Id addressCity{get;set;}
        @AuraEnabled public String addressStateProvince{get;set;}
        @AuraEnabled public String addressPostalCode{get;set;}
        @AuraEnabled public String addressCountry{get;set;}
        @AuraEnabled public Boolean addressDefaultAddress{get;set;}
        @AuraEnabled public String addressType{get;set;}
        @AuraEnabled public Id addressRegion{get;set;}
        @AuraEnabled public Id addressDistrict{get;set;}
        @AuraEnabled public Id addressWard{get;set;}
        @AuraEnabled public Id addressSubDistrict{get;set;}
        @AuraEnabled public String addressBuilding{get;set;}
        @AuraEnabled public String addressVillageNo{get;set;}
        @AuraEnabled public String addressVillageName{get;set;}
        @AuraEnabled public String addressRoad{get;set;}
        @AuraEnabled public String addressValidationStatus{get;set;}
        @AuraEnabled public String addressUnitNo{get;set;}
        @AuraEnabled public Id addressState{get;set;}
        @AuraEnabled public Id addressSuburbTown{get;set;}
    }

    public class cls_AdultContact{  
        @AuraEnabled public String adultSalutation{get;set;}      
        @AuraEnabled public String adultFirstName{get;set;}
        @AuraEnabled public String adultMiddleName{get;set;}
        @AuraEnabled public String adultLastName{get;set;}
        @AuraEnabled public String adultSuffix{get;set;}
        @AuraEnabled public Date adultBirthdate{get;set;}
        @AuraEnabled public String adultProfession{get;set;}
        @AuraEnabled public String adultEmail{get;set;}
        @AuraEnabled public String adultHomePhone{get;set;}
        @AuraEnabled public String adultMainContact{get;set;}
        @AuraEnabled public String adultGender{get;set;}
        @AuraEnabled public Id adultEthnicity{get;set;}
        @AuraEnabled public Id adultLanguage{get;set;}
        @AuraEnabled public Id adultAfterBirthCareCenter{get;set;}
        @AuraEnabled public Id adultEnrolledBy{get;set;}
        @AuraEnabled public String adultPrimaryPurchaseChannel{get;set;}
        @AuraEnabled public String adultSecondaryPurchaseChannel{get;set;}
        //@AuraEnabled public String adultMobilePhone{get;set;}
        @AuraEnabled public Boolean adultMasterOptOut{get;set;}
        @AuraEnabled public Boolean adultEmailOptOut{get;set;}
        @AuraEnabled public Boolean adultWhatsAppOptOut{get;set;}
        @AuraEnabled public Boolean adultDoNotCall{get;set;}
        @AuraEnabled public Boolean adultSMSOptOut{get;set;}
        @AuraEnabled public Boolean adultDataShareOptOut{get;set;}
        @AuraEnabled public String adultPreferredPaymentMethod{get;set;}
        @AuraEnabled public Integer adultHeight{get;set;}
        //@AuraEnabled public String adultMainMedicalCondition{get;set;}
        @AuraEnabled public Date adultEstimatedDueDate{get;set;}
        @AuraEnabled public Integer adultWeight{get;set;}
        @AuraEnabled public Decimal adultCaloriesDay{get;set;}
        //@AuraEnabled public String adultMembershipID{get;set;}
        @AuraEnabled public Date adultMembershipStartDate{get;set;}
        @AuraEnabled public String adultPreferredContactTime{get;set;}
        @AuraEnabled public Boolean adultSecondaryVerified{get;set;}
        @AuraEnabled public String adultCustomerRelationship{get;set;}
        @AuraEnabled public String adultOccupation{get;set;}
        @AuraEnabled public String adultMobilePhone{get;set;}
        @AuraEnabled public String adultConsumerResponse{get;set;}
        @AuraEnabled public String adultEducationLevel{get;set;}
        @AuraEnabled public String adultMonthlyExpsense{get;set;}
        @AuraEnabled public String adultFamilyDiabetesHistory{get;set;}
        @AuraEnabled public String adultLungDiseaseName{get;set;}
        @AuraEnabled public String adultRenalDiseaseType{get;set;}
    }

    public class cls_ChildContact{        
        @AuraEnabled public String childSalutation{get;set;}
        @AuraEnabled public String childFirstName{get;set;}
        @AuraEnabled public String childMiddleName{get;set;}
        @AuraEnabled public String childLastName{get;set;}
        @AuraEnabled public String childSuffix{get;set;}
        @AuraEnabled public Date childBirthdate{get;set;}
        @AuraEnabled public Id childBirthHospital{get;set;}
        @AuraEnabled public Id childEnrolledBy{get;set;}
        @AuraEnabled public String childMainContact{get;set;}
        @AuraEnabled public String childGender{get;set;}
        @AuraEnabled public Integer childHeight{get;set;}
        @AuraEnabled public String childHeightForAge{get;set;}
        @AuraEnabled public String childMainMedicalCondition{get;set;}
        @AuraEnabled public Integer childWeight{get;set;}
        @AuraEnabled public String childWeightForAge{get;set;}
        @AuraEnabled public String childWeightForHeight{get;set;}
        @AuraEnabled public Decimal childCaloriesDay{get;set;}
        @AuraEnabled public Boolean childVerified{get;set;}
        @AuraEnabled public String childAgeRange{get;set;}
        @AuraEnabled public String childCustomerRelationship{get;set;}
    }

    public class cls_BrandRelationship{
        @AuraEnabled public Id brBrandRelationship{get;set;}
        @AuraEnabled public Id brBrandSwitchReason{get;set;}
        @AuraEnabled public String brType{get;set;}
        @AuraEnabled public Boolean brWinBack{get;set;}
        @AuraEnabled public String brProductLoyaltyLength{get;set;}
        @AuraEnabled public String brProductExperience{get;set;}
        @AuraEnabled public Id brCurrentPreviousBrand{get;set;}
        @AuraEnabled public String brStatus{get;set;}
        @AuraEnabled public Date brDateFirstUsed{get;set;}
        @AuraEnabled public Id brSKU{get;set;}
        @AuraEnabled public String brServingSchedule{get;set;}
        @AuraEnabled public Integer brServingPerDay{get;set;}
        @AuraEnabled public String brPreferredFlavor{get;set;}
        @AuraEnabled public String brMilkWaterMixture{get;set;}
        @AuraEnabled public Integer brScoopPerServing{get;set;}
        @AuraEnabled public String brRouteOfFeeding{get;set;}
        @AuraEnabled public Integer brCanPerMonth{get;set;}
        @AuraEnabled public Boolean brBrandOptOut{get;set;}
        @AuraEnabled public Boolean brProductBenefitsExplained{get;set;}
        @AuraEnabled public String brRating{get;set;}
        @AuraEnabled public String brRemarks{get;set;}
        @AuraEnabled public Id brPreviousBrand{get;set;}
        @AuraEnabled public Boolean brCareGiver{get;set;}
        @AuraEnabled public Boolean brGiftGiver{get;set;}
        @AuraEnabled public Boolean brEndUser{get;set;}
        @AuraEnabled public String brBrandUsageReason{get;set;}
    }

    public class cls_ChannelResponse{
        @AuraEnabled public Id crChannel{get;set;}
        @AuraEnabled public Id crCampaign{get;set;}
        @AuraEnabled public Datetime crRegistrationDate{get;set;}
		@AuraEnabled public String crPromoterName{get;set;}
        @AuraEnabled public String crPromoterCode{get;set;}
        @AuraEnabled public String crSupervisorName{get;set;}
        @AuraEnabled public String crSupervisorCode{get;set;}
        @AuraEnabled public Boolean crSampleRequested{get;set;}
        @AuraEnabled public String crOrderCreationStatus{get;set;}
        @AuraEnabled public Id crDeliveryAddress{get;set;}
        @AuraEnabled public Id crProductSampleRequested{get;set;}
        @AuraEnabled public String crHCPClassification{get;set;}
        @AuraEnabled public String crHCPName{get;set;}
        @AuraEnabled public String crCustomerSpecialty{get;set;}
        @AuraEnabled public Boolean crGrowthGuideAppSubmitted{get;set;}
        @AuraEnabled public Id crBirthHospital{get;set;}
        @AuraEnabled public Id crAfterBirthCareCenter{get;set;}
        @AuraEnabled public Id crEnrolledBy{get;set;}
        @AuraEnabled public String crItemTypeRequested{get;set;}
        @AuraEnabled public String crSampleRedemptionMethod{get;set;}
        @AuraEnabled public String crNonDeliveryRedemptionResult{get;set;}
        @AuraEnabled public Datetime crNonDeliveryRedemptionDate{get;set;}
        @AuraEnabled public Id crDrugStoreRedemptionChoice{get;set;}
    }

    public class cls_Case{
        @AuraEnabled public Id caseRecordType{get;set;}
        @AuraEnabled public Id caseContactId{get;set;}
        @AuraEnabled public String caseClassification{get;set;}
        @AuraEnabled public String caseStatus{get;set;}
        @AuraEnabled public Id caseAccountId{get;set;}
        @AuraEnabled public String casePriority{get;set;}
        @AuraEnabled public String caseSubClassification{get;set;}
        @AuraEnabled public String caseOrigin{get;set;}
        @AuraEnabled public String caseSubject{get;set;}
        @AuraEnabled public String caseDescription{get;set;}
        @AuraEnabled public Id caseOrder{get;set;}
        @AuraEnabled public Id caseParentId{get;set;}
        @AuraEnabled public String caseResolutionNotes{get;set;}
        @AuraEnabled public Id caseProduct{get;set;}
        @AuraEnabled public Id caseEscalatedTo{get;set;}
        @AuraEnabled public String caseBatchNumber{get;set;}
        @AuraEnabled public Id caseEndUserName{get;set;}
        @AuraEnabled public Id caseCurrentBrandUsed{get;set;}
        @AuraEnabled public Integer caseConsumption{get;set;}
        @AuraEnabled public Id caseCaregiverName{get;set;}
        @AuraEnabled public String casePackageSize{get;set;}
        @AuraEnabled public String caseCurrentMedicalCondition{get;set;}
        @AuraEnabled public Integer caseReopenCount{get;set;}
        @AuraEnabled public Boolean caseResolved{get;set;}
        @AuraEnabled public String caseReopenNotes{get;set;}
        @AuraEnabled public Id caseCampaign{get;set;}
        @AuraEnabled public String caseLoyaltyCardNumber{get;set;}
        @AuraEnabled public Boolean caseFollowUpCall{get;set;}
        @AuraEnabled public Datetime casePreferredDateTime{get;set;}
        @AuraEnabled public String caseReasonForCallback{get;set;}
        @AuraEnabled public String caseWebEmail{get;set;}
        @AuraEnabled public String caseRetention{get;set;}
        @AuraEnabled public Boolean caseProductReplacement{get;set;}
        @AuraEnabled public Boolean caseCustomerCertification{get;set;}
        @AuraEnabled public String caseProductReplacementStatus{get;set;}
        @AuraEnabled public Id caseStoreWherePurchased{get;set;}
        @AuraEnabled public Date caseManufacturingDate{get;set;}
        @AuraEnabled public Date caseDatePurchased{get;set;}
        @AuraEnabled public Boolean caseFileToTrackwise{get;set;}
        @AuraEnabled public String caseVariant{get;set;}
        @AuraEnabled public String caseLotNumber{get;set;}
        @AuraEnabled public Date caseExpiryDate{get;set;}
        @AuraEnabled public Date caseDateOpenedUsed{get;set;}
        @AuraEnabled public Boolean caseSocialCase{get;set;}
        @AuraEnabled public Datetime caseSourceCreatedDate{get;set;}
        @AuraEnabled public Id caseReplacementProduct{get;set;}
        @AuraEnabled public Id caseCaseRegarding{get;set;}
        @AuraEnabled public String caseReplyVia{get;set;}
        @AuraEnabled public String caseEnquirerType{get;set;}
        @AuraEnabled public String caseComplexity{get;set;}
        @AuraEnabled public Id caseReviewedBy{get;set;}
        @AuraEnabled public Date caseReviewedDate{get;set;}
        @AuraEnabled public Date caseAbbottAwarenessDate{get;set;}
        @AuraEnabled public Date caseDateofPackaging{get;set;}
        @AuraEnabled public String caseTimeCode{get;set;}
        @AuraEnabled public Date caseDateofIncident{get;set;}
        @AuraEnabled public String casePackCondition{get;set;}
        @AuraEnabled public String caseTrackwiseID{get;set;}
        @AuraEnabled public String caseRecommendedBy{get;set;}
        @AuraEnabled public String caseAdditionalObservation{get;set;}
        @AuraEnabled public Boolean caseSampleAvailability{get;set;}
        @AuraEnabled public Boolean caseResponseLetterisRequired{get;set;}
        @AuraEnabled public String caseUsageDetails{get;set;}
        @AuraEnabled public Id caseNutritionHistory{get;set;}
        @AuraEnabled public String caseLevelofEscalation{get;set;}
        @AuraEnabled public String caseReminderStatus{get;set;}
        @AuraEnabled public Id caseState
{get;set;}
        @AuraEnabled public Integer caseQuantity{get;set;}
        @AuraEnabled public Date caseProductReplacementDeliveredDate{get;set;}
    }

    public class cls_SummarizedOrder{
        @AuraEnabled public String sOrderNumber{get;set;}
        @AuraEnabled public String sOrderContactRefNo{get;set;}
        @AuraEnabled public String sOrderName{get;set;}
        @AuraEnabled public String sOrderStreet1{get;set;}
        @AuraEnabled public String sOrderStreet2{get;set;}
        @AuraEnabled public String sOrderWard{get;set;}
        @AuraEnabled public String sOrderDistrict{get;set;}
        @AuraEnabled public String sOrderCity{get;set;}
        @AuraEnabled public String sOrderHomePhone{get;set;}
        @AuraEnabled public String sOrderMobile{get;set;}
        @AuraEnabled public String sOrderOtherPhone{get;set;}
        @AuraEnabled public String sOrderRelatedCampaign{get;set;}
        @AuraEnabled public String sOrderProductNumber{get;set;}
        @AuraEnabled public String sOrderProductCode{get;set;}
        @AuraEnabled public Decimal sOrderTotalQuantity{get;set;}
        @AuraEnabled public String sOrderProductName{get;set;}
        @AuraEnabled public String sOrderPromotion{get;set;}
        @AuraEnabled public String sOrderUnitPrice{get;set;}
        @AuraEnabled public Decimal sOrderAmount{get;set;}
        @AuraEnabled public Date sOrderStartDate{get;set;}
        @AuraEnabled public Date sOrderExportDate{get;set;}
        @AuraEnabled public String sOrderCreatedBy{get;set;}
        @AuraEnabled public String sOrderKeyBrand{get;set;}
        @AuraEnabled public String sOrderNotes{get;set;}
        @AuraEnabled public String sOrderRegion{get;set;}
        @AuraEnabled public String sOrderType{get;set;}
        @AuraEnabled public String sOrderStatus{get;set;}
        @AuraEnabled public String sOrderPaymentMethod{get;set;}
        @AuraEnabled public String sOrderCaseNumber{get;set;}
        @AuraEnabled public String sOrderOrderedFor{get;set;}
        @AuraEnabled public String sOrderCategory{get;set;}
        @AuraEnabled public String sOrderForName{get;set;}
        @AuraEnabled public String sOrderPostalCode{get;set;}
        @AuraEnabled public Date sOrderPreferredDeliveryDate{get;set;}
        @AuraEnabled public String sOrderPreferredDeliveryTime{get;set;}
        
    }
    
    public class cls_ExperianAddress{
        @AuraEnabled public String expStreet1{get;set;}
        @AuraEnabled public String expBuilding{get;set;}
        @AuraEnabled public String expState{get;set;}
        @AuraEnabled public String expPostCode{get;set;}
        @AuraEnabled public String expSubBuilding{get;set;}
    }
}