/**
* @author        Jennifer Alviz    
* @date          5.12.2021
* @description   Batch job to clear opt out dates on contacts where opt out checkbox is unchecked, 
*                affected contacts are prepopulated with the date values upon creation and did not trigger the existing validation rule
* @revision(s)
*/
global class Contact_ClearOptOutDates implements Database.Batchable<sObject> {

    String queryOverride;
    
    global Contact_ClearOptOutDates(String newScope){
        queryOverride = newScope;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query = 'SELECT id,DoNotCall,DoNotCallDate__c,HasOptedOutOfEmail,EmailOptOutDate__c,WhatsappOptOut__c,WhatsappOptOutDate__c,SMSOptOut__c,SMSOptOutDate__c,'
            + 'DataSharingWithThirdPartyOptOut__c,DataSharingOptOutDate__c'                           
            + ' FROM Contact'
            + ' WHERE'
            + ' Type__c = \'Adult\''
            + ' AND Market__c = \'SG\'';

        if(String.isNotBlank(queryOverride)){
        query = queryOverride;
        }

        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> contactToUpdate = new List<Contact>();
        
        for(Contact con : scope){
            Boolean forUpdate = false;

            If(!con.DoNotCall && con.DoNotCallDate__c != null){
                con.DoNotCallDate__c = null;
                forUpdate = true;
            }
            If(!con.HasOptedOutOfEmail && con.EmailOptOutDate__c != null){
                con.EmailOptOutDate__c = null;
                forUpdate = true;
            }
            If(!con.WhatsappOptOut__c && con.WhatsappOptOutDate__c != null){
                con.WhatsappOptOutDate__c = null;
                forUpdate = true;
            }
            If(!con.SMSOptOut__c && con.SMSOptOutDate__c != null){
                con.SMSOptOutDate__c = null;
                forUpdate = true;
            }
            If(!con.DataSharingWithThirdPartyOptOut__c && con.DataSharingOptOutDate__c != null){
                con.DataSharingOptOutDate__c = null;
                forUpdate = true;
            }
            
            if(forUpdate){
                contactToUpdate.add(con);
            }
            
        }
        
        if(!contactToUpdate.isEmpty()) Utilityclass.updateList(contactToUpdate);
    }
        
    global void finish(Database.BatchableContext BC) {
        
    }
    
}