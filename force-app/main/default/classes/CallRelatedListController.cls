/**
* @author        Rey Austral
* @date          7.24.2019
* @description   Controller of CallRelatedList (Lightning Component)
* @revision(s) 
*/
public with sharing class CallRelatedListController {
    @AuraEnabled
    public static List<Case> queryCall(Id contactId) {
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        return [Select Id, CaseNumber, Status, CreatedDate, CallOutcome__c, Campaign__r.Name, Campaign__r.Brand__c, CallRegarding__r.Name from Case where RecordTypeId =: callRTId And contactId =: contactId order by CreatedDate desc];
    }
    
    @AuraEnabled
    public static List<Case> getCall(Integer limits , Integer offsets, Id contactId){      
        Integer intlimits = integer.valueof(limits);
        Integer intoffsets = integer.valueof(offsets);
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        return [Select Id, CaseNumber, Status, CreatedDate, CallOutcome__c, Campaign__r.Name, Campaign__r.Brand__c,CallRegarding__r.Name from Case where RecordTypeId =: callRTId And contactId =: contactId order by CreatedDate Limit :intlimits Offset :intoffsets];
    } 
    
    @AuraEnabled
    public static Integer getTotalCount(Id contactId){
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        AggregateResult results = [select  count(Id) total  from Case  where RecordTypeId =: callRTId And contactId =: contactId];
        Integer total =(Integer)results.get('total') ; 
        return total;
    } 
    
    @AuraEnabled
    public static String getCallRecordType(){
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
    }
}