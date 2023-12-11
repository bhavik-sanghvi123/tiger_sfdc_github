/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Batch class to delete social contacts that are left without any association due to re-parenting
History
08/01/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
global class DeleteInvalidSocialContactsBatch implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        Set<String> defSocAcc = new Set<String>();
        
        for(AffiliateMetadata__mdt amRec : [select MasterLabel, DefaultSocialAccount__c from AffiliateMetadata__mdt where DefaultSocialAccount__c != null]) {
            defSocAcc.add(amRec.DefaultSocialAccount__c);
        }
        
		query = 'select Id from Contact where Account.Name in :defSocAcc and CreatedBy.Name like \'%Social Studio Integration User%\'';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        Set<Id> validContacts = new Set<Id>();
        List<Contact> contactsToDelete = new List<Contact>();
        if(scope != null) {
            for(SocialPersona spRec : [select Id, ParentId from SocialPersona where ParentId in :scope]) {
                validContacts.add(spRec.ParentId);
            }
            
            if(validContacts.isEmpty()) {
                contactsToDelete = scope;
            } else {
                for(Contact conRec : scope) {
                    if(!validContacts.contains(conRec.Id)) {
                        contactsToDelete.add(conRec);
                    }
                }
            }
            
            if(!contactsToDelete.isEmpty()) {
                //delete contactsToDelete;
				Database.DeleteResult[] srList = Database.delete(contactsToDelete, false);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}