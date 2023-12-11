/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Helper class for MY Manual Delivery Status object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/

public class MYManualDeliveryStatusTriggerHelper {

    /* This method get all Affialite Values and check the duplicate;
    */
    public static void validateAffiliateValue(List<MY_Manual_Delivery_Status__c> myDeliveryList) {
        Integer row = 1;
        List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
        avList = [SELECT recordtypeID,RecordType.Name, Name FROM Affiliate_Value__c WHERE RecordType.Name = 'Order Cancellation Reason'];
        Map<String, Set<String>> avMap = new Map<String, Set<String>>();
        for(Affiliate_Value__c av : avList){
            if(avMap.containsKey(av.RecordType.Name)){
                avMap.get(av.RecordType.Name).add(av.Name);
            } else {
                Set<String> amyameSet = new Set<String>();
                amyameSet.add(av.Name);
                avMap.put(av.RecordType.Name,amyameSet);
            }
        }
        
        for(MY_Manual_Delivery_Status__c myDelivery : myDeliveryList){
            row++;
            Set<String> amyames = new Set<String>();
            if(myDelivery.Order_Cancellation_Reason__c != null && myDelivery.Order_Cancellation_Reason__c != ''){
                amyames = avMap.get('Order Cancellation Reason');
                if(!amyames.contains(myDelivery.Order_Cancellation_Reason__c)){
                    myDelivery.addError(myDelivery.Order_Cancellation_Reason__c + ' Order Cancellation Reason not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank( myDelivery.order_delivery_date__c) ) {
                if(!checkDate(myDelivery.order_delivery_date__c)){
                    myDelivery.addError(myDelivery.order_delivery_date__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( myDelivery.source_created_date__c) ) {
                if(!checkDate(myDelivery.source_created_date__c)){
                    myDelivery.addError(myDelivery.source_created_date__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
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
}