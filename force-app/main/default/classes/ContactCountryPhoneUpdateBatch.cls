/*****************************************************************************************
    * @author           Monika Parihar
    * @date             06/10/2021
    * @description      Batch class to update the existing Contact of TW Market ,add country code to phone no.
    * @revision(s)

    * 
      @Modified by      Narence valencia
    * @date             11/29/2021
    * @description      Added logic to remove the first character from CountryCodeMobile__c    

*********************************************************************************************/
global class ContactCountryPhoneUpdateBatch Implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'Select Id,Market__c,Phone,CountryCodeMobile__c from Contact where  Market__c = \'TW\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
         Map<String,String> mapCountryCode = new Map<String,String>();
        List<Contact> conList = new List<Contact>();
        
        //custom metadata to get country phone code out of country code
        Country_Code__mdt[] countryCodeList = [SELECT MasterLabel, Country_Code__c FROM Country_Code__mdt];
        for(Country_Code__mdt record: countryCodeList) {
            mapCountryCode.put(record.MasterLabel,record.Country_Code__c);
        }
        For(Contact con : scope){
            if(mapCountryCode.containskey(con.Market__c) && mapCountryCode !=  null && con.Phone != null){
                con.CountryCodeMobile__c = con.Phone.startsWith('0') ? mapCountryCode.get(con.Market__c)+con.Phone.substring(1):mapCountryCode.get(con.Market__c)+con.Phone;
                
                //added by Narence Valencia
                con.CountryCodeMobile__c = con.CountryCodeMobile__c.substring(1);
                conList.add(con);
            }
        }
        if(!conList.isEmpty()) UtilityClass.updateList(conList);
        
    }    
    
    global void finish(Database.BatchableContext BC) {
    }
}