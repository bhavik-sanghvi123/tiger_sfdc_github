// for deletion 1 time use
global class CaseFieldPatch {} /* Implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        
        String query = 'SELECT ID , ContactId, City__c, District__c, LatestCallOutcome__c'                           
            + ' FROM Case where ContactId != null';
     
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope) {
      Set<Id> contactIds = new Set<Id>();
        for (Case c: scope) {            
            contactIds.add(c.ContactId);                           
        }
       
        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, Default_Address__r.City2__r.Name, Default_Address__r.District__r.Name, LatestCall__r.CallOutcome__c from Contact Where Id in: contactIds]);
        for (Case c: scope) { 
            Contact con = contactMap.get(c.ContactId);
            if (con != null) {
                if (con.Default_Address__c != null && con.Default_Address__r.City2__c != null)
                    c.City__c = con.Default_Address__r.City2__r.Name;
                
                if (con.Default_Address__c != null && con.Default_Address__r.District__c != null)
                    c.District__c = con.Default_Address__r.District__r.Name;

                if (con.LatestCall__c != null)
                    c.LatestCallOutcome__c = con.LatestCall__r.CallOutcome__c;
            }
        }

        Database.update(scope, false);
         
    }    
    
    global void finish(Database.BatchableContext BC) {
    }
} */