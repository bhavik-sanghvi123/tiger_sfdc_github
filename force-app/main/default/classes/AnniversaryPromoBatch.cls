/**
* @author        
* @date          
* @description   Batch job to run monthly to update the Anniversary Promo
* @revision(s)
*/
global class AnniversaryPromoBatch Implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer month = Date.Today().Month();
        String query = 'SELECT id,Total_Purchase_Anniversary_Amount_Adult__c,Anniversary_Promo__c,FirstTransactionDate__c, Anniversary_Month__c from Contact'
        + ' WHERE Total_Purchase_Anniversary_Amount_Adult__c >= 2000 AND Market__c = \'TW\' AND Anniversary_Month__c =: month';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> updateConList = new List<Contact>();
        for(Contact con: scope){
            if(!con.Anniversary_Promo__c){
                con.Birthday_Promo_Eligible__c = false;
                con.Anniversary_Promo__c = true;
                updateConList.add(con);
            }
        }
        if(!updateConList.isEmpty()){
            update updateConList;
        }
        
    }    
    
    global void finish(Database.BatchableContext BC) {
    }
}