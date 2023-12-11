/**
* @author        Rey Austral
* @date          7.23.2019
* @description   Batch job to run daily to update the New to Brand Checkbox
* @revision(s)
*/
global class BrandNewRegistrationBatch Implements Database.Batchable<sObject> {
    String country;
    Date beginDate;
    Integer interval;
    
    global BrandNewRegistrationBatch (String inputCountry, String inputBeginDateStr, Integer inputMonthsInterval){
        if(!String.isBlank(inputCountry)) country = inputCountry;
        if(!String.isBlank(inputBeginDateStr)) beginDate = Date.valueOf(inputBeginDateStr);
        if(inputMonthsInterval != null) interval = inputMonthsInterval;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String amQueryStr = 'SELECT MasterLabel, ChannelNewRegistrationValidity__c FROM AffiliateMetadata__mdt' 
            + ' WHERE ChannelNewRegistrationValidity__c != null';
        if(!String.isBlank(country)) amQueryStr += ' AND MasterLabel =: country';
        amQueryStr += ' ORDER BY ChannelNewRegistrationValidity__c LIMIT 1';
        List<AffiliateMetadata__mdt> am = Database.query(amQueryStr);
        String query;
        
        if(!am.isEmpty()){
            Date referenceDate = Date.today();
            if(beginDate != null) referenceDate = beginDate;
            String stringStartDate;
            if(interval != null) {
                Date startDate = referenceDate.addMonths(-(am.get(0).ChannelNewRegistrationValidity__c.intValue() + interval) );
                stringStartDate = String.valueOf(startDate).replace(' 00:00:00','');
            }
            Date endDate = referenceDate.addMonths(-am.get(0).ChannelNewRegistrationValidity__c.intValue());
            String stringEndDate = String.valueOf(endDate).replace(' 00:00:00','');
            
            query = 'SELECT ID , NewtoBrand__c, NewtoBrandDate__c, PrimaryContact__r.Market__c'                           
                + ' FROM BrandRelationship__c'
                + ' WHERE';
            if(!String.isBlank(country)) query += ' Market__c = \'' + country + '\' AND';
            if(!String.isBlank(stringStartDate)) query += ' NewtoBrandDate__c >= ' + stringStartDate + ' AND';
            query += ' NewtoBrandDate__c < ' + stringEndDate
                + ' AND NewtoBrand__c = true'
                + ' Order by NewtoBrandDate__c asc';
        }
        else{
            query = 'SELECT ID FROM BrandRelationship__c LIMIT 0';
        }
        System.debug(query);
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<BrandRelationship__c> scope) {
        //need to compare per country
        List<AffiliateMetadata__mdt> am = [Select MasterLabel, ChannelNewRegistrationValidity__c 
                                           From AffiliateMetadata__mdt Where ChannelNewRegistrationValidity__c != null];
        Map<String, String> acs = UtilityClass.convertObjToMap(am, CommonConstant.AFFILIATE_MASTERLABEL , 'ChannelNewRegistrationValidity__c');
        
        Map<Id, BrandRelationship__c> brToUpdateMap = New Map<Id, BrandRelationship__c>();
        for(BrandRelationship__c br : scope) {  
            if (acs.containsKey(br.PrimaryContact__r.Market__c)) {
                String settings = acs.get(br.PrimaryContact__r.Market__c);
                Date computedDate = Date.today().addMonths(-Integer.valueOf(settings));
                //the current date should be outside of the (bday+custom settings)
                if (br.NewtoBrandDate__c < computedDate) {                    
                    br.NewtoBrand__c = false;
                    brToUpdateMap.put(br.Id, br);
                }
            }			
        }
        
        if(!brToUpdateMap.isEmpty()) {
            // Update brToUpdateMap.values();
            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(brToUpdateMap.values(), dml);
        }
    }    
    
    global void finish(Database.BatchableContext BC) {
    }
}