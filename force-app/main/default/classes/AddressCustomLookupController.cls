/*
* @author        Rey Austral
* @date          8.9.2019
* @description   Controller for AddressCustomLookup (Lightning component)
* @revision(s) 
*/
public with sharing class AddressCustomLookupController {
    @AuraEnabled (cacheable=true)
    public static List<RecordsData> fetchRecords( String objectName, String filterField, String searchString, String parentField, String parentValue, String recordTypeName ) {
        String recordTypeFilter = '';
        if (String.isNotEmpty(recordTypeName)) {
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{objectName});
            Id recordTypeId = descResult.get(0).getRecordTypeInfosByName().get(String.escapeSingleQuotes(recordTypeName)).getRecordTypeId();
            recordTypeFilter = ' AND RecordTypeId = \'' + recordTypeId + '\'';
        }
        
        List<RecordsData> recordsDataList = new List<RecordsData>();
 
        try {
	        String query = 'SELECT Id, ' + String.escapeSingleQuotes(filterField)+
	                        ' FROM '+String.escapeSingleQuotes(objectName)+
	                        ' WHERE '+String.escapeSingleQuotes(filterField)+' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + 
                			recordTypeFilter;
                            if(String.isNotBlank(parentValue)){
                                query += ' AND ' +String.escapeSingleQuotes(parentField) + ' = \'' +String.escapeSingleQuotes(parentValue)+ '\'';
                            }
                            query += ' LIMIT 50000';
                            
	        for(SObject s : Database.query(query)){
	            RecordsData recordsData = new RecordsData();
	            recordsData.value = String.valueOf(s.get('id'));
	            recordsData.label = String.valueOf(s.get(filterField));
	            recordsDataList.add(recordsData);
	        } 
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
        
        return recordsDataList;
    }

    @AuraEnabled (cacheable=true)
    public static List<RecordsData> fetchTopRecords( String objectName, String filterField, String searchString, String parentField, String parentValue, String recordTypeName ) {
        String recordTypeFilter = '';
        if (String.isNotEmpty(recordTypeName)) {
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{objectName});
            Id recordTypeId = descResult.get(0).getRecordTypeInfosByName().get(String.escapeSingleQuotes(recordTypeName)).getRecordTypeId();
            recordTypeFilter = ' AND RecordTypeId = \'' + recordTypeId + '\'';
        }

        List<RecordsData> recordsDataList = new List<RecordsData>();
        
        try {
	        String query = 'SELECT Id, ' + String.escapeSingleQuotes(filterField)+
	                        ' FROM '+String.escapeSingleQuotes(objectName)+
	                        ' WHERE '+String.escapeSingleQuotes(filterField)+' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + 
                			recordTypeFilter;
                            if(String.isNotBlank(parentValue)){
                                query += ' AND ' +String.escapeSingleQuotes(parentField) + ' = \'' +String.escapeSingleQuotes(parentValue)+ '\'';
                            }
                            query += ' LIMIT 10';
                            
	        for(SObject s : Database.query(query)){
	            RecordsData recordsData = new RecordsData();
	            recordsData.value = String.valueOf(s.get('id'));
	            recordsData.label = String.valueOf(s.get(filterField));
	            recordsDataList.add(recordsData);
	        } 
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
        
        return recordsDataList;
    }
 
    public class RecordsData{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
}
