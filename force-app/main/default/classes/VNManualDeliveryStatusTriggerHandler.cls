/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Handler class for VN_Manual_Delivery_Status__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/
public class VNManualDeliveryStatusTriggerHandler{

    public void BeforeInsert(List<VN_Manual_Delivery_Status__c> vnDeliveryList) {
        VNManualDeliveryStatusTriggerHelper.validateAffiliateValue(vnDeliveryList);
    }
}