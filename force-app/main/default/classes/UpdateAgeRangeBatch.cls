/*----------------------------------------------------------------------------------------
Author:      Marlon Ocillos
Description: Batch to update the age range of child contacts
History
11/04/2019   mocillos   Created
-------------------------------------------------------------------------------------------*/
global class UpdateAgeRangeBatch implements Database.Batchable<sObject> {
    
    public static Id childRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Child').getRecordTypeId();
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id, AgeRange__c, Birthdate, AgeRangeUpdatedDate__c from Contact where AgeRange__c != null and (Birthdate != null or AgeRangeUpdatedDate__c != null) and RecordTypeId = \'' + childRTId + '\'';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> consToUpdate = new List<Contact>();
        
        for(Contact conRec : scope) {
            String ageRange;
            if(conRec.Birthdate != null) {
                ageRange = ageRangeValue(conRec.Birthdate.monthsBetween(System.today()));
            } else {
                ageRange = ageRangeValue(conRec.AgeRangeUpdatedDate__c.monthsBetween(System.today()));
            }
            
            if(ageRange != null) {
                if(conRec.AgeRange__c != ageRange) {
                    conRec.AgeRange__c = ageRange;
                    consToUpdate.add(conRec);
                }
            }
        }
        
        if(!consToUpdate.isEmpty()) {
            update consToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public static String ageRangeValue(Integer ageInMonths) {
        String ageRange;
        if(ageInMonths >= 0 && ageInMonths < 6) {
            ageRange = '0-6 Months';
        } else if(ageInMonths >= 6 && ageInMonths < 12) {
            ageRange = '6-12 Months';
        } else if(ageInMonths >= 12 && ageInMonths < 24) {
            ageRange = '1-2 Years';
        } else if(ageInMonths >= 24 && ageInMonths < 36) {
            ageRange = '2-3 Years';
        } else if(ageInMonths >= 36 && ageInMonths < 48) {
            ageRange = '3-4 Years';
        } else if(ageInMonths >= 48 && ageInMonths < 60) {
            ageRange = '4-5 Years';
        } else if(ageInMonths >= 60 && ageInMonths < 72) {
            ageRange = '5-6 Years';
        } else if(ageInMonths >= 72) {
            ageRange = '6 Years and Above';
        }
        return ageRange;
    }
}