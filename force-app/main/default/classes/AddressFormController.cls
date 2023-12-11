/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Controller for AddressForm Lightning Component

History
08/02/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
public class AddressFormController {
    /**
    * Get login User details
    **/
    @AuraEnabled
    public static User fetchUserDetails() {
		User currentUser = [SELECT Id, Market__c FROM User WHERE Id =: userInfo.getUserId()];
		return currentUser;
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
    * Identify if user has access to a record
    **/
    @AuraEnabled
    public static Boolean getRecordAccess(String addressId) {
		UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userInfo.getUserId() AND RecordId = :addressId];
        return userAccess.HasEditAccess;
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
    * Get Address Details
    **/
    @AuraEnabled
    public static Address__c getAddressRecordDetails(String addressId) {
		Address__c addressRecord = [SELECT Id, Region__c, City2__c, District__c, SubDistrict__c, Ward2__c FROM Address__c WHERE Id =: addressId]; 
        return addressRecord;
    }
}