/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Batch Class to update Campaign Status depending on the Status, Start Date,
                End Date and Approval Status value.

History
06/25/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
global class ProcessSampleOrderBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, BrandRelationship__r.PrimaryContact__c, BrandRelationship__r.PrimaryContact__r.Verified__c, ProductSampleRequested__r.KeyBrand__c, '
            + 'DeliveryAddress__c, Campaign__c, OrderCreationStatus__c , SampleProductCode__c, ProductSampleRequested__c, BrandRelationship__r.User__r.AgeinMonths__c, '
            + 'BrandRelationship__r.User__r.RecordType.DeveloperName, BrandRelationship__r.PrimaryContact__r.Market__c, BrandRelationship__r.User__c,BrandRelationship__r.User__r.MilkCodeRestriction__c, '
            + 'ProductSampleRequested__r.Stage1PaidSample__c, ProductSampleRequested__r.Stage3PaidSample__c, PromoterCode__c, SampleGivenOnGround__c '
            + 'From ChannelResponse__c Where '
            + '( (IsSample_Requested__c = true AND SampleGivenOnGround__c = false) OR (IsSample_Requested__c = false AND SampleGivenOnGround__c = true) ) AND '
            + '( DeliveryAddress__c != null OR SampleGivenOnGround__c = true ) AND '
            + 'Contact__r.Verified__c = true AND '
            + '(OrderCreationStatus__c = \'Pending - Milk Code Restriction\' OR OrderCreationStatus__c = \'Pending\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ChannelResponse__c> scope) {
        System.debug('scope---'+scope);
    	if(scope != null) {
            CreateSampleOrder.executeSampleCreation(scope);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}