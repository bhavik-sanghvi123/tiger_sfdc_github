/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Batch Class that will Membership Number Of Transactions. 

History
09/26/2019   vmirandilla   Created
-------------------------------------------------------------------------------------------*/
global class MembershipNumberOfTransactionsBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, NumberOfTransactions__c'
                            // + ' (SELECT Id, EndDate'
                            // + ' From Orders__r'
                            // + ' WHERE Status != \'Cancelled - New Order Created\''
                            // + ' AND Status != \'Cancelled - Before Delivery\''
                            // + ' AND Status != \'Cancelled - Upon Delivery\''
                            // + ' AND Status != \'Cancelled - Abandoned\''
                            // + ' ORDER BY EndDate DESC)'
                            + ' FROM Membership__c WHERE Status__c != \'Expired\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Membership__c> scope) {
        List<Membership__c> membershipList = new List<Membership__c>();
        
        List<Membership__c> scopeList = [Select  NumberOfTransactions__c, 
                                        (SELECT Id, EndDate From Orders__r WHERE Status != 'Cancelled - New Order Created' 
                                        AND Status != 'Cancelled - Before Delivery'
                                        AND Status != 'Cancelled - Upon Delivery'
                                        AND Status != 'Cancelled - Abandoned'
                                        ORDER BY EndDate DESC)
                                        FROM Membership__c WHERE ID IN: scope];

        for(Membership__c mem : scopeList) {
            if(!mem.Orders__r.isEmpty()) {
                mem.NumberOfTransactions__c = mem.Orders__r.size();
            }
            else {
                mem.NumberOfTransactions__c = 0;
            }
            membershipList.add(mem);
        }
        
        if(!membershipList.isEmpty()) {
            Database.update(membershipList, false);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}