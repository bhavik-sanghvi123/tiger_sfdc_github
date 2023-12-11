/*----------------------------------------------------------------------------------------
Author:      Rey Austral
Description: Batch to update old task record

History
10/14/2019   raustral   Created
-------------------------------------------------------------------------------------------*/
// for deletion
global class TaskCleanupBatch {} /* implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID , WhatId, WhoId,CreatedById From Task Where CallType =\'Inbound\' and WhoId = null';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> scope) {
        Map<String, Id> contactPerMarketMap = new Map<String, Id>();        
        Set<Id> createdUsers = new Set<Id>();

        for(Task t : scope){
            createdUsers.add(t.CreatedById);
        }

        Map<Id, User>  userMap = new Map<Id,User>([Select Id,UserRole.Name from User where Id IN: createdUsers]);
        
        Set<String> contactNameSet = new Set<String>{'SG CTI Rep Contact','PH CTI Rep Contact','MY CTI Rep Contact','VN CTI Rep Contact','TH CTI Rep Contact'};
        List<Contact> contList = [Select Id, Market__c from Contact Where Name IN: contactNameSet];
        for (Contact c : contList) {
            contactPerMarketMap.put(c.Market__c, c.Id);
        }

        List<Task> toUpdateList = new List<Task>();
        for(Task t : scope){
            User currUser = userMap.get(t.CreatedById);  
            if (currUser != null) {    
                String market = currUser.UserRole == null ? '' : retriveMarket(currUser.UserRole.Name);
                if (String.isNotEmpty(market)) {
                    t.WhoId = contactPerMarketMap.get(market); 
                    toUpdateList.add(t);        
                }
            }
        }

        if (!toUpdateList.isEmpty()) {
            Update toUpdateList;
        }
    }

    public static String retriveMarket(String roleName) {
        String result = '';
        if (roleName.toLowerCase().contains('singapore')) {
            result = 'SG';
        } else if (roleName.toLowerCase().contains('philippines')) {
            result = 'PH';
        } else if (roleName.toLowerCase().contains('thailand')) {
            result = 'TH';
        } else if (roleName.toLowerCase().contains('vietnam')) {
            result = 'VN';
        } else if (roleName.toLowerCase().contains('malaysia')) {
            result = 'MY';
        }
        
        return result;
    }
   
    global void finish(Database.BatchableContext BC) {
        
    }
} */