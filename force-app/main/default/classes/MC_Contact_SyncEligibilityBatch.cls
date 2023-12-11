/**
* @author        Jennifer Alviz    
* @date          01.25.2021
* @description   Batch job to update MC Sync Eligibility Fields
* @revision(s)
*/
global class MC_Contact_SyncEligibilityBatch Implements Database.Batchable<sObject>, Database.Stateful{
    
    global Set<Id> conIds = new Set<Id>();
    global Set<Id> accountIds = new Set<Id>();
    global Set<Id> eligibleHouseholdIds = new Set<Id>();
    global Set<Id> eligibleContactIds = new Set<Id>();
  
    Integer NumOfMonths;
    Date eligibleDate;
    String market;

    String queryOverride;
    
    global MC_Contact_SyncEligibilityBatch(String m, Integer n, String newScope){
        queryOverride = newScope;
        Market = m;
        if(n != null){
            NumOfMonths = n * -1;
            eligibleDate = Date.today().addMonths(NumOfMonths);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID , Name, AccountId, Market__c, Active__c, Phone, Email, SMSOptOut__c, HasOptedOutOfEmail,'
            + 'LatestChannelResponseDate__c, LatestTransactionDate__c, Latest_Contacted_Date__c,Latest_SMS_Sent_Date__c, Latest_Email_Sent_Date__c,'
            + 'MC_Sync_Eligibility_ANZ__c, MC_Sync_Eligibility_ID__c, MC_Sync_Eligibility_IN__c, MC_Sync_Eligibility_MY__c,'
            + 'MC_Sync_Eligibility_PH__c, MC_Sync_Eligibility_SG__c, MC_Sync_Eligibility_TH__c, MC_Sync_Eligibility_VN__c'                           
            + ' FROM Contact'
            + ' WHERE'
            + ' (Phone != null'
            + ' OR Email != null)'
            + ' AND Market__c = :Market';

        if(String.isNotBlank(queryOverride)){
            query = queryOverride;
        }

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> contactsToUpdate = new List<Contact>();

        for(Contact con: scope){
            Boolean eligibility = false;
            Boolean toUpdate = false;

            Boolean withLatestDate = false;
            if(con.LatestChannelResponseDate__c != null 
                || con.LatestTransactionDate__c != null
                || con.Latest_Contacted_Date__c != null
                || con.Latest_SMS_Sent_Date__c != null
                || con.Latest_Email_Sent_Date__c != null){
                    
                    withLatestDate = true;
            }

            if(con.Active__c){
                if(((con.Phone != null && !con.SMSOptOut__c) || (con.Email != null && !con.HasOptedOutOfEmail))){
                    if(eligibleDate != null && withLatestDate){
                        if(con.LatestChannelResponseDate__c >= eligibleDate || con.LatestTransactionDate__c >= eligibleDate 
                        || con.Latest_Contacted_Date__c >= eligibleDate || con.Latest_SMS_Sent_Date__c >= eligibleDate
                        || con.Latest_Email_Sent_Date__c >= eligibleDate){ 
    
                            eligibility = true;
                        }
                    }else{
                        // VN & ANZ does not require date validation
                        // contact with no latest dates yet are still considered eligible
                        eligibility = true;
                    }
                }
            }

            // update contact only if eligibility changed
            if(con.Market__c == CommonConstant.MARKET_ANZ && con.MC_Sync_Eligibility_ANZ__c != eligibility){
                con.MC_Sync_Eligibility_ANZ__c = eligibility;
                toUpdate = true;
            }
            else if(con.Market__c == CommonConstant.MARKET_ID && con.MC_Sync_Eligibility_ID__c != eligibility){
                con.MC_Sync_Eligibility_ID__c = eligibility;
                toUpdate = true;
            }
            else if(con.Market__c == CommonConstant.MARKET_IN && con.MC_Sync_Eligibility_IN__c != eligibility){
                con.MC_Sync_Eligibility_IN__c = eligibility;
                toUpdate = true;
            }
            else if(con.Market__c == CommonConstant.MARKET_MY && con.MC_Sync_Eligibility_MY__c != eligibility){
                con.MC_Sync_Eligibility_MY__c = eligibility;
                toUpdate = true;
            }
            else if(con.Market__c == CommonConstant.MARKET_PH && con.MC_Sync_Eligibility_PH__c != eligibility){
                con.MC_Sync_Eligibility_PH__c = eligibility;
                toUpdate = true;
            }
            else if(con.Market__c == CommonConstant.MARKET_SG && con.MC_Sync_Eligibility_SG__c != eligibility){
                con.MC_Sync_Eligibility_SG__c = eligibility;
                toUpdate = true;
            }
            else if(con.Market__c == CommonConstant.MARKET_TH && con.MC_Sync_Eligibility_TH__c != eligibility){
                con.MC_Sync_Eligibility_TH__c = eligibility;
                toUpdate = true;
            }
            else if(con.Market__c == CommonConstant.MARKET_VN && con.MC_Sync_Eligibility_VN__c != eligibility){
                con.MC_Sync_Eligibility_VN__c = eligibility;
                toUpdate = true;
            }

            if(toUpdate){
                contactsToUpdate.add(con);
                accountIds.add(con.AccountId);
                conIds.add(con.Id);

                if(eligibility){
                    eligibleHouseholdIds.add(con.AccountId);
                    eligibleContactIds.add(con.Id);
                }
            }
        }

        if(!contactsToUpdate.isEmpty()) Utilityclass.updateList(contactsToUpdate);

    }

    global void finish(Database.BatchableContext BC) {
        
        if(!conIds.isEmpty()){

            /* TKT-014200 - Remove VN Child Contact Sync Logic
            if(market == CommonConstant.MARKET_VN){
                Database.executebatch(new MC_ChildContact_SyncEligibilityBatch(market, conIds,''), 150);
            }
            */ 

            Database.executebatch(new MC_Account_SyncEligibilityBatch(accountIds,eligibleHouseholdIds), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Account').Batch_Size__c);
            Database.executebatch(new MC_Case_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Case').Batch_Size__c);
            Database.executebatch(new MC_Order_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Order').Batch_Size__c);
            Database.executebatch(new MC_BR_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Brand_Relationship').Batch_Size__c);
            Database.executebatch(new MC_CR_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Channel_Response').Batch_Size__c);
            Database.executebatch(new MC_Address_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Address').Batch_Size__c);
            Database.executebatch(new MC_Membership_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Membership').Batch_Size__c);
            Database.executebatch(new MC_CampaignMem_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Campaign_Member').Batch_Size__c);
            Database.executebatch(new MC_Reward_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Reward').Batch_Size__c);
            Database.executebatch(new MC_MD_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Medical_History').Batch_Size__c);
            Database.executebatch(new MC_IER_SyncEligibilityBatch(conIds,''), (Integer)MC_Sync_Eligibility_Batch_Size__mdt.getInstance('Case').Batch_Size__c);
            
        }

    }
}