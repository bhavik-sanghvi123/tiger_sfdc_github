/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Handler class for MY_Manual_Delivery_Status__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/
public class MYManualDeliveryStatusTriggerHandler{

    public void BeforeInsert(List<MY_Manual_Delivery_Status__c> myDeliveryList) {
        MYManualDeliveryStatusTriggerHelper.validateAffiliateValue(myDeliveryList);
    }
}