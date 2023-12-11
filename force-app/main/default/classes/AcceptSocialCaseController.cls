public class AcceptSocialCaseController {
    
	@AuraEnabled
    public static String acceptSocialCase(String caseId) {
        if(caseId != null) {
            List<Case> caseRec = [select Id, OwnerId, CallTransferReason__c, CaseAccepted__c, Status from Case where Id = :caseId];
            
            if(!caseRec.isEmpty()) {
                if(caseRec[0].CaseAccepted__c) {
                    return 'Case is already accepted';
                } else {
                	caseRec[0].OwnerId = userInfo.getUserId();
                    caseRec[0].CaseAccepted__c = true;
                    caseRec[0].Status = 'First Level Investigation';
                    update caseRec;
                    return 'case accepted';
                }
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static Boolean isSocial(String caseId) {
        if(caseId != null) {
            List<Case> caseRec = [select Id, IsSocialCase__c from Case where Id = :caseId];
            
            if(!caseRec.isEmpty()) {
                return caseRec[0].IsSocialCase__c;
            }
        }
        
        return false;
    }
}