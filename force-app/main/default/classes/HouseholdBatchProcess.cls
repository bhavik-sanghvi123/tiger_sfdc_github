/*----------------------------------------------------------------------------------------
* Script to calcute Household tracking fields in Household which are as follows:
*   - Number of Primary Contacts
*   - Number of Children
*   - Number of Household Members
*   - Number of Adults
-------------------------------------------------------------------------------------------*/

global class HouseholdBatchProcess implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,'
                            + ' AccountId,'
                            + ' PrimaryContact__c,'
                            + ' Type__c,'
                            + ' HouseholdBatchProcessed__c,'
                            + ' Email,'
                            + ' Phone,'
                            + ' FirstName,'
                            + ' LastName,'
                            + ' MilkCodeRestriction__c'
                            + ' FROM Contact WHERE AccountId != null AND HouseholdBatchProcessed__c = FALSE'
                            + ' ORDER BY AccountId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        Set<Id> accIdSet = new Set<Id>();
        List<Contact> processedContactList = new List<Contact>();

        for(Contact con : scope) {
            if(con.AccountId != null) {
                accIdSet.add(con.AccountId);
            }
        }

        Map<Id,Account> accMap = new Map<Id,Account>([SELECT NumberOfHouseholdMembers__c, NumberOfPrimaryContacts__c, 
                                                    NumberOfAdults__c, NumberOfChildren__c,ChildrenUnderMilkCodeRestriction__c,
                                                    PrimaryContact__c, PrimaryContactEmail__c, PrimaryContactPhone__c
                                                    FROM Account 
                                                    WHERE Id IN :accIdSet]);

        for(Contact con : scope) {
            if(accMap.containsKey(con.AccountId)) {
                accMap.get(con.AccountId).NumberOfHouseholdMembers__c = accMap.get(con.AccountId).NumberOfHouseholdMembers__c == null ? 0 : accMap.get(con.AccountId).NumberOfHouseholdMembers__c;
                accMap.get(con.AccountId).NumberOfPrimaryContacts__c = accMap.get(con.AccountId).NumberOfPrimaryContacts__c == null ? 0 : accMap.get(con.AccountId).NumberOfPrimaryContacts__c;
                accMap.get(con.AccountId).NumberOfAdults__c = accMap.get(con.AccountId).NumberOfAdults__c == null ? 0 : accMap.get(con.AccountId).NumberOfAdults__c;
                accMap.get(con.AccountId).NumberOfChildren__c = accMap.get(con.AccountId).NumberOfChildren__c == null ? 0 : accMap.get(con.AccountId).NumberOfChildren__c;
                accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c = accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c == null ? 0 : accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c;
                String firstName = (con.FirstName == null || con.FirstName == '') ? '' : con.FirstName + ' ';
                String lastName = (con.LastName == null || con.LastName == '') ? '' : con.LastName;
                
                accMap.get(con.AccountId).NumberOfHouseholdMembers__c++;

                if(con.PrimaryContact__c == TRUE) {
                    accMap.get(con.AccountId).NumberOfPrimaryContacts__c++;
                    accMap.get(con.AccountId).PrimaryContact__c = firstName + lastName;
                    
                    if(con.Email != null) {
                        accMap.get(con.AccountId).PrimaryContactEmail__c = con.Email;
                    }

                    if(con.Phone != null) {
                        accMap.get(con.AccountId).PrimaryContactPhone__c = con.Phone;
                    }
                }   
                
                if(con.MilkCodeRestriction__c == TRUE) {
                    accMap.get(con.AccountId).ChildrenUnderMilkCodeRestriction__c++;
                }

                if(con.Type__c == 'Adult') {
                    accMap.get(con.AccountId).NumberOfAdults__c++;
                }
                
                else if(con.Type__c == 'Child') {
                    accMap.get(con.AccountId).NumberOfChildren__c++;
                }
                
                con.HouseholdBatchProcessed__c = TRUE;
                accMap.put(con.AccountId, accMap.get(con.AccountId));
                processedContactList.add(con);
            }   
        }

        Database.update(accMap.values(), false);
        Database.update(processedContactList, false);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}