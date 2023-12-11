/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Handler class for VN_call_manual__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/
public class VNCallManualTriggerHandler{

    public void BeforeInsert(List<VN_call_manual__c> vnCallList) {
        VNCallManualTriggerHelper.validateAffiliateValue(vnCallList);
        //VNCallManualTriggerHelper.formatIntegerTextField(vnCallList);
    }
}