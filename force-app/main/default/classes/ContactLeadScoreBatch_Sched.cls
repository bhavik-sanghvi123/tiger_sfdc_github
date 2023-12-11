public class ContactLeadScoreBatch_Sched implements Schedulable {
   
    public void execute(SchedulableContext sc) {
        List<LeadScoringCriteria__c> leadScoreCriteriaList = [SELECT Id,Market__c, KeyBrand__c, ChannelCategory__c, ChannelType__c, Medium__c,Channel_Ref_No__c FROM LeadScoringCriteria__c
                                                         WHERE Is_Active__c=true];
        
        Map<String, List<LeadScoringCriteria__c>> marketBrandLeadScoreCriteriaMap = new Map<String, List<LeadScoringCriteria__c>>();
        Map<String, List<LeadScoring__c>> marketBrandLeadScoreMap = new Map<String, List<LeadScoring__c>>();
        List<String> marketList = new List<String>();
        List<String> brandList = new List<String>();
        for(LeadScoringCriteria__c lcs: leadScoreCriteriaList){
            String keyMarket = lcs.Market__c;
            String keyBrand = lcs.KeyBrand__c;
            brandList.add(keyBrand);
            marketList.add(keyMarket);
        }
        
        Map<String, Set<String>> keybrandObjectMap = new Map<String, Set<String>>();
        //Get Lead Score for all Objects based on Market and Key Brand SOQL-1
        for(LeadScoring__c leadScore: [SELECT Id,Field__c,Market__c, Comparison__c,Text_Value__c,
                                       Range_Min__c,Range_Max__c,Number_Value__c,KeyBrand__c,
                                       Object__c, Score__c, Stackable__c, Binary_Value__c,RecordType__c,
                                       Trigger_Field__c,Name FROM LeadScoring__c 
                                       WHERE Is_Active__c=true]){
            String keyMarket = leadScore.Market__c;
            String keyBrand = leadScore.KeyBrand__c;
            String mapKey = keyMarket+'::'+keyBrand;
            Set<String> leadScoreObjectTempSet = new Set<String>();
            
            if(keybrandObjectMap.containsKey(mapKey)){
            	leadScoreObjectTempSet.addAll(keybrandObjectMap.get(mapKey));                       
            }
            String objectNameTemp = leadScore.Object__c;
            if(leadScore.Object__c.equalsIgnoreCase('Contact')){
                      objectNameTemp = objectNameTemp+'-'+leadScore.RecordType__c;                    
            }                          
            leadScoreObjectTempSet.add(objectNameTemp);
            keybrandObjectMap.put(mapKey,leadScoreObjectTempSet);                             
        }
      	Integer leadScoreBatchSize = Integer.valueof(Label.LeadScoreBatchSize);
        if(!leadScoreCriteriaList.isEmpty()){
            // Make sure you're not exceeding the governor limits
            if (Limits.getLimitAsyncCalls() > Limits.getAsyncCalls()) {
                for(LeadScoringCriteria__c l : leadScoreCriteriaList){
                    String keyMarket = l.Market__c;
                    String keyBrand = l.KeyBrand__c;
                    String mapKey = keyMarket+'::'+keyBrand;
                    List<String> objectList = new List<String>();
                    objectList.addAll(keybrandObjectMap.get(mapKey));
                    database.executebatch(new LeadScoreBatch(l,objectList),leadScoreBatchSize);  
                }
            } else {
                // Handle the case when the limit is reached
                system.debug('Current Limit:' + Limits.getAsyncCalls() + ' Limit:' + Limits.getLimitAsyncCalls());
            } 
        }
    }

}