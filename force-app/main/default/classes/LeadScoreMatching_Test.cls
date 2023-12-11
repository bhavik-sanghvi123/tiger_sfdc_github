@IsTest
public class LeadScoreMatching_Test {
    public static Map<String,String> getLeadscoringObjects(){
        Map<String,String> retStringMap = new Map<String,String>();
        retStringMap.put('Contact','Age__c');
        retStringMap.put('Address__c','StateProvince__c');
        retStringMap.put('BrandRelationship__c','SubmitConversionInteractiveQuiz__c');
        retStringMap.put('ChannelResponse__c','Channel__r.Channel_Ref_No__c');
        retStringMap.put('et4ae5__IndividualEmailResult__c','et4ae5__Opened__c');
        retStringMap.put('Medical_Diagnosis__c','ChildNutritionalIntake__c');
        retStringMap.put('Membership__c','MembershipId__c');
        return retStringMap;
    }
    
    @testSetup static void setup() {
        
        //Create Lead Score Criteria
        List<LeadScoringCriteria__c> leadscoringCriteriaList =  new List<LeadScoringCriteria__c>();
        for(Integer i =0; i< 2; i++){
            leadscoringCriteriaList.add(new LeadScoringCriteria__c(name='Test'+i,Market__c='PH',
                                                                   ChannelCategory__c='Online',
                                                                   ChannelType__c='Social', 
                                                                   Medium__c='fb'));
        }
        insert leadscoringCriteriaList;
        //Create account
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name='123', Market__c='PH'));
        insert accList;
        List<Contact> conlist = new List<Contact>();
        //Create Contact - adult
        Id recortypeIdContactAdult = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Adult').getRecordTypeId();
        conlist.add(new Contact(RecordtypeId = recortypeIdContactAdult, Lastname='Yeah', AccountId=accList[0].Id,Active__c=true,birthdate= System.date.today().addYears(-26)));
        //Create Contact - Child
        Id recortypeIdContactChild = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Child').getRecordTypeId();
        conlist.add(new Contact(RecordtypeId = recortypeIdContactChild, Lastname='Yeah', AccountId=accList[0].Id,Active__c=true, birthdate= System.date.today().addYears(-26)));
        insert conlist;
        
        Id recortypeIdcityChild = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('City').getRecordTypeId();
        
        List<Affiliate_Value__c> affliateList = new List<Affiliate_Value__c>();
        affliateList.add(new Affiliate_Value__c(RecordtypeId=recortypeIdcityChild,Name='Batangas',active__c=true));
        
        insert affliateList;
        List<Address__c> addList = new List<Address__c>();
        addList.add(new Address__c(city2__c=affliateList[0].Id,ParentContact__c=conlist[0].Id,Country__c='Philippines',StateProvince__c='Batangas'));
        
        insert addList;
        List<et4ae5__SendDefinition__c> sendDefinitionList = new List<et4ae5__SendDefinition__c>();
        sendDefinitionList.add(new et4ae5__SendDefinition__c());
        insert sendDefinitionList;
        //Create et4ae5__IndividualEmailResult__c record
        List<et4ae5__IndividualEmailResult__c> ierList = new List<et4ae5__IndividualEmailResult__c>();
        ierList.add(new et4ae5__IndividualEmailResult__c(et4ae5__Contact__c=conlist[0].Id,et4ae5__SendDefinition__c=sendDefinitionList[0].Id, et4ae5__Opened__c=true,et4ae5__NumberOfUniqueClicks__c=3));
        insert ierList;
        Id recortypeIdProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        List<Product2> prdctList = new List<Product2>();
        prdctList.add(new Product2(Name='Pediasure', isActive=true,AvailableForOrder__c=true,CompetitorProduct__c=false, RecordtypeId=recortypeIdProduct));
        insert prdctList;
        
        
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'Testfirstname',
                          lastname='Testlastname',
                          Alias='Test',
                          email = 'john@acme.com',
                          username= 'sjohn@acme.com.test', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;	 
        System.runAs(u) {
            List<BrandRelationship__c> brlist = new List<BrandRelationship__c>();
            brlist.add(new BrandRelationship__c(PrimaryContact__c=conlist[0].Id,User__c=conlist[1].Id,Household__c=accList[0].Id,
                                                //BrandRelationship__c=prdctList[0].Id, 
                                                Type__c='Lead',Status__c='Contacted', Active__c=true,SubmitConversionInteractiveQuiz__c=true));
            insert brlist;
            
            Id recortypeIdChannel = Schema.SObjectType.Channel__c.getRecordTypeInfosByDeveloperName().get('Social').getRecordTypeId();
            
            List<Channel__c> channelList = new List<Channel__c>();
            channelList.add(new Channel__c(Name='Facebook - FP leads', Channel_Ref_No__c='Facebook-FP-leads', Market__c='PH',RecordTypeId=recortypeIdChannel,Category__c='Online'));
            insert channelList;
            
            List<ChannelResponse__c> crList= new List<ChannelResponse__c>();
            crList.add(new ChannelResponse__c( BrandRelationship__c=brlist[0].Id, Channel__c=channelList[0].Id, Discount_Card__c='Yes',Medium__c='fb',RegistrationDate__c=System.now()));
            insert crList;
            
            List<Case> caselist= new List<Case>();
            caseList.add(new Case(AccountId=accList[0].Id));
            insert caseList;
            
            List<Membership__c> membershipList = new List<Membership__c>();
            membershipList.add(new Membership__c(Contact__c = conList[0].Id, MembershipId__c='9222 4344 5553 1234')); 
            insert membershipList;
        }
        //Create Medical_Diagnosis__c records
        List<Medical_Diagnosis__c> medicalDiagnosticList= new List<Medical_Diagnosis__c>();
        medicalDiagnosticList.add(new Medical_Diagnosis__c(Contact__c=conlist[0].Id,
                                                           EndUser__c= conlist[0].Id,
                                                           Active__c=true));
        insert medicalDiagnosticList;
        
        //Create Lead Score
        List<LeadScoring__c> leadScoreList = new List<LeadScoring__c>();
        leadScoreList.add(new LeadScoring__c(Name='Case Engaged with Chat',Market__c='MY',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='Case',Field__c='EngagedWithChat__c',
                                             RecordType__c='Adult',
                                             Comparison__c='Boolean',
                                             Range_Min__c=0,
                                             Range_Max__c=5,
                                             Text_Value__c='',
                                             Score__c=7,
                                             Stackable__c=true,
                                             Binary_Value__c=true,
                                             Trigger_Field__c=''));
        leadScoreList.add(new LeadScoring__c(Name='Age < 24',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='Contact',Field__c='Age__c',
                                             RecordType__c='Adult',
                                             Comparison__c='Less Than',
                                             Range_Min__c=0,
                                             Range_Max__c=5,
                                             Text_Value__c='25',
                                             Number_Value__c=100,
                                             Score__c=7,
                                             Trigger_Field__c='Birthdate'));
        leadScoreList.add(new LeadScoring__c(Name='Age < 241',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='Contact',Field__c='Age__c',
                                             RecordType__c='Child',
                                             Comparison__c='Greater Than',
                                             Range_Min__c=0,
                                             Range_Max__c=5,
                                             Text_Value__c='25',
                                             Number_Value__c=25,
                                             Score__c=7,
                                             Trigger_Field__c='Birthdate'));
        leadScoreList.add(new LeadScoring__c(Name='CR 1',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='ChannelResponse__c',Field__c='Discount_Card__c',
                                             Comparison__c='Text',
                                             Range_Min__c=0,
                                             Range_Max__c=5,
                                             Text_Value__c='yes',
                                             Score__c=7,
                                             Trigger_Field__c=''));
        leadScoreList.add(new LeadScoring__c(Name='Address Calabarzon Batangas',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='Address__c',Field__c='StateProvince__c',
                                             Comparison__c='Text Mid',
                                             Range_Min__c=0,
                                             Range_Max__c=5,
                                             Text_Value__c='Batan',
                                             Score__c=7,
                                             Trigger_Field__c=''));
        leadScoreList.add(new LeadScoring__c(Name='Address Caloocan City',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='Address__c',Field__c='City2__r.Name',
                                             Comparison__c='Text',
                                             Range_Min__c=0,
                                             Range_Max__c=5,
                                             Text_Value__c='CALOOCAN CITY',
                                             Score__c=5,
                                             Trigger_Field__c=''));
        leadScoreList.add(new LeadScoring__c(Name='Address Caloocan City',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='BrandRelationship__c',Field__c='SubmitConversionInteractiveQuiz__c',
                                             Comparison__c='Boolean',
                                             Binary_Value__c=true,
                                             Range_Min__c=0,
                                             Range_Max__c=20,
                                             Text_Value__c='CALOOCAN CITY',
                                             Score__c=5,
                                             Trigger_Field__c=''));
        leadScoreList.add(new LeadScoring__c(Name='EDM Opened',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='et4ae5__IndividualEmailResult__c',Field__c='et4ae5__NumberOfUniqueClicks__c',
                                             Comparison__c='Greater Than',
                                             Binary_Value__c=true,
                                             Range_Min__c=0,
                                             Range_Max__c=20,
                                             Text_Value__c='',
                                             Score__c=5,
                                             Number_Value__c=0,
                                             Trigger_Field__c=''));
        leadScoreList.add(new LeadScoring__c(Name='Nutrition Question Child Feeding Concern',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='Medical_Diagnosis__c',Field__c='ChildFeedingConcern__c',
                                             Comparison__c='Is Null',
                                             Binary_Value__c=true,
                                             Range_Min__c=0,
                                             Range_Max__c=20,
                                             Text_Value__c='',
                                             Score__c=5,
                                             Trigger_Field__c=''));
        leadScoreList.add(new LeadScoring__c(Name='Membership Id DICE Form',Market__c='PH',KeyBrand__c='Pediasure',
                                             Is_Active__c=true,
                                             Object__c='Membership__c',Field__c='MembershipId__c',
                                             Comparison__c='Text Mid List',
                                             Binary_Value__c=true,
                                             Range_Min__c=0,
                                             Range_Max__c=14,
                                             Text_Value__c='9222 4234 5553;9222 4344 5553',
                                             Score__c=5,
                                             Trigger_Field__c=''));
        
        insert leadScoreList;
        
        //Create Lead scoring Match    
        List<LeadScoringNameMatch__c> leadScoringNameMatchList= new List<LeadScoringNameMatch__c>();
        for(Integer i=0; i<20; i++){
            leadScoringNameMatchList.add(new LeadScoringNameMatch__c());
        }
        insert leadScoringNameMatchList;
        
        List<LeadScoringCriteria__c> lscList = new List<LeadScoringCriteria__c>(); 
        lscList.add(new LeadScoringCriteria__c(Market__c='PH', KeyBrand__c='Pediasure', ChannelCategory__c='Online', ChannelType__c='Social', Medium__c='fb',Is_Active__c=true,Channel_Ref_No__c='Facebook-FNC-leads;Facebook-FS-leads;Facebook-FP-leads')); 
        lscList.add(new LeadScoringCriteria__c(Market__c='MY', KeyBrand__c='Ensure', ChannelCategory__c='Online', ChannelType__c='Social', Medium__c='fb',Is_Active__c=true));
        insert lscList;
        
    }
    
    static List<LeadScoringCriteria__c> getLeadScoringCriteria(String market){
        return [SELECT Id,Market__c, KeyBrand__c, ChannelCategory__c, 
                ChannelType__c, Medium__c,Channel_Ref_No__c
                FROM LeadScoringCriteria__c
                WHERE Is_Active__c=true
                AND Market__c=:market];
    }
    static List<LeadScoring__c> getLeadscoringList(String obj){
        return [SELECT Id,Name,Trigger_Field__c,Field__c,score__c,
                Text_Value__c,Comparison__c,Number_Value__c,Binary_Value__c,Range_Min__c,Range_Max__c
                FROM LeadScoring__c 
                WHERE Object__c = : obj];
    }
    @isTest static void contactAdultTest() {
        Test.startTest();
        Id recortypeIdContactAdult = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Adult').getRecordTypeId();
        List<Contact> contactList= [Select Id,Age__c,Birthdate FROM Contact Where RecordTypeId =:recortypeIdContactAdult ];
        List<LeadScoring__c> leadScorList = getLeadscoringList('Contact');
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('created');
        recTriggerFieldMap.put(contactList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(contactList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void contactchildTest() {
        Test.startTest();
        
        Id recortypeIdContactChild = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Child').getRecordTypeId();
        
        List<Contact> contactList= [Select Id,Age__c,Birthdate FROM Contact Where RecordTypeId =:recortypeIdContactChild ];
        List<LeadScoring__c> leadScorList = getLeadscoringList('Contact');
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('created');
        recTriggerFieldMap.put(contactList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(contactList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void contactBRTest() {
        Test.startTest();
        List<BrandRelationship__c> recordList= [Select Id,SubmitConversionInteractiveQuiz__c FROM BrandRelationship__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('BrandRelationship__c');
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('SubmitConversionInteractiveQuiz__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    
    
    @isTest static void membershipTest() {
        Test.startTest();
        List<Membership__c> recordList= [Select Id,MembershipId__c FROM Membership__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Membership__c');
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('MembershipId__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void membershipTextMidListLookupTest() {
        Test.startTest();
        List<Membership__c> recordList= [Select Id,Contact__r.Name FROM Membership__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Membership__c');
        leadScorList[0].Field__c='Contact__r.Name'; 
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('Contact__r.Name');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(false,lcm.checkIfMatch());
        Test.stopTest();
    }
    
    @isTest static void membershipTextMidTest() {
        Test.startTest();
        List<Membership__c> recordList= [Select Id,MembershipId__c FROM Membership__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Membership__c');
        leadScorList[0].Comparison__c='Text Mid';
        leadScorList[0].Text_Value__c='9222 4344 5553';    
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('MembershipId__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void membershipLookupTextMidTest() {
        Test.startTest();
        List<Membership__c> recordList= [Select Id,Contact__r.Name,MembershipId__c FROM Membership__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Membership__c');
        leadScorList[0].Comparison__c='Text Mid';
        leadScorList[0].Field__c = 'MembershipId__c';
        leadScorList[0].Text_Value__c='9222 4344 5553';    
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('MembershipId__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    
    @isTest static void medicalDiagnostic1Test() {
        Test.startTest();
        List<Medical_Diagnosis__c> recordList= [Select Id,ChildFeedingConcern__c FROM Medical_Diagnosis__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Medical_Diagnosis__c');
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('ChildFeedingConcern__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void medicalDiagnostic2Test() {
        Test.startTest();
        List<Medical_Diagnosis__c> recordList= [Select Id,ChildFeedingConcern__c FROM Medical_Diagnosis__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Medical_Diagnosis__c');
        leadScorList[0].Binary_Value__c=false;
        leadScorList[0].Field__c ='ChildFeedingConcern__c';
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('ChildFeedingConcern__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(false,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void ieRTest() {
        Test.startTest();
        List<et4ae5__IndividualEmailResult__c> recordList= [Select Id,et4ae5__NumberOfUniqueClicks__c FROM et4ae5__IndividualEmailResult__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('et4ae5__IndividualEmailResult__c');
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('et4ae5__NumberOfUniqueClicks__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void ieREqualsTest() {
        Test.startTest();
        List<et4ae5__IndividualEmailResult__c> recordList= [Select Id,et4ae5__NumberOfUniqueClicks__c FROM et4ae5__IndividualEmailResult__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('et4ae5__IndividualEmailResult__c');
        leadScorList[0].Comparison__c='Equals';
        leadScorList[0].Number_Value__c=3; 
        leadScorList[0].Field__c='et4ae5__NumberOfUniqueClicks__c';
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('et4ae5__NumberOfUniqueClicks__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void ieREqualsnumberRangeTest() {
        Test.startTest();
        List<et4ae5__IndividualEmailResult__c> recordList= [Select Id,et4ae5__NumberOfUniqueClicks__c FROM et4ae5__IndividualEmailResult__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('et4ae5__IndividualEmailResult__c');
        leadScorList[0].Comparison__c='Number Range';
        leadScorList[0].Number_Value__c=3; 
        leadScorList[0].Field__c='et4ae5__NumberOfUniqueClicks__c';
        leadScorList[0].Range_Min__c=0;
        leadScorList[0].Range_Max__c=3;
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('et4ae5__NumberOfUniqueClicks__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void addressTest() {
        Test.startTest();
        List<Address__c> recordList= [Select Id,StateProvince__c,City2__r.Name FROM Address__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Address__c');
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('StateProvince__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void addressTextLookupTest() {
        Test.startTest();
        List<Address__c> recordList= [Select Id,StateProvince__c,City2__r.Name FROM Address__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Address__c');
        leadScorList[0].Comparison__c='Text';
        leadScorList[0].Text_Value__c='Batangas'; 
        leadScorList[0].Field__c='City2__r.Name';
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('City2__r.Name');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void addressTextNormalTest() {
        Test.startTest();
        List<Address__c> recordList= [Select Id,StateProvince__c,City2__r.Name FROM Address__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Address__c');
        leadScorList[0].Comparison__c='Text';
        leadScorList[0].Text_Value__c='Batangas'; 
        leadScorList[0].Field__c='StateProvince__c';
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('StateProvince__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void addresLookupTextEqualsTest() {
        Test.startTest();
        List<Address__c> recordList= [Select Id,StateProvince__c,City2__r.Name FROM Address__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Address__c');
        leadScorList[0].Comparison__c='Text Equals';
        leadScorList[0].Text_Value__c='Batangas'; 
        leadScorList[0].Field__c='City2__r.Name';
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('City2__r.Name');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
    @isTest static void addressNormalTextEqualsTest() {
        Test.startTest();
        List<Address__c> recordList= [Select Id,StateProvince__c,City2__r.Name FROM Address__c];
        List<LeadScoring__c> leadScorList =getLeadscoringList('Address__c');
        leadScorList[0].Comparison__c='Text Equals';
        leadScorList[0].Text_Value__c='Batangas'; 
        leadScorList[0].Field__c='StateProvince__c';
        Map<Id,Set<String>> recTriggerFieldMap=  new Map<Id,Set<String>>();
        Set<String> historySet =  new Set<String>();
        historySet.add('StateProvince__c');
        recTriggerFieldMap.put(recordList[0].Id, historySet);
        LeadScoreMatching lcm =  new LeadScoreMatching(recordList[0],leadScorList,recTriggerFieldMap,false);
        System.assertEquals(true,lcm.checkIfMatch());
        Test.stopTest();
    }
}