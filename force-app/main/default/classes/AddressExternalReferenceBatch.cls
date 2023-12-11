global class AddressExternalReferenceBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
	String market;
    Integer startRange;
    Integer endRange;
    
    global AddressExternalReferenceBatch (String inputMarket, Integer inputStartRange, Integer inputEndRange){
        if(!String.isBlank(inputMarket)) market = inputMarket;
        if(inputStartRange != null) startRange = inputStartRange;
        if(inputEndRange != null) endRange = inputEndRange;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, External_Reference_Number__c'
            + ' FROM Address__c'
            + ' WHERE External_Reference_Number__c = null';   
        if(!String.isBlank(market)){
            query += ' AND Country__c = \'' + market + '\'';
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
    
    global void execute(Database.BatchableContext BC, List<Address__c> scope) {
        List<Address__c> addressUpdateList = new List<Address__c>();
        System.debug(scope);
        if(!scope.isEmpty()){
            for(Address__c addr : scope){
                Blob requestBlob = Blob.valueOf(addr.Id);
                Blob hash = Crypto.generateDigest('MD5', requestBlob);
                String requestSignature = EncodingUtil.convertToHex(hash);
                addr.External_Reference_Number__c = 'SFMD5-'+requestSignature;
                addressUpdateList.add(addr);
            }
            System.debug('FGG');
            if(!addressUpdateList.isEmpty()) UtilityClass.updateList(addressUpdateList);
            System.debug('FGG');
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }
    
    global void execute(SchedulableContext sc) {
        AddressExternalReferenceBatch batch = new AddressExternalReferenceBatch('Taiwan', null, null); 
        Database.executebatch(batch, 100);
    }

}