/*
Author: Jennifer
Description: One time batch run to patch the value for new field Latest Contacted Date.
Date:
July 14, 2020 Created
*/
public class PopulateLatestContactedDate_Batch {} /*Implements Database.Batchable<sObject> {
    String overrideQuery = '';
    public PopulateLatestContactedDate_Batch(String q) {
        overrideQuery = q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Status, ContactId, CreatedDate, LastModifiedDate,CallCompletedDate__c,CallOutcome__c '                           
            + ' FROM Case'
            + ' WHERE'
            + ' Market__c = \'SG\''
            + ' AND CallCompletedDate__c != null'
            + ' AND Status != \'Cancelled\''
            + ' AND RecordType.Name = \'Call\'';
           
        if(overrideQuery != '') {
            query = overrideQuery;
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        
        Set<Id> ContactIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        
        for(Case c : scope){
            ContactIds.add(c.ContactId);
        } 
        
        for(Contact con: [SELECT Latest_Contacted_Date__c,
                                          (SELECT Status, CreatedDate, LastModifiedDate,CallCompletedDate__c,CallOutcome__c 
                                             FROM Cases
                                            WHERE Status != 'Cancelled'
                                              AND RecordType.Name = 'Call'
                                         ORDER BY CreatedDate)
                                   FROM Contact
                                   WHERE Id IN :ContactIds] ) {
                                   
            Boolean forUpdate = false;
            
            for(Case c: con.Cases) {
            
                // TKT-002254 - latest contacted date
                if((con.Latest_Contacted_Date__c == null || c.CallCompletedDate__c > con.Latest_Contacted_Date__c)
                    && (c.CallOutcome__c == 'Successful' || c.CallOutcome__c == 'Unsuccessful' )) {
                    con.Latest_Contacted_Date__c = c.CallCompletedDate__c;
    
                    forUpdate = true;
                }
            }
           
            if(forUpdate) conList.add(con);

        }
        
        if(!conList.isEmpty()) UtilityClass.updateList(conList);

    }
    public void finish(Database.BatchableContext BC) {}
}*/