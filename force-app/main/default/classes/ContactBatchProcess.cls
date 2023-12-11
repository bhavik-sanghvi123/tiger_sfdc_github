/*----------------------------------------------------------------------------------------
* Script to Enable Milk Restriction Code on Contact
-------------------------------------------------------------------------------------------*/
// for deletion
global class ContactBatchProcess {} /* implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,'
                            + ' AccountId,'
                            + ' Birthdate,'
                            + ' MilkCodeRestriction__c,'
                            + ' Market__c'
                            + ' FROM Contact WHERE Type__c = \'Child\' AND Birthdate != null AND ContactBatchProcessed__c = FALSE'
                            + ' ORDER BY AccountId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<AffiliateMetadata__mdt> amList = [SELECT MasterLabel, MilkCodeRestrictionPeriod__c FROM AffiliateMetadata__mdt];
        Map<String, String> acs = UtilityClass.convertObjToMap(amList, CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_MILKRESTRICTION);
        List<Contact> contactList = new List<Contact>();

        for(Contact con : scope) {
            if(acs.containsKey(con.Market__c)) {
                String settings = acs.get(con.Market__c);
                Date computedDate = con.Birthdate.addMonths(Integer.valueOf(settings));

                if (Date.Today() >= con.Birthdate && Date.Today() <= computedDate) {
                    con.MilkCodeRestriction__c = true;
                } 
            }

            con.ContactBatchProcessed__c = TRUE;
            contactList.add(con);
        }

        Database.update(contactList, false);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}*/