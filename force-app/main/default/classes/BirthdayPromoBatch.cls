/**
* @author        
* @date          
* @description   Batch job to run monthly to update the Birthday Promo
* @revision(s)
*/
global class BirthdayPromoBatch Implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer month = Date.Today().Month();
        String query = 'SELECT id,Total_Purchase_Amount_Adult_Brand__c,Birthdate_Month__c,Birthday_Promo_Eligible__c,Birthdate FROM Contact'
        + ' WHERE Total_Purchase_Amount_Adult_Brand__c >= 2000 AND Market__c = \'TW\' AND Birthdate_Month__c =: month';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> updateConList = new List<Contact>();
        for(Contact con: scope){
            if(!con.Birthday_Promo_Eligible__c){
                con.Anniversary_Promo__c = false;
                con.Birthday_Promo_Eligible__c = true;
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