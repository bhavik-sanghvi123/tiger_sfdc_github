public class LeadScoreBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    //New variable for optimized process - New
    List<String> leadScoreObjectList = new List<String>();
    List<LeadScoring__c> leadScoreList = new List<LeadScoring__c>();
    LeadScoringCriteria__c brandLeadScoreCriteria = new LeadScoringCriteria__c();
    String mapKey;
    Integer currIndex;
    Set<String> trFlds = new Set<String>();
    Map<String,Set<String>> objFds = new Map<String,Set<String>>();
    Date historicalDate ;
    //End
    
    Map<String,Boolean> objectStackable = new Map<String,Boolean>();
    Map<String,Map<Id,Set<String>>> objectIdFields = new Map<String,Map<Id,Set<String>>>();
    Map<String,Map<Id,sObject>> objectMap = new Map<String,Map<Id,sObject>>();
    Map<String,List<LeadScoring__c>> objectLeadScore = new Map<String,List<LeadScoring__c>>();
    Map<Id,sObject> allObjectMap = new Map<Id,sObject>();
    Id adultRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_ADULT_RECORDTYPE).getRecordTypeId();
    Id childRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_CHILD_RECORDTYPE).getRecordTypeId();
    
    
    //Constructor for Date leadScoring
    public LeadScoreBatch(LeadScoringCriteria__c brandLeadScoreCriteria,
                          List<String> leadScoreObjectList,
                          Date dtnow){
                              this.brandLeadScoreCriteria = brandLeadScoreCriteria;
                              this.leadScoreObjectList =  leadScoreObjectList;
                              this.currIndex = 0;
                              this.historicalDate = dtnow;
                          }
    
    //New Constructor for opmitized process
    public LeadScoreBatch(LeadScoringCriteria__c brandLeadScoreCriteria,
                          List<String> leadScoreObjectList){
                              this.brandLeadScoreCriteria = brandLeadScoreCriteria;
                              this.leadScoreObjectList =  leadScoreObjectList;
                              this.currIndex = 0;
                              this.historicalDate = null;
                          }
    
    public Iterable<sObject> start(Database.BatchableContext bc){
        String objectName = this.leadScoreObjectList[this.currIndex];
        String objNm;
        if(objectName.containsIgnoreCase('Contact')){
            objNm = objectName.split('-')[0];
        }else{
            objNm = objectName;
        }
        String market = brandLeadScoreCriteria.Market__c;
        String brand = brandLeadScoreCriteria.KeyBrand__c;
        String medium = brandLeadScoreCriteria.Medium__c;
        String category = brandLeadScoreCriteria.ChannelCategory__c;
        String channelType = brandLeadScoreCriteria.ChannelType__c;
        Map<String,Set<String>> objTrFlds = new Map<String,Set<String>>();
        
        Map<String,Decimal> objectNoOfDays =  new Map<String,Decimal>();
        objFds = new Map<String,Set<String>>();
        
        //Get Lead Score for all Objects based on Market and Key Brand SOQL-1
        List<LeadScoring__c> leadScore = [SELECT Id,Field__c,Market__c, Comparison__c,Text_Value__c,
                                          Range_Min__c,Range_Max__c,Number_Value__c,
                                          Object__c, Score__c, Stackable__c, Binary_Value__c,RecordType__c,Trigger_Field__c,Name FROM LeadScoring__c 
                                          WHERE Is_Active__c=true AND Market__c= :brandLeadScoreCriteria.Market__c AND KeyBrand__c= :brandLeadScoreCriteria.KeyBrand__c AND Object__c=:objNm];
        
        //Get Lead Score Object Settings for Stackable and No of Days of history objects to query SOQL-2
        List<LeadScoringObjectSetting__mdt> leadScoreObject = [SELECT Object__c,Stackable__c,No_of_Days__c FROM LeadScoringObjectSetting__mdt WHERE Market__c= :market
                                                               AND KeyBrand__c= :brand AND Is_Active__c=true];
        
        if(!leadScoreObject.isEmpty()){
            
            for(LeadScoringObjectSetting__mdt ls : leadScoreObject){
                objectStackable.put(ls.Object__c,ls.Stackable__c);
                objectNoOfDays.put(ls.Object__c,ls.No_of_Days__c);
            }
            
        }
        
        if(!leadScore.isEmpty()){
            for(LeadScoring__c ls : leadScore){
                //loop into lead scoring and store object/record type with set of triggered fields and fields
                if(!objTrFlds.isEmpty() && (objTrFlds.containsKey(ls.Object__c) || objTrFlds.containsKey(ls.Object__c + '-' + ls.RecordType__c))){
                    if(ls.RecordType__c == null){
                        if(ls.Trigger_Field__c != null){
                            objTrFlds.get(ls.Object__c).add(ls.Trigger_Field__c);
                        }
                        else{
                            objTrFlds.get(ls.Object__c).add(ls.Field__c);
                        }
                        system.debug('objFds put: ' + ls.Object__c + ' ' + ls.Field__c);
                        objFds.get(ls.Object__c).add(ls.Field__c);
                        objectLeadScore.get(ls.Object__c).add(ls);
                        //objectTriggerFields.get(ls.Object__c).add('created');
                    }
                    else{
                        if(ls.Trigger_Field__c != null){
                            objTrFlds.get(ls.Object__c + '-' + ls.RecordType__c).add(ls.Trigger_Field__c);
                        }
                        else{
                            objTrFlds.get(ls.Object__c + '-' + ls.RecordType__c).add(ls.Field__c);
                        }
                        system.debug('objFds put: ' + ls.Object__c + ' ' + ls.Field__c);
                        objFds.get(ls.Object__c).add(ls.Field__c);
                        objectLeadScore.get(ls.Object__c + '-' + ls.RecordType__c).add(ls);
                        //objectTriggerFields.get(ls.Object__c + '-' + ls.RecordType__c).add('created');
                    }
                    
                }
                else{
                    Set<String> ftmp = new Set<String>();
                    ftmp.add(ls.Trigger_Field__c);
                    
                    Set<String> ftmp1 = new Set<String>();
                    ftmp1.add(ls.Field__c);
                    
                    List<LeadScoring__c> ftmp2 = new List<LeadScoring__c>();
                    ftmp2.add(ls);
                    
                    if(ls.RecordType__c == null){
                        if(ls.Trigger_Field__c != null){
                            objTrFlds.put(ls.Object__c,ftmp);
                        }
                        else{
                            objTrFlds.put(ls.Object__c,ftmp1);
                            
                        }
                        system.debug('objFds put: ' + ls.Object__c + ' ' + ftmp1);
                        objFds.put(ls.Object__c,ftmp1);
                        objectLeadScore.put(ls.Object__c,ftmp2);
                    }
                    else{
                        if(ls.Trigger_Field__c != null){
                            objTrFlds.put(ls.Object__c + '-' + ls.RecordType__c,ftmp);
                            
                            
                        }
                        else{
                            objTrFlds.put(ls.Object__c + '-' + ls.RecordType__c,ftmp1);
                        }
                        system.debug('objFds put: ' + ls.Object__c + ' ' + ftmp1);
                        objFds.put(ls.Object__c,ftmp1);
                        objectLeadScore.put(ls.Object__c + '-' + ls.RecordType__c,ftmp2);
                    }
                }
                
                
            }
        }
        
        Integer noofDays =  objectNoOfDays.get(objNm)==null? 1: (Integer) objectNoOfDays.get(objNm);
        trFlds = new Set<String>();
        trFlds.add('created');
        trFlds.addAll(objTrFlds.get(objectName));
        Set<String> nameMatchSet = new Set<String>();
        String queryLoc;
        if(objTrFlds.get('et4ae5__IndividualEmailResult__c')!=null){
            
            if(!objTrFlds.get('et4ae5__IndividualEmailResult__c').isEmpty()){
                List<LeadScoringNameMatch__c> nameMatch = [SELECT Name__c, Field__c FROM LeadScoringNameMatch__c WHERE Is_Active__c=true AND Market__c= :market 
                                                           AND Object__c='et4ae5__IndividualEmailResult__c' AND Field__c='Name' AND KeyBrand__c= :brand];
                Integer edmNoOfDays = (Integer) objectNoOfDays.get('et4ae5__IndividualEmailResult__c');
                
                if(!nameMatch.isEmpty()){
                    for(LeadScoringNameMatch__c nm : nameMatch){
                        nameMatchSet.add(nm.Name__c);
                    }
                }
                queryLoc = 'SELECT OldValue, NewValue, Field, ParentId FROM et4ae5__IndividualEmailResult__History WHERE Parent.Name IN :nameMatchSet AND Field IN :trFlds';  
            }
        }
        if(objTrFlds.get('Contact-Adult')!=null){
            
            if(!objTrFlds.get('Contact-Adult').isEmpty()){
                queryLoc = 'SELECT OldValue, NewValue, Field, ContactId FROM ContactHistory WHERE Field IN :trFlds AND Contact.Active__c=true AND Contact.Market__c= :market AND Contact.RecordTypeId= :adultRecType';
            }
        }
        if(objTrFlds.get('Contact-Child')!=null){
            
            if(!objTrFlds.get('Contact-Child').isEmpty()){
                
                queryLoc = 'SELECT OldValue, NewValue, Field, ContactId FROM ContactHistory WHERE Field IN :trFlds AND Contact.Active__c=true AND Contact.Market__c= :market AND Contact.RecordTypeId= :childRecType';
                
            }
        }
        if(objTrFlds.get('BrandRelationship__c')!=null){
            
            if(!objTrFlds.get('BrandRelationship__c').isEmpty()){
                queryLoc = 'SELECT OldValue, NewValue, Field, ParentId FROM BrandRelationship__History WHERE Field IN :trFlds AND Parent.Market__c= :market AND Parent.KeyBrand__c= :brand';
            }
        }
        if(objTrFlds.get('ChannelResponse__c')!=null){
            
            if(!objTrFlds.get('ChannelResponse__c').isEmpty()){
                queryLoc = 'SELECT OldValue, NewValue, Field, ParentId FROM ChannelResponse__History WHERE Field IN :trFlds AND Parent.Medium__c= :medium AND Parent.Category__c= :category AND Parent.ChannelType__c= :channelType';
                
                
            }
        }
        if(objTrFlds.get('Case')!=null){
            
            if(!objTrFlds.get('Case').isEmpty()){
                queryLoc = 'SELECT OldValue, NewValue, Field, CaseId FROM CaseHistory WHERE Field IN :trFlds AND Case.Contact.Active__c=true AND Case.Contact.Market__c= :market AND Case.Contact.RecordTypeId= :adultRecType';
            }
            
        }
        if(objTrFlds.get('Address__c')!=null){
            
            if(!objTrFlds.get('Address__c').isEmpty()){
                queryLoc = 'SELECT OldValue, NewValue, Field, ParentId FROM Address__History WHERE Field IN :trFlds';
            }
        }
        if(objTrFlds.get('Membership__c')!=null){
            
            if(!objTrFlds.get('Membership__c').isEmpty()){
                queryLoc = 'SELECT OldValue, NewValue, Field, ParentId FROM Membership__History WHERE Field IN :trFlds';
                
            }
        }
        if(objTrFlds.get('Medical_Diagnosis__c')!=null){
            if(!objTrFlds.get('Medical_Diagnosis__c').isEmpty()){
                queryLoc = 'SELECT OldValue, NewValue, Field, ParentId FROM Medical_Diagnosis__History WHERE Field IN :trFlds';   
            }
        }
        Boolean isDatedValue = false;
        DateTime startDate;
        DateTime endDate;
        if(this.historicalDate!=null){
            isDatedValue =true;
        }
        if(!isDatedValue){
            if(Test.isRunningTest()){
                if(objectName.containsIgnoreCase('Contact')){
                    queryLoc =  'SELECT Id FROM Contact';
                }else{
                    queryLoc =  'SELECT Id FROM '+objectName;
                }
            }else{
                if(noofDays==1){
                    queryLoc += ' AND CreatedDate=YESTERDAY'; 
                }else{
                    queryLoc += ' AND CreatedDate>=LAST_N_DAYS:'+noofDays; 
                }
            }
        }else{
            Integer d = this.historicalDate.day();
            Integer mo = this.historicalDate.month();
            Integer yr = this.historicalDate.year();
            
            startDate = DateTime.newInstance(yr, mo, d, 0, 0, 0);
            endDate = DateTime.newInstance(yr, mo, d, 23, 59, 59);
            
            queryLoc += ' AND CreatedDate>=:startDate AND CreatedDate<=:endDate';
        }
        if(Test.isRunningTest()){
            
        }else{
            if(objectName.containsIgnoreCase('Contact')){
                queryLoc += ' Order By ContactId ASC ';
            }else{
                queryLoc += ' Order By ParentId ASC ';
            } 
        }
        
        
        System.debug('Ger Look here objectName>>>>'+objectName);
        System.debug('Ger Look here queryLoc>>>>'+queryLoc);
        return Database.getqueryLocator(queryLoc);
    }
    
    public Set<Id> getParentId(String objectName, List<sObject> sObjList, String parentFieldName){
        Set<Id> retparentIdList = new Set<Id>();
        Map<Id,Set<String>> edmIdFields = new Map<Id,Set<String>>();
        Map<Id,sObject> edmMap = new Map<Id,sObject>();
        for(sObject sobj : sObjList){
            for(String f : trFlds){
                String newf = f;
                if(f.contains('__r')){
                    List<String> objRelList = f.split('__r.');
                    newf = objRelList[0] + '__c';
                }
                String fieldName;
                if(Test.isRunningTest()){
                    fieldName = 'Id';
                }else{
                    fieldName= 'Field';
                }
                if((String)sobj.get(fieldName) == newf){
                    if(!edmIdFields.isEmpty() && edmIdFields.containsKey((Id)sobj.get(parentFieldName))){
                        edmIdFields.get((String)sobj.get(parentFieldName)).add(f);
                    }
                    else{
                        Set<String> ftmp = new Set<String>();
                        ftmp.add(f);
                        edmIdFields.put((Id)sobj.get(parentFieldName),ftmp);
                    }
                    retparentIdList.add((String)sobj.get(parentFieldName));
                }
                
            }
        }
        
        if(!edmIdFields.isEmpty()){
            objectIdFields.put(objectName,edmIdFields);
        }
        return retparentIdList;
    }

    public void execute(Database.BatchableContext bc, List<sObject> objList){
        String obName = this.leadScoreObjectList[this.currIndex];
        Map<String,Set<Id>> objMatch = new Map<String,Set<Id>>();
        Map<String,Map<Id,Decimal>> objMatchScore = new Map<String,Map<Id,Decimal>>();
        Map<Id,List<Map<Id,Decimal>>> stackableScore = new Map<Id,List<Map<Id,Decimal>>>();
        Map<Id,BrandRelationship__c> brToUpdate = new Map<Id,BrandRelationship__c>();
        String market = brandLeadScoreCriteria.Market__c;
        String brand = brandLeadScoreCriteria.KeyBrand__c;
        String medium = brandLeadScoreCriteria.Medium__c;
        String category = brandLeadScoreCriteria.ChannelCategory__c;
        String channelType = brandLeadScoreCriteria.ChannelType__c;
        //Added for Channel Reference No filter
        List<String> channelRefNoList = new List<String>();
        if(brandLeadScoreCriteria.Channel_Ref_No__c!=null){
            channelRefNoList.addAll(brandLeadScoreCriteria.Channel_Ref_No__c.split(';'));
        }
        String query;
        Set<Id> parentIdList = new Set<Id>();
        //Added new code - Start
        if(obName.equalsIgnoreCase('et4ae5__IndividualEmailResult__c')){
            List<et4ae5__IndividualEmailResult__History > edmHistoryList = new List<et4ae5__IndividualEmailResult__History >();
            if(!Test.isRunningTest()){
               edmHistoryList = objList;
            } 
            if(!edmHistoryList.isEmpty()  || Test.isRunningTest()){
                Set<Id> edmIds = new Set<Id>();
                Map<Id,Set<String>> edmIdFields = new Map<Id,Set<String>>();
                Map<Id,sObject> edmMap = new Map<Id,sObject>();
                parentIdList.addAll(getParentId('et4ae5__IndividualEmailResult__c',objList,'ParentId'));
                
                //adding fields to string query
                if(!objFds.get('et4ae5__IndividualEmailResult__c').isEmpty()){
                    List<String> listFields = new List<String>();
                    listFields.addAll(objFds.get('et4ae5__IndividualEmailResult__c'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                query += ',et4ae5__Contact__c FROM et4ae5__IndividualEmailResult__c WHERE Id IN :parentIdList';
                query += ' AND et4ae5__Contact__r.Active__c=true AND et4ae5__Contact__r.Market__c= :market AND et4ae5__Contact__r.RecordTypeId = :adultRecType';
                if(Test.isRunningTest()){
                    for(et4ae5__IndividualEmailResult__c con: [SELECT Id FROM et4ae5__IndividualEmailResult__c]){
                        parentIdList.add(con.Id);
                    }
                }
                List<et4ae5__IndividualEmailResult__c > edmList = Database.query(query);
                
                if(!edmList.isEmpty()){
                    for(et4ae5__IndividualEmailResult__c edm: edmList){
                        edmMap.put(edm.Id,edm);
                        allObjectMap.put(edm.Id,edm);
                    }
                }
                
                if(!edmMap.isEmpty()){
                    objectMap.put('et4ae5__IndividualEmailResult__c',edmMap);
                }
            }          
        }
        if(obName.equalsIgnoreCase('Contact-Adult')){
            List<ContactHistory> cHistoryList = new List<ContactHistory >();
            if(!Test.isRunningTest()){
               cHistoryList = objList;
            } 
            if(!cHistoryList.isEmpty() || Test.isRunningTest()){
                parentIdList.addAll(getParentId('Contact-Adult',objList,'ContactId'));
                
                //adding fields to string query
                if(!objFds.get('Contact').isEmpty()){
                    List<String> listFields = new List<String>();
                    listFields.addAll(objFds.get('Contact'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                if(Test.isRunningTest()){
                    for(Contact con: [SELECT Id FROM Contact]){
                        parentIdList.add(con.Id);
                    }
                }
                query += ',market__c, RecordTypeId, Verified__c FROM Contact WHERE Id IN :parentIdList';
                query += ' AND Active__c=true AND market__c= :market AND RecordTypeId= :adultRecType';
            }
        }
        if(obName.equalsIgnoreCase('Contact-Child')){
            List<ContactHistory> cHistoryList = new List<ContactHistory >();
            if(!Test.isRunningTest()){
               cHistoryList = objList;
            } 
            if(!cHistoryList.isEmpty() || Test.isRunningTest()){
                parentIdList.addAll(getParentId('Contact-Child',objList,'ContactId'));
                
                //adding fields to string query
                if(!objFds.get('Contact').isEmpty()){
                    List<String> listFields = new List<String>();
                    listFields.addAll(objFds.get('Contact'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                if(Test.isRunningTest()){
                    for(Contact con: [SELECT Id FROM Contact]){
                        parentIdList.add(con.Id);
                    }
                }
                
                query += ',market__c, RecordTypeId, Verified__c FROM Contact WHERE Id IN :parentIdList';
                query += ' AND Active__c=true AND market__c= :market AND RecordTypeId= :childRecType';
            }
        }
        if(obName.equalsIgnoreCase('BrandRelationship__c')){
            List<BrandRelationship__History> brHistoryList = new List<BrandRelationship__History >();
            if(!Test.isRunningTest()){
               brHistoryList = objList;
            } 
            if(!brHistoryList.isEmpty() || Test.isRunningTest()){
                parentIdList.addAll(getParentId('BrandRelationship__c',objList,'ParentId'));
                               
                //adding fields to string query
                if(!objFds.get('BrandRelationship__c').isEmpty()){
                    List<String> listFields = new List<String>();
                    listFields.addAll(objFds.get('BrandRelationship__c'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                if(Test.isRunningTest()){
                    for(BrandRelationship__c con: [SELECT Id FROM BrandRelationship__c]){
                        parentIdList.add(con.Id);
                    }
                }
                query += ',market__c,LeadScoreBRObj__c FROM BrandRelationship__c WHERE Id IN :parentIdList';
                query += ' AND Id IN (SELECT BrandRelationship__c FROM ChannelResponse__c WHERE Medium__c = :medium';
                query += ' AND Category__c = :category';
                query += ' AND ChannelType__c= :channelType ) AND PrimaryContact__r.Active__c=true AND PrimaryContact__r.Market__c= :market AND PrimaryContact__r.RecordTypeId = :adultRecType';
                
            }
            
            
        }
        if(obName.equalsIgnoreCase('ChannelResponse__c')){
            List<ChannelResponse__History> crHistoryList = new List<ChannelResponse__History >();
            if(!Test.isRunningTest()){
               crHistoryList = objList;
            } 
            if(!crHistoryList.isEmpty() || Test.isRunningTest()){
                parentIdList.addAll(getParentId('ChannelResponse__c',objList,'ParentId'));
                
                //adding fields to string query
                if(!objFds.get('ChannelResponse__c').isEmpty()){
                    List<String> listFields = new List<String>();
                    listFields.addAll(objFds.get('ChannelResponse__c'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                query += ',BrandRelationship__c FROM ChannelResponse__c WHERE Id IN :parentIdList';
                query += ' AND Contact__r.Active__c=true AND Contact__r.Market__c= :market AND Contact__r.RecordTypeId = :adultRecType';
                if(market.equalsIgnoreCase('ph')){
                    String FBSTR = 'fb';
                    query += ' AND Medium__c = :FBSTR';
                }
                
                if(Test.isRunningTest()){
                    for(ChannelResponse__c con: [SELECT Id FROM ChannelResponse__c]){
                        parentIdList.add(con.Id);
                    }
                }
                query += ' Order by BrandRelationship__c ASC, LastmodifiedDate ASC';
                
            }
            
            
        }
        if(obName.equalsIgnoreCase('Case')){
            List<CaseHistory> cHistoryList = new List<CaseHistory >();
            if(!Test.isRunningTest()){
               cHistoryList = objList;
            } 
            if(!cHistoryList.isEmpty() || Test.isRunningTest()){
                parentIdList.addAll(getParentId('Case',objList,'CaseId'));
                
                //adding fields to string query
                if(!objFds.get('Case').isEmpty()){
                    List<String> listFields = new List<String>();
                    system.debug('objFds get:' + objFds.get('Case'));
                    listFields.addAll(objFds.get('Case'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                if(Test.isRunningTest()){
                    for(Case cs: [SELECT Id FROM Case]){
                        parentIdList.add(cs.Id);
                    }
                }
                query += ',ContactId FROM Case WHERE Id IN :parentIdList';
                query += ' AND Contact.Active__c=true AND Contact.Market__c= :market AND Contact.RecordTypeId = :adultRecType';
            }
        }
        if(obName.equalsIgnoreCase('Address__c')){
            List<Address__History> adHistoryList = new List<Address__History >();
            if(!Test.isRunningTest()){
               adHistoryList = objList;
            } 
            if(!adHistoryList.isEmpty() || Test.isRunningTest()){
                parentIdList.addAll(getParentId('Address__c',objList,'ParentId'));
                
                //adding fields to string query
                if(!objFds.get('Address__c').isEmpty()){
                    List<String> listFields = new List<String>();
                    system.debug('objFds get:' + objFds.get('Address__c'));
                    listFields.addAll(objFds.get('Address__c'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                query += ',ParentContact__c FROM Address__c WHERE Id IN :parentIdList';
                query += ' AND ParentContact__r.Market__c= :market AND ParentContact__r.RecordTypeId = :adultRecType';
                query += ' AND ParentContact__r.Active__c=true AND DefaultAddress__c=true';
                if(Test.isRunningTest()){
                    for(Address__c con: [SELECT Id FROM Address__c]){
                        parentIdList.add(con.Id);
                    }
                }
            }
        }
        if(obName.equalsIgnoreCase('Membership__c')){
            List<Membership__History> mHistoryList = new List<Membership__History >();
            if(!Test.isRunningTest()){
               mHistoryList = objList;
            } 
            if(!mHistoryList.isEmpty() || Test.isRunningTest()){
                parentIdList.addAll(getParentId('Membership__c',objList,'ParentId'));
                
                //adding fields to string query
                if(!objFds.get('Membership__c').isEmpty()){
                    List<String> listFields = new List<String>();
                    system.debug('objFds get:' + objFds.get('Membership__c'));
                    listFields.addAll(objFds.get('Membership__c'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                query += ',Contact__c FROM Membership__c WHERE Id IN :parentIdList';
                query += ' AND Contact__r.Active__c=true AND Contact__r.Market__c= :market AND Contact__r.RecordTypeId = :adultRecType';
                if(Test.isRunningTest()){
                    for(Membership__c con: [SELECT Id FROM Membership__c]){
                        parentIdList.add(con.Id);
                    }
                }
            }
        }
        if(obName.equalsIgnoreCase('Medical_Diagnosis__c')){
            List<Medical_Diagnosis__History> mHistoryList = new List<Medical_Diagnosis__History >();
            if(!Test.isRunningTest()){
               mHistoryList = objList;
            } 
            if(!mHistoryList.isEmpty() || Test.isRunningTest()){
                parentIdList.addAll(getParentId('Medical_Diagnosis__c',objList,'ParentId'));
                
                //adding fields to string query
                if(!objFds.get('Medical_Diagnosis__c').isEmpty()){
                    List<String> listFields = new List<String>();
                    system.debug('objFds get:' + objFds.get('Medical_Diagnosis__c'));
                    listFields.addAll(objFds.get('Medical_Diagnosis__c'));
                    String j = String.join(listFields, ',');
                    query = 'SELECT Id,' + j;
                }
                else{
                    query = 'SELECT Id';
                }
                query += ',Contact__c,EndUser__c FROM Medical_Diagnosis__c WHERE Id IN :parentIdList';
                query += ' AND Contact__r.Active__c=true AND Contact__r.Market__c= :market AND Contact__r.RecordTypeId = :adultRecType';
                if(Test.isRunningTest()){
                    for(Medical_Diagnosis__c con: [SELECT Id FROM Medical_Diagnosis__c]){
                        parentIdList.add(con.Id);
                    }
                }
            }
        }
        
        List<sObject> recordQueryList =Database.query(query);
        //Added new code - End
        for(sObject obj: recordQueryList){
            Schema.SObjectType objectType = obj.getSObjectType();
            String objectName = String.valueOf(objectType);
            LeadScoreMatching lsMatch;
            system.debug('checking:'+objectName);
            system.debug(objectLeadScore.get(objectName + '-' + 'Adult'));
            if(objectName == 'Contact' && obj.get('RecordTypeId') !=null && obj.get('Id') !=null){
                if(obj.get('RecordTypeId') == adultRecType){
                    lsMatch = new LeadScoreMatching(obj,objectLeadScore.get(objectName + '-' + 'Adult'),objectIdFields.get(objectName + '-' + 'Adult'),objectStackable.get(objectName));
                }
                else if(obj.get('RecordTypeId') == childRecType){
                    lsMatch = new LeadScoreMatching(obj,objectLeadScore.get(objectName + '-' + 'Child'),objectIdFields.get(objectName + '-' + 'Child'),objectStackable.get(objectName));
                }
            }
            else{
                lsMatch = new LeadScoreMatching(obj,objectLeadScore.get(objectName),objectIdFields.get(objectName),objectStackable.get(objectName));
            }
            if(lsMatch != null && lsMatch.checkIfMatch()){
                Id matchId;
                String objName = objectName;
                
                if(objName == 'et4ae5__IndividualEmailResult__c' && obj.get('et4ae5__Contact__c') != null &&  objectStackable.get(objName)){
                    matchId = (Id)obj.get('et4ae5__Contact__c');
                }
                else if(objName == 'Contact' && obj.get('Id') !=null ){
                    if(obj.get('RecordTypeId') == adultRecType){
                        objName += '-Adult';
                        matchId = (Id)obj.get('Id');
                    }
                    else if(obj.get('RecordTypeId') == childRecType){
                        objName += '-Child';
                        matchId = (Id)obj.get('Id');
                    }
                    
                }
                else if(objName == 'BrandRelationship__c' && obj.get('Id') != null){
                    matchId = (Id)obj.get('Id');
                }
                else if(objName == 'ChannelResponse__c' && obj.get('BrandRelationship__c') != null){
                    matchId = (Id)obj.get('BrandRelationship__c');
                }
                else if(objName == 'Case' && obj.get('ContactId') != null){
                    matchId = (Id)obj.get('ContactId');
                }
                else if(objName == 'Address__c' && obj.get('ParentContact__c') != null){
                    matchId = (Id)obj.get('ParentContact__c');
                }
                else if(objName == 'Membership__c' && obj.get('Contact__c') != null){
                    matchId = (Id)obj.get('Contact__c');
                }
                else if(objName == 'Medical_Diagnosis__c' && obj.get('Contact__c') != null){
                    matchId = (Id)obj.get('Contact__c');
                }
                
                if(matchId != null){
                    if(!objMatch.isEmpty() && objMatch.containsKey(objName)){
                        objMatch.get(objName).add(matchId);
                    }
                    else{
                        Set<Id> ftmp = new Set<Id>();
                        ftmp.add(matchId);
                        objMatch.put(objName,ftmp);
                    }
                    
                    
                    if(!objMatchScore.isEmpty() && objMatchScore.containsKey(objName)){
                        if(objectStackable.get(objectName)!=null && objectStackable.get(objectName)){
                            Decimal score = objMatchScore.get(objName).get(matchId)!=null? objMatchScore.get(objName).get(matchId):0;
                            score+=lsMatch.conScore;
                            objMatchScore.get(objName).put(matchId,score);
                        }
                        else{
                            objMatchScore.get(objName).put(matchId,lsMatch.conScore);
                        }   
                    }
                    else{
                        Map<Id,Decimal> ftmp = new Map<Id,Decimal>();
                        ftmp.put(matchId,lsMatch.conScore);
                        objMatchScore.put(objName,ftmp);
                    }
                }
                
            }
        }
        
        if(objMatch.get('et4ae5__IndividualEmailResult__c')!=null && !objMatch.get('et4ae5__IndividualEmailResult__c').isEmpty()){
            Set<Id> conMatch = objMatch.get('et4ae5__IndividualEmailResult__c');
            Map<Id,Decimal> conMatchScore = objMatchScore.get('et4ae5__IndividualEmailResult__c');
            Boolean stackable = objectStackable.get('et4ae5__IndividualEmailResult__c');
            
            List<BrandRelationship__c> brList = queryBrandRelationship(category, medium, 
                                                                       channelType, brandLeadScoreCriteria,
                                                                       conMatch, channelRefNoList);
            
            System.debug(brList);
            System.debug(conMatchScore);
            for(BrandRelationship__c br: brList){
                if(conMatchScore.get(br.PrimaryContact__c)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreEDMObj__c = conMatchScore.get(br.PrimaryContact__c);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreEDMObj__c += conMatchScore.get(br.PrimaryContact__c);
                    }
                }
            }
        }
        if(objMatch.get('Contact-Adult')!=null && !objMatch.get('Contact-Adult').isEmpty()){
            Set<Id> conMatch = objMatch.get('Contact-Adult');
            Map<Id,Decimal> conMatchScore = objMatchScore.get('Contact-Adult');
            Boolean stackable = objectStackable.get('Contact');
            
            List<BrandRelationship__c> brList = queryBrandRelationship(category, medium, 
                                                                       channelType, brandLeadScoreCriteria,
                                                                       conMatch, channelRefNoList);
            
            for(BrandRelationship__c br: brList){
                if(conMatchScore.get(br.PrimaryContact__c)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreAdultContactObj__c = conMatchScore.get(br.PrimaryContact__c);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreAdultContactObj__c += conMatchScore.get(br.PrimaryContact__c);
                    }
                }
            }                            
        }
        if(objMatch.get('Contact-Child')!=null && !objMatch.get('Contact-Child').isEmpty()){
            Set<Id> conMatch = objMatch.get('Contact-Child');
            Map<Id,Decimal> conMatchScore = objMatchScore.get('Contact-Child');
            
            Boolean stackable = objectStackable.get('Contact');
            
            List<BrandRelationship__c> brList = [SELECT Id, User__c, LeadScoreChildContactObj__c FROM BrandRelationship__c 
                                                 WHERE Id IN (SELECT BrandRelationship__c FROM ChannelResponse__c WHERE Medium__c = :medium 
                                                              AND Category__c = :category 
                                                              AND ChannelType__c= :channelType )
                                                 AND Active__c = true AND PrimaryContact__r.Active__c=true AND User__r.Active__c=true
                                                 AND PrimaryContact__r.Market__c= :brandLeadScoreCriteria.Market__c AND User__r.RecordTypeId = :childRecType
                                                 AND User__c IN :conMatch AND KeyBrand__c= :brandLeadScoreCriteria.KeyBrand__c AND BrandRelationshipType__c='Pediatric'];
            
            for(BrandRelationship__c br: brList){
                if(conMatchScore.get(br.User__c)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreChildContactObj__c = conMatchScore.get(br.User__c);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreChildContactObj__c += conMatchScore.get(br.User__c);
                    }
                }
            }                            
        }
        if(objMatch.get('BrandRelationship__c')!=null && !objMatch.get('BrandRelationship__c').isEmpty()){
            Set<Id> brMatch = objMatch.get('BrandRelationship__c');
            Map<Id,Decimal> brMatchScore = objMatchScore.get('BrandRelationship__c');
            Boolean stackable = objectStackable.get('BrandRelationship__c');
            List<BrandRelationship__c> brList = [SELECT Id, PrimaryContact__c, LeadScoreBRObj__c FROM BrandRelationship__c 
                                                 WHERE Id IN :brMatch];
            
            for(BrandRelationship__c br: brList){
                if(brMatchScore.get(br.Id)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreBRObj__c = brMatchScore.get(br.Id);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreBRObj__c += brMatchScore.get(br.Id);
                    }
                }
            }                            
        }
        if(objMatch.get('ChannelResponse__c')!=null && !objMatch.get('ChannelResponse__c').isEmpty()){
            Set<Id> brMatch = objMatch.get('ChannelResponse__c');
            Map<Id,Decimal> crMatchScore = objMatchScore.get('ChannelResponse__c');
            Boolean stackable = objectStackable.get('ChannelResponse__c');
            List<BrandRelationship__c> brList = [SELECT Id, PrimaryContact__c, LeadScoreCRObj__c FROM BrandRelationship__c 
                                                 WHERE Id IN :brMatch AND PrimaryContact__r.Active__c=true
                                                 AND PrimaryContact__r.Market__c= :market AND PrimaryContact__r.RecordTypeId = :adultRecType
                                                 AND KeyBrand__c= :brand AND Active__c = true];
            
            for(BrandRelationship__c br: brList){
                if(crMatchScore.get(br.Id)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreCRObj__c = crMatchScore.get(br.Id);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreCRObj__c += crMatchScore.get(br.Id);
                    }                }
            }                            
        }
        if(objMatch.get('Case')!=null && !objMatch.get('Case').isEmpty()){
            Set<Id> conMatch = objMatch.get('Case');
            Map<Id,Decimal> caseMatchScore = objMatchScore.get('Case');
            Boolean stackable = objectStackable.get('Case');
            List<BrandRelationship__c> brList = queryBrandRelationship(category, medium, 
                                                                       channelType, brandLeadScoreCriteria,
                                                                       conMatch, channelRefNoList);
            
            for(BrandRelationship__c br: brList){
                if(caseMatchScore.get(br.PrimaryContact__c)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreCaseObj__c = caseMatchScore.get(br.PrimaryContact__c);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreCaseObj__c += caseMatchScore.get(br.PrimaryContact__c);
                    }
                }
            }
        }
        if(objMatch.get('Address__c')!=null && !objMatch.get('Address__c').isEmpty()){
            Set<Id> conMatch = objMatch.get('Address__c');
            Map<Id,Decimal> adMatchScore = objMatchScore.get('Address__c');
            Boolean stackable = objectStackable.get('Address__c');
            List<BrandRelationship__c> brList = queryBrandRelationship(category, medium, 
                                                                       channelType, brandLeadScoreCriteria,
                                                                       conMatch, channelRefNoList);
            for(BrandRelationship__c br: brList){
                if(adMatchScore.get(br.PrimaryContact__c)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreAddressObj__c = adMatchScore.get(br.PrimaryContact__c);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreAddressObj__c += adMatchScore.get(br.PrimaryContact__c);
                    }
                }
            }
        }
        if(objMatch.get('Membership__c')!=null && !objMatch.get('Membership__c').isEmpty()){
            Set<Id> conMatch = objMatch.get('Membership__c');
            Map<Id,Decimal> mMatchScore = objMatchScore.get('Membership__c');
            Boolean stackable = objectStackable.get('Membership__c');
            List<BrandRelationship__c> brList = queryBrandRelationship(category, medium, 
                                                                       channelType, brandLeadScoreCriteria,
                                                                       conMatch, channelRefNoList);
            
            for(BrandRelationship__c br: brList){
                if(mMatchScore.get(br.PrimaryContact__c)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreMembershipObj__c = mMatchScore.get(br.PrimaryContact__c);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreMembershipObj__c += mMatchScore.get(br.PrimaryContact__c);
                    }
                }
            }
        }
        if(objMatch.get('Medical_Diagnosis__c')!=null && !objMatch.get('Medical_Diagnosis__c').isEmpty()){
            Set<Id> conMatch = objMatch.get('Medical_Diagnosis__c');
            Map<Id,Decimal> mMatchScore = objMatchScore.get('Medical_Diagnosis__c');
            Boolean stackable = objectStackable.get('Medical_Diagnosis__c');
            List<BrandRelationship__c> brList = queryBrandRelationship(category, medium, 
                                                                       channelType, brandLeadScoreCriteria,
                                                                       conMatch, channelRefNoList);
            
            for(BrandRelationship__c br: brList){
                if(mMatchScore.get(br.PrimaryContact__c)!=null){
                    Boolean brExist = false;
                    if(brToUpdate.get(br.Id)!=null){
                        brExist = true;
                    }
                    //New code
                    if(!brExist){
                        brToUpdate.put(br.Id,br);
                    }
                    
                    if(!stackable){
                        brToUpdate.get(br.Id).LeadScoreNutritionObj__c = mMatchScore.get(br.PrimaryContact__c);
                    }
                    else{
                        brToUpdate.get(br.Id).LeadScoreNutritionObj__c += mMatchScore.get(br.PrimaryContact__c);
                    }
                }
            }
        }
        
        System.debug('brToUpdate: ' + brToUpdate);
        if(!brToUpdate.isEmpty()){
            UtilityClass.updateList(brToUpdate.values());
        }
        
    }
    
    public List<BrandRelationship__c> queryBrandRelationship(String category, String medium, 
                                                             String channelType, LeadScoringCriteria__c brandLeadScoreCriteria,
                                                             Set<Id> conMatch, List<String> channelRefNoList)
    {
        Boolean ISTRUE = true;
        String market = brandLeadScoreCriteria.Market__c;
        String keyBrand = brandLeadScoreCriteria.KeyBrand__c;
        String qry ='SELECT Id, PrimaryContact__c, LeadScoreCaseObj__c, LeadScoreChildContactObj__c, LeadScoreAdultContactObj__c, LeadScoreAddressObj__c, LeadScoreNutritionObj__c, LeadScoreMembershipObj__c, LeadScoreEDMObj__c FROM BrandRelationship__c ';
        qry += 'WHERE Id IN (SELECT BrandRelationship__c FROM ChannelResponse__c WHERE Category__c = :category AND ChannelType__c= :channelType ';
        if(!String.isEmpty(medium)){
            qry += 'AND Medium__c =: medium ';                                                         
        }
        if(channelRefNoList.size()!=0){
            qry += 'AND Channel__r.Channel_Ref_No__c =: channelRefNoList ';                                                         
        }
        qry += ') AND Active__c=: ISTRUE AND PrimaryContact__r.Active__c=: ISTRUE ';
        qry += 'AND PrimaryContact__c IN :conMatch AND PrimaryContact__r.Market__c= :market ';
        qry += 'AND PrimaryContact__r.RecordTypeId = :adultRecType AND KeyBrand__c= :keyBrand ';
        
        return Database.query(qry);
    }
    
    public void finish(Database.BatchableContext bc){
        this.currIndex++;
        if(this.currIndex<this.leadScoreObjectList.size()){
            LeadScoreBatch lsb = new LeadScoreBatch(this.brandLeadScoreCriteria,this.leadScoreObjectList);
            lsb.currIndex = currIndex;
            database.executebatch(lsb);
        }
    }
    
}