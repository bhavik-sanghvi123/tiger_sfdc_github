global class UpdateChildEndUserCountBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    String market;
    Integer startRange;
    Integer endRange;
    
    global UpdateChildEndUserCountBatch (String inputMarket, Integer inputStartRange, Integer inputEndRange){
        if(!String.isBlank(inputMarket)) market = inputMarket;
        if(inputStartRange != null) startRange = inputStartRange;
        if(inputEndRange != null) endRange = inputEndRange;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id conChildRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        String query = 'SELECT Id'
            + ' FROM Contact'
            + ' WHERE Active__c = true AND RecordTypeId =: conChildRecType';   
        if(!String.isBlank(market)){
            query += ' AND Account.Market__c = \'' + market + '\'';
        }
        if(endRange != null && startRange != null){
            query += ' AND (CreatedDate >= LAST_N_DAYS: ' + endRange
                + ' AND CreatedDate <= LAST_N_DAYS: ' + startRange +') ';
        }
        else {
            if(endRange != null){
                query += ' AND (CreatedDate >= LAST_N_DAYS: ' + endRange +') ';
            }
            else if(startRange != null){
                query += ' AND (CreatedDate <= LAST_N_DAYS: ' + startRange +') ';
            }
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        Map<Id, Contact> conUpdateMap = new Map<Id, Contact>();
        if(!scope.isEmpty()){
            for(Contact con : [SELECT Id, Brand_Relationship_EndUser_Child_Count__c, (SELECT Id FROM BrandRelationships__r WHERE Active__c = true) FROM Contact WHERE Id IN: scope]){
                if(!con.BrandRelationships__r.isEmpty()){
                    Contact conRec = new Contact();
                    conRec.Id = con.Id;
                    conRec.Brand_Relationship_EndUser_Child_Count__c = con.BrandRelationships__r.size();
                    conUpdateMap.put(con.Id, conRec);
                }
            }
            
            if(!conUpdateMap.keySet().isEmpty()) UtilityClass.updateList(conUpdateMap.values());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }
    
    global void execute(SchedulableContext sc) {
        UpdateChildEndUserCountBatch batch = new UpdateChildEndUserCountBatch(market, startRange, endRange); 
        Database.executebatch(batch, 50);
    }
    
}