/*----------------------------------------------------------------------------------------
Author:      Marc Anthony Bondoc
Description: Batch Class to update Promotion Status depending on the Status and Start Date,
                value.

History
02/13/2019   mbondoc   Created
-------------------------------------------------------------------------------------------*/
global class UpdatePromotionStatusBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Status__c,'
                            + ' StartDate__c,'
            				+ ' EndDate__c'
                            + ' FROM Promotion__c'
                            + ' WHERE'
                            + ' (Status__c = \'Planned\' AND StartDate__c = TODAY)'
             				+ ' OR (Status__c = \'In Progress\' AND EndDate__c = TODAY)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Promotion__c> scope) {
        
        for(Promotion__c prom : scope) {
            
            if(prom.Status__c == 'Planned' && prom.StartDate__c == Date.Today()) { 
                prom.Status__c = 'In Progress';
            }
          if(prom.Status__c == 'In Progress' && prom.EndDate__c ==Date.Today())
            {
                prom.Status__c = 'Completed';
            }

        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
    }

}