public class CreateOrderFromContactController {
    
    public class ContactForOrder {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public Integer age;
        @AuraEnabled public String market;
        @AuraEnabled public String addressId;
        @AuraEnabled public String defaultAddress;
        @AuraEnabled public String campaignNames;
        @AuraEnabled public String householdId;
        @AuraEnabled public String recordUrl;
        @AuraEnabled public Id orderId;
        @AuraEnabled public Id pricebookId;
        
    }
    
    public class CreateOrderElements {
        @AuraEnabled public List<ContactForOrder> contactList;
        @AuraEnabled public List<String> marketValues;
    }
    
    @AuraEnabled
    public static CreateOrderElements pageOnInit (String brName, Integer mainAge, String mainMarket, Integer endAge, String endMarket, String campId, String crName) {
        CreateOrderElements elem = new CreateOrderElements();
        elem.contactList = fetchContacts(brName, mainAge, mainMarket, endAge, endMarket, campId, crName);
        elem.marketValues = fetchMarketValues();
        return elem;
    }
    
    @AuraEnabled
    public static CreateOrderElements getMarketVal () {
        CreateOrderElements elem = new CreateOrderElements();
        elem.marketValues = fetchMarketValues();
        return elem;
    }
    
    @AuraEnabled
    public static List<ContactForOrder> getContacts (String brName, Integer mainAge, String mainMarket, Integer endAge, String endMarket, String campId, String crName) {
        return fetchContacts(brName, mainAge, mainMarket, endAge, endMarket, campId, crName);
    }
    
    @AuraEnabled
    public static List<ContactForOrder> createOrder (String orderVal,  List<Object> conObj) {

        Order newOrder = (Order)JSON.deserialize(orderVal, Order.class);
        List<Order> orderToIns = new List<Order>();
            
        Map<Id, ContactForOrder> conOrderMap = new Map<Id, ContactForOrder>();
        for (Object con : conObj) {
            Map<Object, Object> conMap = (Map<Object, Object>)con;
            Order ord               = newOrder.clone();
            ord.AccountId           = (Id) conMap.get('householdId');
            ord.OrderedBy__c        = (Id) conMap.get('id');
            ord.ShippingAddress__c  = (Id) conMap.get('addressId');
            orderToIns.add(ord);
            
            ContactForOrder conOrder = new ContactForOrder();
            conOrder.id             = (Id) conMap.get('id');
            conOrder.name           = (String) conMap.get('name');
            conOrder.age            = Integer.valueOf(conMap.get('age'));
            conOrder.market         = (String) conMap.get('market');
            conOrder.householdId    = (String) conMap.get('householdId');
            conOrder.addressId      = (String) conMap.get('addressId');
            conOrder.defaultAddress = (String) conMap.get('defaultAddress');
            conOrder.campaignNames  = (String) conMap.get('campaignNames');
            conOrder.recordUrl      = (String) conMap.get('recordUrl');
            conOrderMap.put((Id)conMap.get('id'), conOrder);
        }
        
        //Database.insert(orderToIns, false);
        insert orderToIns;
        
        List<ContactForOrder> conList = new List<ContactForOrder>();
        for (Order o : [SELECT Id, OrderedBy__c, Pricebook2Id FROM Order WHERE Id IN :orderToIns]) {
            ContactForOrder con = conOrderMap.get(o.OrderedBy__c);
            con.orderId = o.Id;
            con.pricebookId = o.Pricebook2Id;
            conList.add(con);
        }
        
        return conList;
    }
    
    @AuraEnabled
    public static void createOrderProd (String orderProdVal, List<Object> conObj) {
        
		OrderItem newOrdProd = (OrderItem)JSON.deserialize(orderProdVal, OrderItem.class);
        
		Id pricebookId 		= (Id) ((Map<Object, Object>)conObj[0]).get('pricebookId');
        PricebookEntry pb 	= [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :newOrdProd.Product2Id AND Pricebook2Id = :pricebookId LIMIT 1];
            
        List<OrderItem> itemToIns = new List<OrderItem>();
        for (Object con : conObj) {
            Map<Object, Object> conMap = (Map<Object, Object>)con;
            OrderItem ordItem = newOrdProd.clone();
            ordItem.PricebookEntryId = pb.Id;
            ordItem.OrderId = (Id) conMap.get('orderId');
            ordItem.UnitPrice = pb.UnitPrice;
			//ordItem.Quantity = 1;
            itemToIns.add(ordItem);
        }
        
        //Database.insert(itemToIns, false);
        insert itemToIns;
    }
    
    private static List<ContactForOrder> fetchContacts (String brName, Integer mainAge, String mainMarket, Integer endAge, String endMarket, String campId, String crName) {
        
        List<ContactForOrder> conList = new List<ContactForOrder>();
        Set<Id> householdIdList = new Set<Id>();
        Set<Id> disContact = new Set<Id>();
        
        String brQuery = createQuery(brName, mainAge, mainMarket, endAge, endMarket, campId, crName);
        for (BrandRelationship__c br : Database.query(brQuery)) {
            
            ContactForOrder con;
            if (!disContact.contains(br.PrimaryContact__c) && (campId == '' || (campId != '' && br.Channel_Responses__r.size() > 0))) {
                con	= new ContactForOrder();
                con.id 				= br.PrimaryContact__c;
                con.name 			= br.PrimaryContact__r.Name;
                con.age 			= Integer.valueOf(br.PrimaryContact__r.Age__c);
                con.market 			= br.PrimaryContact__r.Market__c;
                con.householdId 	= br.PrimaryContact__r.AccountId;
                con.recordUrl		= '/' + br.PrimaryContact__c;
                
                disContact.add(br.PrimaryContact__c);
                householdIdList.add(br.PrimaryContact__r.AccountId);
            }
            
            if (con != NULL) {
                String campaignName = '';
                for (ChannelResponse__c ch : br.Channel_Responses__r) {
                    campaignName += campaignName != '' ? ', ' : '';
                    campaignName += ch.Campaign__c != NULL ? ch.Campaign__r.Name : '';
                }
                
                con.campaignNames = campaignName;
                conList.add(con);
            }
        }
        
        Map<Id, Address__c> householdAddressMap = new Map<Id, Address__c>();
        for (Address__c add : [SELECT Id, FullAddress__c, ParentHousehold__c FROM Address__c WHERE ParentHousehold__c IN :householdIdList AND DefaultAddress__c = TRUE]) {
            householdAddressMap.put(add.ParentHousehold__c, add);
        }
        
        List<ContactForOrder> newConList = new List<ContactForOrder>();
        for (ContactForOrder con : conList) {
            if (householdAddressMap.containsKey(con.householdId)) {
                ContactForOrder newCon 	= con;
                newCon.addressId 		= householdAddressMap.get(con.householdId).Id;
                newCon.defaultAddress 	= householdAddressMap.get(con.householdId).FullAddress__c;
                newConList.add(newCon);
            }
        }
        
		return newConList;
    }
    
    private static List<String> fetchMarketValues () {
		Schema.DescribeFieldResult fieldResult = ACcount.Market__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<String> pickListValuesList= new List<String>();
		for(Schema.PicklistEntry pickListVal : ple) {
			pickListValuesList.add(pickListVal.getLabel());
		}
        
		return pickListValuesList;
    }
    
    private static String createQuery (String brName, Integer mainAge, String mainMarket, Integer endAge, String endMarket, String campId, String crName) {
        
        String query = 'SELECT Id, PrimaryContact__c, PrimaryContact__r.RecordType.Name, PrimaryContact__r.Name, PrimaryContact__r.Age__c, PrimaryContact__r.Market__c, PrimaryContact__r.AccountId';
        query += ', (SELECT Campaign__c, Campaign__r.Name FROM Channel_Responses__r';
        query += campId != NULL && campId != '' ? ' WHERE Campaign__c = \'' + campId + '\') ' : ') '; 
        query += 'FROM BrandRelationship__c WHERE ';
        
        String whereCls = '';        
        whereCls += brName != NULL && brName != '' ? 'BrandRelationship__r.Name LIKE \'%' + brName + '%\'' : '';
        if(brName != NULL && brName != ''){
            whereCls += crName != NULL && crName != '' ? ' AND Name LIKE \'%' + crName + '%\'' : '';
        }else{
            whereCls += crName != NULL && crName != '' ? 'Name LIKE \'%' + crName + '%\'' : '';
        }
        whereCls += mainAge != NULL ? whereCls != '' ? ' AND PrimaryContact__r.Age__c = :mainAge' : 'PrimaryContact__r.Age__c = :mainAge' : '';
        whereCls += mainMarket != NULL && mainMarket != '' ? whereCls != '' ? ' AND PrimaryContact__r.Market__c = :mainMarket' : 'PrimaryContact__r.Market__c = :mainMarket' : '';
        whereCls += endAge != NULL ? whereCls != '' ? ' AND User__r.AgeinMonths__c = :endAge' : 'User__r.AgeinMonths__c = :endAge' : '';
        whereCls += endMarket != NULL && endMarket != '' ? whereCls != '' ? ' AND User__r.Market__c = :endMarket' : 'User__r.Market__c = :endMarket' : '';
        whereCls += whereCls != '' ? ' AND PrimaryContact__r.RecordType.Name = \'Adult\' LIMIT 50000' : 'PrimaryContact__r.RecordType.Name = \'Adult\' LIMIT 50000';
        
        return query + whereCls;
    }
    
}