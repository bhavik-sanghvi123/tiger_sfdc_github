/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Batch Class to update Memebership Details on a daily basis

History
04/09/2019   vmirandilla   Created
05/15/2019   raustral      Remove sub query causing cpu limit when result is too large
-------------------------------------------------------------------------------------------*/
global class UpdateMembershipDetailsBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT NumberOfDaysDormant__c,'
                            + ' NumberOfTransactions__c,'
                            + ' MembershipStartDate__c'
                            //+ ' (SELECT EndDate'
                            //+ ' From Orders__r'
                            //+ ' ORDER BY EndDate DESC LIMIT 1)'
                            + ' FROM Membership__c WHERE Status__c != \'Expired\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Membership__c> scope) {
        List<Membership__c> membershipList = new List<Membership__c>();

        List<Membership__c> scopeList = [Select NumberOfDaysDormant__c, NumberOfTransactions__c, MembershipStartDate__c,
                                        (SELECT EndDate From Orders__r ORDER BY EndDate DESC LIMIT 1)
                                        FROM Membership__c WHERE ID IN: scope];

        for(Membership__c mem : scopeList) {
            if(!mem.Orders__r.isEmpty()) {
                for(Order order : mem.Orders__r) {
                    if(order.EndDate != null) {
                        if(order.EndDate == Date.valueOf(System.today())) {
                            mem.NumberOfDaysDormant__c = 0;    
                        } else {
                            mem.NumberOfDaysDormant__c = order.EndDate.daysBetween(System.today());
                        }
                        
                        if(mem.NumberOfDaysDormant__c >= 90) {
                            mem.Status__c = CommonConstant.MEMBERSHIP_STATUS_EXPIRED;
                            mem.MembershipExpiryDate__c = order.EndDate.addDays(90);
                        }
                    }
                }
            } else {
                if(mem.MembershipStartDate__c != null) {
                    if(mem.MembershipStartDate__c == Date.valueOf(System.today())) {
                        mem.NumberOfDaysDormant__c = 0;    
                    } else {
                        mem.NumberOfDaysDormant__c = mem.MembershipStartDate__c.daysBetween(System.today());
                    }
                    
                    if(mem.NumberOfDaysDormant__c >= 90) {
                        mem.Status__c = CommonConstant.MEMBERSHIP_STATUS_EXPIRED;
                        mem.MembershipExpiryDate__c = mem.MembershipStartDate__c.addDays(90);
                    }
                }
            }

            if (mem.NumberOfDaysDormant__c < 0) {
                mem.NumberOfDaysDormant__c = 0;
            }

            membershipList.add(mem);
        }

        if(!membershipList.isEmpty()) {
            Database.update(membershipList, false);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}