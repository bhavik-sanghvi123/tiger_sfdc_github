// for deletion
public class OrderTriggerBatch {} /* implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT ID, ParentMembership__c,OrderedBy__c, Status '                           
            + ' FROM Order'
            + ' WHERE'
            + ' createddate > 2020-06-18T10:00:00Z and createddate <= 2020-06-19T23:00:00Z'
            + ' AND (Createdby.Name = \'Data Migration\' OR Createdby.Name = \'Data Integration\')';
        return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Order> scope) {
   		Set<Id> conIdSet = new Set<Id>();
        Set<Id> membershipIdSet = new Set<Id>();
        Set<Id> oldMembershipIdSet = new Set<Id>();
        Set<Id> endDateUpdateMembershipIsSet = new Set<Id>();
        String orderStatus;

   		for(Order o : scope) {
   			if(o.ParentMembership__c != null) {
                membershipIdSet.add(o.ParentMembership__c);
            }

            if(o.OrderedBy__c != null && o.Status == CommonConstant.ORDER_STATUS_COMPLETED) {
                conIdSet.add(o.OrderedBy__c);
            }
   		}

   		if (!conIdSet.isEmpty()) {
	   		List<Contact> contactToUpdateList = [Select Id, FirstTransactionDate__c, LatestTransactionDate__c, MembershipStartDate__c, 
	                                             (Select EndDate From Orders__r Where EndDate != null AND Status =: CommonConstant.ORDER_STATUS_COMPLETED
	                                              order by EndDate) 
	                                             From Contact Where Id IN : conIdSet];                                          
	        for (Contact con : contactToUpdateList) {             

	            if (con.Orders__r.isEmpty()) {                               
	                con.FirstTransactionDate__c = null;
	                con.LatestTransactionDate__c = null;
	            } else {
	                //refresh the date        
	                con.FirstTransactionDate__c = null;
	                con.LatestTransactionDate__c = null;
	                
	                for(Order order : con.Orders__r) {
	                    //update loyalty - US-0492
	                    if (con.MembershipStartDate__c == null) {
	                        //MembershipStartDate__c should only be populated with the first completed order
	                        //if MembershipStartDate__c is null it means there is no order with completed status
	                        //if the code execute this function it means the con.Orders__r should only have 1 record
	                        con.MembershipStartDate__c = order.EndDate;
	                    }

	                    if (con.FirstTransactionDate__c == null) {
	                        con.FirstTransactionDate__c = order.EndDate;
	                        con.LatestTransactionDate__c = order.EndDate;
	                    } else {
	                        con.FirstTransactionDate__c = con.FirstTransactionDate__c > order.EndDate ? order.EndDate : con.FirstTransactionDate__c;
	                        con.LatestTransactionDate__c = con.LatestTransactionDate__c < order.EndDate ? order.EndDate : con.LatestTransactionDate__c;
	                    }
	                }
	            }
	        }

	        if (!contactToUpdateList.isEmpty()) {
	            //update contactToUpdateList;
	            Database.DMLOptions dml = new Database.DMLOptions();
	            dml.DuplicateRuleHeader.allowSave = true;
	            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
	        
	            List<Database.SaveResult> sr = Database.update(contactToUpdateList, dml);
        	}
    	}

    	if(!membershipIdSet.isEmpty()) {
            updateMembershipDetails(membershipIdSet);
        }

        orderCount(scope);
        updateBrandRelationship(scope);
	
	}

	public static void updateMembershipDetails(Set<Id> membershipIdSet) {
        List<Membership__c> membershipList = new List<Membership__c>();
        for(Membership__c mem : [SELECT NumberOfDaysDormant__c, NumberOfTransactions__c, MembershipStartDate__c,
                                    (SELECT EndDate From Orders__r WHERE Status != 'Cancelled - New Order Created' AND Status != 'Cancelled - Before Delivery' AND Status != 'Cancelled - Upon Delivery' AND Status != 'Cancelled - Abandoned' 
                                    ORDER BY EndDate DESC LIMIT 1) 
                                    FROM Membership__c
                                    WHERE Id IN :membershipIdSet]) {

            mem.NumberOfTransactions__c = 0;

            if(!mem.Orders__r.isEmpty()) {
            	mem.NumberOfTransactions__c = mem.Orders__r.size();

                for(Order order : mem.Orders__r) {                	

                    if(order.EndDate != null) {
                        if(order.EndDate == Date.valueOf(System.today())) {
                            mem.NumberOfDaysDormant__c = 0;    
                        } else {
                            mem.NumberOfDaysDormant__c = order.EndDate.daysBetween(System.today());
                        }

                        if(mem.NumberOfDaysDormant__c >= 90) {
                            mem.Status__c = CommonConstant.MEMBERSHIP_STATUS_EXPIRED;
                            mem.MembershipExpiryDate__c = order.EndDate.addDays(90);
                        }
                    }
                }
            } else {
                if(mem.MembershipStartDate__c != null) {
                    if(mem.MembershipStartDate__c == Date.valueOf(System.today())) {
                        mem.NumberOfDaysDormant__c = 0;    
                    } else {
                        mem.NumberOfDaysDormant__c = mem.MembershipStartDate__c.daysBetween(System.today());
                    }

                    if(mem.NumberOfDaysDormant__c >= 90) {
                        mem.Status__c = CommonConstant.MEMBERSHIP_STATUS_EXPIRED;
                        mem.MembershipExpiryDate__c = mem.MembershipStartDate__c.addDays(90);
                    }
                }
            }

            if (mem.NumberOfDaysDormant__c < 0) {
                mem.NumberOfDaysDormant__c = 0;
            }

            membershipList.add(mem);
        }

        if(!membershipList.isEmpty()) {
        	update membershipList;
        }
    }

    public static void orderCount(List<Order> orderList) {
        set<id> caseId = new set<id>();
        
        For(Order o: [Select Id, Case__c, Order_Number_Formula__c, ParentMembership__c From order where id in: orderList]) {
            caseId.add(o.Case__c);
        }
        
        Map<Id, Case> caseMaptoUpdate = new Map<Id, Case>();
        for(Case c : [Select Id, Order__c, RecordType.Name From Case Where Recordtype.Name = 'Call' AND id in: caseId]) {
            caseMaptoUpdate.put(c.id, c);
        }
        
        system.debug(caseMaptoUpdate);
        
        for(AggregateResult result:[Select SUM(Order_Number_Formula__c) Qty, Case__c getId From Order Where Case__c in: caseMaptoUpdate.keyset() GROUP by Case__c]) {
            String parentId = (String)result.get('getId');
            Case cas = caseMaptoUpdate.get(parentId);
            Decimal totalQuantity = (decimal)result.get('Qty');
            cas.Order_Count__c = totalQuantity;
            caseMaptoUpdate.put(parentId,cas);
        }
        system.debug(caseMaptoUpdate.values());
        database.update(caseMaptoUpdate.values());
    }

    public static void updateBrandRelationship(List<Order> orderList) {
        Set<Id> conIdSet = new Set<Id>();
        Map<String, String> orderContactMap = new Map<String, String>();
        
        for(Order o : orderList) {           
            if ( o.OrderedBy__c != null && o.Status == CommonConstant.ORDER_STATUS_COMPLETED) {
                conIdSet.add(o.OrderedBy__c);
                orderContactMap.put(o.Id , o.OrderedBy__c);
            }            
        }
        
        if (!conIdSet.isEmpty()) {

        	Map<String, Set<String>> contactProductMap = new Map<String, Set<String>>();
	        for (OrderItem oItem : [Select Product2.KeyBrand__c,OrderId From OrderItem Where OrderId IN: orderContactMap.keySet() ]) {
	            String contactId = orderContactMap.get(oItem.OrderId);
	            if (contactProductMap.containsKey(contactId)) {
	                Set<String> currentBrand = contactProductMap.get(contactId);
	                currentBrand.add(oItem.Product2.KeyBrand__c);
	                contactProductMap.put(contactId, currentBrand);
	            } else {
	                contactProductMap.put(contactId, new Set<String>{ oItem.Product2.KeyBrand__c });
	            }            
	        }
	        
	        List<BrandRelationship__c> toUpdateBrand = new List<BrandRelationship__c>();
	        
	        for (Contact con : [Select Id, (Select Id, KeyBrand__c, Status__c, Type__c, WinBack__c From BrandRelationships__r) From Contact Where Id in :conIdSet]) {
	            Set<String> productBrand = contactProductMap.get(con.Id);
	            for (BrandRelationship__c brand : con.BrandRelationships__r) {
	                if (productBrand.contains(brand.KeyBrand__c)) {
	                    if (brand.Type__c == CommonConstant.BRAND_TYPE_LEAD) {
	                        brand.Type__c = CommonConstant.BRAND_TYPE_USER;
	                        brand.Status__c = CommonConstant.BRAND_STATUS_NEW;
	                        toUpdateBrand.add(brand);
	                    } else if (brand.Type__c ==  CommonConstant.BRAND_TYPE_USER && brand.Status__c == CommonConstant.BRAND_STATUS_LAPSED) {
	                        brand.Status__c = CommonConstant.BRAND_STATUS_EXISTING;
	                        brand.WinBack__c = true;
	                        toUpdateBrand.add(brand);
	                    }
	                }
	            }
	            
	        } 
	        System.debug(toUpdateBrand);
	        if(!toUpdateBrand.isEmpty()) {
	            //update toUpdateBrand;
	            Database.DMLOptions dml = new Database.DMLOptions();
	            dml.DuplicateRuleHeader.allowSave = true;
	            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
	        
	            List<Database.SaveResult> sr = Database.update(toUpdateBrand, dml);
	        }

        }        
    }
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}*/