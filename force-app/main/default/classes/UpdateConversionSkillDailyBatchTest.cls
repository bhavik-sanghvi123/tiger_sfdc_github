@isTest
public class UpdateConversionSkillDailyBatchTest {
    
    @testSetup
    static void setup(){
        
        // create PH Admin and PH Call Center Agent
        User agentUser = TestDataFactory.createUser('ANI Call Center Agent', 'PHAgent1', 'PH');
        insert agentUser;
        User sysAdmin = TestDataFactory.createUser('System Administrator', 'PHAdmin' , 'PH');
        insert sysAdmin;
        
        // create PH Account, Contact, Call Campaign, Product, and Brand Relationship
        Account testAcc = TestDataFactory.createTestHousehold(1, 'PH')[0];
        Contact testCon = TestDataFactory.createTestAdultContact(1, testAcc.Id)[0];
        Campaign testCampaign = TestDataFactory.createCampaign('Test Campaign 1', 'Glucerna', 'PH');
        insert testCampaign;
        Product2 testProd = TestDataFactory.createTestBrandProduct(1)[0];
        BrandRelationship__c testBR = TestDataFactory.createTestBrandRelationShip(1, testCon.Id, testProd.Id)[0];
        testBr.FirstTransactionDate__c = Date.today();
        update testBR;
        
        // create PH Call Case
        Id callRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Case caseRec = new Case();
        caseRec.RecordtypeId = callRecordTypeId;
        caseRec.ContactId = testCon.Id;
        caseRec.CallType__c = 'Outbound';
        caseRec.Status = 'New';
        caseRec.AccountId = testAcc.Id;
        caseRec.CallRegarding__c = testCon.Id;
        caseRec.Campaign__c = testCampaign.Id;
        caseRec.RelatedBrandRelationship__c = testBR.Id;
        caseRec.Market__c = 'PH';
        insert caseRec;
        
        Map<String, Id> skillMap = new Map<String, Id>();
        
        // create Service Resource and Service Resource Skill
        System.runAs(sysAdmin){
            List<ServiceResourceSkill> srsList = new List<ServiceResourceSkill>();
            
            ServiceResource srRec = new ServiceResource();
            srRec.Name = agentUser.FirstName + agentUser.LastName;
            srRec.RelatedRecordId = agentUser.Id;
            srRec.ResourceType = 'A';
            srRec.IsActive = true;
            insert srRec;
            
            for(Skill skillRec : [SELECT Id, MasterLabel, DeveloperName FROM Skill]){
                skillMap.put(skillRec.DeveloperName, skillRec.Id);
                ServiceResourceSkill srs = new ServiceResourceSkill();
                srs.ServiceResourceId = srRec.Id;
                srs.SkillId = skillRec.Id;
                System.debug('Skill Id: ' + srs.SkillId);
                srs.EffectiveStartDate = System.today() - 5;
                
                srsList.add(srs);
            }
            insert srsList;
        }
        
        // query Service Channel
        ServiceChannel sc = [SELECT Id, RelatedEntity FROM ServiceChannel WHERE RelatedEntity = 'Case'];
            
        // create Pending Service Routing
        PendingServiceRouting psrRec = new PendingServiceRouting();
        psrRec.CapacityWeight = 1;
        psrRec.IsReadyForRouting = False;
        psrRec.RoutingModel  = 'MostAvailable';
        psrRec.RoutingPriority = 1;
        psrRec.RoutingType = 'SkillsBased';
        psrRec.ServiceChannelId = sc.Id;
        psrRec.WorkItemId = caseRec.Id;
        psrRec.PushTimeout = 36000;
        insert psrRec;
        
        // create Skill Requirements
        List<SkillRequirement> srList = new List<SkillRequirement>();
        SkillRequirement srBrandGlucerna = new SkillRequirement();
        srBrandGlucerna.RelatedRecordId = psrRec.Id;
        srBrandGlucerna.SkillId = skillMap.get('Brand_Glucerna');
        srList.add(srBrandGlucerna);
 
        SkillRequirement srConversionConversion = new SkillRequirement();
        srConversionConversion.RelatedRecordId = psrRec.Id;
        srConversionConversion.SkillId = skillMap.get('Conversion_Conversion');
        srList.add(srConversionConversion);
        
        SkillRequirement srMarketPH = new SkillRequirement();
        srMarketPH.RelatedRecordId = psrRec.Id;
        srMarketPH.SkillId = skillMap.get('Market_PH');
        srList.add(srMarketPH);

        insert srList;	
    }
    
    static testmethod void executeTest(){
        Test.startTest();
        UpdateConversionSkillDailyBatch updateConversionSkillBatch= new UpdateConversionSkillDailyBatch();
        String cronExpr = '0 0 5 ? * * *';
        String jobId = System.schedule('PH - Update Conversion Skill Batch', cronExpr, updateConversionSkillBatch);
        updateConversionSkillBatch.execute(null);
        Test.stopTest();
    }
}