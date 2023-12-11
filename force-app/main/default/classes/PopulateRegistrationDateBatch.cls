/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Batch to fixe blank registration date

History
09/20/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
// for deletion
global class PopulateRegistrationDateBatch {} /* implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id, RegistrationDate__c, CreatedDate from ChannelResponse__c where RegistrationDate__c = null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ChannelResponse__c> scope) {
    	List<ChannelResponse__c> crsToUpdate = new List<ChannelResponse__c>();
        if(scope != null && !scope.isEmpty()) {
            for(ChannelResponse__c crRec : scope) {
                crRec.RegistrationDate__c = crRec.CreatedDate;
                crsToUpdate.add(crRec);
            }
        }
        
        if(!crsToUpdate.isEmpty()) {
            Database.SaveResult[] srList = Database.update(crsToUpdate, false);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
} */