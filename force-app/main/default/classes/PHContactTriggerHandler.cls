/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Handler class for PH_Contact__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/
public class PHContactTriggerHandler{

    public void BeforeInsert(List<PH_Contact__c> phContactList) {
        PHContactTriggerHelper.validateAffiliateValue(phContactList);
    }
}