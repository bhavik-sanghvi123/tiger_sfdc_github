/*
Author: Frank Gomendoza
Description: Batch class for copying Membership details to Contact
*/
global class ContactMembershipBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    public static Map<String, String> brandCodeMap = new Map<String, String>{'92221' => 'Ensure', '92222' => 'Glucerna', '92224' => 'Pediasure', '92225' => 'Similac'};
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String contactAdultRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Adult').getRecordTypeId();
        String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate, Contact__c, MembershipExpiryDate__c, MembershipId__c, MembershipStartDate__c, NumberOfDaysDormant__c, '
            + 'NumberOfTransactions__c, Status__c, SourceCreatedDate__c, Integration_Src__c, Recent_Product_Purchased__c, Membership_Type__c '
            + 'FROM Membership__c '
            + 'WHERE Contact__c != null AND Contact__r.Market__c = \'PH\' AND Contact__r.Active__c = true AND Contact__r.RecordTypeId =: contactAdultRectypeId AND MembershipId__c != null '
            + 'ORDER BY Contact__c ASC';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Membership__c> scope) {
        if(!scope.isEmpty()){
            Map<Id, Map<String, Membership__c>> brandMembershipMap = new Map<Id, Map<String, Membership__c>>();
            Set<Id> conIdSet = new Set<Id>();
            List<Membership__c> membershipList = new List<Membership__c>();
            Map<Id, Contact> conUpdateMap = new Map<Id, Contact>();  
            
            for(Membership__c newMem : scope){
                membershipList.add(newMem);
                conIdSet.add(newMem.Contact__c);
            }
            for(Membership__c existingMem : [SELECT Id, MembershipId__c, NumberOfDaysDormant__c, NumberOfTransactions__c, MembershipStartDate__c, Contact__c, Status__c, Recent_Product_Purchased__c, CreatedDate FROM Membership__c WHERE Contact__c IN : conIdSet AND Id NOT IN: scope AND MembershipId__c != null]){
                membershipList.add(existingMem);
            }
            for(Membership__c member : membershipList){
                brandMembershipMap = MembershipTriggerHelper.createBrandMembershipMap(brandMembershipMap, member);
            }
            
            for(Membership__c mem : membershipList){
                String rawMembershipId = mem.MembershipId__c.replaceAll('(\\s+)', '');
                String brand = brandCodeMap.get(rawMembershipId.left(5));
                if(brandMembershipMap.containsKey(mem.Contact__c)){
                    if(brandMembershipMap.get(mem.Contact__c).containsKey(brand)){
                        Membership__c brandMem = brandMembershipMap.get(mem.Contact__c).get(brand);
                        conUpdateMap = MembershipTriggerHelper.processContactUpdateMap(brandMem, brand);
                    }
                }
            }
            
            if(!conUpdateMap.keySet().isEmpty()){
                update conUpdateMap.values();
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
    }
    
    global void execute(SchedulableContext sc) {
        ContactMembershipBatch batch = new ContactMembershipBatch(); 
        Database.executebatch(batch, 30);
    }
}