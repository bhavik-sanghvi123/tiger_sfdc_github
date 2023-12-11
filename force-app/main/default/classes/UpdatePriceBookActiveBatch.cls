/*----------------------------------------------------------------------------------------
Author:      Marc Anthony Bondoc
Description: Batch Class to update Active checkbox depending on the Start Date and End Date,
                value.

History
02/19/2019   mbondoc   Created
-------------------------------------------------------------------------------------------*/
global class UpdatePriceBookActiveBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT IsActive,'
                            + ' StartDate__c,'
            				+ ' EndDate__c'
                            + ' FROM Pricebook2'
                            + ' WHERE'
                            + ' (StartDate__c = TODAY)'
             				+ ' OR (EndDate__c = TODAY)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Pricebook2> scope) {
        
        for(Pricebook2 pbook : scope) {
            
            if(pbook.StartDate__c == Date.Today()) { 
                pbook.IsActive = true;
            }
            if(pbook.EndDate__c ==Date.Today())
            {
                pbook.IsActive = false;
            }

        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
    }

}