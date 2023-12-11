@isTest
private class SkillsBasedRoutingTest {
    
    @testsetup
    static void setupData() {
        Test.enableChangeDataCapture();
        List<User> userList = new List<User>();
        List<Campaign> campList = new List<Campaign>();
        List<ServiceResource> srList = new List<ServiceResource>();
        List<ServiceResourceSkill> srsList = new List<ServiceResourceSkill>();
        //Map<String, Skill> skillMap = new Map<String, Skill>();
        
        User sysAdmin = TestDataFactory.createUser('System Administrator', 'kaps' , 'PH');
        userList.add(sysAdmin);
        User agentUser = TestDataFactory.createUser('ANI Call Center Agent', 'pasd' , 'PH');
        userList.add(agentUser);
        User agentUserMY = TestDataFactory.createUser('ANI Call Center Agent', 'myagent' , 'MY');
        userList.add(agentUserMY);
        User agentUserSG = TestDataFactory.createUser('ANI Call Center Agent', 'sgagent' , 'SG');     
        userList.add(agentUserSG);
        User agentUserTH = TestDataFactory.createUser('ANI Call Center Agent', 'thagent' , 'TH');
        userList.add(agentUserTH);
        User agentUserIN = TestDataFactory.createUser('ANI Call Center Agent', 'inagent' , 'IN');
        userList.add(agentUserIN); 
        User agentUserTW = TestDataFactory.createUser('ANI Call Center Agent', 'twagent' , 'TW');
        userList.add(agentUserTW);
        
        insert userList;
        
       

        System.runAs(sysAdmin) {
            ServiceResource sr1 = new ServiceResource();
            sr1.Name = agentUser.FirstName + ' ' + agentUser.LastName;
            sr1.RelatedRecordId = agentUser.Id;
            sr1.ResourceType = 'A';
            sr1.IsActive = True;
            insert sr1;
            
            for(Skill skillRec : [Select Id, MasterLabel, DeveloperName From Skill]) {
                system.debug('skillRec---'+skillRec);
                ServiceResourceSkill srs1 = new ServiceResourceSkill();
                srs1.ServiceResourceId = sr1.Id;
                srs1.SkillId = skillRec.Id;
                srs1.EffectiveStartDate = System.now() - 15;
                
                srsList.add(srs1);
            }
            
            insert srsList;

            List<Account> accList = TestDataFactory.createTestHousehold(1);
            List<Contact> conList = TestDataFactory.createTestAdultContact(5, accList.get(0).Id);
            campList.add(TestDataFactory.createCampaign('Test Campaign 1', 'Similac', 'PH'));
            campList.add(TestDataFactory.createCampaign('Test Campaign 2', 'Ensure', 'VN'));
            campList.add(TestDataFactory.createCampaign('Test Campaign 3', 'Ensure', 'MY')); 
            campList.add(TestDataFactory.createCampaign('Test Campaign 4', 'Ensure', 'TW'));           
          
            insert campList;
            List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
            List<Channel__c> lChannel = TestDataFactory.createTestChannel(1);
            List<BrandRelationship__c> lBrand = TestDataFactory.createTestBrandRelationShip(1, conList.get(0).Id, lProduct.get(0).Id);           

            ChannelResponse__c ch = new ChannelResponse__c();
            ch.BrandRelationship__c = lBrand.get(0).Id;
            ch.Channel__c = lChannel.get(0).Id;
            ch.RegistrationDate__c = Date.today();
            insert ch;
            
             List<Product2>  lstProduct= TestDataFactory.createTestBrandProductTW(2);           
             lstProduct[0].ProductCode = 'Code01';
             update lstProduct;
        }
    }
    
    @isTest
    static void reRouteBulkInsert_test() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        List<Case> updatedCaseList = new List<Case>();
        List<PendingServiceRouting> psrList = new List<PendingServiceRouting>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id from Contact limit 2];
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 1'];
        User u1 = [select Id from User where LastName = 'kaps'];
        User u2 = [select Id from User where LastName = 'pasd'];
        
        System.debug('u1---'+u1.Id);
        System.debug('u2---'+u2.Id);
        
        for(Contact conRec : conList) {
            Case ca1 = new Case();
            ca1.RecordtypeId = callRTId;
            ca1.ContactId = conRec.Id;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId = a1.Id;
            ca1.CallRegarding__c = conRec.Id;
            ca1.Campaign__c = camp1.Id;
            
            caseList.add(ca1);   
        }
        
        System.Test.startTest();
        System.runAs(u1) {
            insert caseList;   
        }
        System.Test.stopTest();
        Test.getEventBus().deliver();
        
        psrList = [select Id from PendingServiceRouting limit 1];
        
        //System.assertEquals(!psrList.isEmpty(), True);
    }
    
    @isTest
    static void reRouteToPreviousAgent_test() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        Id regionRTId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByDeveloperName().get('Region').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        
        Account a1 = [select Id from Account limit 1];
        List<Contact> conList = [select Id, Region__c from Contact limit 1];
        
        Affiliate_Value__c afRegion1 = new Affiliate_Value__c();
        afRegion1.RecordTypeId = regionRTId;
        afRegion1.Active__c = True;
        afRegion1.Name = 'North Central';
        afRegion1.Market__c = 'VN';
        afRegion1.AffiliateValue__c = 'North Central';
        insert afRegion1;
        
        conList[0].Region__c = afRegion1.Id;
        update conList;
        
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 2'];
        User u1 = [select Id from User where LastName = 'kaps'];
        User u2 = [select Id, Name from User where LastName = 'pasd'];
        
        System.runAs(u1) {
            Case ca1 = new Case();
            ca1.OwnerId = u2.Id;
            ca1.RecordtypeId = callRTId;
            ca1.ContactId = conList[0].Id;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId = a1.Id;
            ca1.CallRegarding__c = conList[0].Id;
            ca1.Campaign__c = camp1.Id;
            
            insert ca1;
            Test.getEventBus().deliver();
            
            Case ca2 = new Case();
            ca2.OwnerId = u2.Id;
            ca2.RecordtypeId = callRTId;
            ca2.ContactId = conList[0].Id;
            ca2.CallType__c = 'Outbound';
            ca2.Status = 'New';
            ca2.AccountId = a1.Id;
            ca2.CallRegarding__c = conList[0].Id;
            ca2.Campaign__c = camp1.Id;
            
            insert ca2;
            Test.getEventBus().deliver();
        }
                
        Case ca3 = new Case();
        ca3.RecordtypeId = callRTId;
        ca3.ContactId = conList[0].Id;
        ca3.CallType__c = 'Outbound';
        ca3.Status = 'New';
        ca3.AccountId = a1.Id;
        ca3.CallRegarding__c = conList[0].Id;
        ca3.Campaign__c = camp1.Id;
        
        insert ca3;
        Test.getEventBus().deliver();
        
        Case ca4 = [select Id, OwnerId, Owner.Name from Case where Id = :ca3.Id];
        
        //System.assertEquals(u2.Id, ca4.OwnerId);
    }

    @isTest
    static void reRouteToMYAgent_test() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        
        Account a1 = [select Id from Account limit 1];        
        
        Campaign camp1 = [select Id from Campaign where Name = 'Test Campaign 3'];
        User u1 = [select Id from User where LastName = 'kaps'];         

        System.runAs(u1) {
            Affiliate_Value__c av = TestDataFactory.createAffiliate('PH', 'English');        
            Contact con = [select Id from Contact limit 1];
            con.PreferredLanguage__c = av.Id;
            update con;

            System.Test.startTest();
            Case ca1 = new Case();            
            ca1.RecordtypeId = callRTId;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId = a1.Id;
            ca1.ContactId = con.Id;
            ca1.Campaign__c = camp1.Id;
            
            insert ca1;
            System.Test.stopTest();          
        }

        Test.getEventBus().deliver();
        List<PendingServiceRouting> psrList = [select Id from PendingServiceRouting limit 1];
        
        //System.assertEquals(!psrList.isEmpty(), True);
    }

    @isTest
    static void reRouteToSGAgent_test() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();   
        User u1 = [select Id from User where LastName = 'sgagent'];         
   
        System.runAs(u1) {
            
           Campaign camp1 =  TestDataFactory.createCampaign('Test Campaign 4', 'Ensure', 'SG');
            camp1.TargetCompletionTime__c = 1;
            Insert camp1;
            List<Account> accList = TestDataFactory.createTestHousehold(1);
            accList.get(0).Market__c = 'SG';
            Update accList;
            List<Contact> conList = TestDataFactory.createSGTestAdultContact(1, accList.get(0).Id);
          
            Case ca1 = new Case();            
            ca1.RecordtypeId = callRTId;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId =  accList.get(0).Id;
            ca1.ContactId = conList.get(0).Id;
            ca1.Campaign__c = camp1.Id;
            
            insert ca1;
            Test.getEventBus().deliver();
        }

        List<PendingServiceRouting> psrList = [select Id from PendingServiceRouting limit 1];
        
        //System.assertEquals(!psrList.isEmpty(), True);
    }

    @isTest
    static void reRouteToTHAgent_test() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();   
        User u1 = [select Id from User where LastName = 'thagent'];         
   
        System.runAs(u1) {
            
            Campaign camp1 =  TestDataFactory.createCampaign('Test Campaign 5', 'Ensure', 'TH');
            camp1.TargetCompletionTime__c = 1;
            Insert camp1;

            List<Account> accList = TestDataFactory.createTestHousehold(1);
            accList.get(0).Market__c = 'TH';
            Update accList;
            List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
          
            Case ca1 = new Case();            
            ca1.RecordtypeId = callRTId;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId =  accList.get(0).Id;
            ca1.ContactId = conList.get(0).Id;
            ca1.Campaign__c = camp1.Id;
            
            insert ca1;
            Test.getEventBus().deliver();
        }

        List<PendingServiceRouting> psrList = [select Id from PendingServiceRouting limit 1];

        //System.assertEquals(!psrList.isEmpty(), True);
    }


    @isTest
    static void reRouteToINAgent_test() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();   
        User u1 = [select Id from User where LastName = 'inagent'];         
   
        System.runAs(u1) {
            
            Campaign camp1 =  TestDataFactory.createCampaign('Test Campaign 6', 'Ensure', 'IN');
            camp1.TargetCompletionTime__c = 1;
            Insert camp1;

            List<Account> accList = TestDataFactory.createTestHousehold(1);
            accList.get(0).Market__c = 'IN';
            Update accList;
            List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
          
            System.Test.startTest();
            Case ca1 = new Case();            
            ca1.RecordtypeId = callRTId;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId =  accList.get(0).Id;
            ca1.ContactId = conList.get(0).Id;
            ca1.Campaign__c = camp1.Id;
            
            insert ca1;
            System.Test.stopTest();          
        }

        Test.getEventBus().deliver();
        List<PendingServiceRouting> psrList = [select Id from PendingServiceRouting limit 1];
        
        //System.assertEquals(!psrList.isEmpty(), True);
    }
    @isTest
    static void reRouteToTWAgent_test() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();   
        User u1 = [select Id from User where LastName = 'twagent'];       
        Group g1 = new Group(Name= CommonConstant.QUEUECALLROUTINGAND, type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;  
        Group g2 = new Group(Name= CommonConstant.QUEUECALLROUTINGPED, type='Queue');
        insert g2;
        QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
        insert q2;  
        
       List<Product2> lstProduct =[Select Id From Product2 Where ProductCode='Code01'];
   
        System.runAs(u1) {
            
            Campaign camp1 =  TestDataFactory.createCampaign('Test Campaign 7', 'Ensure','TW',lstProduct[0].Id );
            camp1.SalesCall__c = True;
            camp1.TargetCompletionTime__c = 1;
            Insert camp1;

            List<Account> accList = TestDataFactory.createTestHousehold(1);
            accList.get(0).Market__c = 'TW';
            Update accList;
            List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
          
            System.Test.startTest();
            Case ca1 = new Case();            
            ca1.RecordtypeId = callRTId;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId =  accList.get(0).Id;
            ca1.ContactId = conList.get(0).Id;
            ca1.Campaign__c = camp1.Id;
            
            insert ca1;
            System.Test.stopTest();          
        }

        Test.getEventBus().deliver();
        List<PendingServiceRouting> psrList = [select Id from PendingServiceRouting limit 1];
    }
    @isTest
    static void reRouteToTWAgent_test1() {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();   
        User u1 = [select Id from User where LastName = 'twagent'];       
        
       List<Product2> lstProduct =[Select Id From Product2 Where ProductCode='Code01'];
   
        System.runAs(u1) {
             List<Product2> lProduct = TestDataFactory.createTestBrandProductTW(1);           
            
            AbbottPartner__c abbottPartner = new AbbottPartner__c(PartnerName__c= 'Deitician',CallAgent__c=u1.id);
            insert abbottPartner;
            
            Campaign camp1 =  TestDataFactory.createCampaign('Test Campaign 7', 'Ensure','TW',lstProduct[0].Id );
            camp1.SalesCall__c = True;
            camp1.TargetCompletionTime__c = 1;
            Insert camp1;

            List<Account> accList = TestDataFactory.createTestHousehold(1);
            accList.get(0).Market__c = 'TW';
            Update accList;
            List<Contact> conList = TestDataFactory.createTestAdultContact(1, accList.get(0).Id);
          
            PricebookEntry entry = TestDataFactory.createPricebookEntry('TW');
            insert entry;
             System.Test.startTest();
            List<Order> lOrder = TestDataFactory.createOrder(1, accList.get(0).Id, conList.get(0).Id, Test.getStandardPricebookId());
            Insert lOrder;    
            
             //Create Promotion Record
             List<Promotion__c> lPromotion = TestDataFactory.createPromotion(1);
        
             //Create Promotion Item
             List<PromotionItem__c> lPromotionItem = TestDataFactory.createPromotionItem(1,entry.Product2Id ,lpromotion.get(0).Id);
        
            //Create Order Item
            OrderItem item1 = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
            item1.PromotionItem__c =  lPromotionItem.get(0).Id;
            insert item1 ;
            
            lOrder[0].status='Completed';
            lOrder[0].RelatedCampaign__c=camp1.Id;
            lOrder[0].Abbott_Sales_Person__c =abbottPartner.Id;
            update  lOrder[0];
            
            
            //System.Test.startTest();
            Case ca1 = new Case();            
            ca1.RecordtypeId = callRTId;
            ca1.CallType__c = 'Outbound';
            ca1.Status = 'New';
            ca1.AccountId =  accList.get(0).Id;
            ca1.ContactId = conList.get(0).Id;
            ca1.Campaign__c = camp1.Id;
            
            insert ca1;
            System.Test.stopTest();          
        }

        Test.getEventBus().deliver();
        List<PendingServiceRouting> psrList = [select Id from PendingServiceRouting limit 1];
    }
}