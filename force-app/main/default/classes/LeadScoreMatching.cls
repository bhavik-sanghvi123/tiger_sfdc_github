public class LeadScoreMatching {
    
    SObject record;
    List<LeadScoring__c> leadScore = new List<LeadScoring__c>();
    List<LeadScoring__c> matchLeadScore = new List<LeadScoring__c>();
    Map<Id,Set<String>> recTriggerField = new Map<Id,Set<String>>();
    Boolean stackable;
    public Decimal conScore = 0;
    
    public LeadScoreMatching(SObject record, List<LeadScoring__c> leadScore, Map<Id,Set<String>> recTriggerField, Boolean stackable){
        this.record = record;
        this.leadScore = leadScore;
        this.recTriggerField = recTriggerField;
        this.stackable = stackable;
    }
    
    public Boolean checkIfMatch(){
        Boolean match = false;
        Boolean startComparing = false;
		String leadscoreName ='';
        for(LeadScoring__c ls : leadScore){
            leadscoreName = ls.Name;
            if(!Test.isRunningTest()){
            	if(!stackable || recTriggerField.get((Id)record.get('Id')).contains('created')){
                    startComparing = true;
                }
                else if (stackable && (recTriggerField.get((Id)record.get('Id')).contains(ls.Trigger_Field__c) || recTriggerField.get((Id)record.get('Id')).contains(ls.Field__c))){
                    startComparing = true;
                }
            }else{
                startComparing = true;
            }
            
            
            
            if(startComparing){
                Switch on ls.Comparison__c{
                    
                    when 'Text'{
                        
                        String field1;
                        String field2;
                        String field3;
                        SObject parentObj;
                        Id grandparentId;
                        
                        if (ls.Field__c.contains('__r')){
                            system.debug('ls Field' + ls.Field__c);
                            List<String> objRelList = ls.Field__c.split('\\.');
                            system.debug('objRelList' + objRelList);
                            field1 = objRelList[0];
                            if(objRelList[1]=='Parent'){
                                field2 = objRelList[1] + 'Id';
                            }
                            else{
                                field2 = objRelList[1];
                            }
                            if(objRelList.size()==3){
                                field3 = objRelList[2];
                                parentObj = (SObject)record.getSObject(field1);
                                grandparentId = (Id)parentObj.get(field2);
                            }
                            
                            if (objRelList.size()==2 && record.getSObject(field1) != null && record.getSObject(field1).get(field2) != null){
                                String textVal = (String)record.getSObject(field1).get(field2);
                                if(textVal.equalsIgnoreCase(ls.Text_Value__c)){
                                    conScore+=ls.score__c;
                                    match=true;
                                }
                            }
                            else if(objRelList.size()==3 && record.getSObject(field1) != null && record.getSObject(field1).get(field2) != null && grandparentId != null){
                                Campaign parentCampaign = [
                                    SELECT Name
                                    FROM Campaign
                                    WHERE Id = :grandparentId
                                ];
                                String textVal = parentCampaign.Name;
                                if(textVal.equalsIgnoreCase(ls.Text_Value__c)){
                                    conScore+=ls.score__c;
                                    match=true;
                                }
                            }
                        } else if (record.get(ls.Field__c) != null){
                            String textVal = (String)record.get(ls.Field__c);
                            if(textVal.equalsIgnoreCase(ls.Text_Value__c)){
                                conScore+=ls.score__c;
                                match=true;
                            }
                            
                        }
                        
                    }
                    
                    when 'Text Equals'{
                        
                        String field1;
                        String field2;
                        
                        if (ls.Field__c.contains('__r')){
                            List<String> objRelList = ls.Field__c.split('__r.');
                            field1 = objRelList[0] + '__r';
                            field2 = objRelList[1];
                            
                            if (record.getSObject(field1) != null && record.getSObject(field1).get(field2) != null && record.getSObject(field1).get(field2).equals(ls.Text_Value__c)){
                                conScore+=ls.score__c;
                                match=true;
                            }
                        } else if (record.get(ls.Field__c) != null && record.get(ls.Field__c).equals(ls.Text_Value__c)){
                            conScore+=ls.score__c;
                            match=true;
                            
                        }
                        
                    }
                    
                    when 'Number Range'{
                        
                        //System.debug(record.get(ls.Field__c));
                        
                        if (record.get(ls.Field__c) != null && ((Double) record.get(ls.Field__c) >= ls.Range_Min__c && (Double) record.get(ls.Field__c) <= ls.Range_Max__c)){
                            conScore+=ls.score__c;
                            match=true;
                        }
                        
                    }
                    
                    when 'Greater Than'{
                        
                        //System.debug(record.get(ls.Field__c));
                        if (record.get(ls.Field__c) != null && (Double) record.get(ls.Field__c) > ls.Number_Value__c){
                            conScore+=ls.score__c;
                            match=true;
                        }
                        
                    }
                    
                    when 'Less Than'{
                        
                        //System.debug(record.get(ls.Field__c));
                        if (record.get(ls.Field__c) != null && (Double) record.get(ls.Field__c) < ls.Number_Value__c){
                            conScore+=ls.score__c;
                            match=true;
                        }
                        
                    }
                    
                    when 'Equals'{
                        
                        //System.debug(record.get(ls.Field__c));
                        if (record.get(ls.Field__c) != null && (Double) record.get(ls.Field__c) == ls.Number_Value__c){
                            conScore+=ls.score__c;
                            match=true;
                        }
                    }
                    
                    when 'Boolean'{
                        
                        //System.debug(record.get(ls.Field__c));
                        if (record.get(ls.Field__c) != null && (Boolean) record.get(ls.Field__c) == ls.Binary_Value__c){
                            conScore+=ls.score__c;
                            match=true;
                        }
                        
                    }
                    
                    when 'Is Null'{
                        
                        //System.debug(record.get(ls.Field__c));
                        if (ls.Binary_Value__c){
                            if (record.get(ls.Field__c) == null){
                                conScore+=ls.score__c;
                                match=true;
                            }
                        } else if (!ls.Binary_Value__c){
                            if (record.get(ls.Field__c) != null){
                                conScore+=ls.score__c;
                                match=true;
                            }
                        }
                        
                    }
                    
                    when 'Text Mid'{
                        
                        String field1;
                        String field2;
                        
                        if (ls.Field__c.contains('__r')){
                            List<String> objRelList = ls.Field__c.split('__r.');
                            field1 = objRelList[0] + '__r';
                            field2 = objRelList[1];
                            
                            if (record.getSObject(field1) != null && record.getSObject(field1).get(field2) != null){
                                String originalText = (String) record.getSObject(field1).get(field2);
                                String textToCompare = originalText.mid((Integer) ls.Range_Min__c, (Integer) ls.Range_Max__c);
                                
                                if (textToCompare.equalsIgnoreCase(ls.Text_Value__c)){
                                    conScore+=ls.score__c;
                                    match=true;
                                }
                            }
                            
                        }
                        
                        else if (record.get(ls.Field__c) != null){
                            String originalText = (String) record.get(ls.Field__c);
                            String textToCompare = originalText.mid((Integer) ls.Range_Min__c, (Integer) ls.Range_Max__c);
                            
                            if (textToCompare.equalsIgnoreCase(ls.Text_Value__c)){
                                conScore+=ls.score__c;
                                match=true;
                            }
                            
                        }
                        
                    }
                    when 'Text Mid List'{
                        
                        String field1;
                        String field2;
                        
                        if (ls.Field__c.contains('__r')){
                            List<String> objRelList = ls.Field__c.split('__r.');
                            field1 = objRelList[0] + '__r';
                            field2 = objRelList[1];
                            
                            if (record.getSObject(field1) != null && record.getSObject(field1).get(field2) != null){
                                String originalText = (String) record.getSObject(field1).get(field2);
                                String textToCompare = originalText.mid((Integer) ls.Range_Min__c, (Integer) ls.Range_Max__c);
                                Set<String> textValueSet = new Set<String>();
                                textValueSet.addAll(ls.Text_Value__c.split(';'));
                                if(textValueSet.contains(textToCompare)){
                                    conScore+=ls.score__c;
                                    match=true;
                                }
                            }
                            
                        }
                        
                        else if (record.get(ls.Field__c) != null){
                            String originalText = (String) record.get(ls.Field__c);
                            String textToCompare = originalText.mid((Integer) ls.Range_Min__c, (Integer) ls.Range_Max__c);
                            Set<String> textValueSet = new Set<String>();
                            textValueSet.addAll(ls.Text_Value__c.split(';'));
                            if (textValueSet.contains(textToCompare)){
                                conScore+=ls.score__c;
                                match=true;
                            }
                            
                        }
                        
                    }
                }
                
            }
            }
        return match;
    }
    
}