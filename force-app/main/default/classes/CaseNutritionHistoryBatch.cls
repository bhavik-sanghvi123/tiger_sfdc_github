/*
Author: Frank Gomendoza
Description: Batch job that creates MD (Nutritional History) records to be scheduled hourly daily
*/
global class CaseNutritionHistoryBatch implements Database.Batchable<sObject>, Schedulable{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        String query = 'SELECT Id, CallRegarding__c, ContactId '
            + 'FROM Case '
            + 'WHERE Market__c = \'' + CommonConstant.MARKET_TW + '\' '
            + 'AND CreatedDate = Today '
            + 'AND RecordTypeId =: callRTId '
            + 'AND MedicalDiagnosis__c = null '
            + 'Order By CaseNumber ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope) {
    	if(!scope.isEmpty()){
            List<Medical_Diagnosis__c> createMDRecordsList = new List<Medical_Diagnosis__c>();
            for(Case c : scope){
                Medical_Diagnosis__c md = new Medical_Diagnosis__c();
                if(c.CallRegarding__c != null){
                    md.Contact__c = c.CallRegarding__c;
                }else{
                    md.Contact__c = c.ContactId;
                }
                md.Related_Case__c = c.Id;
                md.CreatedforIntegration__c = true ;
                createMDRecordsList.add(md);
            }
            if(!createMDRecordsList.isEmpty()) UtilityClass.insertList(createMDRecordsList);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }
    
    global void execute(SchedulableContext sc) {
        CaseNutritionHistoryBatch batch = new CaseNutritionHistoryBatch(); 
        Database.executebatch(batch, 1);
    }
}