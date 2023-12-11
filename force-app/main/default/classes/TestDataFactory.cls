/**
* @author        Rey Austral
* @date          1.16.2019
* @description   Test class to create test data
* @revision(s)
*/
@isTest
public class TestDataFactory {
    
    public static string generateRandomNumber(integer length) {
        string result = '';
        while(result.length() < length){
            blob privateKey = crypto.generateAesKey(256);
            string randomString = EncodingUtil.base64Encode(crypto.generateMac('hmacSHA512',privateKey,privateKey));
            result += randomString.replaceAll('[^0-9]','');
        }
        result = result.substring(0,length);
        return result;
    }
    
    //This method creates User test data passing in profile name and alias
    public static User createUser(String profileName, String alias, String market) {
        Profile profile = [SELECT Id FROM Profile WHERE Name=:profileName];
        User user = new User(
            Username=alias+'@test.com', Alias=alias, CommunityNickname=alias, TimeZoneSidKey='Asia/Manila', 
            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',
            FirstName=alias, LastName=alias, Email=alias+'@test.com', ProfileId=profile.Id, Market__c=market);
        
        return user;
    }
    
    public static User createUser(String profileName, String alias, String market, String fname, String lname) {
        Profile profile = [SELECT Id FROM Profile WHERE Name=:profileName];
        User user = new User(
            Username=alias+'@test.com', Alias=alias, CommunityNickname=alias, TimeZoneSidKey='Asia/Manila', 
            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',
            FirstName=fname, LastName=lname, Email=alias+'@test.com', ProfileId=profile.Id, Market__c=market);
        
        return user;
    }
    
    public static List<Account> createTestHousehold(Integer numOfRecords){
        //default account no record type        
        list<Account> lAccount = new list<Account>();        
        
        //Id idRecType = Schema.sObjectType.Account.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Account acc = new Account();          
            //add new required field in here
            acc.Name = 'AccountName -' + i + Integer.valueof((Math.random() * 100));           
            acc.Market__c = 'PH';
            lAccount.add(acc);
        }
        
        insert lAccount;
        return lAccount;
    }
    
    public static List<Account> createTestHousehold(Integer numOfRecords, String market){
        //default account no record type        
        list<Account> lAccount = new list<Account>();        
        
        //Id idRecType = Schema.sObjectType.Account.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Account acc = new Account();          
            //add new required field in here
            acc.Name = 'AccountName -' + i + Integer.valueof((Math.random() * 100));           
            acc.Market__c = market;
            lAccount.add(acc);
        }
        
        insert lAccount;
        return lAccount;
    }

    public static List<Account> createTestHouseholdMY(Integer numOfRecords){
        //default account no record type        
        list<Account> lAccount = new list<Account>();        
        
        //Id idRecType = Schema.sObjectType.Account.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Account acc = new Account();          
            //add new required field in here
            acc.Name = 'AccountName -' + i + Integer.valueof((Math.random() * 100));           
            acc.Market__c = 'MY';
            lAccount.add(acc);
        }
        
        insert lAccount;
        return lAccount;
    }

    // Sean Cordova
    public static List<Account> createTestHouseholdSG(Integer numOfRecords){
        //default account no record type        
        list<Account> lAccount = new list<Account>();        
        
        //Id idRecType = Schema.sObjectType.Account.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Account acc = new Account();          
            //add new required field in here
            acc.Name = 'AccountName -' + i + Integer.valueof((Math.random() * 100));           
            acc.Market__c = 'SG';
            lAccount.add(acc);
        }
        
        // insert lAccount;
        UtilityClass.insertList(lAccount);
        return lAccount;
    }

    // Sean Cordova
    public static List<Account> createTestHousehold2(Integer numOfRecords){
        //default account no record type        
        list<Account> lAccount = new list<Account>();        
        
        //Id idRecType = Schema.sObjectType.Account.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Account acc = new Account();          
            //add new required field in here
            acc.Name = 'AccountName -' + i + Integer.valueof((Math.random() * 100));           
            acc.Market__c = 'PH';
            lAccount.add(acc);
        }
        
        return lAccount;
    }

    public static List<Account> createTestHouseholdNoInsert(Integer numOfRecords, String market){
        //default account no record type        
        list<Account> lAccount = new list<Account>();        
        
        //Id idRecType = Schema.sObjectType.Account.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Account acc = new Account();          
            //add new required field in here
            acc.Name = 'AccountName -' + i + Integer.valueof((Math.random() * 100));           
            acc.Market__c = market;
            lAccount.add(acc);
        }
        
        return lAccount;
    }
    
    public static List<Contact> createTestAdultContact(Integer numOfRecords, Id accountId){
        
        list<Contact> lContact = new list<Contact>();        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        List<Account> acct = [SELECT Id, Market__c FROM Account WHERE Id =: accountId];

        for(Integer i=0; i<numOfRecords; i++) {
            
            Contact con = new Contact();          
            //add new required field in here
            con.LastName = 'LastName -' + i + generateRandomNumber(2);
            con.AccountId = accountId;
            con.RecordTypeId = idRecType;
            if(!acct.isEmpty() && acct[0].Market__c == 'IN'){
                con.Phone = '6' + generateRandomNumber(9);
            }
            else if(!acct.isEmpty() && acct[0].Market__c == 'PH'){
                con.Phone = '09' + generateRandomNumber(9);
            }
            else if(!acct.isEmpty() && acct[0].Market__c == 'SG'){
                con.Phone = '09' + generateRandomNumber(6);
            }
            else{
                con.Phone = '0' + generateRandomNumber(9);
            }
            con.Type__c = 'Adult';
            con.Verified__c = true;               
            lContact.add(con);
        }
        
        insert lContact;
        return lContact;
    }

    public static List<Contact> createTestAdultContactNoInsert(Integer numOfRecords, Id accountId){
        
        list<Contact> lContact = new list<Contact>();        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        List<Account> acct = [SELECT Id, Market__c FROM Account WHERE Id =: accountId];

        for(Integer i=0; i<numOfRecords; i++) {
            
            Contact con = new Contact();          
            //add new required field in here
            con.LastName = 'LastName -' + i + generateRandomNumber(2);
            con.AccountId = accountId;
            con.RecordTypeId = idRecType;
            if(!acct.isEmpty() && acct[0].Market__c == 'IN'){
                con.Phone = '6' + generateRandomNumber(9);
            }
            else{
                con.Phone = '0' + generateRandomNumber(9);
            }
            con.Type__c = 'Adult';
            con.Verified__c = true;
            con.EstimatedDueDate__c = Date.today().addMonths(3);
            lContact.add(con);
        }
        
        return lContact;
    }

    // Sean Cordova
    public static List<Contact> createTestAdultContactSG(Integer numOfRecords, Id accountId){
        
        list<Contact> lContact = new list<Contact>();        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Contact con = new Contact();          
            //add new required field in here
            con.LastName = 'LastName -' + i + generateRandomNumber(2);
            con.AccountId = accountId;
            con.RecordTypeId = idRecType;
            con.Phone = '0' + generateRandomNumber(7);
            con.Type__c = 'Adult';
            con.Verified__c = true;  
            con.LifetimePoints__c = 0;             
            lContact.add(con);
        }
        
        insert lContact;
        return lContact;
    }
    
    public static List<Contact> createTestAdultContactSGPoints(Integer numOfRecords, Id accountId, Decimal lifetimePts, Decimal totalPtsRedeemed, Decimal startEarnPts, Decimal startRedeemPts, Decimal monthlyExpiredPts){
        
        list<Contact> lContact = new list<Contact>();        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Contact con = new Contact();          
            //add new required field in here
            con.LastName = 'LastName -' + i + generateRandomNumber(2);
            con.AccountId = accountId;
            con.RecordTypeId = idRecType;
            con.Phone = '0' + generateRandomNumber(7);
            con.Type__c = 'Adult';
            con.Verified__c = true;  
            con.LifetimePoints__c = lifetimePts; 
            con.TotalPointsRedeemed__c = totalPtsRedeemed; 
            con.Start_Earn_Points__c = startEarnPts; 
            con.Start_Redeem_Points__c = startRedeemPts; 
            con.Monthly_Expired_Points__c = monthlyExpiredPts;             
            lContact.add(con);
        }
        
        insert lContact;
        return lContact;
    }
    
    public static List<Contact> createTestChildContact(Integer numOfRecords, Id accountId){
        
        list<Contact> lContact = new list<Contact>();        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        List<Account> acct = [SELECT Id, Market__c FROM Account WHERE Id =: accountId];

        for(Integer i=0; i<numOfRecords; i++) {
            
            Contact con = new Contact();          
            //add new required field in here
            con.LastName = 'LastName -' + i + generateRandomNumber(2);        
            con.AccountId = accountId;
            con.RecordTypeId = idRecType;
            if(!acct.isEmpty() && acct[0].Market__c == 'IN'){
                con.Phone = '6' + generateRandomNumber(9);
            }
            else{
                con.Phone = '0' + generateRandomNumber(10);
            }
            con.Type__c = 'Child';
            lContact.add(con);
        }
        
        insert lContact;
        return lContact;
    }

    public static List<Contact> createTestChildContactNoInsert(Integer numOfRecords, Id accountId){
        
        list<Contact> lContact = new list<Contact>();        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        List<Account> acct = [SELECT Id, Market__c FROM Account WHERE Id =: accountId];
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Contact con = new Contact();          
            //add new required field in here
            con.LastName = 'LastName -' + i + generateRandomNumber(2);        
            con.AccountId = accountId;
            con.RecordTypeId = idRecType;
            if(!acct.isEmpty() && acct[0].Market__c == 'IN'){
                con.Phone = '6' + generateRandomNumber(9);
            }
            else{
                con.Phone = '0' + generateRandomNumber(10);
            }
            con.Type__c = 'Child';
            con.BirthDate = Date.today().addMonths(3);
            lContact.add(con);
        }
        
        return lContact;
    }
    
    public static List<Product2> createTestBrandProduct(Integer numOfRecords){
        
        list<Product2> lProduct2 = new list<Product2>();        
        
        //Id idRecType = Schema.sObjectType.Product2.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Product2 prod = new Product2();          
            //add new required field in here
            prod.Name = 'ProductName -' + i;           
            prod.AvailableBrandRelationship__c = true;
            prod.Market__c = 'PH';
            prod.Keybrand__c = 'Ensure';
            prod.IsActive = true;
            prod.Family='Adult';
            prod.ProductCode = generateRandomNumber(12);
            lProduct2.add(prod);
        }
        
        insert lProduct2;
        return lProduct2;
    }

    public static List<Product2> createTestBrandProductNoInsert(Integer numOfRecords){
        
        list<Product2> lProduct2 = new list<Product2>();        
        
        //Id idRecType = Schema.sObjectType.Product2.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Product2 prod = new Product2();          
            //add new required field in here
            prod.Name = 'ProductName -' + i;           
            prod.AvailableBrandRelationship__c = true;
            prod.Market__c = 'PH';
            prod.Keybrand__c = 'Ensure';
            prod.IsActive = true;
            prod.Family='Adult';
            prod.ProductCode = generateRandomNumber(12);
            lProduct2.add(prod);
        }
        
        return lProduct2;
    }


    // Sean Cordova
    public static List<Product2> createTestBrandProduct2(Integer numOfRecords){
        
        list<Product2> lProduct2 = new list<Product2>();        
        
        //Id idRecType = Schema.sObjectType.Product2.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Product2 prod = new Product2();          
            //add new required field in here
            prod.Name = 'ProductName -' + i;           
            prod.AvailableBrandRelationship__c = true;
            prod.Market__c = 'PH';
            prod.Keybrand__c = 'Ensure';
            prod.IsActive = true;
            prod.Family='Adult';
            prod.ProductCode = generateRandomNumber(12);
            lProduct2.add(prod);
        }
        
        return lProduct2;
    }

    // Sean Cordova
    public static List<Product2> createTestBrandProductSG(Integer numOfRecords){
        
        list<Product2> lProduct2 = new list<Product2>();        
        
        //Id idRecType = Schema.sObjectType.Product2.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Product2 prod = new Product2();          
            //add new required field in here
            prod.Name = 'ProductName -' + i;           
            prod.AvailableBrandRelationship__c = true;
            prod.Market__c = 'SG';
            prod.Keybrand__c = 'Ensure';
            prod.IsActive = true;
            prod.Family='Adult';
            prod.ProductCode = generateRandomNumber(12);
            lProduct2.add(prod);
        }
        
        return lProduct2;
    }
    
    public static List<BrandRelationship__c> createTestBrandRelationShip(Integer numOfRecords, Id contactId, Id productId){
        
        list<BrandRelationship__c> lBrandRelationship = new list<BrandRelationship__c>();        
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            BrandRelationship__c brand = new BrandRelationship__c();          
            //add new required field in here
            brand.Type__c = 'Lead';
            brand.Status__c = 'Contacted';            
            brand.BrandRelationship__c = productId;
            brand.User__c = contactId;
            brand.PrimaryContact__c = contactId;   
            brand.Active__c = true;                     
            lBrandRelationship.add(brand);
        }
        
        insert lBrandRelationship;
        return lBrandRelationship;
    }

    public static List<BrandRelationship__c> createTestBrandRelationShipNoInsert(Integer numOfRecords, Id contactId, Id productId){
        
        list<BrandRelationship__c> lBrandRelationship = new list<BrandRelationship__c>();        
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            BrandRelationship__c brand = new BrandRelationship__c();          
            //add new required field in here
            brand.Type__c = 'Lead';
            brand.Status__c = 'Contacted';            
            brand.BrandRelationship__c = productId;
            brand.User__c = contactId;
            brand.PrimaryContact__c = contactId;   
            brand.Active__c = true;                     
            lBrandRelationship.add(brand);
        }
        
        return lBrandRelationship;
    }
    
    public static List<BrandRelationship__c> createTestBrandRelationShipwithUser(Integer numOfRecords, Id primaryId, Id userId, Id productId){
        
        list<BrandRelationship__c> lBrandRelationship = new list<BrandRelationship__c>();        
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            BrandRelationship__c brand = new BrandRelationship__c();          
            //add new required field in here
            brand.Type__c = 'Lead';
            brand.Status__c = 'Contacted';            
            brand.BrandRelationship__c = productId;
            brand.User__c = userId;
            brand.PrimaryContact__c = primaryId;   
            brand.Active__c = true;                     
            lBrandRelationship.add(brand);
        }
        
        insert lBrandRelationship;
        return lBrandRelationship;
    }

    public static List<BrandRelationship__c> createTestBrandRelationShipwithUser2(Integer numOfRecords, Id primaryId, List<Contact> conList, Id productId){
        
        list<BrandRelationship__c> lBrandRelationship = new list<BrandRelationship__c>();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            BrandRelationship__c brand = new BrandRelationship__c();
            //add new required field in here
            brand.Type__c = 'Lead';
            brand.Status__c = 'Contacted';
            brand.BrandRelationship__c = productId;
            brand.User__c = conList[i].Id;
            brand.PrimaryContact__c = primaryId;
            brand.Active__c = true;
            lBrandRelationship.add(brand);
        }
        
        insert lBrandRelationship;
        return lBrandRelationship;
    }
    
    public static List<Channel__c> createTestChannel(Integer numOfRecords){
        
        list<Channel__c> lChannel = new list<Channel__c>();        
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Channel__c chan = new Channel__c();          
            //add new required field in here
            chan.Market__c = 'PH';
            chan.Category__c = 'Online';
            lChannel.add(chan);
        }
        
        insert lChannel;
        return lChannel;
    }

    public static List<Channel__c> createTestChannel(Integer numOfRecords, String market){
        
        list<Channel__c> lChannel = new list<Channel__c>();        
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Channel__c chan = new Channel__c();          
            //add new required field in here
            chan.Market__c = market;
            chan.Category__c = 'Online';
            lChannel.add(chan);
        }
        
        insert lChannel;
        return lChannel;
    }
    
    public static List<Channel__c> createTestChannel(Integer numOfRecords, String market, String name){
        
        list<Channel__c> lChannel = new list<Channel__c>();        
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Channel__c chan = new Channel__c();          
            //add new required field in here
            chan.Name = name;
            chan.Market__c = market;
            chan.Category__c = 'Online';
            lChannel.add(chan);
        }
        
        insert lChannel;
        return lChannel;
    }

    // Sean Cordova
    public static List<Channel__c> createTestChannel2(Integer numOfRecords){
        
        list<Channel__c> lChannel = new list<Channel__c>();        
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Channel__c chan = new Channel__c();          
            //add new required field in here
            chan.Market__c = 'PH';
            chan.Category__c = 'Online';
            lChannel.add(chan);
        }
        
        return lChannel;
    }
    
    public static ChannelResponse__c createTestChannelResponse(BrandRelationship__c br, Channel__c chan){
        
        ChannelResponse__c cr = new ChannelResponse__c();
        cr.BrandRelationship__c = br.Id;
        cr.Channel__c = chan.Id;
        cr.Contact__c = br.PrimaryContact__c;
        insert cr;
        return cr;
    }

    public static List<ChannelResponse__c> createTestChannelResponseMultiple(Integer numOfRecords, BrandRelationship__c br, Channel__c chan, Address__c addr, Product2 prod, boolean sampleRequested, String orderCreationStatus){
        
        List<ChannelResponse__c> crToInsertList = new List<ChannelResponse__c>();
        for(Integer i=0; i<numOfRecords; i++){
            ChannelResponse__c cr = new ChannelResponse__c();
            cr.BrandRelationship__c = br.Id;
            cr.Channel__c = chan.Id;
            cr.Contact__c = br.PrimaryContact__c;
            cr.DeliveryAddress__c = addr.Id;
            cr.ProductSampleRequested__c = prod.Id;
            cr.IsSample_Requested__c = sampleRequested;
            cr.OrderCreationStatus__c = orderCreationStatus;
            crToInsertList.add(cr);
        }
        
        insert crToInsertList;
        return crToInsertList;
    }
    
    public static List<Address__c> createTestDefaultAddress(Integer numOfRecords, Id contactId, Id regionId, Id cityId){
        
        list<Address__c> lAddress = new list<Address__c>();  
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Address__c address = new Address__c();          
            //add new required field in here
            address.ParentContact__c = contactId;
            address.DefaultAddress__c = TRUE;
            address.Street1__c = 'Kent Street';
            address.City2__c = cityId;
            address.Country__c = 'Australia';
            address.Region__c = regionId;
            lAddress.add(address);
        }
        
        insert lAddress;
        return lAddress;
    }
    
    public static List<Address__c> createTestDefaultAddressNoInsert(Integer numOfRecords, Id contactId, Id regionId, Id cityId, String country){
        
        list<Address__c> lAddress = new list<Address__c>();  
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Address__c address = new Address__c();          
            //add new required field in here
            address.ParentContact__c = contactId;
            address.DefaultAddress__c = TRUE;
            address.Street1__c = 'Kent Street';
            address.City2__c = cityId;
            address.Country__c = country;
            address.Region__c = regionId;
            lAddress.add(address);
        }
        
        return lAddress;
    }
    
    
    public static List<Address__c> createTestNonDefaultAddress(Integer numOfRecords, Id contactId, Id regionId, Id cityId){
        
        list<Address__c> lAddress = new list<Address__c>();  
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Address__c address = new Address__c();          
            //add new required field in here
            address.ParentContact__c = contactId;
            address.Street1__c = 'Kent Street';
            address.City2__c = cityId;
            address.Country__c = 'Australia';
            address.Region__c = regionId;
            lAddress.add(address);
        }
        
        insert lAddress;
        return lAddress;
    }
    
    public static List<Affiliate_Value__c> createTestRegion(Integer numOfRecords){
        
        list<Affiliate_Value__c> lRegion = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get(CommonConstant.AFFILIATE_REGION_RECORDTYPE).getRecordTypeId();      
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c region = new Affiliate_Value__c();          
            //add new required field in here
            region.Name = 'West';
            region.Market__c = 'PH';
            region.AffiliateValue__c = 'West';
            region.Active__c = TRUE;
            region.RecordTypeId = idRecType;
            lRegion.add(region);
        }
        
        insert lRegion;
        return lRegion;
    }

    public static List<Affiliate_Value__c> createTestRegion(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lRegion = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get(CommonConstant.AFFILIATE_REGION_RECORDTYPE).getRecordTypeId();      
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c region = new Affiliate_Value__c();          
            //add new required field in here
            region.Name = 'West';
            region.Market__c = market;
            region.AffiliateValue__c = 'West';
            region.Active__c = TRUE;
            region.RecordTypeId = idRecType;
            lRegion.add(region);
        }
        
        insert lRegion;
        return lRegion;
    }
    
    
    public static List<Affiliate_Value__c> createTestCity(Integer numOfRecords){
        
        list<Affiliate_Value__c> lCity = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('City').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c city = new Affiliate_Value__c();          
            //add new required field in here
            city.Name = 'Test City';
            city.Market__c = 'PH';
            city.AffiliateValue__c = 'Test City';
            city.Active__c = TRUE;
            city.RecordTypeId = idRecType;
            lCity.add(city);
        }
        
        insert lCity;
        return lCity;
    }

    public static List<Affiliate_Value__c> createTestCity(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lCity = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('City').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c city = new Affiliate_Value__c();          
            //add new required field in here
            city.Name = 'Test City';
            city.Market__c = market;
            city.AffiliateValue__c = 'Test City';
            city.Active__c = TRUE;
            city.RecordTypeId = idRecType;
            lCity.add(city);
        }
        
        insert lCity;
        return lCity;
    }
    
    public static List<Affiliate_Value__c> createTestState(Integer numOfRecords){
        
        list<Affiliate_Value__c> lstate = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('State').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c state = new Affiliate_Value__c();          
            //add new required field in here
            state.Name = 'Test State';
            state.Market__c = 'PH';
            state.AffiliateValue__c = 'Test State';
            state.Active__c = TRUE;
            state.RecordTypeId = idRecType;
            lstate.add(state);
        }
        
        insert lstate;
        return lstate;
    }
    
    public static List<Affiliate_Value__c> createTestEscalation(Integer numOfRecords, String market, Id parent, Id product){
        
        list<Affiliate_Value__c> lescalation = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Case Escalation Point').getRecordTypeId();     
        
        for(Integer i=1; i<numOfRecords; i++) {
            
            Affiliate_Value__c escalation = new Affiliate_Value__c();          
            //add new required field in here
            escalation.Name = 'Escalation' + i;
            escalation.Market__c = market;
            escalation.AffiliateValue__c = 'Escalation' + i;
            escalation.Active__c = TRUE;
            escalation.RecordTypeId = idRecType;
            escalation.MainEscalationPointEmail__c = 'email' + i + '@testclass.com';
            escalation.ParentAffiliateValue__c = parent;
            escalation.EscalationLevel__c = String.valueof(i);
            escalation.ChannelType__c = 'Traditional';
            escalation.Product__c = product;
            lescalation.add(escalation);
        }
        
        insert lescalation;
        return lescalation;
    }
    
    public static List<Affiliate_Value__c> createTestWard(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lWard = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Ward').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c ward = new Affiliate_Value__c();          
            //add new required field in here
            ward.Name = 'Test ward';
            ward.Market__c = market;
            ward.AffiliateValue__c = 'Test ward';
            ward.Active__c = TRUE;
            ward.RecordTypeId = idRecType;
            lWard.add(ward);
        }
        
        insert lWard;
        return lWard;
    }
    
    public static List<Affiliate_Value__c> createTestDistrict(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('District').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test destrict';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test destrict';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestEthnicity(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Ethnicity').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test Ethnicity';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test Ethnicity';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestSwitchReason(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Brand Switch Reason').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test Switch';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test Switch';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestSuccessfulReason(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Successful Reason').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test Successful Reason';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test Successful Reason';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestUncontactableReason(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Uncontactable Reason').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test Uncontactable Reason';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test Uncontactable Reason';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestUnsuccessfulReason(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Unsuccessful Reason').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test Unsuccessful Reason';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test Unsuccessful Reason';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestInvalidReason(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Unsuccessful Reason').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test Invalid Reason';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test Invalid Reason';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestOrderCancellationReason(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Order Cancellation Reason').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test Order Cancellation Reason';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test Order Cancellation Reason';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestCallTransferReason(Integer numOfRecords, String market){
        
        list<Affiliate_Value__c> lAV = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Call Transfer Reason').getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c av = new Affiliate_Value__c();          
            //add new required field in here
            av.Name = 'Test Call Transfer Reason';
            av.Market__c = market;
            av.AffiliateValue__c = 'Test Call Transfer Reason';
            av.Active__c = TRUE;
            av.RecordTypeId = idRecType;
            lAV.add(av);
        }
        
        insert lAV;
        return lAV;
    }
    
    public static List<Affiliate_Value__c> createTestOCR(Integer numOfRecords){
        
        list<Affiliate_Value__c> lOcr = new list<Affiliate_Value__c>();
        Id idRecType = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get(CommonConstant.AFFILIATE_OCR_RECORDTYPE).getRecordTypeId();     
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Affiliate_Value__c ocr = new Affiliate_Value__c();          
            //add new required field in here
            ocr.Name = 'Duplicate Order';
            ocr.Market__c = CommonConstant.MARKET_VN;
            ocr.AffiliateValue__c = 'Duplicate Order';
            ocr.Active__c = TRUE;
            ocr.RecordTypeId = idRecType;
            lOcr.add(ocr);
        }
        
        insert lOcr;
        return lOcr;
    }
    
    public static Campaign createCampaign(String campaignName, String brand, String market) {
        Campaign camp1 = new Campaign();
        camp1.Name = campaignName;
        camp1.IsActive = True;
        camp1.Type = 'Event';
        camp1.ApprovalStatus__c = 'Approved';
        camp1.Urgency__c = 'Medium';
        camp1.Status = 'Completed';
        camp1.StartDate = Date.today() - 15;
        camp1.EndDate = Date.today() + 15;
        camp1.Brand__c = brand;
        camp1.Market__c = market;
        camp1.Objective__c = 'Test Objective';
        
        return camp1;
    }
    
    public static Affiliate_Value__c createAffiliate(String market, String affiliateName) {        
        Id rtId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Preferred Language').getRecordTypeId();
        Affiliate_Value__c av = new Affiliate_Value__c();
        av.Name = affiliateName;
        av.Market__c = market;
        av.AffiliateValue__c = affiliateName;
        av.Active__c = true;
        av.RecordTypeId = rtId;
        insert av;
        return av;
    }

    public static Affiliate_Value__c createAffiliateNoInsert(String market, String affiliateName) {        
        Id rtId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get('Preferred Language').getRecordTypeId();
        Affiliate_Value__c av = new Affiliate_Value__c();
        av.Name = affiliateName;
        av.Market__c = market;
        av.AffiliateValue__c = affiliateName;
        av.Active__c = true;
        av.RecordTypeId = rtId;

        return av;
    }

    public static Affiliate_Value__c createAffiliate(String market, String affiliateName, String recType) {        
        Id rtId = Schema.SObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
        Affiliate_Value__c av = new Affiliate_Value__c();
        av.Name = affiliateName;
        av.Market__c = market;
        av.AffiliateValue__c = affiliateName;
        av.Active__c = true;
        av.RecordTypeId = rtId;
        insert av;
        return av;
    }
    
    public static Case createCaseCall(Id accountId, Id contactId) {
        Id caseRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        Case caseRec = new Case();
        caseRec.CallType__c = 'Inbound';
        caseRec.Status = 'New';
        caseRec.CallRegarding__c = contactId;
        caseRec.ContactId = contactId;
        caseRec.AccountId = accountId;
        caseRec.AbbottAwarenessDate__c = Date.today().addDays(-2);
        
        insert caseRec;
        return caseRec;
    }

    public static Case createCaseCallNoInsert(Id accountId, Id contactId) {
        Id caseRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        Case caseRec = new Case();
        caseRec.CallType__c = 'Inbound';
        caseRec.Status = 'New';
        caseRec.CallRegarding__c = contactId;
        caseRec.ContactId = contactId;
        caseRec.AccountId = accountId;
        caseRec.AbbottAwarenessDate__c = Date.today().addDays(-2);
        
        return caseRec;
    }
    
    // Sean Cordova
    public static Pricebook2 createPricebook(String market) {
        Pricebook2 pb = new Pricebook2();
        pb.Name = market + ' Custom Pricebook';
        pb.IsActive = TRUE;
        pb.Market__c = 'VN';
        
        insert pb;
        return pb;
    }
    
    // Sean Cordova
    public static List<PriceBook2> createPriceBook2(Integer a, String market){
        List<PriceBook2> pList = new List<PriceBook2>();        
        for(Integer i=0; i<a; i++){
            pList.add(new PriceBook2(Name = 'Test PriceBook Name', 
                                     StartDate__c = date.today() ,
                                     EndDate__c = date.today(),
                                     Market__c = market
                                    ));
        }
        database.insert(pList);
        return pList;        
    }

    public static List<PriceBook2> createPriceBook2(Integer a){
        List<PriceBook2> pList = new List<PriceBook2>();        
        for(Integer i=0; i<a; i++){
            pList.add(new PriceBook2(Name = 'Test PriceBook Name', 
                                     StartDate__c = date.today() ,
                                     EndDate__c = date.today(),
                                     Market__c = 'VN'
                                    ));
        }
        database.insert(pList);
        return pList;        
    }
    
    public static List<Reward__c> createReward(Integer numOfRecords, Id contactId, Date awardDate){
        List<Reward__c> rewardList = new List<Reward__c>();  
        Id earRecTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_EARN_RECORDTYPE).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++){
            rewardList.add(new Reward__c(Contact__c = contactId, 
                                         Active__c = TRUE,
                                         PointsAmount__c = 500,
                                         RecordTypeId = earRecTypeId,
                                         AwardDate__c = awardDate
                                        ));
        }
        database.insert(rewardList);
        return rewardList;        
    }
    
    public static List<Order> createOrder(Integer a, Id accountId, Id contactId, Id pricebookId){
        List<Order> pList = new List<Order>();        
        for(Integer i=0; i<a; i++){
            pList.add(new Order(
                AccountId = accountId,
                OrderedBy__c = contactId,
                Status = CommonConstant.ORDER_STATUS_DRAFT,
                EffectiveDate = Date.today() ,
                Pricebook2Id = pricebookId    ,
                EndDate = Date.today().addDays(2)                                
            ));
        }
        //database.insert(pList);

        return pList;        
    }
    
    public static PricebookEntry createPricebookEntry() {
        // Instantiate the Pricebook2 record first, setting the Id
        Pricebook2 standardPricebook = new Pricebook2(
            Id =  System.Test.getStandardPricebookId(),
            IsActive = true,
            Market__c = 'PH'
        );
        
        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;
        
        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        // This should return true now
        system.assertEquals(true, standardPricebook.IsStandard, 'The Standard Pricebook should now return IsStandard = true');
        
        // Create Parent Brand
        List<Product2> productList = new List<Product2>();

        Product2 testParentBrand = new Product2(
            Name = 'Test Parent Brand', 
            IsActive = true,
            Market__c = 'PH',
            Keybrand__c = 'Ensure',
            ProductHierarchyLevel__c = 'Brand',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            AvailableForOrder__c = true,
            ProductCode= generateRandomNumber(12)
        );
        // insert testParentBrand;
        
        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            IsActive = true,
            Market__c = 'PH',
            Keybrand__c = 'Ensure',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            AvailableForOrder__c = true,
            ParentBrand__c = testParentBrand.Id,
            ProductCode= generateRandomNumber(12)
        );
        // insert testProduct;
        
        productList.add(testParentBrand);
        productList.add(testProduct);

        UtilityClass.insertList(productList);
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        return testPbe;
    }
    
    public static PricebookEntry createPricebookEntry(String market) {
        // Instantiate the Pricebook2 record first, setting the Id
        Pricebook2 standardPricebook = new Pricebook2(
            Id =  System.Test.getStandardPricebookId(),
            IsActive = true,
            Market__c = market
        );
        
        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;
        
        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        // This should return true now
        system.assertEquals(true, standardPricebook.IsStandard, 'The Standard Pricebook should now return IsStandard = true');
        
        List<Product2> productList = new List<Product2>();

        // Create Parent Brand
        Product2 testParentBrand = new Product2(
            Name = 'Test Parent Brand', 
            IsActive = true,
            Market__c = market,
            Keybrand__c = 'Ensure',
            ProductHierarchyLevel__c = 'Brand',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );
        
        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            IsActive = true,
            Market__c = market,
            Keybrand__c = 'Ensure',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            ParentBrand__c = testParentBrand.Id,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );

        productList.add(testParentBrand);
        productList.add(testProduct);

        UtilityClass.insertList(productList);
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        return testPbe;
    }

    public static PricebookEntry createPricebookEntry(String market, String curr) {
        Pricebook2 standardPricebook = new Pricebook2(
            Id =  System.Test.getStandardPricebookId(),
            IsActive = true,
            Market__c = market
        );

        update standardPricebook;
        
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        List<Product2> productList = new List<Product2>();
        Product2 testParentBrand = new Product2(
            Name = 'TEST_PARENT_BRAND', 
            IsActive = true,
            Market__c = market,
            Keybrand__c = 'Ensure',
            ProductHierarchyLevel__c = 'Brand',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );
        
        Product2 testProduct = new Product2(
            Name = 'TEST_PRODUCT', 
            IsActive = true,
            Market__c = market,
            Keybrand__c = 'Ensure',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            ParentBrand__c = testParentBrand.Id,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );

        productList.add(testParentBrand);
        productList.add(testProduct);

        UtilityClass.insertList(productList);
        
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = curr
        );

        insert testPbe;
        return testPbe;
    }

    public static PricebookEntry createProductAndPricebookEntryOnly(String market, String curr, Id pricebookId) {

        List<Product2> productList = new List<Product2>();

        // Create Parent Brand
        Product2 testParentBrand = new Product2(
            Name = 'TEST_PARENT_BRAND', 
            IsActive = true,
            Market__c = market,
            Keybrand__c = 'Ensure',
            ProductHierarchyLevel__c = 'Brand',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );
        
        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'TEST_PRODUCT', 
            IsActive = true,
            Market__c = market,
            Keybrand__c = 'Ensure',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            ParentBrand__c = testParentBrand.Id,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );

        productList.add(testParentBrand);
        productList.add(testProduct);

        UtilityClass.insertList(productList);
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = curr
        );
        
        insert testPbe;
        return testPbe;
    }
    
    public static PricebookEntry createProductAndPricebookEntryDiffBrand(String market, String curr, Id pricebookId, String brand) {

        List<Product2> productList = new List<Product2>();

        // Create Parent Brand
        Product2 testParentBrand = new Product2(
            Name = 'TEST_PARENT_BRAND', 
            IsActive = true,
            Market__c = market,
            Keybrand__c = brand,
            ProductHierarchyLevel__c = 'Brand',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );
        
        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'TEST_PRODUCT', 
            IsActive = true,
            Market__c = market,
            Keybrand__c = brand,
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            ParentBrand__c = testParentBrand.Id,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );

        productList.add(testParentBrand);
        productList.add(testProduct);

        UtilityClass.insertList(productList);
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = curr
        );
        
        insert testPbe;
        return testPbe;
    }
    
    public static Product2 createProductDiffBrand(String market, String curr, Id pricebookId, String brand, String productName) {

        List<Product2> productList = new List<Product2>();

        // Create Parent Brand
        Product2 testParentBrand = new Product2(
            Name = productName, 
            IsActive = true,
            Market__c = market,
            Keybrand__c = brand,
            ProductHierarchyLevel__c = 'Brand',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );
        insert testParentBrand;
        // Create the Product
        Product2 testProduct = new Product2(
            Name = productName, 
            IsActive = true,
            Market__c = market,
            Keybrand__c = brand,
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            ParentBrand__c = testParentBrand.Id,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );
		insert testProduct;
                
        return testProduct;
    }
    
    public static Product2 createProductDiffBrand(String market, String curr, Id pricebookId, String brand, String productName, String externalId) {

        List<Product2> productList = new List<Product2>();

        // Create Parent Brand
        Product2 testParentBrand = new Product2(
            Name = productName, 
            IsActive = true,
            Market__c = market,
            Keybrand__c = brand,
            ProductHierarchyLevel__c = 'Brand',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12)
        );
        insert testParentBrand;
        // Create the Product
        Product2 testProduct = new Product2(
            Name = productName, 
            IsActive = true,
            Market__c = market,
            Keybrand__c = brand,
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            ParentBrand__c = testParentBrand.Id,
            Stage1PaidSample__c = true,
            Stage3PaidSample__c = true,
            Available_For_Promo__c = true,
            Min_Birth_Month__c = -5.0,
            Max_Birth_Month__c = 12.0,
            Max_eligible_for_Promo__c = 1.0,
            ProductCode= generateRandomNumber(12),
            ExternalId__c = externalId
        );
		insert testProduct;
                
        return testProduct;
    }
    public static List<Product2> createProductMultipleNoInsert(Integer numOfProducts, String market, String curr, Id pricebookId) {
        
        List<Product2> productList = new List<Product2>();
        
        for(Integer i=0; i<numOfProducts; i++){
            // Create Parent Brand
            Product2 testParentBrand = new Product2(
                Name = 'TEST_PARENT_BRAND', 
                IsActive = true,
                Market__c = market,
                Keybrand__c = 'Ensure',
                ProductHierarchyLevel__c = 'Brand',
                AvailableForSample__c = true,
                AvailableBrandRelationship__c = true,
                Stage1PaidSample__c = true,
                Stage3PaidSample__c = true,
                Available_For_Promo__c = true,
                Min_Birth_Month__c = -5.0,
                Max_Birth_Month__c = 12.0,
                Max_eligible_for_Promo__c = 1.0,
                ProductCode= generateRandomNumber(12)
            );
            
            // Create the Product
            Product2 testProduct = new Product2(
                Name = 'TEST_PRODUCT', 
                IsActive = true,
                Market__c = market,
                Keybrand__c = 'Ensure',
                AvailableForSample__c = true,
                AvailableBrandRelationship__c = true,
                ParentBrand__c = testParentBrand.Id,
                Stage1PaidSample__c = true,
                Stage3PaidSample__c = true,
                Available_For_Promo__c = true,
                Min_Birth_Month__c = -5.0,
                Max_Birth_Month__c = 12.0,
                Max_eligible_for_Promo__c = 1.0,
                ProductCode= generateRandomNumber(12)
            );
            
            productList.add(testParentBrand);
            productList.add(testProduct);
        }
        
        return productList;
    }
    
    public static PricebookEntry createPricebookEntryNoInsert(String market, String curr, Id pricebookId, Id productId) {  
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = curr
        );

        return testPbe;
    }


    public static PricebookEntry createPricebookEntry2(String market, Product2 testParentBrand, Product2 testProduct) {
        // Instantiate the Pricebook2 record first, setting the Id
        Pricebook2 standardPricebook = new Pricebook2(
            Id =  System.Test.getStandardPricebookId(),
            IsActive = true,
            Market__c = market
        );
        
        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;
        
        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        // This should return true now
        system.assertEquals(true, standardPricebook.IsStandard, 'The Standard Pricebook should now return IsStandard = true');
        
        List<Product2> productList = new List<Product2>();

        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        return testPbe;
    }
    
    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId) {
        OrderItem testoi = new OrderItem(
            OrderId = orderId,
            ServiceDate = Date.today(),
            Quantity = 1,
            UnitPrice = 100,           
            PricebookEntryId = pricebookEntryId
        );
        
        return testoi;
    }
    
    public static ContentWorkspace createFileLibrary(String market) {
        ContentWorkspace content = new ContentWorkspace(
            Name = 'Order Export Library - ' + market,
            ShouldAddCreatorMembership = true
        );
        
        return content;
    }
    
    /*create Order*/
    public static List<Order> newOrder(Integer numOrder){
        List<Order> orderList = new List<Order>(); 
        
        List<Account> accList = createTestHousehold(1);
        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        Contact con = new Contact();          
        //add new required field in here
        con.LastName = 'LastName -' + generateRandomNumber(2);           
        con.AccountId = accList[0].id;
        con.RecordTypeId = idRecType;
        con.Phone = '0' + generateRandomNumber(10);
        con.Type__c = 'Adult';
        //database.insert(con);
        insert con;
        
        //Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Children Account').getRecordTypeId();
        date newDate = date.newInstance(2018, 5, 17);
        //Create the account object and assign values to the required account fields.
        for(Integer i=0;i<numOrder;i++){
            orderList.add(new Order(
                AccountId = accList[0].id,
                OrderedBy__c = con.id,
                EffectiveDate = newDate,
                Status = 'Draft'
            ));
        }            
        
        return orderList; 
    }
    
    /*create OrderItem*/
    public static List<OrderItem> newOrderItem(Integer numOrderItem){
        List<OrderItem> orderItemList = new List<OrderItem>(); 
        
        List<Order> orderList = newOrder(1);
        database.insert(orderList); 
        
        LIst<Promotion__c> newPromotion = createPromotion(1);
        database.insert(newPromotion);
        
        for(Integer i=0;i<numOrderItem;i++){
            orderItemList.add(new OrderItem(
                OrderId = orderList[0].id,
                Quantity = 10,
                UnitPrice = 50,
                Promotion__c = newPromotion[0].id
            ));
        }            
        
        return orderItemList; 
    }
    
    public static List<Promotion__c> createPromotion(Integer numOrderItem){
        List<Promotion__c> promotionList = new List<Promotion__c>(); 
        
        for(Integer i=0;i<numOrderItem;i++){
            promotionList.add(new Promotion__c(
                Name = 'Promotion Name' + i,
                Status__c = 'Planned',
                Market__c = 'PH',
                StartDate__c = date.today()
                
                
            ));
        }            
        insert promotionList;
        return promotionList; 
    }

    public static List<Promotion__c> createPromotionNoInsert(Integer numOrderItem){
        List<Promotion__c> promotionList = new List<Promotion__c>(); 
        
        for(Integer i=0;i<numOrderItem;i++){
            promotionList.add(new Promotion__c(
                Name = 'Promotion Name' + i,
                Status__c = 'Planned',
                Market__c = 'PH',
                StartDate__c = date.today()
                
                
            ));
        }            
        return promotionList; 
    }
    
    public static List<PromotionItem__c> createPromotionItem(Integer numOrderItem, Id productId, Id promotionId){
        List<PromotionItem__c> promotionItemList = new List<PromotionItem__c>(); 
        
        for(Integer i=0;i<numOrderItem;i++){
            promotionItemList.add(new PromotionItem__c(
                PromotionPrice__c = 100,
                Product__c = productId,
                Promotion__c = promotionId ,
                DefaultOrderQuantity__c = 1           
                
            ));
        }            
        
        insert promotionItemList;
        return promotionItemList; 
    }

    public static List<PromotionItem__c> createPromotionItemNoInsert(Integer numOrderItem, Id productId, Id promotionId){
        List<PromotionItem__c> promotionItemList = new List<PromotionItem__c>(); 
        
        for(Integer i=0;i<numOrderItem;i++){
            promotionItemList.add(new PromotionItem__c(
                PromotionPrice__c = 100,
                Product__c = productId,
                Promotion__c = promotionId ,
                DefaultOrderQuantity__c = 1           
                
            ));
        }            
        
        return promotionItemList; 
    }
    
    public static List<Case> createCase(integer newCase) {
        Id caseRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        List<Case> getCase = new List<Case>();
        List<Account> newAcc = createTestHousehold(1);
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        Contact con = new Contact();          
        //add new required field in here
        con.LastName = 'LastName -';           
        con.AccountId = newAcc[0].id;
        con.RecordTypeId = idRecType;
        con.Phone = '063123456789';
        con.Type__c = 'Adult';
        con.Verified__c = true;
        con.RecordTypeId = idRecType;
        database.insert(con);
        
        
        for(Integer i=0;i<newCase;i++){
            getCase.add(new Case(CallType__c = 'Inbound',
                                 Status = 'New', 
                                 CallRegarding__c = con.Id,
                                 ContactId = con.Id,
                                 AccountId = newAcc[0].id,
                                 RecordTypeId = caseRId
                                ));
        }
        
        return getCase;
    }
    
    public static List<Membership__c> createMembership(integer newMembeship, Id contactId, Integer numberOfDays) {
        List<Membership__c> membershipList = new List<Membership__c>();
        
        for(Integer i=0; i<newMembeship; i++){
            Membership__c mem = new Membership__c();          
            mem.Contact__c = contactId;           
            mem.MembershipStartDate__c = Date.Today().addDays(numberOfDays);
            membershipList.add(mem);
        }
        
        insert membershipList;
        return membershipList;
    }

    // Sean Cordova
    public static List<Membership__c> createMembership2(integer newMembeship, Id contactId, Integer numberOfDays) {
        List<Membership__c> membershipList = new List<Membership__c>();
        
        for(Integer i=0; i<newMembeship; i++){
            Membership__c mem = new Membership__c();          
            mem.Contact__c = contactId;           
            mem.MembershipStartDate__c = Date.Today().addDays(numberOfDays);
            membershipList.add(mem);
        }
        
        return membershipList;
    }
    
    public static List<PackageItem__c> createTestPackageItem(Id prodId, Id pckgItemId, Integer numOfRecords){   
        List<PackageItem__c> lPackageItenm = new List<PackageItem__c>();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            PackageItem__c pckItem = new PackageItem__c();
            pckItem.ParentPackage__c = prodId;
            pckItem.Quantity__c = 1;
            pckItem.PackageItem__c = pckgItemId;
            
            lPackageItenm.add(pckItem);
        }
        
        insert lPackageItenm;
        return lPackageItenm;
    }
    
    public static Milestone__c createMilestone(String market, String recType, String msValue){
        
        /* UPDATE THIS IN CASE THERE IS A NEW RECORD TYPE */
        Id recTypeId = Schema.SObjectType.Milestone__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();

        Milestone__c ms = new Milestone__c();
        ms.Market__c = market;
        ms.Name = recType.contains('Age') ? msValue + ' Month' : msValue + ' week';
        ms.IsActive__c = true;
        ms.MilestoneValue__c = Decimal.valueOf(msValue);
        ms.RecordTypeId = recTypeId;
        
        insert ms;
        return ms;
    }
    
    public static Asset createAsset(){
        // Instantiate the Pricebook2 record first, setting the Id
        Pricebook2 standardPricebook = new Pricebook2(
            Id =  System.Test.getStandardPricebookId(),
            IsActive = true,
            Market__c = 'ANZ'
        );
        
        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;
        
        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        // This should return true now
        system.assertEquals(true, standardPricebook.IsStandard, 'The Standard Pricebook should now return IsStandard = true');
        
        // Create Parent Brand
        Product2 testParentBrand = new Product2(
            Name = 'Test Parent Brand', 
            IsActive = true,
            Market__c = 'ANZ',
            Keybrand__c = 'Ensure',
            ProductHierarchyLevel__c = 'Brand',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            AvailableForOrder__c = true,
            ProductCode= generateRandomNumber(12)
        );
        insert testParentBrand;
        
        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            IsActive = true,
            Market__c = 'ANZ',
            Keybrand__c = 'Ensure',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            AvailableForOrder__c = true,
            ParentBrand__c = testParentBrand.Id,
            ProductCode= generateRandomNumber(12)
        );
        insert testProduct;
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        Schema.Location location = new Schema.Location();
        location.Name = 'Field';
        location.LocationType = 'Plant';
        insert location;
        
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Product2Id = testProduct.Id; 
        asset.LocationId = location.Id;
        asset.Input_Quantity__c = 1;
        return asset;
    }
    
    public static Asset_Service__c createAssetService(){
        Pricebook2 standardPricebook = new Pricebook2(
            Id =  System.Test.getStandardPricebookId(),
            IsActive = true,
            Market__c = 'ANZ'
        );
        
        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;
        
        
        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            IsActive = true,
            Market__c = 'ANZ',
            Keybrand__c = 'Ensure',
            AvailableForSample__c = true,
            AvailableBrandRelationship__c = true,
            AvailableForOrder__c = true,
            ProductCode= generateRandomNumber(12)
        );
        insert testProduct;
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        Schema.Location location = new Schema.Location();
        location.Name = 'Field';
        location.LocationType = 'Plant';
        insert location;
        
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Product2Id = testProduct.Id; 
        asset.LocationId = location.Id;
        asset.Input_Quantity__c = 1;
        insert asset;
        
        Account acc = new Account();        
        acc.Name = 'AccountName -' + Integer.valueof((Math.random() * 100));           
        acc.Market__c = 'ANZ';
        insert acc;
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        Contact con = new Contact();        
        con.LastName = 'LastName -' + generateRandomNumber(2);
        con.AccountId = acc.Id;
        con.RecordTypeId = idRecType;
        con.Phone = '0' + generateRandomNumber(9);
        con.Type__c = 'Adult';
        con.Verified__c = true; 
        insert con;
        
        Asset_Service__c assetService = new Asset_Service__c();
        assetService.Name = 'TestAssetService';
        assetService.Asset__c = asset.Id;
        assetService.AccountId__c = acc.Id;
        assetService.AssetServiceRegarding__c = con.Id;
        assetService.Status__c = 'New';
        insert assetService;
        return assetService;
        
    }
     
    public static List<Contact> createSGTestAdultContact(Integer numOfRecords, Id accountId){
        
        list<Contact> lContact = new list<Contact>();        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Contact con = new Contact();          
            //add new required field in here
            con.LastName = 'LastName -' + i + generateRandomNumber(2);
            con.AccountId = accountId;
            con.RecordTypeId = idRecType;
            con.Phone = '0' + generateRandomNumber(7);
            con.Type__c = 'Adult';
            con.Verified__c = true;               
            lContact.add(con);
        }
        
        insert lContact;
        return lContact;
    }
    
    public static List<Contact> createSGTestChildContact(Integer numOfRecords, Id accountId){
        
        list<Contact> lContact = new list<Contact>();        
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Contact con = new Contact();          
            //add new required field in here
            con.LastName = 'LastName -' + i + generateRandomNumber(2);        
            con.AccountId = accountId;
            con.RecordTypeId = idRecType;
            con.Phone =  '0' + generateRandomNumber(7);
            con.Type__c = 'Child';
            lContact.add(con);
        }
        
        insert lContact;
        return lContact;
    }
    
    public static List<Case> createPHCase(integer newCase) {
        Id caseRId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        List<Case> getCase = new List<Case>();
        List<Account> newAcc = createTestHousehold(1);
        
        Id idRecType = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        
        Contact con = new Contact();          
        //add new required field in here
        con.LastName = 'LastName -';           
        con.AccountId = newAcc[0].id;
        con.RecordTypeId = idRecType;
        con.Phone = '06312345678';
        con.Type__c = 'Adult';
        con.Verified__c = true;
        con.RecordTypeId = idRecType;
        database.insert(con);
        
        
        for(Integer i=0;i<newCase;i++){
            getCase.add(new Case(CallType__c = 'Inbound',
                                 Status = 'New', 
                                 CallRegarding__c = con.Id,
                                 ContactId = con.Id,
                                 AccountId = newAcc[0].id,
                                 RecordTypeId = caseRId
                                ));
        }
        
        return getCase;
    }

    public static List<OrderExport2__c> createOE(Integer newOE, List<Order> oList) {
        List<OrderExport2__c> oeList = new List<OrderExport2__c>();

        for(Integer i = 0; i < newOE; i++) {
            oeList.add(new OrderExport2__c(Order__c = oList[0].Id, FileExportTime__c = time.newInstance(01, 02, 03, 0000)));
        }

        return oeList;
    }

    public static List<Product2> createTestBrandProductTW(Integer numOfRecords){
        
        list<Product2> lProduct2 = new list<Product2>();        
        
        //Id idRecType = Schema.sObjectType.Product2.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Product2 prod = new Product2();          
            //add new required field in here
            prod.Name = 'ProductName -' + i;           
            prod.AvailableBrandRelationship__c = true;
            prod.Market__c = 'TW';
            prod.Keybrand__c = 'Ensure';
            prod.IsActive = true;
            prod.Family='Adult';
            prod.ProductCode = generateRandomNumber(12);
            prod.ProductHierarchyLevel__c ='Brand';
            lProduct2.add(prod);
        }
        
        insert lProduct2;
        return  lProduct2;
    }

    public static List<Product2> createTestBrandProductTWNoInsert(Integer numOfRecords){
        
        list<Product2> lProduct2 = new list<Product2>();        
        
        //Id idRecType = Schema.sObjectType.Product2.getRecordTypeInfosByName().get(sRecordType).getRecordTypeId();
        
        for(Integer i=0; i<numOfRecords; i++) {
            
            Product2 prod = new Product2();          
            //add new required field in here
            prod.Name = 'ProductName -' + i;           
            prod.AvailableBrandRelationship__c = true;
            prod.Market__c = 'TW';
            prod.Keybrand__c = 'Ensure';
            prod.IsActive = true;
            prod.Family='Adult';
            prod.ProductCode = generateRandomNumber(12);
            prod.ProductHierarchyLevel__c ='Brand';
            prod.Stage1PaidSample__c = true;
            prod.Stage3PaidSample__c = true;
            prod.Available_For_Promo__c = true;
            prod.Min_Birth_Month__c = -5.0;
            prod.Max_Birth_Month__c = 12.0;
            prod.Max_eligible_for_Promo__c = 1.0;
            lProduct2.add(prod);
        }
        
        return  lProduct2;
    }

    public static Campaign createCampaign(String campaignName, String brandName, String market,Id ProductId) {
        Campaign camp1 = new Campaign();
        camp1.Name = campaignName;
        camp1.IsActive = True;
        camp1.Type = 'Event';
        camp1.ApprovalStatus__c = 'Approved';
        camp1.Urgency__c = 'Medium';
        camp1.Status = 'Completed';
        camp1.StartDate = Date.today() - 15;
        camp1.EndDate = Date.today() + 15;
        camp1.Brand__c = brandName;
        camp1.Product__c = ProductId;
        camp1.Market__c = market;
        camp1.Objective__c = 'Test Objective';
        
        return camp1;
    }

    public static Campaign createCampaignInsert(String campaignName, String brandName, String market,Id ProductId) {
        Campaign camp1 = new Campaign();
        camp1.Name = campaignName;
        camp1.IsActive = True;
        camp1.Type = 'Event';
        camp1.ApprovalStatus__c = 'Approved';
        camp1.Urgency__c = 'Medium';
        camp1.Status = 'Completed';
        camp1.StartDate = Date.today() - 15;
        camp1.EndDate = Date.today() + 15;
        camp1.Brand__c = brandName;
        camp1.Product__c = ProductId;
        camp1.Market__c = market;
        camp1.Objective__c = 'Test Objective';
        
        insert camp1;
        return camp1;
    }

    public static Contact createContact(Boolean isPrimary, Id acctId, Id motherId, Date bday, String mobile) {
        Contact con = new Contact();   
        if(isPrimary){
            con.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
            con.Type__c = 'Adult';
            con.PrimaryContact__c = true;
        }
        else{
            con.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Child').getRecordTypeId();
            con.Type__c = 'Child';
            con.Parent__c = motherId;
        }
               
        con.LastName = 'LastName -' + generateRandomNumber(2);
        con.AccountId = acctId;
        con.Birthdate = bday;
        con.Phone = mobile;
        con.Verified__c = true;               

        insert con;
        return con;
    }

    public static Affiliate_value__c createAffiliateValue(String identifier, String externalId, String market, Id parentAV) {
        Affiliate_Value__c av = new Affiliate_Value__c(); 
        av.RecordTypeId = Schema.sObjectType.Affiliate_Value__c.getRecordTypeInfosByName().get(identifier).getRecordTypeId();   
        av.Name = externalId;
        av.Market__c = market;
        av.AffiliateValue__c = externalId;
        av.ParentAffiliateValue__c = parentAV;
        av.Active__c = true;
        
        insert av;
        return av;
    }

    public static Address__c createAddress(Boolean isDefault, Id parentId, String country, Id cityId, Id districtId, Id regionId, String street) {
        Address__c address = new Address__c();          
        //add new required field in here
        address.ParentContact__c = parentId;
        address.DefaultAddress__c = isDefault;
        address.Street1__c = street;
        address.City2__c = cityId;
        address.District__c = districtId;
        address.Country__c = country;
        address.Region__c = regionId;
    
        insert address;
        return address;
    }
    
    public static AbbottPartner__c createAbbottPartner(String market, String recType, String externalId) {
        AbbottPartner__c ap = new AbbottPartner__c();          
        ap.Market__c = market;
        ap.RecordTypeId = Schema.sObjectType.AbbottPartner__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();   
        ap.Active__c = true;
        ap.External_Id__c = externalId;
        ap.PartnerCode__c = externalId;

        insert ap;
        return ap;
    }

    public static TW_Order_Manual__c createTWOrderManual(String phone, String bday, String payType, String vat, String deliveryTime, String deliveryDate, String type, String promoterCode,
                                                        String salesPerson, String city, String district, String street, String taxId, String taxName, String product1, String quantity1, 
                                                        String product2, String quantity2, String product3, String quantity3, String product4, String quantity4, String pricebook) 
    {
        TW_Order_Manual__c two = new TW_Order_Manual__c();          
        two.Phone__c = phone;
        two.Birthdate__c = bday;
        two.Payment_Type__c = payType;
        two.VAT__c = vat;
        two.Preferred_Delivery_Time__c = deliveryTime;
        two.Preferred_Delivery_Date__c = deliveryDate;
        two.Type__c = type;
        two.Promoter_Code__c = promoterCode;
        two.Sales_Person__c = salesPerson;
        two.City__c = city;
        two.District__c = district;
        two.Street__c = street;
        two.Tax_ID__c = taxId;
        two.Tax_Name__c = taxName;
        two.Product_1__c = product1;
        two.Quantity_1__c = quantity1;
        two.Product_2__c = product2;
        two.Quantity_2__c = quantity2;
        two.Product_3__c = product3;
        two.Quantity_3__c = quantity3;
        two.Product_4__c = product4;
        two.Quantity_4__c = quantity4;
        two.Pricebook_Name__c = pricebook;

        insert two;
        return two;
    }
    
    public static TW_Order_Manual__c createTWOrderManualNoInsert(String phone, String bday, String payType, String vat, String deliveryTime, String deliveryDate, String type, String promoterCode,
                                                                 String salesPerson, String city, String district, String street, String taxId, String taxName, String product1, String quantity1, 
                                                                 String product2, String quantity2, String product3, String quantity3, String product4, String quantity4, String pricebook) 
    {
        TW_Order_Manual__c two = new TW_Order_Manual__c();          
        two.Phone__c = phone;
        two.Birthdate__c = bday;
        two.Payment_Type__c = payType;
        two.VAT__c = vat;
        two.Preferred_Delivery_Time__c = deliveryTime;
        two.Preferred_Delivery_Date__c = deliveryDate;
        two.Type__c = type;
        two.Promoter_Code__c = promoterCode;
        two.Sales_Person__c = salesPerson;
        two.City__c = city;
        two.District__c = district;
        two.Street__c = street;
        two.Tax_ID__c = taxId;
        two.Tax_Name__c = taxName;
        two.Product_1__c = product1;
        two.Quantity_1__c = quantity1;
        two.Product_2__c = product2;
        two.Quantity_2__c = quantity2;
        two.Product_3__c = product3;
        two.Quantity_3__c = quantity3;
        two.Product_4__c = product4;
        two.Quantity_4__c = quantity4;
        two.Pricebook_Name__c = pricebook;
        
        return two;
    }

    public static et4ae5__IndividualEmailResult__c createIER(Id conId, Boolean isHardBounce, Boolean isSoftBounce, Id triggeredSendId) {
        et4ae5__IndividualEmailResult__c ier = new et4ae5__IndividualEmailResult__c();          
        ier.et4ae5__Contact__c = conId;
        ier.et4ae5__HardBounce__c = isHardBounce;
        ier.et4ae5__SoftBounce__c = isSoftBounce;
        ier.et4ae5__TriggeredSendDefinition__c = triggeredSendId;

        insert ier;
        return ier;
    }
    
    public static List<et4ae5__IndividualEmailResult__c> createIERMultiple(Id conId, Boolean isHardBounce, Boolean isSoftBounce, Id triggeredSendId, Integer numRecords) {
        List<et4ae5__IndividualEmailResult__c> emailList = new List<et4ae5__IndividualEmailResult__c>();
        for(Integer num=0; num<numRecords; num++){
            et4ae5__IndividualEmailResult__c ier = new et4ae5__IndividualEmailResult__c();          
            ier.et4ae5__Contact__c = conId;
            ier.et4ae5__HardBounce__c = isHardBounce;
            ier.et4ae5__SoftBounce__c = isSoftBounce;
            ier.et4ae5__TriggeredSendDefinition__c = triggeredSendId;
            emailList.add(ier);
        }

        insert emailList;
        return emailList;
    }
    
    public static et4ae5__Automated_Send__c createAutomatedSend(Boolean isActive, Id businessUnit, String emailName, String fromEmail, String fromName, String subject) {
        et4ae5__Automated_Send__c autoSend = new et4ae5__Automated_Send__c();          
        autoSend.et4ae5__Active__c = isActive;
        autoSend.et4ae5__Business_Unit__c = businessUnit;
        autoSend.et4ae5__EmailName__c = emailName;
        autoSend.et4ae5__FromEmail__c = fromEmail;
        autoSend.et4ae5__FromName__c = fromName;
        autoSend.et4ae5__Subject__c = subject;

        insert autoSend;
        return autoSend;
    }

    public static et4ae5__Business_Unit__c createBusinessUnit(Boolean isEnabled, String businessUnitId) {
        et4ae5__Business_Unit__c businessUnit = new et4ae5__Business_Unit__c();          
        businessUnit.et4ae5__Enabled__c = isEnabled;
        businessUnit.et4ae5__Business_Unit_ID__c = businessUnitId;

        insert businessUnit;
        return businessUnit;
    }
    
    public static Membership__c createMembershipRecord(Id contactId, Date memberStartDate, Date memberExpiryDate, String membershipId, Id productId, String status) {
        Membership__c mem = new Membership__c();
        mem.Contact__c = contactId;           
        mem.MembershipStartDate__c = memberStartDate;
        mem.MembershipExpiryDate__c = memberExpiryDate;
        mem.MembershipId__c = membershipId;
        mem.Recent_Product_Purchased__c = productId;
        mem.Status__c = status;

        return mem;
    }
    
    public static VN_Contact_Manual__c createVNContactManual(String addrCountry, String addrStreet, String addrCity, String brBrandId, String brBrandName, String brRelationType, String brRelationStatus, String contactLastName, String contactEmail, String contactPhone, 
                                                             String crChannelId, String crChannelName, String crRegDate, String sampleProductId) {
		VN_Contact_Manual__c rec = new VN_Contact_Manual__c();
		rec.br_brandid__c = brBrandId;
        rec.br_brandname__c = brBrandName;
        rec.br_relationtype__c = brRelationType;
        rec.br_relationstatus__c = brRelationStatus;
		rec.cr_channelid__c = crChannelId;
        rec.cr_channelname__c = crChannelName;
        rec.cr_registrationdate__c = crRegDate;
        rec.cr_sampleproductid__c = sampleProductId;
		rec.addr_country__c = addrCountry;
        rec.addr_streetline1__c = addrStreet;
		rec.addr_city__c = addrCity;
        rec.contact_lastname__c = contactLastName;
		rec.contact_mobilephone__c = contactPhone;
		rec.contact_email__c = contactEmail;
		return rec;
	}
    
    public static Case createCall(String status, Id accId, Id conId, Id callRegId, String subject, Id campaignId, String callType, Id channelId, String market){
        Id caseCallId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordtypeId = caseCallId;
        newCase.Status = status;
        newCase.AccountId = accId;
        newCase.ContactId = conId;
        newCase.CallRegarding__c = callRegId;
        newCase.Subject = subject;
        newCase.Campaign__c = campaignId;
        newCase.CallType__c = callType;
        newCase.Channel__c = channelId;
        newCase.Market__c = market;
        insert newCase;
        return newCase;
    }
}