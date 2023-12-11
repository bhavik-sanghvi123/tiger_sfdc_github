/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Handler class for MY_Contact__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/
public class MYContactTriggerHandler{

    public void BeforeInsert(List<MY_Contact__c> vnContactList) {
        MYContactTriggerHelper.validateAffiliateValue(vnContactList);
    }
}