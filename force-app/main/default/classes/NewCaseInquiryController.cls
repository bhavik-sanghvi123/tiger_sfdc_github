public class NewCaseInquiryController{
    
    @AuraEnabled
    public static Case getCaseDetails(String caseId) {    
        
        Case caseRecord = [SELECT Id, ContactId, AccountId, ContactPhone FROM Case WHERE Id =: caseId];
        return caseRecord;      
    }
}