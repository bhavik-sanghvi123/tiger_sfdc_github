public class UtilityClass {

    public class CustomException extends Exception {}

    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    //-------------------------- END getDependentMap Method -------------------------------------------------

    public static Map<String, String> convertObjToMap(List<sObject> objDetailList, String key, String value)  {
        Map<String, String> resultMap = new Map<String, String>();

        for(sObject obj : objDetailList) {
            if(String.isNotBlank(String.valueOf(obj.get(value)))) {
                resultMap.put( (String)obj.get(key) , String.valueOf(obj.get(value)));
            }
        }

        return resultMap;
    }

    //-------------------------- END convertObjToMap Method -------------------------------------------------
    
    
     public static Boolean IsTriggerActive(String triggerName){
        

        Boolean isActive = true; //default to true, always run on test class
        try{
            TriggerSwitch__mdt triggerSwitch = [SELECT MasterLabel, isActive__c, BypassTriggerforUsernames__c
                                                   FROM TriggerSwitch__mdt
                                                  WHERE MasterLabel =: triggerName LIMIT 1];
            if(!Test.isRunningTest() && triggerSwitch != null ){
                isActive = triggerSwitch.isActive__c;
                if(triggerSwitch.BypassTriggerforUsernames__c != null
                    && triggerSwitch.BypassTriggerforUsernames__c.containsIgnoreCase(UserInfo.getUserName())) {
                    isActive = false;
                }
            }
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return isActive;
    }

    public static List<String> getFields(String objName) {
        List<String> fields = new List<String>();
        for(Schema.SObjectField sfield : Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().Values()) {
            fields.add(sfield.getDescribe().getname());
        }
        return fields;
    }

    public static List<AffiliateMetadata__mdt> getAffiliateMetadata(){
        String queryStr = 'SELECT ' + String.join(getFields(CommonConstant.AFFILIATEMETADATA_OBJECT), ',') + ' FROM ' + CommonConstant.AFFILIATEMETADATA_OBJECT;
        return Database.query(queryStr);
    }

    public static Map<String, AffiliateMetadata__mdt> getAffiliateMetadataMap(){
        Map<String, AffiliateMetadata__mdt> afMap = new Map<String, AffiliateMetadata__mdt>();
        String queryStr = 'SELECT ' + String.join(getFields(CommonConstant.AFFILIATEMETADATA_OBJECT), ',') + ' FROM ' + CommonConstant.AFFILIATEMETADATA_OBJECT;
        for(AffiliateMetadata__mdt af: Database.query(queryStr)) {
            afMap.put(af.MasterLabel, af);
        }
        return afMap;
    }

    public static void updateList(List<SObject> sObjects) {
        for (Database.SaveResult sr: Database.update(sObjects, false)) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage() + ' | fields::  ' + err.getFields());
                }
            }
        }
    }

    public static void insertList(List<SObject> sObjects) {
        for (Database.SaveResult sr: Database.insert(sObjects, false)) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage() + ' | fields::  ' + err.getFields());
                }
            }
        }
    }

    //this method is used to convert dice date format into salesforce date
    public static Date convertDiceDateFormat(String inputDate) {
        List<String> arrayDate = inputDate.split(' ');
        String newDateFormat = arrayDate[2]+'-'+CommonConstant.MONTH_MAP.get(arrayDate[0])+'-'+arrayDate[1];
        Date createdDate = Date.valueOf(newDateFormat);
        return createdDate;
    }
    //this method is used to convert membership Id that being returned by Dice API
    public static String convertDiceMembershipIdFormat(String memberId) {
        String convertedMemberId = memberId.substring(0,4)+' '+memberId.substring(4,8)+' '+memberId.substring(8,12)+' '+memberId.substring(12,17)+' '+memberId.substring(17);
        return convertedMemberId;
    }
    //this method is used to convert string into date time format
    //sample input : YYYY-MM-DD : 2022-11-25
    public static DateTime convertStringToDateTime(String dateInputString){
        Date dateInputFormat = Date.valueOf(dateInputString);
        Integer day = dateInputFormat.day();
        Integer mon = dateInputFormat.month();
        Integer year = dateInputFormat.year();
        DateTime dateTimeFormat = DateTime.newInstance(year, mon, day, 8, 0, 0);
        return dateTimeFormat;
    }
}