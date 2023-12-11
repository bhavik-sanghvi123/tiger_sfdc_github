public with sharing class addDeleteController {
    @AuraEnabled
    public static void saveOrderItem(List<OrderItem> ListOrderItem){
        Insert ListOrderItem;
    }
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = String.isBlank(searchKeyWord) ? '%' : String.escapeSingleQuotes(searchKeyWord.trim()) + '%';
        
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
        
    }
    
}