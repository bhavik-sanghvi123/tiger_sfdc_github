// for deletion
public class OrderProductBatch {} /* implements Database.Batchable<sObject> {
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT ID , PromotionItem__c, Promotion__c'                           
            + ' FROM OrderItem'
            + ' WHERE'
            + ' (CreatedDate = TODAY OR CreatedDate = YESTERDAY)';
        return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<OrderItem> scope) {
		Set<Id> promoItedIdSet = new Set<Id>();
        List<OrderItem> orderItemList =  new List<OrderItem>();
        for(OrderItem oi : scope) {
            if(oi.PromotionItem__c != null) {
                promoItedIdSet.add(oi.PromotionItem__c);
                orderItemList.add(oi);
            }
        }
        
        if (!promoItedIdSet.isEmpty()) {
        	Map<Id,PromotionItem__c> promoItemMap = new Map<Id,PromotionItem__c>([Select Promotion__c
                                                            FROM PromotionItem__c
                                                            WHERE Id IN :promoItedIdSet ]);

        	for(OrderItem oi : orderItemList) {
	            if(promoItemMap.containsKey(oi.PromotionItem__c)) {
	                oi.Promotion__c = promoItemMap.get(oi.PromotionItem__c).Promotion__c;
	            }
        	}

        	Update orderItemList;
        }
 
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}*/