/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Handler class for Reward object
                  - Computes the Contact's Reward Points Balance
History
01/15/2019   vmirandilla    Created
07/20/2020   malviz         bypass delete when To be Archived is true
12/09/2020   malviz         TKT-002934: Recalculate points when redemption is voided
12/23/2020	 jreyes			US-1701  Sum of active Reward points in the Membership Field "Total_Reward__c"
-------------------------------------------------------------------------------------------*/

public class RewardTriggerHandler implements ITriggerHandler{

    public void BeforeInsert(List<SObject> newList) {
        //Populates Reward's Points Amount based on Product's Required Reward Points.
        RewardTriggerHelper.getRequiredRewardPoints(newList);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { 
        //Updates Reward's Points Amount based on Product's Required Reward Points
        RewardTriggerHelper.getRequiredRewardPoints(newList);
        RewardTriggerHelper.updateRewardPointsBalance(oldMapItems, newMapItems);
    }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ 
        //Handles the incremental changes of Contact's Household tracking fields during Contact creation.
        RewardTriggerHelper.calculateRewardPointsBalance(newList, TRUE);
    }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){
        //Handles the incremental or decremental changes of Contact's Household tracking fields during Contact update.
        //RewardTriggerHelper.updateRewardPointsBalance(oldMapItems, newMapItems);

        //Handles the total related points for the Membership
        RewardTriggerHelper.sumOfTotalPoints(newList);

        //TKT-002934: Recalculate points when redemption is voided
        Map<Id,Reward__c> newRewards = (Map<Id,Reward__c>) newMapItems;
        Map<Id,Reward__c> oldRewards = (Map<Id,Reward__c>) oldMapItems;
        Map<Id,Reward__c> rewardsToVoid = new Map<Id,Reward__c>();
        Map<Id,Reward__c> rewardsToUnVoid = new Map<Id,Reward__c>();
        Id redeemRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_REDEEM_RECORDTYPE).getRecordTypeId();
       
        for(Reward__c reward: newRewards.values()){
            Reward__c oldRewardRec = (Reward__c)oldRewards.get(reward.Id);
            If(reward.recordTypeId == redeemRecordTypeId && reward.isVoid__c != oldRewardRec.isVoid__c){
                if(reward.isVoid__c){
                    rewardsToVoid.put(reward.Id,reward);        
                }else{
                    rewardsToUnVoid.put(reward.Id,reward);        
                }
            }
        }
        if(!rewardsToVoid.isEmpty()) RewardTriggerHelper.calculateRewardPointsBalance(rewardsToVoid.values(), FALSE);
        if(!rewardsToUnVoid.isEmpty()) RewardTriggerHelper.calculateRewardPointsBalance(rewardsToUnVoid.values(), TRUE);
    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        //Handles the decremental changes of Contact's Household tracking fields during Contact deletion.
        Map<Id,Reward__c> oldRewards = (Map<Id,Reward__c>) oldMapItems;
        Map<Id,Reward__c> rewardsToProcess = new Map<Id,Reward__c>();
       
        for(Reward__c reward: oldRewards.values()){
           If(reward.To_be_Archived__c == false){
               rewardsToProcess.put(reward.Id,reward);
           }
        }
       
        if(!rewardsToProcess.isEmpty()) RewardTriggerHelper.calculateRewardPointsBalance(rewardsToProcess.values(), FALSE);
    }
}