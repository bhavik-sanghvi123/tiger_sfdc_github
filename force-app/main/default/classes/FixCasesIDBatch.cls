/*
Author: Frank Gomendoza
Description: (For Indonesia) Batch job that performs data patch for CR records that has missed Case creation in SFMC
*/
global class FixCasesIDBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<String> crNameList = new List<String>();
    String fixType;
    String campaignName;
    List<Id> caseToInsertSuccess = new List<Id>();
    List<Id> campaignMemberToInsertSuccess = new List<Id>();
    Integer caseToInsertFail = 0;
    Integer campaignMemberToInsertFail = 0;
    
    global FixCasesIDBatch(List<String> inputCRNameList, String inputFixType, String inputCampaignName){
        if(!inputCRNameList.isEmpty()) crNameList = inputCRNameList;
        if(!String.isBlank(inputFixType)) fixType = inputFixType; //Missing or Retention
        if(!String.isBlank(inputCampaignName)) campaignName = inputCampaignName; //Filled if Retention
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryStr;
        if(!crNameList.isEmpty()){
            queryStr = 'SELECT Id, Name, Brandrelationship__c, Brandrelationship__r.Primarycontact__c, Brandrelationship__r.User__c, '
                + 'Brandrelationship__r.Primarycontact__r.Donotcall, Brandrelationship__r.User__r.Primarycontact__c, Brandrelationship__r.User__r.Parent__c, '
                + 'Brandrelationship__r.KeyBrand__c, Brand__c '
                + 'FROM ChannelResponse__c '
                + 'WHERE Name IN: crNameList ';
        }
        else{
            queryStr = 'SELECT Id FROM ChannelResponse__c LIMIT 0';
        }
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<ChannelResponse__c> crList){
        List<Case> caseToInsert = new List<Case>();
        List<CampaignMember> campaignMemberToInsert = new List<CampaignMember>();
        
        User u = [SELECT Id FROM User WHERE Name = 'MC Connect-CRM ID' LIMIT 1][0];
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        
        if(fixType == 'Missing'){
            Campaign campaignPediasure = [SELECT Id, Name FROM Campaign WHERE Name = 'ID1.0_Pediasure_Call1_Verificationcall' LIMIT 1][0];
            Campaign campaignEnsure = [SELECT Id, Name FROM Campaign WHERE Name = 'ID2.0_Ensure_Call1_Verificationcall' LIMIT 1][0];
            for(ChannelResponse__c cr : crList){
                if(cr.Brandrelationship__r.KeyBrand__c.contains('Ensure')){
                    Case c = new Case();
                    c.OwnerId = u.Id;
                    c.RecordTypeId = callRTId;
                    c.Status = 'New';
                    c.CallType__c = 'Outbound';
                    c.Campaign__c = campaignEnsure.Id;
                    c.CallRegarding__c = cr.Brandrelationship__r.primarycontact__c;
                    c.ContactId = cr.Brandrelationship__r.primarycontact__c;
                    c.Priority = 'Medium';
                    c.Origin = 'Inbound Call';
                    c.Subject = campaignEnsure.Name;
                    c.Market__c = 'ID';
                    c.RelatedChannelResponse__c = cr.Id;
                    caseToInsert.add(c);
                    
                    CampaignMember cm = new CampaignMember();
                    cm.CampaignId = campaignEnsure.Id;
                    cm.ContactId = cr.Brandrelationship__r.primarycontact__c;
                    cm.Status = 'Sent';
                    campaignMemberToInsert.add(cm);
                }
                else if(cr.Brandrelationship__r.KeyBrand__c.contains('Pediasure')){
                    Case c = new Case();
                    c.OwnerId = u.Id;
                    c.RecordTypeId = callRTId;
                    c.Status = 'New';
                    c.CallType__c = 'Outbound';
                    c.Campaign__c = campaignPediasure.Id;
                    c.CallRegarding__c = cr.Brandrelationship__r.User__c;
                    c.ContactId = cr.Brandrelationship__r.primarycontact__c;
                    c.Priority = 'Medium';
                    c.Origin = 'Inbound Call';
                    c.Subject = campaignPediasure.Name;
                    c.Market__c = 'ID';
                    c.RelatedChannelResponse__c = cr.Id;
                    caseToInsert.add(c);
                    
                    CampaignMember cm = new CampaignMember();
                    cm.CampaignId = campaignPediasure.Id;
                    cm.ContactId = cr.Brandrelationship__r.primarycontact__c;
                    cm.Status = 'Sent';
                    campaignMemberToInsert.add(cm);
                }
            }
            
        }
        else if(fixType == 'Retention' && !String.isBlank(campaignName)){
            Campaign campaignRetention = [SELECT Id, Name FROM Campaign WHERE Name =: campaignName LIMIT 1][0];
            for(ChannelResponse__c cr : crList){
                Case c = new Case();
                c.OwnerId = u.Id;
                c.RecordTypeId = callRTId;
                c.Status = 'New';
                c.CallType__c = 'Outbound';
                c.Campaign__c = campaignRetention.Id;
                c.CallRegarding__c = cr.Brandrelationship__r.User__c;
                c.ContactId = cr.Brandrelationship__r.primarycontact__c;
                c.Priority = 'Medium';
                c.Origin = 'Inbound Call';
                c.Subject = campaignRetention.Name;
                c.Market__c = 'ID';
                c.RelatedChannelResponse__c = cr.Id;
                caseToInsert.add(c);
                
                CampaignMember cm = new CampaignMember();
                cm.CampaignId = campaignRetention.Id;
                cm.ContactId = cr.Brandrelationship__r.primarycontact__c;
                cm.Status = 'Sent';
                campaignMemberToInsert.add(cm);
            }
        }
        
        if(!campaignMemberToInsert.isEmpty()){
            List<Database.SaveResult> srCampaignMemberList = Database.insert(campaignMemberToInsert, false);
            for (Integer i=0; i<srCampaignMemberList.size(); i++){
                if (!srCampaignMemberList.get(i).isSuccess()){
                    Database.Error e = srCampaignMemberList.get(i).getErrors().get(0);
                    System.debug('Insert Failed: ' + e.getStatusCode() + ': ' + e.getMessage());
                    System.debug('Fields that affected this error: ' + e.getFields());
                    campaignMemberToInsertFail++;
                }
                else{
                    campaignMemberToInsertSuccess.add(srCampaignMemberList.get(i).getId());
                }
            }
        }
        
        if(!caseToInsert.isEmpty()){
            List<Database.SaveResult> srCaseList = Database.insert(caseToInsert, false);
            for (Integer i=0; i<srCaseList.size(); i++){
                if (!srCaseList.get(i).isSuccess()){
                    Database.Error e = srCaseList.get(i).getErrors().get(0);
                    System.debug('Insert Failed: ' + e.getStatusCode() + ': ' + e.getMessage());
                    System.debug('Fields that affected this error: ' + e.getFields());
                    caseToInsertFail++;
                }  
                else{
                    caseToInsertSuccess.add(srCaseList.get(i).getId());
                }
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Number of Inserted Case: ' +caseToInsertSuccess.size());
        System.debug('Number of Failed Case: ' +caseToInsertFail);
        System.debug('Number of Inserted Campaign Members: ' +campaignMemberToInsertSuccess.size());
        System.debug('Number of Failed Campaign Members: ' +campaignMemberToInsertFail);
    }
}