// for deletion
global class SampleOrderCleanupBatch {} /* implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, RegistrationDate__c, SampleProductCode__c, BrandRelationship__c,OrderCreationStatus__c '         
            + 'From ChannelResponse__c Where LastModifiedDate = TODAY and ProductSampleRequested__c != null order by BrandRelationship__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ChannelResponse__c> scope) {
    	if(scope != null) {
            
            Set<Id> brIds = new Set<Id>();

            List<ChannelResponse__c> toDeteleCR = new List<ChannelResponse__c>();
            for (ChannelResponse__c cr : scope) {     
                brIds.add(cr.BrandRelationship__c);
            }

            Map<Id, BrandRelationship__c> brMap = new Map<Id, BrandRelationship__c>([Select Id, PrimaryContact__c,KeyBrand__c,                                                                                      
                                                                                     (Select RegistrationDate__c, SampleProductCode__c, OrderCreationStatus__c,BrandRelationship__c
                                                                                      From Channel_Responses__r Order By RegistrationDate__c,Name asc )
                                                                                     From BrandRelationship__c Where Id IN: brIds]);

            for (BrandRelationship__c br : brMap.values()) {
                Integer crSize = br.Channel_Responses__r.size();
                if (crSize > 1) {
                    Set<String> uniqueCR = new Set<String>();
                    List<ChannelResponse__c> crIneligbleList = new List<ChannelResponse__c>();
                    for (ChannelResponse__c cr : br.Channel_Responses__r) {
                        String keyName = cr.SampleProductCode__c + cr.RegistrationDate__c + cr.OrderCreationStatus__c;
                        if (uniqueCR.contains(keyName)) {
                            toDeteleCR.add(cr);
                        } else {
                            uniqueCR.add(keyName);
                            if (cr.OrderCreationStatus__c == CommonConstant.CHANNELRESPONSE_ORDERSTATUS_INELIGBLE) {
                                crIneligbleList.add(cr);
                            }
                        }
                    }
                    for (ChannelResponse__c cr : crIneligbleList) {
                        String keyName = cr.SampleProductCode__c + cr.RegistrationDate__c + CommonConstant.CHANNELRESPONSE_ORDERSTATUS_SUCCESSFUL;
                        if (uniqueCR.contains(keyName)) {
                            toDeteleCR.add(cr);
                        }
                    }
                }
            }
            if(!toDeteleCR.isEmpty()) {
                List<Order> toDeleteOrder = [Select Id,Status from Order where ChannelResponse__c in: toDeteleCR];
                if (toDeleteOrder.size() != 0) {
                    for (Order o: toDeleteOrder) {
                        o.Status = 'Draft';
                    }
                    Update toDeleteOrder;
                    Delete toDeleteOrder;
                }                
                Delete toDeteleCR;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
} */