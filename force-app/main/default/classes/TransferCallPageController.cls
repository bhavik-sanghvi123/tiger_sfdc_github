/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Controller Class for TransferCallPage

History
07/03/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/

public without sharing class TransferCallPageController {

    /***
    This method gets the login user's market to be used on query filters.
    ***/
	@AuraEnabled
    public static String fetchUserMarket() {
        String userMarket = [SELECT Id, Market__c FROM User WHERE Id =: userInfo.getUserId()].Market__c;
        return userMarket;
    }

    /***
    This method gets the Preferred Language associated to the Case's Contact.
    Preferred Language will be used as filter to the list of User wherein the user can transfer the call.
    ***/
    @AuraEnabled
    public static Case fetchContact(String caseId) {
        Case caseRec = [SELECT Id, ContactId, Contact.PreferredLanguage__r.Name FROM Case WHERE Id =: caseId];
        return caseRec;
    }

    /***
    Returns the actual Affiliated Value Id of the Preferred Language
    ***/
    @AuraEnabled
    public static String fetchLanguage(String affiliateId) {
        String language = [SELECT Id, Name FROM Affiliate_Value__c WHERE Id =: affiliateId].Name;
        return language;
    }

    /***
    This method updates the Case Owner and Contact's Preferred Language based on user input.
    ***/
    @AuraEnabled
    public static void transferCall(String caseId, String ownerId, String reason, String contactId, String contactLanguage) {
        try {
            Contact conRec = new Contact();
            conRec.Id = contactId;
            conRec.PreferredLanguage__c = contactLanguage;
            update conRec;

            Case caseRec = new Case();
            caseRec.Id = caseId;
            caseRec.OwnerId = ownerId;
            caseRec.CallTransferReason__c = reason;
            update caseRec;
        } catch(DmlException dex) {
            throw new AuraHandledException(dex.getDmlMessage(0));
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

}