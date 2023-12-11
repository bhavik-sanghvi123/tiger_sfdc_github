/***********************************************************************
* @author        Monika Parihar    
* @date          8/10/2021
* @description   Batch job to update MC Sync Eligibility Fields for TW
* @revision(s)
**************************************************************************/

global class MC_Contact_SyncEligibilityTWBatch Implements Database.Batchable<sObject>, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID , Name, AccountId, Market__c, Active__c, Phone, Email, HasOptedOutOfEmail,LineUIDPediatric__c,LineUIDAdult__c,LineOptOut__c,MC_Sync_Eligibility_TW__c FROM CONTACT WHERE'
            + ' (Phone != null'
            + ' OR Email != null'
            + ' OR LineUIDPediatric__c != null'
            + ' OR LineUIDAdult__c != null)'
            + ' AND PrimaryContact__c = True'
            + ' AND LineOptOut__c = False'
            + ' AND Active__c = True'
            + ' AND Blacklisted__c = False'
            + ' AND MasterOptOut__c = False'
            + ' AND RecordType.Name = \'Adult\''
            + ' AND Market__c =  \'TW\'';
       
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> contactsToUpdate = new List<Contact>();

        for(Contact con: scope){
            if(!con.MC_Sync_Eligibility_TW__c){
                con.MC_Sync_Eligibility_TW__c = True;
            }
            contactsToUpdate.add(con);
        }
        
        if(!contactsToUpdate.isEmpty()) Utilityclass.updateList(contactsToUpdate);

    }

    global void finish(Database.BatchableContext BC) {

    }
}