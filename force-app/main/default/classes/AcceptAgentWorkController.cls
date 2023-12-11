public class AcceptAgentWorkController {
    
    /*
    1 - Success
    2 - Case owned by other agent
    3 - Call already accepted
    */
    @AuraEnabled
    public static String acceptCall(Id caseId) {
        String ret = '1';
        
        try {            
            Case caseRec = [SELECT OwnerId, CallAccepted__c,Market__c FROM Case WHERE Id =: caseId LIMIT 1];
            System.debug('caseRec -> ' + caseRec);
            
            //validation for IN market
            List<GroupMember> userGroup = new List<GroupMember>([SELECT GroupId,UserOrGroupId FROM GroupMember 
                                                                WHERE UserOrGroupId =:UserInfo.getUserId() AND (NOT Group.Name LIKE '%IN_Market%' ) AND Group.Type = 'Regular']);
                
            List<GroupMember> ownerGroup = new List<GroupMember>([SELECT GroupId,UserOrGroupId FROM GroupMember 
                                                                WHERE UserOrGroupId =:caseRec.OwnerId AND (NOT Group.Name LIKE '%IN_Market%') AND Group.Type = 'Regular']);
            
            if (caseRec.OwnerId != UserInfo.getUserId() && caseRec.Market__c != 'IN'){
                ret = '2';
            }
            else if(caseRec.Market__c == 'IN' && (userGroup.isEmpty() || ownerGroup.isEmpty()) && caseRec.OwnerId != UserInfo.getUserId()) {
                ret = '2';
            }
            else if(caseRec.Market__c == 'IN' && !isMember(userGroup,caseRec.OwnerId)){
                ret = '2';
            }
            else if(caseRec.CallAccepted__c){
                ret = '3';
            }
            else {
                if(caseRec.Market__c == 'IN' && isMember(userGroup,caseRec.OwnerId)){
                    caseRec.OwnerId = UserInfo.getUserId();
                }   
                caseRec.CallAccepted__c = TRUE;
                update caseRec;
            }
        }
        catch(Exception e) {
            System.debug('Exception -> ' + e.getMessage());
        }
        
        return ret;
    }
	@AuraEnabled
    public static Boolean isMember(List<GroupMember> userGroup, id caseowner) {
        Set<Id> groupSet = new Set<Id>();
        Set<Id> memberSet = new Set<Id>();
        Boolean isMember = false;
        
        for(GroupMember mem: userGroup){
            groupSet.add(mem.GroupId);
        }
        
        List<GroupMember> allMembersList = new List<GroupMember>([SELECT GroupId,UserOrGroupId FROM GroupMember 
        													WHERE GroupId IN :groupSet]);
        
        for(GroupMember mem: allMembersList){
            memberSet.add(mem.UserOrGroupId);
        }
        
        if(memberSet.contains(caseowner)){
            isMember = true;
        }
        return isMember;
    }
}