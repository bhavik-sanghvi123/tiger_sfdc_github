// for deletion
public class ContactCleanUp {} /* implements Database.Batchable<sObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext BC){

        String queryStr = 'SELECT EstimatedDueDate__c,'
                                + ' (SELECT Id FROM Addresses__r WHERE DefaultAddress__c = true LIMIT 1),'
                                + ' (SELECT CallOutcome__c FROM Cases WHERE RecordType.Name = \'Call\' Order By CaseNumber)'
                         + ' FROM Contact';
        if(Test.isRunningTest()){
            queryStr = 'SELECT Id, EstimatedDueDate__c,(SELECT CallOutcome__c FROM Cases Order By CaseNumber), (SELECT Id FROM Addresses__r WHERE DefaultAddress__c = true LIMIT 1) FROM Contact';
        }
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext BC, List<Contact> contactList){
        List<Contact> conUpdate = new List<Contact>();
        List<Case> caseUpdate = new List<Case>();

        for(Contact c: contactList){
            Boolean forUpdate = false;
        
            // update case's call outcome
            if(!c.Cases.isEmpty() && c.Cases.size() > 1){
                String callOutcome = '';
                for(Case ca: c.Cases) {

                    if(String.isNotBlank(callOutcome)) {
                        ca.LatestCallOutcome__c = callOutcome;
                        caseUpdate.add(ca);
                    }

                    if(String.isNotBlank(ca.CallOutcome__c)) {
                        callOutcome = ca.CallOutcome__c;
                        c.LatestCall2__c = ca.Id;
                        c.Latest_Call_Outcome__c = ca.CallOutCome__c;
                        forUpdate = true;
                    }
                }
            }

            //update contact's address
            if(!c.Addresses__r.isEmpty()){
                c.Default_Address__c = c.Addresses__r[0].Id;
                forUpdate = true;
            }
            if(c.EstimatedDueDate__c != null) {
                c.Initial_Estimated_Due_Date_IEDD__c = c.EstimatedDueDate__c;
                forUpdate = true;
            }

            if(forUpdate) { conUpdate.add(c); }

        }

        if(!conUpdate.isEmpty()){ Database.update(conUpdate, false); }
        if(!caseUpdate.isEmpty()){ Database.update(caseUpdate, false); }
    }
    
    public void finish(Database.BatchableContext BC){}
}*/