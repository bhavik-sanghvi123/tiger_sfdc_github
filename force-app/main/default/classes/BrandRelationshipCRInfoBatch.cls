global class BrandRelationshipCRInfoBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    String market;
    Integer daysRange;
    Date startDate;
    Date endDate;
    Set<Id> brIdSet = new Set<Id>();
    
    global BrandRelationshipCRInfoBatch (String marketInput, Integer daysRangeInput, Date startDateInput, Date endDateInput, Set<Id> brIdSetInput){
        if(!String.isBlank(marketInput)) market = marketInput;
        if(daysRangeInput != null) daysRange = daysRangeInput;
        if(startDateInput != null) startDate = startDateInput;
        if(endDateInput != null) endDate = endDateInput;
        if(brIdSetInput != null && !brIdSetInput.isEmpty()) brIdSet = brIdSetInput;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryStr;
        String queryStrWhere;
        queryStr = 'SELECT Id, Active__c, BrandRelationship__c, KeyBrand__c, Market__c, CreatedDate, PrimaryContact__c, User__c, Type__c,'
            + ' FirstChannelResponse__c, FirstChannelResponseDate__c, LatestChannelResponse__c, LatestChannelResponseDate__c,'
            + ' (SELECT Id, BrandRelationship__c, Campaign__c, Category__c, Channel__c, ChannelType__c, Classification__c, Contact__c, ProductSampleRequested__c, RegistrationDate__c FROM Channel_Responses__r)'
            + ' FROM BrandRelationship__c ';
        queryStrWhere = ' WHERE Active__c = true AND (FirstChannelResponse__c = null OR LatestChannelResponse__c = null)';
        if(!String.isBlank(market) || daysRange != null ||startDate != null || endDate != null || !brIdSet.isEmpty()){
            if(!String.isBlank(market)){
                queryStrWhere += ' AND Market__c = \'' + market + '\'';
            }
            if(daysRange != null) {
                DateTime setDate = Date.today().addDays(-daysRange);
                String formatSetDate = setDate.format('yyyy-MM-dd');
                queryStrWhere += ' AND DAY_ONLY(CreatedDate) >= ' + formatSetDate;
            }
            if(startDate != null){
                queryStrWhere += ' AND DAY_ONLY(CreatedDate) >= :startDate';
            }
            if(endDate != null){
                queryStrWhere += ' AND DAY_ONLY(CreatedDate) <= :endDate';
            }
            if(!brIdSet.isEmpty()){
                queryStrWhere += ' AND Id IN: brIdSet';
            }
        }
        queryStr += queryStrWhere;
		System.debug(queryStrWhere);
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<BrandRelationship__c> scope) {
        Map<Id, BrandRelationship__c> brUpdateMap = new Map<Id, BrandRelationship__c>();
        if(!scope.isEmpty()){
            for(BrandRelationship__c br : scope){
                for(ChannelResponse__c cr : br.Channel_Responses__r){
                    Datetime registrationDate = cr.RegistrationDate__c == null ? cr.CreatedDate : cr.RegistrationDate__c;
                    if(brUpdateMap.containsKey(br.Id)){
                        BrandRelationship__c brComp = brUpdateMap.get(br.Id);
                        if(brComp.FirstChannelResponseDate__c == null || registrationDate < brComp.FirstChannelResponseDate__c){
                            br.FirstChannelResponse__c = cr.Channel__c;
                            br.FirstChannelResponseDate__c = registrationDate;
                        }
                        if(brComp.LatestChannelResponseDate__c == null || registrationDate > brComp.LatestChannelResponseDate__c){
                            br.LatestChannelResponse__c = cr.Channel__c;
                            br.LatestCampaign__c = cr.Campaign__c;
                            br.LatestChannelResponseDate__c = registrationDate;
                        }
                        brUpdateMap.put(br.Id, br);
                    }
                    else{
                        br.FirstChannelResponse__c = cr.Channel__c;
                        br.FirstChannelResponseDate__c = registrationDate;
                        br.LatestChannelResponse__c = cr.Channel__c;
                        br.LatestChannelResponseDate__c = registrationDate;
                        brUpdateMap.put(br.Id, br);
                    }
                }
            }
            
            if(!brUpdateMap.keySet().isEmpty()) UtilityClass.updateList(brUpdateMap.values()); 
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        BrandRelationshipCRInfoBatch batch = new BrandRelationshipCRInfoBatch(market, daysRange, startDate, endDate, brIdSet); 
        Database.executebatch(batch, 50);
    }
}