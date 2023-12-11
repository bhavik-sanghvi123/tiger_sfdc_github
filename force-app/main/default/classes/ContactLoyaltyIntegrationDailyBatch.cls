/*
Author: Frank Gomendoza
Description: Daily batch job that increments Contact monthly expired points for SG Loyalty Program
*/
global class ContactLoyaltyIntegrationDailyBatch implements Database.Batchable<sObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> conIds = new Set<Id>();
        for(ChannelResponse__c cr : [SELECT Id, Contact__c, Channel__c, Channel__r.Name FROM ChannelResponse__c WHERE Channel__r.Name = 'Abbott Family Rewards SG']){
            if(cr.Contact__c != null){
                conIds.add(cr.Contact__c);
            }
        }
        if(!conIds.isEmpty()){
            String query = 'SELECT Id, LifetimePoints__c, Start_Earn_Points__c, Start_Redeem_Points__c, ExpiredPoints__c, TotalPointsRedeemed__c, Monthly_Expired_Points__c FROM Contact WHERE Id IN :conIds';
            return Database.getQueryLocator(query);
        }
        else{
            return Database.getQueryLocator('SELECT Id FROM Contact LIMIT 0');
        }
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Contact> contactList = new List<Contact>();
        
        for(Contact c : scope){
            Decimal expiredPts = c.ExpiredPoints__c != null ? c.ExpiredPoints__c : 0;
            if(expiredPts != 0){
                c.Monthly_Expired_Points__c += expiredPts;
                contactList.add(c);
            }
        }
        
        if(!contactList.isEmpty()){
            Savepoint sp = Database.setSavepoint();
            try{
                List<Database.SaveResult> srList = Database.update(contactList, false);
                for (Integer i=0; i<srList.size(); i++){
                    if (!srList.get(i).isSuccess()){
                        Database.Error e = srList.get(i).getErrors().get(0);
                        System.debug('Update Failed: ' + e.getStatusCode() + ': ' + e.getMessage());
                        System.debug('Contact fields that affected this error: ' + e.getFields());
                    }  
                }
            } catch(Exception e){
                System.debug(e.getMessage());
                System.debug('Rollback all data for this transaction');
                Database.rollback(sp);
            }
            
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    global void execute(SchedulableContext sc) {
        ContactLoyaltyIntegrationDailyBatch batch = new ContactLoyaltyIntegrationDailyBatch(); 
        Database.executebatch(batch, 200);
    }
}