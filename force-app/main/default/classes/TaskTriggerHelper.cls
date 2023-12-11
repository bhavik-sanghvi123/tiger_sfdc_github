/*------------------------------------------------------------
Author:      Jennifer Alviz
Description: Helper class for Task object

History
02/12/2019   malviz    Created
10/21/2019   raustral  Add updateWhoId
-------------------------------------------------------------------------------------------*/

public class TaskTriggerHelper {
    
    public static void updateActivityHistory(List<Task> taskList){
        
        List<Task> tasktoupdate = new List<Task>();
        String subject,comments;
        
        for(Task t : taskList){
            subject = string.valueOf(t.subject);
            comments = string.valueOf(t.description);
            
            if(t.status  == 'Completed' && subject.contains('requires your attention') && comments.contains('emailtosalesforce')){
                t.notifyserviceagent__c = true;                
            }
        }
    }
    
    public static void updateRelatedCase(List<Task> taskList){
        
        Set<Id> relatedCaseId = new Set<Id>();
        List<Case> casetoUpdate = new List<Case>();
        String subject,comments;
        
        for (Task t : tasklist){
            subject = string.valueOf(t.subject);
            comments = string.valueOf(t.description);
            
            if(t.status  == 'Completed' && subject.contains('requires your attention') && comments.contains('emailtosalesforce')){
                relatedCaseId.add(t.whatid);
            }
        }
        
        List<Case> caseList =[Select id from Case where id IN:relatedCaseId];        
        
        for(Case c : caseList){
            c.notifyserviceagent__c = true;
            casetoUpdate.add(c);
        }
        
        if(!casetoUpdate.isempty()){
            update casetoUpdate;
        }        
    }
    
    public static void updateWhoId(List<Task> taskList) {        
        List<Task> validTask = new List<Task>();
        for(Task t : taskList){
            if (t.WhoId == null && t.CallType == CommonConstant.CASE_CALL_TYPE_INBOUND) {
                validTask.add(t);               
            }            
        }
        
        if (!validTask.isEmpty()) {
            User ur = [Select UserRole.name, Profile.Name From User Where Id =: Userinfo.getUserId()];
            String roleName = test.isRunningTest() ? 'vietnam' : '';
            if ( ur.UserRole != null ) {
                roleName = ur.UserRole.name;
            }
            
            Id ctiContact;

            if (String.isNotEmpty(roleName)) {
                List<Contact> contList = [Select Id, Market__c from Contact Where Name =: retrieveContactName(roleName)];
                if (!contList.isempty()) {
                    ctiContact = contList.get(0).Id;
                }   
            }                     
            
            if(String.isNotEmpty(ctiContact)) {
                for(Task t : validTask){ 
                    t.WhoId = ctiContact;                     
                }
            }
        }                
    }
    
    public static String retrieveContactName(String roleName) {
        String result = '';
        if (roleName.toLowerCase().contains('singapore')) {
            result = 'SG CTI Rep Contact';
        } else if (roleName.toLowerCase().contains('philippines')) {
            result = 'PH CTI Rep Contact';
        } else if (roleName.toLowerCase().contains('thailand')) {
            result = 'TH CTI Rep Contact';
        } else if (roleName.toLowerCase().contains('vietnam')) {
            result = 'VN CTI Rep Contact';
        } else if (roleName.toLowerCase().contains('malaysia')) {
            result = 'MY CTI Rep Contact';
        }
        
        return result;
    }
}