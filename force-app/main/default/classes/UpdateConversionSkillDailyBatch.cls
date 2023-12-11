global class UpdateConversionSkillDailyBatch implements Database.Batchable<sObject>, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id, AccountId, RelatedBrandRelationship__c ' 
                        + 'FROM Case '
                        + 'WHERE RelatedBrandRelationship__c != null AND RelatedBrandRelationship__r.FirstTransactionDate__c != null ' 
                        + 'AND Campaign__c != null AND Campaign__r.Market__c = \'PH\' ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope){
        
        // query PendingServiceRouting, Skill, and SkillRequirement records
        List<Skill> postConversionSkill = [SELECT Id FROM Skill WHERE DeveloperName = 'Conversion_Post_Conversion' LIMIT 1];
        
        Map<Id, PendingServiceRouting> psrMap = new Map<Id, PendingServiceRouting>([SELECT Id, WorkItemId FROM PendingServiceRouting WHERE WorkItemId IN: scope AND IsReadyForRouting = false]);
        
        List<SkillRequirement> srRecords = [SELECT RelatedRecordId, SkillId FROM SkillRequirement WHERE Skill.DeveloperName = 'Conversion_Conversion' AND RelatedRecordId IN: psrMap.keySet()];
        
        
        // actual execute statements
        Map<Id, SkillRequirement> srUpdateMap = new Map<Id, SkillRequirement>();
        Map<Id, PendingServiceRouting> psrUpdateMap = new Map<Id, PendingServiceRouting>();
        
        for(SkillRequirement srToUpdate : srRecords){
            if(!srUpdateMap.containsKey(srToUpdate.Id)){
                srToUpdate.SkillId = postConversionSkill[0].Id;
                srUpdateMap.put(srToUpdate.Id, srToUpdate);
            }
            PendingServiceRouting psr = (PendingServiceRouting) psrMap.get(srToUpdate.RelatedRecordId);
            if(!psrUpdateMap.containsKey(psr.Id)){
                psr.isReadyForRouting = true;
                psrUpdateMap.put(psr.Id, psr);
            }
        }
        
        if(!srUpdateMap.values().isEmpty()){
            Savepoint sp = Database.setSavepoint();
            try{
                List<Database.SaveResult> srList = Database.update(srUpdateMap.values(), false);
                for (Integer i=0; i<srList.size(); i++){
                    if (!srList.get(i).isSuccess()){
                        Database.Error e = srList.get(i).getErrors().get(0);
                        System.debug('Update Failed: ' + e.getStatusCode() + ': ' + e.getMessage());
                        System.debug('Fields that affected this error: ' + e.getFields());
                    }  
                }
            } catch(Exception e){
                System.debug(e.getMessage());
                System.debug('Rollback all data for this transaction');
                Database.rollback(sp);
            } 
        }

        if(!psrUpdateMap.values().isEmpty()){
            Savepoint sp = Database.setSavepoint();
            try{
                List<Database.SaveResult> srList = Database.update(psrUpdateMap.values(), false);
                for (Integer i=0; i<srList.size(); i++){
                    if (!srList.get(i).isSuccess()){
                        Database.Error e = srList.get(i).getErrors().get(0);
                        System.debug('Update Failed: ' + e.getStatusCode() + ': ' + e.getMessage());
                        System.debug('Fields that affected this error: ' + e.getFields());
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
        UpdateConversionSkillDailyBatch batch = new UpdateConversionSkillDailyBatch(); 
        Database.executebatch(batch, 100);
    }
}