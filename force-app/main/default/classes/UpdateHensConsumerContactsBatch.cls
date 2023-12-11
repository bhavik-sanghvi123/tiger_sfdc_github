/**
* @author        Jennifer Alviz    
* @date          6.3.2021
* @description   Batch job to Update Hens and Consumer indicator on existing ANZ contacts
* @revision(s)

6/10/2021   malviz      One-time use only, commented out entire code
*/

public class UpdateHensConsumerContactsBatch {}/*Implements Database.Batchable<sObject>{
    
    String queryOverride;

    global UpdateHensConsumerContactsBatch(String newScope){
        String queryOverride;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, is_Hens__c, is_Consumer__c, Contact__c,'
            + 'BrandRelationship__r.PrimaryContact__c,BrandRelationship__r.PrimaryContact__r.is_HENS__c,BrandRelationship__r.PrimaryContact__r.is_Consumer__c'                
            + ' FROM ChannelResponse__c'
            + ' WHERE'
            + ' Contact__r.Market__c = \'ANZ\''
            + ' AND (Channel__r.Name = \'HENS\''
            + ' OR Channel__r.Name = \'WEB\''
            + ' OR Channel__r.Name = \'Consumer-Partner\')';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        } 

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ChannelResponse__c> scope) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        for(ChannelResponse__c cr : scope){
            Boolean forUpdate = false; 

            Contact con = contactMap.containsKey(cr.Contact__c) ?
            contactMap.get(cr.Contact__c) :
            new Contact(Id = cr.BrandRelationship__r.PrimaryContact__c,
                        is_Hens__c = cr.BrandRelationship__r.PrimaryContact__r.is_HENS__c,
                        is_Consumer__c = cr.BrandRelationship__r.PrimaryContact__r.is_Consumer__c);

            if(cr.is_Hens__c && !con.is_Hens__c){
                con.is_Hens__c = cr.is_Hens__c;
                forUpdate = true;      
            }
            else if(cr.is_Consumer__c && !con.is_Consumer__c){
                con.is_Consumer__c = cr.is_Consumer__c;
                forUpdate = true;   
            }

            if(forUpdate){  
                contactMap.put(con.Id, con);
            }
        }
        
        if(!contactMap.isEmpty()) UtilityClass.updateList(contactMap.values());
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}*/