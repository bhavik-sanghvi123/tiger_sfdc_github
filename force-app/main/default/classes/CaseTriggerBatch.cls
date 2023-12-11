// for deletion
public class CaseTriggerBatch {} /* implements Database.Batchable<sObject> {
	
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT ID,  RecordTypeId, CallCompletedDate__c, ContactId'                           
            + ' FROM Case'
            + ' WHERE'
            + ' RecordType.Name = \'Call\''
            + ' AND lastmodifieddate = LAST_N_DAYS:2'
            + ' AND Createdby.Name = \'Data Migration\'';
        if(System.Test.isRunningTest()) { 
            query = 'SELECT ID,  RecordTypeId, CallCompletedDate__c, ContactId'                           
            + ' FROM Case'
            + ' WHERE'
            + ' RecordType.Name = \'Call\''
            + ' AND createdDate > 2019-06-07T10:00:00Z and createdDate <= 2019-06-10T23:00:00Z'
            + ' AND (Createdby.Name = \'Data Migration\' OR Createdby.Name = \'Data Integration\')';
        }
        return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Case> scope) {
   		//Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();

   		Map<Id, Case> conCaseFirstMap = new Map<Id, Case>();
        Map<Id, Case> conCaseLastMap = new Map<Id, Case>();
        Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();

		for(Case caseRec : scope) {
                // Process only Calls where Call Completed Date is not blank
        	if(caseRec.CallCompletedDate__c != null) {
                // Put Call Completed Date in a map where the Key is the Contact and the value is the oldest Completed Call
            	if(!conCaseFirstMap.containsKey(caseRec.ContactId)) {
                    conCaseFirstMap.put(caseRec.ContactId, caseRec);
                } else {
                    Case currentOldestCall = conCaseFirstMap.get(caseRec.ContactId);
                    if(caseRec.CallCompletedDate__c < currentOldestCall.CallCompletedDate__c) {
                        conCaseFirstMap.put(caseRec.ContactId, caseRec);
                    }
                }
                // Put Call Completed Date in a map where the Key is the Contact and the value is the lates Completed Call
                if(!conCaseLastMap.containsKey(caseRec.ContactId)) {
                    conCaseLastMap.put(caseRec.ContactId, caseRec);
                } else {
                    Case currentOldestCall = conCaseLastMap.get(caseRec.ContactId);
                    if(caseRec.CallCompletedDate__c > currentOldestCall.CallCompletedDate__c) {
                        conCaseLastMap.put(caseRec.ContactId, caseRec);
                    }
                }
        	}   
        }

        if(!conCaseFirstMap.isEmpty()) {
            for(Contact conRec : [select Id, FirstCallDate__c, FirstCall__c from Contact where Id in :conCaseFirstMap.keySet()]) {
                if(conCaseFirstMap.containsKey(conRec.Id)) {
                    if(conRec.FirstCallDate__c != null && conCaseFirstMap.get(conRec.Id).CallCompletedDate__c < conRec.FirstCallDate__c) {
                    	conRec.FirstCallDate__c = conCaseFirstMap.get(conRec.Id).CallCompletedDate__c;
                        conRec.FirstCall__c = conCaseFirstMap.get(conRec.Id).Id;
                        if(contactToUpdateMap.containsKey(conRec.Id)) {
                            contactToUpdateMap.get(conRec.Id).FirstCallDate__c = conRec.FirstCallDate__c;
                            contactToUpdateMap.get(conRec.Id).FirstCall__c = conRec.FirstCall__c;
                        } else {
                        	contactToUpdateMap.put(conRec.Id, conRec);   
                        }
                    } else if(conRec.FirstCallDate__c == null) { conRec.FirstCallDate__c = conCaseFirstMap.get(conRec.Id).CallCompletedDate__c;  conRec.FirstCall__c = conCaseFirstMap.get(conRec.Id).Id;
                    	if(contactToUpdateMap.containsKey(conRec.Id)) {  contactToUpdateMap.get(conRec.Id).FirstCallDate__c = conRec.FirstCallDate__c;  contactToUpdateMap.get(conRec.Id).FirstCall__c = conRec.FirstCall__c;
                        } else {	contactToUpdateMap.put(conRec.Id, conRec);              }
                    }
                }
            }
        }
        // Process all Contacts where the Last Calls needs to be updated
        if(!conCaseLastMap.isEmpty()) {
            for(Contact conRec : [select Id, LastCallDate__c, LatestCall__c from Contact where Id in :conCaseLastMap.keySet()]) {
                if(conCaseLastMap.containsKey(conRec.Id)) {
                    if(conRec.LastCallDate__c != null && conCaseLastMap.get(conRec.Id).CallCompletedDate__c > conRec.LastCallDate__c) {
                    	conRec.LastCallDate__c = conCaseLastMap.get(conRec.Id).CallCompletedDate__c;
                        conRec.LatestCall__c = conCaseLastMap.get(conRec.Id).Id;
                    	if(contactToUpdateMap.containsKey(conRec.Id)) {  contactToUpdateMap.get(conRec.Id).LastCallDate__c = conRec.LastCallDate__c; contactToUpdateMap.get(conRec.Id).LatestCall__c = conRec.LatestCall__c;
                        } else { contactToUpdateMap.put(conRec.Id, conRec); }
                    } else if(conRec.LastCallDate__c == null) {     conRec.LastCallDate__c = conCaseLastMap.get(conRec.Id).CallCompletedDate__c;  conRec.LatestCall__c = conCaseLastMap.get(conRec.Id).Id;
                    	if(contactToUpdateMap.containsKey(conRec.Id)) {
                            contactToUpdateMap.get(conRec.Id).LastCallDate__c = conRec.LastCallDate__c;  contactToUpdateMap.get(conRec.Id).LatestCall__c = conRec.LatestCall__c;
                        } else { contactToUpdateMap.put(conRec.Id, conRec); }
                    }
                }
            }
        }
        // Update Contacts
        if(!contactToUpdateMap.isEmpty()) {
            //update contactToUpdateMap.values();

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        
            List<Database.SaveResult> sr = Database.update(contactToUpdateMap.values(), dml);
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
} */