/*************************************************************************************************
* @author         Monika Parihar
* @date           11/08/2021
* @description    Batch job will run to mark all contacts with Contact.Trade_Channel_Customer = TRUE,
                  when any related Channel Response contains Channel = Trade_BrandSwitch_PED
* @revision(s)
************************************************************************************************/

global class ContactTradeChannelUpdateBatch Implements Database.Batchable<sObject> {
    /*************************************************************************************************
    * @author         Monika Parihar
    * @MethodName     start
    * @description    Method to query all the CR record whose channel is Trade_BrandSwitch_PED and Market is TW
    ************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String amount = 'Select id,Contact__c  from ChannelResponse__c where Channel__r.Name =  \'Trade_BrandSwitch_PED\' AND  Contact__r.Market__c= \'TW\'';
        return Database.getQueryLocator(amount);
    }
    /*************************************************************************************************
    * @author         Monika Parihar
    * @MethodName     Execute
    * @description    Method update all the Contact associated with CR in Scope
    ************************************************************************************************/
    global void execute(Database.BatchableContext BC, List<ChannelResponse__c> scope) {
        Set<Id> conList = new Set<Id>();
        List<Contact> updateconList = new List<Contact>();
        for(ChannelResponse__c cr: scope){
            if(cr.Contact__c!= null){
                conList.add(cr.Contact__c);
            }
        }
        for(Contact con : [Select id from Contact where Id in :conList]){
            con.TradeChannelCustomer__c = true;
            updateconList.add(con);
        }
        if(!updateconList.isEmpty()){
            update updateconList;
        }
        
    }    
    /*************************************************************************************************
    * @author         Monika Parihar
    * @MethodName     Finish
    * @description    
    ************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
    }
}