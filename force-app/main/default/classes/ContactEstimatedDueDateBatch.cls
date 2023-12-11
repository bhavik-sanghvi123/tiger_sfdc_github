/**
* @author        Rey Austral
* @date          1.14.2019
* @description   Batch job to run daily to create child record in the contact
* @revision(s)
                 1.30.2019 - update estimated due date to null 
                 1.31.2019 - add milk code restriction field
                 5.27.2019 - change the condition of the main query to include also record that has been created before
                 8.11.2020 - TKT-002360 exclude VN on clearing EDD
                 3.20.2023 - TKT-012178 For SG - create BR upon creation of child EDD
*/
global class ContactEstimatedDueDateBatch Implements Database.Batchable<sObject> {
    
    //TKT-012178 - Product to be used for child EDD
    Product2 simMomChildProduct = [SELECT Id FROM Product2 WHERE ExternalId__c =: System.Label.ContactEDDBatch_Product AND Market__c = 'SG' AND IsActive = true][0];

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID , EstimatedDueDate__c, AccountId, OwnerId'                           
            + ' FROM Contact'
            + ' WHERE'
            + ' EstimatedDueDate__c <= TODAY'
            + ' AND PrimaryContact__c = true'
            + ' AND Market__c != \'TW\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> lScope = [SELECT ID , EstimatedDueDate__c, AccountId, Account.Market__c, OwnerId, Market__c, (Select Id, Birthdate from Parents__r) 
                                FROM Contact Where ID IN: scope];

        List<Contact> toInsert = new List<Contact>();
        List<BrandRelationship__c> brToInsert = new List<BrandRelationship__c>();
        Map<String, String> accountMarketMap = new Map<String, String>();

        Id childRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CommonConstant.CONTACT_CHILD_RECORDTYPE).getRecordTypeId();
        for(Contact con : lScope) {
            //TKT-012178 - Map for getting Market from Account
            if(con.AccountId != null && con.Account.Market__c != null && !accountMarketMap.containsKey(con.AccountId)){
                accountMarketMap.put(con.AccountId, con.Account.Market__c);
            }

            if (con.Parents__r.isEmpty()) {           
                Contact childContact = createChild(con, childRecordTypeId);
                toInsert.add(childContact);
            } else {
                //Nemo can create the child even if the child has not been born
                //check if there is already existing child with the birthdate is the same as the estimateduedate
                Boolean existingChild = false;
                for (Contact child : con.Parents__r) {
                    if (child.Birthdate == con.EstimatedDueDate__c) {
                        existingChild = true;
                    }
                }
                //only create a child if no existing child found
                if (existingChild == false) {
                    Contact childContact = createChild(con, childRecordTypeId);
                    toInsert.add(childContact);
                }
            }
            //estimated due date will still be updated even if no child was created
            //dont clear EDD for VN Contacts with 40 weeks milestone
            if(con.Market__c != 'VN'){
                con.EstimatedDueDate__c = null;
            }
        }

        if (!toInsert.isEmpty()) {
            Insert toInsert;

            //TKT-012178 -Logic for SG Contact EDD - insert new Child BR
            for(Contact createdChild : toInsert){
                if(accountMarketMap.get(createdChild.AccountId) == 'SG'){
                    BrandRelationship__c childBR = createBR(createdChild);
                    brToInsert.add(childBR);
                }
            }
            if(!brToInsert.isEmpty()){
                insert brToInsert;
            }
        }        

        if (!lScope.isEmpty()) {
            // Update lScope;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(lScope, dml);
        }
    }

    public Contact createChild(Contact con, String childRecordTypeId) {
        Contact childContact = new Contact();
        childContact.AccountId = con.AccountId;
        childContact.Birthdate = con.EstimatedDueDate__c;
        childContact.LastName = CommonConstant.CONTACT_CHILD_LASTNAME;
        childContact.Type__c = CommonConstant.CONTACT_CHILD_TYPE;
        childContact.RecordTypeId = childRecordTypeId;
        childContact.Parent__c = con.Id;
        childContact.MilkCodeRestriction__c = true;
        childContact.EstimatedBirthdate__c = con.EstimatedDueDate__c;
        childContact.OwnerId = con.OwnerId;

        return childContact;
    }

    //TKT-012178 - Child EDD BR mapping
    public BrandRelationship__c createBR(Contact child) {
        BrandRelationship__c br = new BrandRelationship__c();
        br.BrandRelationship__c = simMomChildProduct.Id;
        br.PrimaryContact__c = child.Parent__c;
        br.Household__c = child.AccountId;
        br.User__c = child.Id;
        br.Type__c = 'Lead';
        br.Status__c = 'Uncontacted';
        br.Active__c = true;
        
        return br;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}