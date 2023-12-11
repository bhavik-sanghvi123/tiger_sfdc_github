/*----------------------------------------------------------------------------------------
* Script to populate Contact's Region based on Default Address' Region:
-------------------------------------------------------------------------------------------*/
// for deletion
global class AddressBatchProcess {} /* implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,'
                            + ' Region__c,'
                            + ' ParentContact__c,'
                            + ' DefaultAddress__c'
                            + ' FROM Address__c'
                            + ' WHERE DefaultAddress__c = TRUE AND Region__c != null AND ParentContact__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Address__c> scope) {
        Set<Id> conIdSet = new Set<Id>();
        Map<Id,Address__c> addressMap = new Map<Id,Address__c>();
        List<Contact> processedContactList = new List<Contact>();

        for(Address__c address : scope) {
            conIdSet.add(address.ParentContact__c);
            addressMap.put(address.ParentContact__c, address);
        }

        List<Contact> contactList = [SELECT Id, Region__c FROM Contact WHERE Id IN :conIdSet];

        for(Contact con : contactList) {
            if(con.Region__c != addressMap.get(con.Id).Region__c) {
                con.Region__c = addressMap.get(con.Id).Region__c;
                processedContactList.add(con);
            }
        }

        if (!processedContactList.isEmpty()) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        
            List<Database.SaveResult> sr = Database.update(processedContactList, dml);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
} */