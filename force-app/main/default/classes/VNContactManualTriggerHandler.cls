/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Handler class for VN_call_manual__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/
public class VNContactManualTriggerHandler{

    public void BeforeInsert(List<VN_contact_manual__c> vnCallList) {
        VNContactManualTriggerHelper.validateAffiliateValue(vnCallList);
    }
}