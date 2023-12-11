/*------------------------------------------------------------
Author:      Jennifer Alviz
Description: Email Service class for creating Activity History

History
02/15/2019   malviz    Created
-------------------------------------------------------------------------------------------*/

global class createActivity implements messaging.Inboundemailhandler {
    
    List<Case>  caseList; 
    
    global messaging.InboundEmailresult handleInboundEmail(messaging.InboundEmail email, messaging.InboundEnvelope envelope) {
        
        caseList = new list <Case> ();
        
        messaging.InboundEmailresult result = new messaging.InboundEmailresult();
        
        string Activityname = email.fromname;
        String fromemailaddresss = email.fromAddress;
        string des = email.plaintextbody;
        string tasksubject = email.subject;
        string caseId = des.substring(des.indexof('ref: ')+5, des.indexof('ref: ')+20);
        
        List <Case> caseList = [select id, OwnerId from Case where id = : caseId AND (Market__c != 'ANZ' AND (NOT owner.name like '%- ANZ')) limit 1];
        
        if(!caseList.isEmpty()){
        Task tkobj = new Task(OwnerId = caseList[0].OwnerId, 
                    Description = des, 
                    subject = tasksubject, 
                    Priority = 'Normal',
                    Status = 'Completed', 
                    ActivityDate = System.today(), 
                    ReminderDateTime = System.now(), 
                    whatId = caseId, 
                    FromEmailAddress__c = fromemailaddresss);
  
        insert tkobj;
        }
        return null;
    }
}