/**
* @author        Jennifer Alviz
* @date          8.11.2020
* @description   Batch job to run daily to clear EDD on VN Contacts passed due date, MC has a trigger for 40 Weeks milestone, so need to retain EDD
* @revision(s)

4.6.2021    malviz  - TKT-003681: Clear latest milestone on related BR
9.9.2021	malviz	- TKT-005612: Remove Primary Contact filter
*/
global class ContactEstimatedDueDateBatch_VN Implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID , EstimatedDueDate__c, AccountId, OwnerId'                           
            + ' FROM Contact'
            + ' WHERE'
            + ' EstimatedDueDate__c < TODAY'
            + ' AND WeeksOfPregnancy__c > 40'
            + ' AND Market__c = \'VN\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> lScope = [SELECT ID , EstimatedDueDate__c, Market__c
                                FROM Contact Where ID IN: scope];

        List<BrandRelationship__c> brToUpdate = new List<BrandRelationship__c>();
        Set<Id> conIds = new Set<Id>();

        for(Contact con : lScope) {

            //clear EDD for VN Contacts with more than 40 weeks milestone
            con.EstimatedDueDate__c = null;
            conIds.add(con.Id);
        }

        for(BrandRelationship__c br : [SELECT Id, LatestMilestone__c, MilestoneStatus__c FROM BrandRelationship__c WHERE User__c in :conIds]){
            Boolean toUpdate = false;
            if(br.LatestMilestone__c != null){
                br.LatestMilestone__c = null;
                br.MilestoneStatus__c = null;
                toUpdate = true;
            }
            if(toUpdate) brToUpdate.add(br);
        }


        if (!lScope.isEmpty()) {
            // Update lScope;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(lScope, dml);
        }

        if (!brToUpdate.isEmpty()){
            UtilityClass.updateList(brToUpdate);
        }
    }

    
    global void finish(Database.BatchableContext BC) {
    }
}