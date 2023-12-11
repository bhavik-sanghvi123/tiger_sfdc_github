public class NewOrderController {
    @AuraEnabled
    public static String createNewOrder(String caseId, String contactId, String sObjectName) {    
        
        Order newOrder = new Order();

        newOrder.EffectiveDate = Date.Today();
        newOrder.Status = CommonConstant.ORDER_STATUS_DRAFT;
        newOrder.PaymentMethod__c = CommonConstant.ORDER_PAYMENT_METHOD_CASH;

        if(sObjectName == CommonConstant.CASE_OBJECT) {
            Case caseRec = [SELECT Id, AccountId, Origin, ContactId, CallType__c FROM Case WHERE Id =: caseId];

            if(caseRec.CallType__c == CommonConstant.CASE_CALL_TYPE_INBOUND) {
                newOrder.Type = CommonConstant.ORDER_TYPE_TELESALES_INBOUND;
            }
            else if (caseRec.CallType__c == CommonConstant.CASE_CALL_TYPE_OUTBOUND) {
                newOrder.Type = CommonConstant.ORDER_TYPE_TELESALES_OUTBOUND;
            }
            else {
                newOrder.Type = CommonConstant.ORDER_TYPE_OTHER;
            }

            newOrder.AccountId =  caseRec.AccountId;
            newOrder.OrderedBy__c = caseRec.ContactId;
            newOrder.Case__c = caseId;
        }

        else if(sObjectName == CommonConstant.CONTACT_OBJECT) {
            Contact conRec = [SELECT Id, AccountId, Market__c FROM Contact WHERE Id =: contactId];
        
            newOrder.AccountId = conRec.AccountId;
            newOrder.OrderedBy__c = contactId;
            if(conRec.Market__c == 'SG'){
                newOrder.Type = CommonConstant.ORDER_TYPE_TELESALES_OUTBOUND;
            }
            else{
                newOrder.Type = CommonConstant.ORDER_TYPE_OTHER;
            }
        }

        newOrder.CreatedFromNewOrderButton__c = true;

        insert newOrder;
        system.debug(newOrder);
        return newOrder.Id;      
    }

    @AuraEnabled
    public static String saveUpdatedOrderDetails(String orderId, String typeValue, String paymentMethodValue, String orderNotesValue) {
       
        Order orderRec = new Order();
        orderRec.Id = orderId;
        orderRec.Type = typeValue;
        orderRec.PaymentMethod__c = paymentMethodValue;
        orderRec.OrderNotes__c = orderNotesValue;

        update orderRec;
        return orderRec.Id;
    }

    @AuraEnabled
    public static String fetchUser() {
        String userMarket;
        User currentUser = [SELECT Id, UserRole.Name FROM User WHERE Id =: userInfo.getUserId()];

        if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_MALAYSIA) {
            userMarket = CommonConstant.MARKET_MY;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_PHILIPPINES) {
            userMarket = CommonConstant.MARKET_PH;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_SINGAPORE) {
            userMarket = CommonConstant.MARKET_SG;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_THAILAND) {
            userMarket = CommonConstant.MARKET_TH;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_VIETNAM) {
            userMarket = CommonConstant.MARKET_VN;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_INDIA) {
            userMarket = CommonConstant.MARKET_IN;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_ANZ) {
            userMarket = CommonConstant.MARKET_ANZ;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_INDONESIA) {
            userMarket = CommonConstant.MARKET_ID;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_TAIWAN) {
            userMarket = CommonConstant.MARKET_TW;
        } else if(currentUser.UserRole.Name == CommonConstant.USER_ROLE_ASEAPAC) {
            userMarket = CommonConstant.MARKET_ASEAPAC;
        }

        return userMarket;
    }

    // Start Marlon
    @AuraEnabled
    public static String fetchContact(String conId) {
        String contactMarket = '';
        if(conId != '') {
            Contact conRec = [SELECT Id, Market__c FROM Contact WHERE Id =: conId];
            contactMarket = conRec.Market__c;
        }

        return contactMarket;
    }
    // End Marlon

    @AuraEnabled
    public static List<sObject> lookupRecord(String searchKeyWord, String objName) {
        String userMarket = fetchUser();
        List<Pricebook2> returnList = new List<Pricebook2>();

        if(objName == CommonConstant.PRICEBOOK_OBJECT) {
            returnList = [SELECT Id, Name, DiscountPercentage__c, ExclusiveOfGST__c, GSTRate__c FROM Pricebook2 WHERE IsActive = TRUE AND Market__c =: userMarket];
        }

        return returnList;
    }

    @AuraEnabled
    public static sObject getDefaultPricebook(String objName, Boolean isSample, String conId) {
        String userMarket = fetchUser();
        Pricebook2 defaultPricebook;
        if(!isSample) {
            if(objName == CommonConstant.PRICEBOOK_OBJECT) {
                defaultPricebook = [SELECT Id, Name, DiscountPercentage__c, ExclusiveOfGST__c, GSTRate__c FROM Pricebook2 WHERE IsActive = TRUE AND Market__c =: userMarket AND DefaultForTelesales__c = TRUE];
            }
        } else {
            String contactMarket = fetchContact(conId);
            List<AffiliateMetadata__mdt> amRec = new List<AffiliateMetadata__mdt>();
            String pricebookName = '';

            if(contactMarket != '') {
                amRec = [select Id, SampleRequestPricebook__c from AffiliateMetadata__mdt where MasterLabel = :contactMarket];
                
                if(!amRec.isEmpty() && amRec[0].SampleRequestPricebook__c != null) {
                    pricebookName = amRec[0].SampleRequestPricebook__c;
                    
                    defaultPricebook = [select Id, Name, DiscountPercentage__c, ExclusiveOfGST__c, GSTRate__c from Pricebook2 where IsActive = true and Name = :pricebookName];
                }
            }
        }
        return defaultPricebook;
    }

    @AuraEnabled
    public static List<sObject> fetchLookupValues(String pricebookId, String householdId, String objName, String contactId, String searchKey, String productId) {
        Set<Id> prodIds = new Set<Id>();
        List<sObject> returnList = new List<sObject>();
        String searchInput = String.isBlank(searchKey) ? '%%' : '%'+String.escapeSingleQuotes(searchKey.trim())+'%';

        if(objName == CommonConstant.PRODUCT_OBJECT) {
            List<PricebookEntry> pbeList = [SELECT Id, Name, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id =: pricebookId AND isActive = TRUE];

            if(!pbeList.isEmpty()) {
                for(PricebookEntry pbe : pbeList) {
                    prodIds.add(pbe.Product2Id);
                }
            }

            if(!prodIds.isEmpty()) {
                if(searchKey == null || searchKey == '') {
                    returnList = [SELECT Id, Name, RecordType.Name, ProductCode FROM Product2 WHERE Id IN: prodIds AND AvailableForOrder__c = TRUE AND IsActive = TRUE ORDER BY Name];
                } else {
                    returnList = [SELECT Id, Name, RecordType.Name, ProductCode FROM Product2 WHERE Id IN: prodIds AND AvailableForOrder__c = TRUE AND IsActive = TRUE AND (Name LIKE :searchInput OR ProductCode LIKE :searchInput) ORDER BY Name];
                }
            }

        }  

        else if(objName == CommonConstant.CONTACT_OBJECT) {    
            String query = 'SELECT Id, Name, Birthdate FROM Contact WHERE AccountId = \'' +String.escapeSingleQuotes(householdId)+ '\'';
            if(String.isNotBlank(searchKey) ){
                query += ' AND Name LIKE \'' +String.escapeSingleQuotes(searchInput)+ '\'';
            }
            if(String.isNotBlank(productId) ){
                Product2 p = [SELECT Id, Min_Birth_Month__c, Max_Birth_Month__c FROM Product2 WHERE Id =: productId];
                if(p.Min_Birth_Month__c != null){
                    query += ' AND AgeinMonths__c >= ' +p.Min_Birth_Month__c;
                }
                if(p.Max_Birth_Month__c != null){
                    query += ' AND AgeinMonths__c <= ' +p.Max_Birth_Month__c;
                }
            }
            returnList = Database.query(query);
        }
        
        else if(objName == CommonConstant.CHANNEL_OBJECT) {
            if(searchKey == null || searchKey == '') {
                returnList = [SELECT Id, Name, Market__c FROM Channel__c WHERE Market__c = :CommonConstant.MARKET_SG];
            }
            else {
                returnList = [SELECT Id, Name, Market__c FROM Channel__c WHERE Market__c = :CommonConstant.MARKET_SG AND Name LIKE :searchInput];   
            }
        }
        
        else if(objName == CommonConstant.ADRESS_OBJECT) {
            returnList = [SELECT Id, Name, Street1__c, Street2__c, City2__c, 
                          Country__c, FullAddress__c, PostalCode__c, StateProvince__c,
                          Ward2__c, District__c, Region__c,DefaultAddress__c, SubDistrict__c, 
                          Building__c, Road__c, VillageNo__c, VillageName__c,
                          State__c, SuburbTown__c
                          FROM Address__c WHERE ParentContact__c =: contactId];
        }
        return returnList;
    }

    @AuraEnabled
    public static PricebookEntry getPricebookEntryDetails(String pricebookId, String productId) {
        PricebookEntry pbe = [SELECT Id, Name, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id =: pricebookId AND Product2Id =: productId];
        return pbe;
    }

    @AuraEnabled
    public static List<Promotion__c> getRelatedPromotion(String promoName) {
        String userMarket = fetchUser();
        String promoFilter = promoName + '%';
        List<Promotion__c> promotionList = new List<Promotion__c>();
        
        if(promoName != '' && promoName != null) {
            promotionList = [SELECT Id, Name, Market__c, Status__c, StartDate__c
                                                    FROM Promotion__c 
                                                    WHERE Market__c =: userMarket 
                                                    AND Status__c =: CommonConstant.PROMOTION_STATUS_INPROGRESS
                                                    AND StartDate__c < TODAY AND Name LIKE :promoFilter];
        } else {
            promotionList = [SELECT Id, Name, Market__c, Status__c, StartDate__c
                                                    FROM Promotion__c 
                                                    WHERE Market__c =: userMarket 
                                                    AND Status__c =: CommonConstant.PROMOTION_STATUS_INPROGRESS
                                                    AND StartDate__c < TODAY];
        }
        return promotionList;
    }

    @AuraEnabled
    public static List<PromotionItem__c> getRelatedPromotionItems(String promotionId) {
        List<PromotionItem__c> promotionItemList = [SELECT Id, Name, PromotionPrice__c, Product__c, Product__r.Name, DefaultOrderQuantity__c, 
                                                        Promotion__r.Name, Product__r.ProductCode
                                                    FROM PromotionItem__c 
                                                    WHERE Promotion__c =: promotionId];
        return promotionItemList;
    }
    
    @AuraEnabled
    public static Order getOrderRecord(String orderId) {
        Order orderRecord  = [SELECT Id, Case__c, AccountId, OrderNumber, Type, PaymentMethod__c, Status, EffectiveDate,OrderedBy__c FROM Order WHERE Id =: orderId];
        return orderRecord;
    }
    
    @AuraEnabled
    public static void updateOrder(String orderID, String orderCancelReason) {        
        Order orderRec = new Order();
        orderRec.Id = orderID;
        orderRec.OrderCacellationReason__c = orderCancelReason;
        orderRec.Status = CommonConstant.ORDER_STATUS_CANCELLED_ABANDONED;
		orderRec.EndDate = System.today();

        update orderRec;
    }

    @AuraEnabled
    public static void submitOrder(String orderParameter , List<OrderItem> orderItemList) {
        try {
           
            SumarryWrapper param = (SumarryWrapper)JSON.deserialize(orderParameter, SumarryWrapper.class);
            Map<String, String> productEntryMap = new Map<String, String>();
            String currencyCode;
            for (PricebookEntry entry : [SELECT Id, Name, Product2Id, Pricebook2Id, UnitPrice, CurrencyIsoCode FROM PricebookEntry WHERE Pricebook2Id =: param.pricebook]) {     
                //get only one           
                currencyCode =  entry.CurrencyIsoCode;
                productEntryMap.put(entry.Product2Id, entry.Id);
            }

            if(param.updateAddress) {
                upsert param.addressRec;
                param.deliveryAddress = param.addressRec.Id;
            }

            Order orders = new Order();
            orders.Id = param.orderId;
            orders.Pricebook2Id = param.pricebook;
            orders.CurrencyIsoCode = currencyCode;
            Update orders;

            system.debug(productEntryMap);
            for (OrderItem item : orderItemList) {                                
                item.PricebookEntryId = productEntryMap.get(item.Product2Id);
                //item.Product2Id = null;
            }
            System.debug(orderItemList);
            Insert orderItemList;

            
            orders.PaymentMethod__c = param.paymentMethod;
            orders.ShippingAddress__c = param.deliveryAddress;
            orders.RelatedCampaign__c = param.campaign == '' ? null : param.campaign;
            orders.Channel__c = param.channel == '' ? null : param.channel;
            orders.OrderNotes__c = param.notes;
            orders.PreferredDeliveryDate__c  = param.deliveryDate;
            orders.PreferredDeliveryTime__c  = param.deliveryTime;
            orders.TotalDiscountAmount__c = param.totalDiscount;
            orders.TotalGSTAmount__c = param.totalGST;
            orders.Status = CommonConstant.ORDER_STATUS_SUBMITTED;
            orders.Vat__c = param.vatValue; // Sean Cordova
            orders.TaxId__c = param.taxIDValue; // Sean Cordova
            orders.TaxName__c = param.taxNameValue; // Sean Cordova
            orders.Abbott_Partner_Code__c = param.abbottPartnerCodeValue; // Sean Cordova
            orders.Abbott_Sales_Person__c = param.abbottSalesPersonValue; // Sean Cordova
            orders.Description = param.description; // Sean Cordova
            
            Update orders;
        } catch(DmlException dex) {
            throw new AuraHandledException(dex.getDmlMessage(0));
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }   

    @AuraEnabled
    public static List<Address__c> getDefaultAddress(String contactId) {
        return [Select Id, Name, Street1__c, Street2__c, City2__c, Country__c, FullAddress__c, UnitNumber__c, PostalCode__c, StateProvince__c,
                            Ward2__c, District__c, Region__c, DefaultAddress__c, SubDistrict__c, Building__c, Road__c, VillageNo__c, VillageName__c,
                			State__c, SuburbTown__c
                			from Address__c Where ParentContact__c =:contactId and DefaultAddress__c = true];
    }

    @AuraEnabled
    public static List<Address__c> getHouseholdAddress(String householdId) {
        return [Select Id, Name, FullAddress__c, ParentContact__r.Name, DefaultAddress__c, Street1__c, Street2__c, City2__c, 
                            Country__c,  PostalCode__c, StateProvince__c, Ward2__c, District__c, Region__c, SubDistrict__c, 
                			Building__c, Road__c, VillageNo__c, VillageName__c, State__c, SuburbTown__c
                			from Address__c Where ParentHousehold__c =: householdId];
    }

    @AuraEnabled
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Address__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }

    @AuraEnabled
    public static Map<String,String> getPickListValuesPreferredDeliveryTime(String userMarket){
        Map<String,String> pickListValuesMap= new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Order.PreferredDeliveryTime__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            String apiName = pickListVal.getValue();
            if(userMarket == 'SG'){
                if(apiName.startsWith('SG_')){
                    pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
                }
            }
            else{
                if(!apiName.startsWith('SG_')){
                    pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
                }
            }
        }
        return pickListValuesMap;
    }
    
    @AuraEnabled
    public static String getMarket(String contactId){
        string marketValue;
        string market;
        for(Contact getMarket : [Select Market__c From Contact Where Id =:contactId]) {
            market = getMarket.Market__c;
        }
        if(market == 'VN') {
            marketValue = 'Vietnam';
        } else if (market == 'MY') {
            marketValue = 'Malaysia';
        } else if (market == 'SG') {
            marketValue = 'Singapore';
        } else if (market == 'PH') {
            marketValue = 'Philippines';
        } else if(market == 'TH') {
            marketValue = 'Thailand';
        } else if(market == 'IN') {
            marketValue = 'India';
        } else if(market == 'ANZ') {
            marketValue = 'ANZ';
        } else if(market == 'Indonesia') {
            marketValue = 'ID';
        }
        return marketValue;
    }

    @AuraEnabled
    public static String getCaseRecordTypeName(String caseId){
        string caseRecordType = [SELECT Id, RecordType.Name FROM Case WHERE Id = :caseId].RecordType.Name;
        return caseRecordType;
    }

    @AuraEnabled
    public static String checkContactAndHousehold(String caseId){
        String isProceed;
        Case caseRec = [SELECT Id, ContactId, AccountId FROM Case WHERE Id = :caseId];
        if (caseRec.ContactId != null || caseRec.AccountId != null) {
            isProceed = 'false';
        } else {
            isProceed = 'true';
        }
        return isProceed;
    }

    @AuraEnabled
    public static List<PackageItem__c> getPackageItems(String productId) {
        List<PackageItem__c> packageItemList = [SELECT Id, PackageItem__r.Name, ProductCode__c, Quantity__c, ParentPackage__c FROM PackageItem__c WHERE ParentPackage__c =: productId];
        return packageItemList;
    }
    
    /**
    * Get login User details
    **/
    @AuraEnabled
    public static User getLoginUserDetails() {
		User currentUser = [SELECT Id, Market__c FROM User WHERE Id =: userInfo.getUserId()];
		return currentUser;
    }
    
    /**
    * Get Address details (text fields) by making an API Call
    **/
    @AuraEnabled
    public static CommonObjectWrapper.cls_ExperianAddress getAddressDetails(String postalCode, String unitNumber) {
		HttpResponse formatResponse =  ExperianCallout.getInfoFromExternalService(postalCode, unitNumber);
        CommonObjectWrapper.cls_ExperianAddress expAddress = ExperianResponseProcessor.processReponse(formatResponse);    
        return expAddress;
    }

    /**
    * Get Experian token
    **/
    @AuraEnabled
    public static String getExperianToken() {
		String token = [SELECT MasterLabel, DeveloperName, Token__c FROM AuthenticationToken__mdt WHERE DeveloperName = 'Experian_Token'].Token__c; 
        return token;
    }
    
    /**
    * Get Singapore City Affiliate Value
    **/
    @AuraEnabled
    public static String getAffiliateSingaporeCity() {
		Id singaporeId = [SELECT Id FROM Affiliate_Value__c WHERE RecordType.Name = :CommonConstant.AFFILIATE_CITY_RECORDTYPE AND Active__c = TRUE AND Name = 'Singapore' AND Market__c = :CommonConstant.MARKET_SG].Id; 
        return singaporeId;
    }
    
    /**
    * Get Related Campaign's Channel
    **/
    @AuraEnabled
    public static String getChannelRecord(Id campaignId) {
		Id channelId = [SELECT Id, Channel__c FROM Campaign WHERE Id = :campaignId].Channel__c; 
        return channelId;
    }
    
    /**
    * Get Case Details
    **/
    @AuraEnabled
    public static Case getCaseDetails(Id caseId) {
		Case caseRec = [SELECT Id, RelatedCampaign__c, RelatedCampaign__r.Channel__c, CaseNumber, MedicalDiagnosis__c, MedicalDiagnosis__r.Name, RelatedBrandRelationship__c, 
                        RelatedChannelResponse__c, RelatedBrandRelationship__r.BrandRelationship__r.KeyBrand__c, RelatedBrandRelationship__r.BrandRelationship__r.Family,
						Contact.BlacklistedStatus__c
                        FROM Case WHERE Id = :caseId]; 
        return caseRec;
    }

    /**
    * Get Metro Manila City Affiliate Value
    **/
    @AuraEnabled
    public static String getAffiliateCityName(String cityId) {
		String cityName = [SELECT Id,Name FROM Affiliate_Value__c WHERE Id = :cityId].Name; 
        String city;
        if(Label.PH_Cities.containsIgnoreCase(cityName)){
            city = 'Metro Manila';
        }
        return city;
    }

    @AuraEnabled
    public static AbbottPartner__c getAbbottPartnerPartnerDetails(String abbottPartnerId){
        AbbottPartner__c ap = [SELECT Name, PartnerCode__c, PartnerName__c FROM AbbottPartner__c WHERE ID = :abbottPartnerId LIMIT 1];

        return ap;
    }

    @AuraEnabled
    public static String getPricebookName(String pricebookId){
        Pricebook2 pb = [SELECT Name FROM Pricebook2 WHERE ID = :pricebookId LIMIT 1];

        return pb.Name;
    }

    public class SumarryWrapper {
        @AuraEnabled
        public String orderId { get; set; }
        @AuraEnabled
        public String paymentMethod { get; set; }
        @AuraEnabled
        public String deliveryAddress { get; set; }
        @AuraEnabled
        public String campaign { get; set; }
        @AuraEnabled
        public String channel { get; set; }
        @AuraEnabled
        public String notes { get; set; }
        @AuraEnabled
        public Date deliveryDate { get; set; }
        @AuraEnabled
        public String deliveryTime { get; set; }
        @AuraEnabled
        public String pricebook { get; set; }
        @AuraEnabled
        public Decimal totalDiscount { get; set; }
        @AuraEnabled
        public Decimal totalGST { get; set; }
        @AuraEnabled
        public Boolean updateAddress { get; set; }
        @AuraEnabled
        public Address__c addressRec { get; set; }

        //Sean Cordova
        @AuraEnabled
        public String vatValue { get; set; }
        //Sean Cordova
        @AuraEnabled
        public String taxIDValue { get; set; }
        //Sean Cordova
        @AuraEnabled
        public String taxNameValue { get; set; }
        //Sean Cordova
        @AuraEnabled
        public String abbottPartnerCodeValue { get; set; }
        //Sean Cordova
        @AuraEnabled
        public String abbottSalesPersonValue { get; set; }
        //Sean Cordova
        @AuraEnabled
        public String description { get; set; }
    }
}