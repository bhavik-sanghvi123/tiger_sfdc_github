/**
* @author        Rey Austral
* @date          7.23.2019
* @description   Class to execute batch job BrandNewRegistrationBatch
* @testClass     BrandNewRegistrationBatchTest
* @revision(s) 
*/
global class BrandNewRegistrationBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        if(AffiliateMetadata__mdt.getInstance('ANZ').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchANZ = new BrandNewRegistrationBatch('ANZ', '', AffiliateMetadata__mdt.getInstance('ANZ').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchANZ, 1000);
        }
        if(AffiliateMetadata__mdt.getInstance('ID').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchID = new BrandNewRegistrationBatch('ID', '', AffiliateMetadata__mdt.getInstance('ID').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchID, 1000);
        }
        if(AffiliateMetadata__mdt.getInstance('IN').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchIN = new BrandNewRegistrationBatch('IN', '', AffiliateMetadata__mdt.getInstance('IN').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchIN, 1000);
        }
        if(AffiliateMetadata__mdt.getInstance('MY').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchMY = new BrandNewRegistrationBatch('MY', '', AffiliateMetadata__mdt.getInstance('MY').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchMY, 1000);
        }
        if(AffiliateMetadata__mdt.getInstance('PH').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchPH = new BrandNewRegistrationBatch('PH', '', AffiliateMetadata__mdt.getInstance('PH').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchPH, 1000);
        }
        if(AffiliateMetadata__mdt.getInstance('SG').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchSG = new BrandNewRegistrationBatch('SG', '', AffiliateMetadata__mdt.getInstance('SG').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchSG, 1000);
        }
        if(AffiliateMetadata__mdt.getInstance('TH').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchTH = new BrandNewRegistrationBatch('TH', '', AffiliateMetadata__mdt.getInstance('TH').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchTH, 1000);
        }
        if(AffiliateMetadata__mdt.getInstance('TW').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchTW = new BrandNewRegistrationBatch('TW', '', AffiliateMetadata__mdt.getInstance('TW').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchTW, 1000);
        }
        if(AffiliateMetadata__mdt.getInstance('VN').BrandNewRegistrationInterval__c != null){
            BrandNewRegistrationBatch batchVN = new BrandNewRegistrationBatch('VN', '', AffiliateMetadata__mdt.getInstance('VN').BrandNewRegistrationInterval__c.intValue());
            database.executebatch(batchVN, 1000);
        }
    }
}