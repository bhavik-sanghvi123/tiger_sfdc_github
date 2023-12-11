// for deletion
public class OrderCleanup {} /* implements Database.Batchable<sObject>, Database.Stateful {
    
    User datamigration;
    Id callRecordType;

    public OrderCleanup(){
        String dataStr = Test.isRunningTest() ?  'datamigration@tigerani.abbott.comtest' : 'datamigration@tigerani.abbott.com';
        datamigration = [SELECT Id FROM User WHERE Username =: dataStr];
        callRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String market = 'PH';
        String queryStr = 'SELECT Status, OrderedBy__c'
                        + ' FROM Order'
                        + ' WHERE Account.Market__c =: market';
        if(!Test.isRunningTest()){
            queryStr += ' AND CreatedById =\'' + datamigration.Id + '\'' ;
        }
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Order> orderList){

        Set<Id> contactIds = new Set<Id>();
        for(Order o: orderList){
            o.Type = 'Trade';
            if(o.Status == 'Draft') {
                o.Status = 'Completed';
                contactIds.add(o.OrderedBy__c);
            }
            system.debug('Order: ' + o.Id);
        }

        Database.update(orderList, true);
        String newuser = '%New User Call 1%';
        String reactivationUser = '%Reactivation Call 1%';

        List<Case> caseList = new List<Case>([SELECT Id
                                                FROM Case
                                               WHERE RecordTypeId =: callRecordType
                                                 AND Status = 'New'
                                                 AND ContactId IN: contactIds
                                                 AND (Campaign__r.Name LIKE: newuser
                                                  OR Campaign__r.Name LIKE: reactivationUser)]);
        
        for(case c: caseList){
            system.debug('case: ' + c);

        }
        if(!caseList.isEmpty()){
            Database.delete(caseList, false);
        }
    }
    public void finish(Database.BatchableContext BC){}
} */