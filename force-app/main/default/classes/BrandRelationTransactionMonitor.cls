public class BrandRelationTransactionMonitor implements Database.Batchable<sObject>  {

    private Boolean isHourly = true;
    public BrandRelationTransactionMonitor(Boolean i) {
        isHourly = i;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        String status = CommonConstant.ORDER_STATUS_COMPLETED;
        DateTime last2hours = Datetime.now().addhours(-2);
        String query = 'SELECT ParentId,Field,OldValue,NewValue FROM ChannelResponse__History WHERE CreatedDate >: minute15';
        String queryStr = 'SELECT Order.EndDate, Order.OrderedBy__c, Product2.BrandRelationshipLink__c'
                        + ' FROM OrderItem'
                        + ' WHERE Order.Status =: status'
                        + ' AND BrandRelationshipLinkStatus__c = false'
                        + ' AND Product2.BrandRelationshipLink__c != null';

        // will be used to run hourly
        if(isHourly) {
            queryStr += ' AND Order.LastModifiedDate >: last2hours';
        }

        queryStr += ' ORDER BY CreatedDate DESC';

        if(Test.isRunningTest()){
            queryStr = 'SELECT Order.EndDate, Order.OrderedBy__c, Product2.BrandRelationshipLink__c, BrandRelationshipLinkStatus__c'
                        + ' FROM OrderItem'
                        + ' WHERE Order.Status =: status';
        }

        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext BC, List<OrderItem> oiList){
        
        Set<Id> conIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        // create map of contact and product
        Map<String, List<OrderItem>> contactProductMap = new Map<String, List<OrderItem>>();
        for(OrderItem oi: oiList){
            String key = oi.Order.OrderedBy__c + '-' + oi.Product2.BrandRelationshipLink__c;
            if(!contactProductMap.containsKey(key)){
                contactProductMap.put(key, new List<OrderItem>());
            }
            contactProductMap.get(key).add(oi);

            conIds.add(oi.Order.OrderedBy__c);
            productIds.add(oi.Product2.BrandRelationshipLink__c);
        }

        Map<Id, OrderItem> oiListForUpdate = new Map<Id, OrderItem>();
        Map<Id, BrandRelationship__c> brList = new Map<Id, BrandRelationship__c>();
        for(BrandRelationship__c br: [SELECT FirstTransactionDate__c, LatestTransactionDate__c, PrimaryContact__c, BrandRelationship__c
                                        FROM BrandRelationship__c
                                       WHERE PrimaryContact__c IN: conIds
                                         AND BrandRelationship__c IN: productIds]){
            Boolean forUpdate = false;                                             
            String key = br.PrimaryContact__c + '-' + br.BrandRelationship__c;
            if(contactProductMap.containsKey(key)){
                for(OrderItem oi: contactProductMap.get(key)){

                    // check first transaction date
                    if(br.FirstTransactionDate__c == null
                        || (br.FirstTransactionDate__c != null 
                            && br.FirstTransactionDate__c > oi.Order.EndDate)){
                        br.FirstTransactionDate__c = oi.Order.EndDate;
                        forUpdate = true;
                    }

                    // check latest transaction date
                    if(br.LatestTransactionDate__c == null
                        || (br.LatestTransactionDate__c != null 
                            && br.LatestTransactionDate__c < oi.Order.EndDate)
                        ){
                        br.LatestTransactionDate__c = oi.Order.EndDate;
                        forUpdate = true;
                    }

                    // update order item to prcessed
                    oi.BrandRelationshipLinkStatus__c = true;
                    oiListForUpdate.put(oi.Id, oi);
                }
            }

            if(forUpdate) brList.put(br.Id, br);
        }

        if(!oiListForUpdate.isEmpty()) UtilityClass.updateList(oiListForUpdate.values());
        if(!brList.isEmpty()) UtilityClass.updateList(brList.values());
    }
    
    public void finish(Database.BatchableContext BC){}
}