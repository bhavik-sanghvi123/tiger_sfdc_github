global class IndividualEmailResultBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    Integer startRange;
    Integer endRange;

    global IndividualEmailResultBatch (Integer inputStartRange, Integer inputEndRange){
        if(inputStartRange != null) startRange = inputStartRange;
        if(inputEndRange != null) endRange = inputEndRange;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String contactAdultRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        String query = 'SELECT Id, Name, et4ae5__Contact__c, et4ae5__Contact__r.EmailBounced__c, et4ae5__HardBounce__c, et4ae5__SoftBounce__c'
            + ' FROM et4ae5__IndividualEmailResult__c'
            + ' WHERE et4ae5__Contact__c != null AND et4ae5__Contact__r.Market__c = \'PH\' AND et4ae5__Contact__r.Active__c = true AND et4ae5__Contact__r.RecordTypeId =: contactAdultRectypeId'
            + ' AND (et4ae5__HardBounce__c = true OR et4ae5__SoftBounce__c = true)';
            if(endRange != null && startRange != null){
                query += ' AND (LastModifiedDate >= LAST_N_DAYS: ' + endRange
                + ' AND LastModifiedDate <= LAST_N_DAYS: ' + startRange +') ';
            }
            else {
                if(endRange != null){
                    query += ' AND (LastModifiedDate >= LAST_N_DAYS: ' + endRange +') ';
                }
                else if(startRange != null){
                    query += ' AND (LastModifiedDate <= LAST_N_DAYS: ' + startRange +') ';
                }
            }
            query += ' ORDER BY et4ae5__Contact__c ASC';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<et4ae5__IndividualEmailResult__c> scope) {
        if(!scope.isEmpty()){
            Map<Id, Contact> conUpdateMap = new Map<Id, Contact>();  
            Set<Id> conIds = new Set<Id>();
            
            for(et4ae5__IndividualEmailResult__c ier : scope){
                conIds.add(ier.et4ae5__Contact__c);
            }
            for(Contact con : [SELECT Id FROM Contact WHERE Id IN: conIds AND EmailBounced__c = false]){
                con.EmailBounced__c = true;
                conUpdateMap.put(con.Id, con);
            }
            
            update conUpdateMap.values();
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }
    
    global void execute(SchedulableContext sc) {
        IndividualEmailResultBatch batch = new IndividualEmailResultBatch(0, 60); 
        Database.executebatch(batch, 50);
    }
    
}