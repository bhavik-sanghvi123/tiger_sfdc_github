/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Helper class for VN Manual Delivery Status object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/

public class VNManualDeliveryStatusTriggerHelper {

    /* This method get all Affialite Values and check the duplicate;
    */
    public static void validateAffiliateValue(List<VN_Manual_Delivery_Status__c> vnDeliveryList) {
        Integer row = 1;
        List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
        avList = [SELECT recordtypeID,RecordType.Name, Name FROM Affiliate_Value__c WHERE RecordType.Name = 'Order Cancellation Reason'];
        Map<String, Set<String>> avMap = new Map<String, Set<String>>();
        for(Affiliate_Value__c av : avList){
            if(avMap.containsKey(av.RecordType.Name)){
                avMap.get(av.RecordType.Name).add(av.Name);
            } else {
                Set<String> avNameSet = new Set<String>();
                avNameSet.add(av.Name);
                avMap.put(av.RecordType.Name,avNameSet);
            }
        }
        Map<String, String> orderStatusMap = getPickListValuesIntoMap();
        for(VN_Manual_Delivery_Status__c vnDelivery : vnDeliveryList){
            row++;
            Set<String> avNames = new Set<String>();
             if(String.isNotBlank( vnDelivery.order_status__c )) {
                if(!orderStatusMap.containsKey( vnDelivery.order_status__c )) {
                    vnDelivery.addError(vnDelivery.order_status__c + ' Status does not exist at row  ' + row);
                    continue;
                }
            }

            if(!vnDelivery.order_status__c.equalsIgnoreCase('Completed')){
                if(String.isNotBlank( vnDelivery.Order_Cancellation_Reason__c)){
                    avNames = avMap.get('Order Cancellation Reason');
                    if(!avNames.contains(vnDelivery.Order_Cancellation_Reason__c)){
                        vnDelivery.addError(vnDelivery.Order_Cancellation_Reason__c + ' Order Cancellation Reason not exists at row ' + row);
                        continue;
                    }
                } else {
                    vnDelivery.addError(' Order Cancellation Reason is required for Cancelled order status at row ' + row);
                    continue;
                }
            }
                    
            if(String.isNotBlank( vnDelivery.order_delivery_date__c) ) {
                if(!checkDatetime(vnDelivery.order_delivery_date__c)){
                    vnDelivery.addError(vnDelivery.order_delivery_date__c + ' is Invalid date, use dd/mm/yyyy hh:mm at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( vnDelivery.source_created_date__c) ) {
                if(!checkDate(vnDelivery.source_created_date__c)){
                    vnDelivery.addError(vnDelivery.source_created_date__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }           
        }
    }
    
    public static Boolean checkDate(String checkDate) {
        String datePattern = '(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[012])/((11|12|13|14|15|16|17|18|19|20)\\d\\d)';
        Pattern pat = Pattern.compile(datePattern);
        Matcher mat = pat.matcher(checkDate);
        return mat.matches();
    }

    public static Boolean checkDatetime(String checkDate) {
        String datePattern = '(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[012])/((11|12|13|14|15|16|17|18|19|20)\\d\\d\\s((0?[0-9]|1[0-9]|2[0-3]|[0-9]):[0-5][0-9]))';
        Pattern pat = Pattern.compile(datePattern);
        Matcher mat = pat.matcher(checkDate);
        return mat.matches();
    }

    public static Map<String, String> getPickListValuesIntoMap(){
        Map<String,String> pickListValuesList= new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.put(pickListVal.getLabel(), pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
}