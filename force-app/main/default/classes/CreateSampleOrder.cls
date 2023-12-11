public class CreateSampleOrder {
     
    public static void executeSampleCreation(List<ChannelResponse__c> newList) {            
        List<AffiliateMetadata__mdt> am = [Select MasterLabel, SampleRequestPricebook__c , PeriodtRequest__c, MilkCodeRestrictionPeriod__c
                                            From AffiliateMetadata__mdt Where SampleRequestPricebook__c != null];
        List<Product2> stgProdList = [SELECT Id, Stage1PaidSample__c, Stage3PaidSample__c, AvailableForSample__c, IsActive
                                      FROM Product2 
                                      WHERE (Stage1PaidSample__c = TRUE OR Stage3PaidSample__c = TRUE) AND AvailableForSample__c = TRUE AND IsActive = TRUE];

        Map<String, String> affiliatePeriodMap = UtilityClass.convertObjToMap(am, CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_MONTHPERIODREQUEST);        
        Map<String, String> affiliatePricebookMap = UtilityClass.convertObjToMap(am,  CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_SAMPLEPRICEBOOK);
        Map<String, String> affiliateMilkRestriction = UtilityClass.convertObjToMap(am, CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_MILKRESTRICTION);
        Map<String, String> channelMarketMap = new Map<String, String>();
        Set<String> abbottPartnerSet = new Set<String>();
        Map<Id, ChannelResponse__c> channelResponseMap = new Map<Id, ChannelResponse__c>();
        
        Set<Id> orderBySet = new Set<Id>();
        Set<String> pricebookSet = new Set<String>();
        Set<Id> stg1PrdIdSet = new Set<Id>();
        Set<Id> stg3PrdIdSet = new Set<Id>();
        
        if(!stgProdList.isEmpty()) {
            for(Product2 prd : stgProdList) {
                if(prd.Stage1PaidSample__c) {
                    stg1PrdIdSet.add(prd.Id);
                }
                else if(prd.Stage3PaidSample__c) {
                    stg3PrdIdSet.add(prd.Id);
                }
            }
        }

        for(ChannelResponse__c cr : newList) {
            //orderBySet - used in the query to get only order item that belongs to the contact in the list            
            orderBySet.add(cr.BrandRelationship__r.PrimaryContact__c);
            //pricebookSet - in the metadata query to get only related market 
            pricebookSet.add(  affiliatePricebookMap.get(cr.BrandRelationship__r.PrimaryContact__r.Market__c)  );
            //channelMarketMap - used to get the market when the order item is being created, order has no market field
            channelMarketMap.put(cr.Id, cr.BrandRelationship__r.PrimaryContact__r.Market__c);
            abbottPartnerSet.add(cr.PromoterCode__c);
            channelResponseMap.put(cr.Id, cr);
        }  
        if(System.Test.isRunningTest()) { 
            pricebookSet.add('Standard Price Book');
        }
        //check if there are already sample order created on the contact
        List<OrderItem> currentOrderList  = [Select Order.EffectiveDate, Product2Id, OrderId, Product2.ProductCode, Order.OrderedBy__c
                                            From OrderItem where Order.OrderedBy__c IN: orderBySet AND Order.Type IN (:CommonConstant.ORDER_TYPE_SAMPLEREQUEST, :CommonConstant.ORDER_TYPE_OTHER)];

        Map<String, String> chanelProductMap = new Map<String, String>();
        //channelToUpdateList - need to update the channel status
        List<ChannelResponse__c> channelToUpdateList = new List<ChannelResponse__c>();
        List<Order> orderList = new List<Order>();
        //order creation
        Map<String, AbbottPartner__c> abbottPartnerMap = new Map<String, AbbottPartner__c>();
        for(AbbottPartner__c ap : [SELECT Id, External_Id__c FROM AbbottPartner__c WHERE External_Id__c IN: abbottPartnerSet]){
            abbottPartnerMap.put(ap.External_Id__c, ap);
        }
        //get the unit price and pricebook id
        List<PricebookEntry> pricebookentryList = [Select Id, Product2Id, Pricebook2Id, Pricebook2.Market__c, UnitPrice, ProductCode , CurrencyIsoCode
                                                    From PricebookEntry 
                                                    Where Pricebook2.Name IN: pricebookSet AND Product2.IsActive = true AND Product2.AvailableForSample__c = true AND Pricebook2.IsActive = true];
        //Map<market , map<productid, pricebookentry>> pricebookUnitPriceMap
        Map<String, Map<String, PricebookEntry>> pricebookUnitPriceMap = createUnitPriceMap(pricebookentryList);
        //Map<CR ID, cr.br.user__c>
        Map<Id, Id> brandEndUserMap = new Map<Id, Id>();
        Set<String> uniqueOrderSet = new Set<String>();

        for(ChannelResponse__c cr : newList) {
            if ((cr.BrandRelationship__r.PrimaryContact__r.Verified__c && cr.BrandRelationship__r.PrimaryContact__r.Market__c != CommonConstant.MARKET_TW) || cr.BrandRelationship__r.PrimaryContact__r.Market__c == CommonConstant.MARKET_TW) {
                Integer period = 0; 
                if (affiliatePeriodMap.containsKey(cr.BrandRelationship__r.PrimaryContact__r.Market__c)) {
                    period =  Integer.valueOf( affiliatePeriodMap.get(cr.BrandRelationship__r.PrimaryContact__r.Market__c) ); 
                }
                String orderKeyName = cr.BrandRelationship__r.PrimaryContact__c + cr.SampleProductCode__c;

                if (cr.DeliveryAddress__c == null && !cr.SampleGivenOnGround__c) {
                    cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_MISSINGADDRESS;
                    channelToUpdateList.add(cr); 
                } else if(cr.BrandRelationship__r.User__c != null
                          && cr.BrandRelationship__r.User__r.RecordType.DeveloperName == CommonConstant.CONTACT_CHILD_RECORDTYPE
                          && (cr.BrandRelationship__r.PrimaryContact__r.Market__c == 'SG' || cr.BrandRelationship__r.PrimaryContact__r.Market__c == 'TH')
                          && cr.BrandRelationship__r.User__r.MilkCodeRestriction__c == true) { //TKT-001614
                    cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PENDINGMILKCODE;
                    channelToUpdateList.add(cr);
                } else if(!stg1PrdIdSet.isEmpty() && cr.BrandRelationship__r.PrimaryContact__r.Market__c == CommonConstant.MARKET_TW && cr.ProductSampleRequested__r.Stage1PaidSample__c
                          && validateStageProducts(currentOrderList, cr.SampleProductCode__c, cr.BrandRelationship__r.PrimaryContact__c, stg1PrdIdSet)) {
                    cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_INELIGBLE;
                    channelToUpdateList.add(cr);
                } else if(!stg3PrdIdSet.isEmpty() && cr.BrandRelationship__r.PrimaryContact__r.Market__c == CommonConstant.MARKET_TW && cr.ProductSampleRequested__r.Stage3PaidSample__c
                          && validateStageProducts(currentOrderList, cr.SampleProductCode__c, cr.BrandRelationship__r.PrimaryContact__c, stg3PrdIdSet)) {
                    cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_INELIGBLE;
                    channelToUpdateList.add(cr); 
                } else if (validateExistingOrder(currentOrderList,  cr.SampleProductCode__c, cr.BrandRelationship__r.PrimaryContact__c, period, cr.SampleGivenOnGround__c) && !uniqueOrderSet.contains(orderKeyName)) {
                    Order order = new Order();
                    //if product on CR has  Stage3PaidSample__c or Stage1PaidSample__c =true for TW Market,Order Type should be others
                    if((cr.ProductSampleRequested__r.Stage3PaidSample__c || cr.ProductSampleRequested__r.Stage1PaidSample__c) &&  cr.BrandRelationship__r.PrimaryContact__r.Market__c == CommonConstant.MARKET_TW){                        
                        order.Type = CommonConstant.ORDER_TYPE_OTHER; //added by Monika for story 3273
                        order.PaymentMethod__c = CommonConstant.ORDER_PAYMENT_METHOD_CASH; //added by Sean for TKT-005973

                        Date d = Date.today();
                        DateTime dt = (DateTime) d;
                        String day = dt.format('E');
            
                        if(day == 'Fri') {
                            order.PreferredDeliveryDate__c = d.addDays(3);
                        }
                        else if (day == 'Sat') {
                            order.PreferredDeliveryDate__c = d.addDays(2);
                        }
                        else {
                            order.PreferredDeliveryDate__c = d.addDays(1);
                        }
                    }else{
                        order.Type = CommonConstant.ORDER_TYPE_SAMPLEREQUEST; //default logic
                        order.PaymentMethod__c = ''; //added by Sean for TKT-005973
                    }
                    order.EffectiveDate = Date.today();
                    order.OrderedBy__c = cr.BrandRelationship__r.PrimaryContact__c;
                    order.ChannelResponse__c = cr.Id;
                    order.ShippingAddress__c = cr.DeliveryAddress__c;
                    // order.PaymentMethod__c = '';
                    order.RelatedCampaign__c = cr.Campaign__c;
                    order.VAT__c = CommonConstant.ORDER_VAT;//VAT required on order,validation rule
                    //cannot change to another status beside draft because there is no order item in the order
                    order.Status = CommonConstant.ORDER_STATUS_DRAFT;
                    order.CreatedFromCRRecord__c = true;
                    order.Abbott_Partner_Code__c = abbottPartnerMap.containsKey(cr.PromoterCode__c) ? abbottPartnerMap.get(cr.PromoterCode__c).Id : null;
                    order.Abbott_Sales_Person__c = abbottPartnerMap.containsKey(cr.PromoterCode__c) ? abbottPartnerMap.get(cr.PromoterCode__c).Id : null;
                    
                    brandEndUserMap.put(cr.Id, cr.BrandRelationship__r.User__c);
                    if (pricebookUnitPriceMap.containsKey(cr.BrandRelationship__r.PrimaryContact__r.Market__c)) {
                        Map<String, PricebookEntry> pricebookEntryMap = pricebookUnitPriceMap.get(cr.BrandRelationship__r.PrimaryContact__r.Market__c);
                        if (pricebookEntryMap.containsKey(cr.SampleProductCode__c)) {
                            //change from ProductSampleRequested__c to SampleProductCode__c
                            PricebookEntry currentPrice = pricebookEntryMap.get(cr.SampleProductCode__c);

                            order.Pricebook2Id = currentPrice.Pricebook2Id;
                            order.CurrencyIsoCode = currentPrice.CurrencyIsoCode;

                            orderList.add(order);
                            uniqueOrderSet.add(orderKeyName);
                        } else {
                            cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PRODUCTUNAVAILABLE;
                            channelToUpdateList.add(cr); 
                        }
                    } else {
                        cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_PRODUCTUNAVAILABLE;
                        channelToUpdateList.add(cr); 
                    }
                    
                    //the product will be used in creating an order item
                    //we are iterating order and not the channel when creating an order item, not possible to get the product code from the order
                    //change from ProductSampleRequested__c to SampleProductCode__c
                    chanelProductMap.put(cr.Id, cr.SampleProductCode__c);
                } else {
                    cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_INELIGBLE;
                    channelToUpdateList.add(cr); 
                }

           }
        }
        //order product creation
        if(!orderList.isEmpty()) {
            insert orderList;
            List<OrderItem> orderItemList = new List<OrderItem>();
            List<Order> orderToUpdateList = new List<Order>();
            for(Order order : orderList) {
                OrderItem item = new OrderItem();
                item.OrderId = order.Id;
                //item.Product2Id = chanelProductMap.get(order.ChannelResponse__c);
                item.ServiceDate = Date.today();
                item.Quantity = 1;
                //possible multiple market
                String channelMarket = channelMarketMap.get(order.ChannelResponse__c);
                Map<String, PricebookEntry> pricebookEntryMap = pricebookUnitPriceMap.get(channelMarket);
                //chanelProductMap - to get the product code value stored in the channel response record
                PricebookEntry currentPrice = pricebookEntryMap.get(chanelProductMap.get(order.ChannelResponse__c));
                item.PricebookEntryId = currentPrice.Id;
                item.UnitPrice = currentPrice.UnitPrice;                
                item.Category__c = CommonConstant.ORDERITEM_CATEGORY_TRIAL;
                item.OrderedFor__c = brandEndUserMap.get(order.ChannelResponse__c);
                orderItemList.add(item);
                //update the status of the order
                ChannelResponse__c cr = new ChannelResponse__c();
                if(channelResponseMap.get(order.ChannelResponse__c).SampleGivenOnGround__c){
                    order.Status = CommonConstant.ORDER_STATUS_SAMPLEGIVENONGROUND;
                    cr.Id = order.ChannelResponse__c;
                    cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_SUCCESSFULSAMPLEGIVENONGROUND;
                }
                else{
                    order.Status = CommonConstant.ORDER_STATUS_SUBMITTED;
                    cr.Id = order.ChannelResponse__c;
                    cr.OrderCreationStatus__c = CommonConstant.CHANNELRESPONSE_ORDERSTATUS_SUCCESSFUL;
                }
                orderToUpdateList.add(order);
                channelToUpdateList.add(cr);
            }

            if(!orderItemList.isEmpty()) {
                insert orderItemList;
                update orderToUpdateList;
            }
        }  

        if (!channelToUpdateList.isEmpty()) {
            update channelToUpdateList;
        }
    }
    
    public static Map<String, Map<String, PricebookEntry>> createUnitPriceMap(List<PricebookEntry> priceBookList) {
        Map<String, Map<String, PricebookEntry>> priceMap = new Map<String, Map<String, PricebookEntry>>();
        for (PricebookEntry entry : priceBookList) {
            if (priceMap.containsKey(entry.Pricebook2.Market__c)) {
                Map<String, PricebookEntry> currentPriceMap = priceMap.get(entry.Pricebook2.Market__c);
                //change from Product2Id to ProductCode
                currentPriceMap.put(entry.ProductCode, entry);
            } else {
                Map<String, PricebookEntry> currentPriceMap = new Map<String, PricebookEntry>();
                //change from Product2Id to ProductCode
                currentPriceMap.put(entry.ProductCode, entry);
                priceMap.put(entry.Pricebook2.Market__c, currentPriceMap);
            }
        }
        return priceMap;
    }

    public static Boolean validateExistingOrder(List<OrderItem> orderItemList, String productCode, Id orderBy, Integer validMonths, Boolean isSampleGivenOnGround) {
        Boolean isValid = true;
        if(!isSampleGivenOnGround){
            for (OrderItem item : orderItemList) {
                if (item.Product2.ProductCode == productCode && item.Order.OrderedBy__c ==  orderBy && item.Order.EffectiveDate.addMonths(validMonths) >= Date.today()){
                    isValid = false;
                }
            }
        }

        return isValid;
    }
    
    public static Boolean validateStageProducts (List<OrderItem> orderItemList, String productCode, Id orderBy, Set<Id> stgPrdIdSet) {
        Boolean isInvalid = false;

        if(!orderItemList.isEmpty()) {
            for (OrderItem item : orderItemList) {
                if(stgPrdIdSet.contains(item.Product2Id) && item.Product2.ProductCode == productCode && item.Order.OrderedBy__c ==  orderBy) {
                    isInvalid = true;
                }
            }
        }

        return isInvalid;
    }
}