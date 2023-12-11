/*
Monitors if there is an order that has been cancelled - abandoned.
Update case' skill requirement so omni channel can reroute it to correct agent
*/
public class OrderMonitoring implements Database.Batchable<sObject>{

    Id callRecordType;

    public OrderMonitoring() {
        callRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String f = 'Status';
        Datetime dt = Datetime.Now().addHours(-1);

        String queryStr = 'SELECT Order.OrderedBy__c, OldValue, NewValue'
                        + ' FROM OrderHistory'
                        + ' WHERE Field =: f'
                        + ' AND Order.Account.Market__c = \'PH\''
                        + ' AND CreatedDate >=: dt';

        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<OrderHistory> orderHistories){

        String newVal = 'Cancelled - Abandoned';
        Set<Id> contactIds = new Set<Id>();
        for(OrderHistory oh: orderHistories){
            if(oh.NewValue == newVal){
                contactIds.add(oh.Order.OrderedBy__c);
            }
        }
        
        if(!contactIds.isEmpty()) process(contactIds);
    }
    public void finish(Database.BatchableContext BC){}

    public void process(Set<Id> contactIds){
        List<Id> caseIds = new List<Id>();
        for(Contact con: [SELECT (SELECT Id FROM Orders__r),
                                 (SELECT Id FROM Cases
                                   WHERE Status = 'New'
                                     AND RecordTypeId =: callRecordType
                                     AND AutoAssignCalls__c = true)
                          FROM Contact
                         WHERE Id IN: contactIds]){
            if(con.Orders__r.size() == 1) {
                for(Case c: con.Cases){
                    caseIds.add(c.Id);
                }
            }
        }

        if(!caseIds.isEmpty()){
            Delete [SELECT id FROM PendingServiceRouting WHERE WorkItemId IN: caseIds];
            SkillsBasedRouting.routeUsingSkills(caseIds);
        }
    }
    
}