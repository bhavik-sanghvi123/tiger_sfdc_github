/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Batch class to create households for valid contacts generated through social studio
History
08/01/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
global class CreateHouseholdForSocialContactsBatch implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        Set<String> defSocAcc = new Set<String>();
        
        for(AffiliateMetadata__mdt amRec : [select MasterLabel, DefaultSocialAccount__c from AffiliateMetadata__mdt where DefaultSocialAccount__c != null]) {
            defSocAcc.add(amRec.DefaultSocialAccount__c);
        }
        
		query = 'select Id, AccountId, LastName from Contact where Phone != null and Account.Name in :defSocAcc and CreatedBy.Name like \'%Social Studio Integration User%\'';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        Map<Id, String> validContacts = new Map<Id, String>();
        Map<Id, Account> accountsToInsert = new Map<Id, Account>();
        Map<Id, Id> consAndAccs = new Map<Id, Id>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Case> casesToUpdate = new List<Case>();
        if(scope != null) {
            for(SocialPersona spRec : [select Id, AuthorLabels, ParentId from SocialPersona where ParentId in :scope]) {
                validContacts.put(spRec.ParentId, spRec.AuthorLabels.left(2));
            }
            
            if(!validContacts.isEmpty()) {
                for(Contact conRec : scope) {
                    if(validContacts.containsKey(conRec.Id)) {
                        Account acc = new Account(Name = conRec.LastName, Market__c = validContacts.get(conRec.Id));
                        accountsToInsert.put(conRec.Id, acc);
                        contactsToUpdate.add(conRec);
                    }
                }
                
                if(!accountsToInsert.isEmpty()) {
                    insert accountsToInsert.values();
                    
                    for(Contact conRec : contactsToUpdate) {
                        conRec.AccountId = accountsToInsert.get(conRec.Id).Id;
                        conRec.PrimaryContact__c = true;
                        consAndAccs.put(conRec.Id, accountsToInsert.get(conRec.Id).Id);
                    }
                    
                    if(!contactsToUpdate.isEmpty()) {
                        update contactsToUpdate;
                    }
                    
                    for(Case caseRec : [select Id, AccountId, ContactId from Case where ContactId in :consAndAccs.keySet()]) {
                        caseRec.AccountId = consAndAccs.get(caseRec.ContactId);
                        casesToUpdate.add(caseRec);
                    }
                    
                    if(!casesToUpdate.isEmpty()) {
                        update casesToUpdate;
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}