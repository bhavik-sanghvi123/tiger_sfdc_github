/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Batch Class to update Campaign Status depending on the Status, Start Date,
                End Date and Approval Status value.

History
01/10/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
global class UpdateCampaignStatusBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Status,'
                            + ' ApprovalStatus__c,'
                            + ' StartDate,'
                            + ' EndDate'
                            + ' FROM Campaign'
                            + ' WHERE'
                            + ' (Status = \'Planned\' AND StartDate = TODAY AND ApprovalStatus__c = \'Approved\')'
                            + ' OR (Status = \'In Progress\' AND EndDate = TODAY)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Campaign> scope) {
        
        for(Campaign camp : scope) {
            
            if(camp.Status == 'Planned' && camp.StartDate == Date.Today() && camp.ApprovalStatus__c =='Approved') { 
                camp.Status = 'In Progress';
            }
            else if(camp.Status == 'In Progress' && camp.EndDate == Date.Today()) {
                camp.Status = 'Completed';
            }
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}