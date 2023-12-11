/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Helper class for Contact object
- Computes Contact's Reward Points Balance based on related Reward records
History
01/15/2019   vmirandilla    Created
12/23/2020   jreyes         US - 1701: Added sumOfTotalPoints, updated calculateRewardPointsBalance
01/22/2021   emontesa       updated the sumOfTotalPoints method and calculateRewardPointsBalance, removed dml statements outside loops
-------------------------------------------------------------------------------------------*/

public class RewardTriggerHelper {
    
    /* This method get the Product's Reward Points Required value and will store to Reward's Points Amount field*/
    public static void getRequiredRewardPoints(List<Reward__c> rewardList) {
        Map<Id,Product2> prodMap = getRelatedProduct(rewardList);
        Id redeemRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_REDEEM_RECORDTYPE).getRecordTypeId();
        Id adjustSubRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_SUBTRACT_RECORDTYPE).getRecordTypeId();
        
        for(Reward__c reward : rewardList) {
            if(reward.RecordTypeId == redeemRecordTypeId && reward.ProductForRedemption__c != null) {
                reward.PointsAmount__c = prodMap.get(reward.ProductForRedemption__c).RewardsPointsRequired__c;
            }
            if(reward.ExpiryDate__c <= Date.today()
                && reward.RecordTypeId != redeemRecordTypeId
                && reward.RecordTypeId != adjustSubRecordTypeId) {
                if(!Test.isRunningTest()) {
                    reward.Active__c = FALSE;
                }
            }
        } 
    }
     
    /* This method will calculate the Contact's Reward Balance based on Reward's Points Amount
    * Earn or Adjust (Add) - add value to Reward Balance
    * Redeem or Adjust (Subtract) - add value to Reward Balance
    */
    public static void calculateRewardPointsBalance(List<Reward__c> rewardList, Boolean isNew) {
        Map<Id,Contact> conMap = getRelatedContact(rewardList);
        Map<Id,Reward__c> earnAddRewardMap = getEarnAddRewards(rewardList, isNew);
        List<Reward__c> rewardforUpdateList = new List<Reward__c>();
        Map<Id,Reward__c> rewardforUpdateMap = new Map<Id,Reward__c>();
        Map<Id,Contact> contactforUpdateMap = new Map<Id,Contact>();
        
        Id earnRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_EARN_RECORDTYPE).getRecordTypeId();
        Id redeemRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_REDEEM_RECORDTYPE).getRecordTypeId();
        Id adjustAddRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_ADD_RECORDTYPE).getRecordTypeId();
        Id adjustSubRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_SUBTRACT_RECORDTYPE).getRecordTypeId();
        
        for(Reward__c reward : rewardList) {
            if(conMap.containsKey(reward.Contact__c)) {
                Decimal tempReward = conMap.get(reward.Contact__c).RewardPoints__c;
                conMap.get(reward.Contact__c).RewardPoints__c = tempReward  == null ? 0 : tempReward;
                Decimal contactRewardPoints  = tempReward;
                Decimal rewardPoints = reward.PointsAmount__c;
                Decimal finalRewardPoints = 0;
                
                if(reward.Active__c == TRUE) {
                    if(reward.RecordTypeId == earnRecordTypeId || reward.RecordTypeId == adjustAddRecordTypeId) {
                        if(isNew) {
                            finalRewardPoints = contactRewardPoints + rewardPoints;
                        } else {
                            finalRewardPoints = contactRewardPoints - rewardPoints;
                        }
                    }
                    else if(reward.RecordTypeId == redeemRecordTypeId || reward.RecordTypeId == adjustSubRecordTypeId) {
                        //added quanity
                        Decimal actualPoints = reward.RecordTypeId == redeemRecordTypeId ? reward.Quantity__c * reward.PointsAmount__c : reward.PointsAmount__c;

                        if(actualPoints > contactRewardPoints && isNew) {                            
                            reward.addError('Unable to save record - Insufficient points on Contact\'s Reward Points Balance');
                        }
                        
                        for(Reward__c earnAdjustRec : earnAddRewardMap.values()) {
                            if(reward.Contact__c == earnAdjustRec.Contact__c) {
                               
                                Decimal consumed = earnAdjustRec.Consumed__c == null ? 0 : earnAdjustRec.Consumed__c;                                
                                if (isNew) {
                                    if(actualPoints <= earnAdjustRec.PointsAmount__c) {                                        
                                        earnAdjustRec.PointsAmount__c  = earnAdjustRec.PointsAmount__c - actualPoints;
                                        earnAdjustRec.Consumed__c = consumed + actualPoints;
                                        earnAdjustRec.Active__c = earnAdjustRec.PointsAmount__c == 0 ? FALSE : TRUE;     
                                        
                                        //rewardforUpdateList.add(earnAdjustRec); TKT-001625
                                        rewardforUpdateMap.put(earnAdjustRec.Id, earnAdjustRec);
                                        break;
                                    } 
                                    else if(actualPoints > earnAdjustRec.PointsAmount__c) {                                        
                                        actualPoints = actualPoints - earnAdjustRec.PointsAmount__c;
                                        //actualPoints = actualPoints - (reward.RecordTypeId == adjustSubRecordTypeId ? earnAdjustRec.PointsAmount__c : earnAdjustRec.Consumed__c);
                                        earnAdjustRec.Consumed__c = consumed + earnAdjustRec.PointsAmount__c;
                                        earnAdjustRec.PointsAmount__c = earnAdjustRec.PointsAmount__c - earnAdjustRec.PointsAmount__c;
                                        earnAdjustRec.Active__c = earnAdjustRec.PointsAmount__c == 0 ? FALSE : TRUE;      
                                     
                                        //rewardforUpdateList.add(earnAdjustRec); TKT-001625
                                        rewardforUpdateMap.put(earnAdjustRec.Id, earnAdjustRec);                                   
                                    }                                     
                                } else if (!isNew && consumed != 0){ //reactivate again the earn and update the consumed/points amount; ignore earn that is not yet consumed
                                    if (actualPoints > consumed) {
                                        earnAdjustRec.PointsAmount__c = consumed;
                                        earnAdjustRec.Consumed__c = 0;
                                        earnAdjustRec.Active__c = true;
                                        actualPoints = actualPoints - consumed;  
                                        rewardforUpdateMap.put(earnAdjustRec.Id, earnAdjustRec);    
                                    } else {
                                        consumed = consumed - actualPoints;
                                        earnAdjustRec.PointsAmount__c = earnAdjustRec.PointsAmount__c + actualPoints;
                                        earnAdjustRec.Active__c = true;
                                        earnAdjustRec.Consumed__c = consumed;
                                        actualPoints = 0;
                                        rewardforUpdateMap.put(earnAdjustRec.Id, earnAdjustRec);    
                                        break;                                        
                                    }
                                }
                            }
                            // else {
                            //     reward.addError('Unable to save record - Insufficient points on Contact\'s Reward Points Balance');
                            // }
                        }
                    }
                    
                    if(reward.RecordTypeId != redeemRecordTypeId && reward.RecordTypeId != adjustSubRecordTypeId) {
                        if(finalRewardPoints >= 0) {
                            conMap.get(reward.Contact__c).RewardPoints__c  = finalRewardPoints;
                            
                            contactforUpdateMap.put(reward.Contact__c, new Contact(Id=reward.Contact__c, RewardPoints__c=finalRewardPoints));
                        } else {
                            reward.addError('Unable to save record - Insufficient points on Contact\'s Reward Points Balance');
                        }
                    }
                }
            }
        }
        /* This method to get the total reward points and put it in the related membership record*/
        Set<Id> memIdSet = new Set<Id>();
        Map<Reward__c, Membership__c> rewardMemMap = new Map<Reward__c, Membership__c>(); // maps the Reward and Membership Record        
        
        for(Reward__c reward : rewardList) {
            if(reward.Membership__c != null) {
                memIdSet.add(reward.Membership__c);                
            }
        }       
 
        if(!memIdSet.isEmpty()){
            
        Map<Id, Membership__c> membershipMap = new Map<Id, Membership__c>([SELECT Id, Total_Reward__c FROM Membership__c WHERE Id IN :memIdSet]);
        for(Reward__c reward : rewardList){ //maps the rewardMemMap
            if(!rewardMemMap.containsKey(reward)){
              rewardMemMap.put(reward, membershipMap.get(reward.Membership__c));
            }
        }
        
        List<Reward__c> rewardAddMap = new List<Reward__c> ([Select id, PointsAmount__c, recordtype.name
                                                                    FROM Reward__c
                                                                    WHERE Membership__c IN :memIdSet
                                                                    AND RecordTypeId = :adjustAddRecordTypeId
                                                                    AND Active__c = True]);
        
        List<Reward__c> rewardSubstractMap = new List<Reward__c> ([Select id, PointsAmount__c, recordtype.name
                                                                    FROM Reward__c
                                                                    WHERE Membership__c IN :memIdSet
                                                                    AND RecordTypeId = :adjustSubRecordTypeId
                                                                    AND Active__c = True]);
        Decimal finalPoints = 0;
        Decimal addFinalPoints = 0;
        Decimal subtractFinalPoints = 0;
        
        for(Reward__c rewardAdd : rewardAddMap){
            addFinalPoints = addFinalPoints + rewardAdd.PointsAmount__c;
        }
        
        for(Reward__c rewardSubtract : rewardSubstractMap){
            subtractFinalPoints = subtractFinalPoints + rewardSubtract.PointsAmount__c;
        }
        
        finalPoints = addFinalPoints - subtractFinalPoints;
            
        List<Membership__c> memListToUpdate = new List<Membership__c>();
        
        for(Reward__c reward : rewardList) {
            if(reward.RecordTypeId == adjustAddRecordTypeId) {
                Membership__c rewardMembership = new Membership__c();
                rewardMembership = rewardMemMap.get(reward);
                if(!memListToUpdate.contains(rewardMembership)){                    
                    rewardMembership.Total_Reward__c = finalPoints;
                    memListToUpdate.add(rewardMembership);
                }
            }
            else if(reward.RecordTypeId == adjustSubRecordTypeId) {
                Membership__c rewardMembership = new Membership__c();
                rewardMembership = rewardMemMap.get(reward);
                if(!memListToUpdate.contains(rewardMembership)){                    
                    rewardMembership.Total_Reward__c = finalPoints;
                    memListToUpdate.add(rewardMembership);
                }
            }
            /* commented by Crissar Ibarra - 11/15/2021*/
            /*
            else{
                reward.addError('Unable to save record - Insufficient points on Contact\'s Reward Points Balance');
            }
            */
        }
            if(!memListToUpdate.IsEmpty()){                
                update memListToUpdate;
            }
       }
        
        //update conMap.values();
        //TKT-001625
        if (!contactforUpdateMap.isEmpty()) {
            Update contactforUpdateMap.values();
        }
        if(!rewardforUpdateMap.isEmpty()){
            update rewardforUpdateMap.values();
        }
    }
    
    /* This method update the Contact's Reward Points depending on the update made on the related Reward record.*/
    public static void updateRewardPointsBalance(Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {
        Id earnRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_EARN_RECORDTYPE).getRecordTypeId();
        Id redeemRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_REDEEM_RECORDTYPE).getRecordTypeId();
        Id adjustAddRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_ADD_RECORDTYPE).getRecordTypeId();
        Id adjustSubRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_SUBTRACT_RECORDTYPE).getRecordTypeId();
        
        List<Reward__c> rewardforUpdateList = new List<Reward__c>();
        Map<Id,Product2> prodMapNew = getRelatedProduct(newMap.values());
        Map<Id,Product2> prodMapOld = getRelatedProduct(oldMap.values());
        Map<Id,Contact> conMap = getRelatedContact(newMap.values());
        Map<Id,Reward__c> earnAddRewardMap = getEarnAddRewards(newMap.values(), true);
        List<Reward__c> earnAddInactiveRewardList = getEarnAddInactiveRewards(newMap.values());
        
        Integer numberOfExport = 0;
        for(Reward__c reward : (List<Reward__c>)newMap.values()) {
            Reward__c oldRecord = (Reward__c) oldMap.get(reward.Id);
            //skip if the reward has been exported
            //temp fix - need to refactor the code           
            if (oldRecord.Extracted__c != reward.Extracted__c && reward.DeliveryStatus__c == CommonConstant.ORDER_STATUS_TRANSFERRED && reward.FileExportDate__c != oldRecord.FileExportDate__c) {
                numberOfExport = numberOfExport + 1;
                continue;
            }
            
            Decimal contactRewardPoints  = conMap.get(reward.Contact__c).RewardPoints__c;
            Decimal currentRewardPoints = reward.PointsAmount__c;
            Decimal oldValueRewardPoints = oldRecord.PointsAmount__c;
            Decimal currentRedeemPoints = reward.RecordTypeId == redeemRecordTypeId ? reward.Quantity__c * reward.PointsAmount__c : 0;
            Decimal oldQuantity = oldRecord.Quantity__c == null ? 1 : oldRecord.Quantity__c;
            Decimal oldValueRedeemPoints = oldRecord.RecordTypeId == redeemRecordTypeId ? oldQuantity * oldRecord.PointsAmount__c : 0;
            Decimal finalRewardPoints = 0;
            Decimal tempConPoints = 0;
            
            if(oldRecord.Contact__c != reward.Contact__c) {
                reward.addError('Contact cannot be modified.');
            }
            
            if(prodMapNew.containsKey(reward.ProductForRedemption__c) || reward.RecordTypeId == adjustSubRecordTypeId) { 
                if((reward.ProductForRedemption__c != oldRecord.ProductForRedemption__c && reward.RecordTypeId == redeemRecordTypeId && oldRecord.RecordTypeId == redeemRecordTypeId) ||                   
                   (reward.Quantity__c != oldQuantity && reward.RecordTypeId == redeemRecordTypeId)) {                        
                        tempConPoints = (oldQuantity * oldRecord.PointsAmount__c) + contactRewardPoints;       
        
                        if((reward.Quantity__c * reward.PointsAmount__c) > tempConPoints) {
                            reward.addError('Unable to save record - Insufficient points on Contact\'s Reward Points Balance');
                        }

                        rewardforUpdateList.addAll(computeRedeemChanges(reward, oldRecord, earnAddRewardMap, earnAddInactiveRewardList));
                        finalRewardPoints = contactRewardPoints;
                   }  else if(reward.PointsAmount__c != oldRecord.PointsAmount__c && reward.RecordTypeId == adjustSubRecordTypeId && oldRecord.RecordTypeId == adjustSubRecordTypeId) {
                        tempConPoints = oldRecord.PointsAmount__c + contactRewardPoints;
    
                        if(reward.PointsAmount__c > tempConPoints) {
                            reward.addError('Unable to save record - Insufficient points on Contact\'s Reward Points Balance');
                        }

                        rewardforUpdateList.addAll(computeSubtractEarnChanges(reward, oldRecord, earnAddRewardMap, earnAddInactiveRewardList));
                        finalRewardPoints = contactRewardPoints;
                   }
            }
            
            if(conMap.containsKey(reward.Contact__c)) {
                if(oldRecord.Active__c == TRUE && reward.Active__c == TRUE) {
                    //3.28.2019 - seperate the redeem from subtract 
                    if((oldRecord.RecordTypeId == earnRecordTypeId || oldRecord.RecordTypeId == adjustAddRecordTypeId) &&
                       reward.RecordTypeId == adjustSubRecordTypeId) {
                           finalRewardPoints = contactRewardPoints - oldValueRewardPoints - currentRewardPoints;
                       }
                    else if((oldRecord.RecordTypeId == earnRecordTypeId || oldRecord.RecordTypeId == adjustAddRecordTypeId) &&
                            reward.RecordTypeId == redeemRecordTypeId ) {
                                finalRewardPoints = contactRewardPoints - oldValueRewardPoints - currentRedeemPoints;
                            }
                    else if(oldRecord.RecordTypeId == adjustSubRecordTypeId &&
                            (reward.RecordTypeId == earnRecordTypeId || reward.RecordTypeId == adjustAddRecordTypeId)) {
                                finalRewardPoints = contactRewardPoints + oldValueRewardPoints + currentRewardPoints;
                            }
                    else if(oldRecord.RecordTypeId == redeemRecordTypeId &&
                            (reward.RecordTypeId == earnRecordTypeId || reward.RecordTypeId == adjustAddRecordTypeId)) {
                                finalRewardPoints = contactRewardPoints + oldValueRedeemPoints + currentRewardPoints;
                            }
                    
                    else if((oldRecord.RecordTypeId == earnRecordTypeId || oldRecord.RecordTypeId == adjustAddRecordTypeId) ||
                            (oldRecord.RecordTypeId == earnRecordTypeId && reward.RecordTypeId == adjustAddRecordTypeId) || 
                            (oldRecord.RecordTypeId == adjustAddRecordTypeId && reward.RecordTypeId == earnRecordTypeId) ||
                            ((oldRecord.RecordTypeId == reward.RecordTypeId) && (reward.RecordTypeId == earnRecordTypeId || reward.RecordTypeId == adjustAddRecordTypeId))) {
                                finalRewardPoints = (contactRewardPoints - oldValueRewardPoints) + currentRewardPoints;
                            }
                    
                    else if(oldRecord.RecordTypeId == redeemRecordTypeId && reward.RecordTypeId == adjustSubRecordTypeId){
                        finalRewardPoints = (contactRewardPoints + oldValueRedeemPoints) - currentRewardPoints;
                    }
                    else if(oldRecord.RecordTypeId == adjustSubRecordTypeId && reward.RecordTypeId == redeemRecordTypeId){
                        finalRewardPoints = (contactRewardPoints + oldValueRewardPoints) - currentRedeemPoints;
                    } else { //TKT-001625
                        finalRewardPoints = contactRewardPoints;
                    }
                }
                
                else if(oldRecord.Active__c == FALSE && reward.Active__c == TRUE  ) {
                    if(oldRecord.RecordTypeId == reward.RecordTypeId) {
                        if(reward.RecordTypeId == earnRecordTypeId || reward.RecordTypeId == adjustAddRecordTypeId) {
                            finalRewardPoints = contactRewardPoints + currentRewardPoints;
                        }
                        else if(reward.RecordTypeId == adjustSubRecordTypeId) {
                            finalRewardPoints = contactRewardPoints - currentRewardPoints;
                        }
                        else if(reward.RecordTypeId == redeemRecordTypeId) {
                            finalRewardPoints = contactRewardPoints - currentRedeemPoints;
                        }
                    }
                    else if(oldRecord.RecordTypeId != reward.RecordTypeId) {
                        if((oldRecord.RecordTypeId == earnRecordTypeId || oldRecord.RecordTypeId == adjustAddRecordTypeId) &&
                           reward.RecordTypeId == adjustSubRecordTypeId) {
                               finalRewardPoints = contactRewardPoints - currentRewardPoints;
                           }
                        else  if((oldRecord.RecordTypeId == earnRecordTypeId || oldRecord.RecordTypeId == adjustAddRecordTypeId) &&
                                 reward.RecordTypeId == redeemRecordTypeId ) {
                                     finalRewardPoints = contactRewardPoints - currentRedeemPoints;
                                 }
                        else if((oldRecord.RecordTypeId == redeemRecordTypeId || oldRecord.RecordTypeId == adjustSubRecordTypeId) &&
                                (reward.RecordTypeId == earnRecordTypeId || reward.RecordTypeId == adjustAddRecordTypeId)) {
                                    finalRewardPoints = contactRewardPoints + currentRewardPoints;
                                }
                        else if((oldRecord.RecordTypeId == earnRecordTypeId && reward.RecordTypeId == adjustAddRecordTypeId) ||
                                (oldRecord.RecordTypeId == adjustAddRecordTypeId || reward.RecordTypeId == earnRecordTypeId)) {
                                    //need to analyze
                                    finalRewardPoints = contactRewardPoints + currentRewardPoints;
                                }
                        else if(oldRecord.RecordTypeId == redeemRecordTypeId && reward.RecordTypeId == adjustSubRecordTypeId) {
                            finalRewardPoints = contactRewardPoints - currentRewardPoints;
                        }
                        else if(oldRecord.RecordTypeId == adjustSubRecordTypeId || reward.RecordTypeId == redeemRecordTypeId) {
                            finalRewardPoints = contactRewardPoints - currentRedeemPoints;
                        }
                    }
                }
                
                else if(oldRecord.Active__c == TRUE && reward.Active__c == FALSE) {
                    if((oldRecord.RecordTypeId == earnRecordTypeId || oldRecord.RecordTypeId == adjustAddRecordTypeId) ||
                       (oldRecord.RecordTypeId == earnRecordTypeId && reward.RecordTypeId == adjustAddRecordTypeId) || 
                       (oldRecord.RecordTypeId == adjustAddRecordTypeId && reward.RecordTypeId == earnRecordTypeId) ||
                       ((oldRecord.RecordTypeId == reward.RecordTypeId) && (reward.RecordTypeId == earnRecordTypeId || reward.RecordTypeId == adjustAddRecordTypeId))) {
                           finalRewardPoints = (contactRewardPoints - oldValueRewardPoints) + currentRewardPoints;              
                       }
                }
                
                else {
                    finalRewardPoints = contactRewardPoints;
                }
                
                if(finalRewardPoints >= 0
                    && !(!reward.Active__c
                    && (reward.RecordTypeId == redeemRecordTypeId
                        || reward.RecordTypeId ==adjustSubRecordTypeId )) //ignore expired redeem and manual subtract
                    ) {
                    conMap.get(reward.Contact__c).RewardPoints__c = finalRewardPoints;
                }
                
                else {
                    if (finalRewardPoints < 0 && reward.Active__c == FALSE) {
                        conMap.get(reward.Contact__c).RewardPoints__c = 0;
                    }
                    else if(reward.Active__c == TRUE) {
                        reward.addError('Unable to save record - Insufficient points on Contact\'s Reward Points Balance');
                    } 
                }
            }
        }
        //temp fix - need to refactor the code       
        if(newMap.size() != numberOfExport) {
            update conMap.values();
        }
       
        if(!rewardforUpdateList.isEmpty()){
            update rewardforUpdateList;
        }
        //update conMap.values();
    }
    
    public static Map<Id,Contact> getRelatedContact(List<Reward__c> rewardList) {
        Set<Id> conIdSet = new Set<Id>();
        
        for(Reward__c reward : rewardList) {
            if(reward.Contact__c != null) {
                conIdSet.add(reward.Contact__c);
            }
        }
        
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select RewardPoints__c
                                                      FROM Contact
                                                      WHERE Id IN :conIdSet]);
        
        return conMap ;
    }
    
    public static Map<Id,Product2> getRelatedProduct(List<Reward__c> rewardList) {
        Set<Id> prodIdSet = new Set<Id>();
        
        for(Reward__c reward : rewardList) {
            if(reward.ProductForRedemption__c != null) {
                prodIdSet.add(reward.ProductForRedemption__c);
            }
        }
        
        Map<Id,Product2> prodMap = new Map<Id,Product2>([Select RewardsPointsRequired__c
                                                         FROM Product2
                                                         WHERE Id IN :prodIdSet]);
        
        return prodMap ;
    }
    
    public static Map<Id,Reward__c> getEarnAddRewards(List<Reward__c> rewardList, Boolean activeOnly) {
        Id earnRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_EARN_RECORDTYPE).getRecordTypeId();
        Id adjustAddRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_ADD_RECORDTYPE).getRecordTypeId();
        Set<Id> conIdSet = new Set<Id>();
        
        for(Reward__c reward : rewardList) {
            if(reward.Contact__c != null) {
                conIdSet.add(reward.Contact__c);
            }
        }
         Map<Id,Reward__c> earnAddRewardMap = new Map<Id,Reward__c>();
        if (activeOnly) {
            earnAddRewardMap = new Map<Id,Reward__c>([Select Id, PointsAmount__c, Consumed__c, Contact__c, ExpiryDate__c, CreatedDate
                                                                    FROM Reward__c
                                                                    WHERE Contact__c IN :conIdSet
                                                                    AND (RecordTypeId = :earnRecordTypeId OR RecordTypeId = :adjustAddRecordTypeId)
                                                                    AND Active__c = TRUE
                                                                    AND PointsAmount__c > 0
                                                                    ORDER BY CreatedDate, ExpiryDate__c]);
        } else {
            earnAddRewardMap = new Map<Id,Reward__c>([Select Id, PointsAmount__c, Consumed__c, Contact__c, ExpiryDate__c, CreatedDate
                                                                    FROM Reward__c
                                                                    WHERE Contact__c IN :conIdSet
                                                                    AND (RecordTypeId = :earnRecordTypeId OR RecordTypeId = :adjustAddRecordTypeId)                                                                 
                                                                    ORDER BY CreatedDate, ExpiryDate__c]);            
        }     
        
        return earnAddRewardMap ;
    }
    
    public static List<Reward__c> getEarnAddInactiveRewards(List<Reward__c> rewardList) {
        Id earnRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_EARN_RECORDTYPE).getRecordTypeId();
        Id adjustAddRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_ADD_RECORDTYPE).getRecordTypeId();
        Set<Id> conIdSet = new Set<Id>();
        
        for(Reward__c reward : rewardList) {
            if(reward.Contact__c != null) {
                conIdSet.add(reward.Contact__c);
            }
        }
        
        List<Reward__c> earnAddInactiveRewardList = [Select Id, PointsAmount__c, Consumed__c, Contact__c, ExpiryDate__c, CreatedDate
                                                     FROM Reward__c
                                                     WHERE Contact__c IN :conIdSet
                                                     AND (RecordTypeId = :earnRecordTypeId OR RecordTypeId = :adjustAddRecordTypeId)
                                                     AND ((Active__c = FALSE AND ExpiryDate__c > TODAY) OR (Active__c = TRUE AND PointsAmount__c != 0))
                                                     ORDER BY CreatedDate, ExpiryDate__c];
        
        return earnAddInactiveRewardList;
    }

    public static List<Reward__c> computeRedeemChanges(Reward__c reward, Reward__c oldRecord, Map<Id,Reward__c> earnAddRewardMap, List<Reward__c> earnAddInactiveRewardList) {          
        List<Reward__c> rewardforUpdateList = new List<Reward__c>();       
        Decimal currentRedeemPoints = reward.Quantity__c * reward.PointsAmount__c;
        Decimal oldQuantity = oldRecord.Quantity__c == null ? 1 : oldRecord.Quantity__c;
        Decimal oldValueRedeemPoints = oldQuantity * oldRecord.PointsAmount__c;

        //if the updated points is lower than the previous points, there might be "earn" rewards that has been inactive before 
        //because it was consume when the "redeem" reward was inserted if the redeem is much greater to the earn
        //need to enable those inactive earn records              
        if( oldValueRedeemPoints > currentRedeemPoints && !earnAddInactiveRewardList.isEmpty()) {
            for(Reward__c earnAdjustInactiveRec : earnAddInactiveRewardList) {
                if(reward.Contact__c == earnAdjustInactiveRec.Contact__c) {
                    earnAdjustInactiveRec.PointsAmount__c  = earnAdjustInactiveRec.PointsAmount__c + (oldValueRedeemPoints - currentRedeemPoints);
                    earnAdjustInactiveRec.Consumed__c = earnAdjustInactiveRec.Consumed__c - (oldValueRedeemPoints - currentRedeemPoints);
                    
                    if(earnAdjustInactiveRec.PointsAmount__c > 0) {
                        earnAdjustInactiveRec.Active__c = TRUE;
                    }
                    rewardforUpdateList.add(earnAdjustInactiveRec);
                    break;
                }
            }
        }
        
        else if(oldValueRedeemPoints < currentRedeemPoints) {
            Decimal actualPoints = currentRedeemPoints - oldValueRedeemPoints;           
            
            for(Reward__c earnAdjustRec : earnAddRewardMap.values()) {                
                if(reward.Contact__c == earnAdjustRec.Contact__c) {
                    if(actualPoints <= earnAdjustRec.PointsAmount__c) {
                        earnAdjustRec.PointsAmount__c  = earnAdjustRec.PointsAmount__c - actualPoints;
                        earnAdjustRec.Consumed__c = earnAdjustRec.Consumed__c + actualPoints;
                        if(earnAdjustRec.PointsAmount__c == 0) {
                            earnAdjustRec.Active__c = FALSE;
                        }
                        rewardforUpdateList.add(earnAdjustRec);
                        break;
                    } 
                    else if(actualPoints > earnAdjustRec.PointsAmount__c) {
                        actualPoints = actualPoints - earnAdjustRec.PointsAmount__c;
                        earnAdjustRec.Consumed__c = earnAdjustRec.Consumed__c + earnAdjustRec.PointsAmount__c;
                        earnAdjustRec.PointsAmount__c = earnAdjustRec.PointsAmount__c - earnAdjustRec.PointsAmount__c;                       
                        //actualPoints = actualPoints - earnAdjustRec.PointsAmount__c;
                        if(earnAdjustRec.PointsAmount__c == 0) {
                            earnAdjustRec.Active__c = FALSE;
                        }
                        rewardforUpdateList.add(earnAdjustRec);
                    }
                }
            }            
        }
        
        return rewardforUpdateList;
    }

    public static List<Reward__c> computeSubtractEarnChanges(Reward__c reward, Reward__c oldRecord, Map<Id,Reward__c> earnAddRewardMap, List<Reward__c> earnAddInactiveRewardList) {
        List<Reward__c> rewardforUpdateList = new List<Reward__c>();       
        if(oldRecord.PointsAmount__c > reward.PointsAmount__c && !earnAddInactiveRewardList.isEmpty()) {
            for(Reward__c earnAdjustInactiveRec : earnAddInactiveRewardList) {
                if(reward.Contact__c == earnAdjustInactiveRec.Contact__c) {
                    earnAdjustInactiveRec.PointsAmount__c  = earnAdjustInactiveRec.PointsAmount__c + (oldRecord.PointsAmount__c - reward.PointsAmount__c);

                    if(earnAdjustInactiveRec.PointsAmount__c > 0) {
                        earnAdjustInactiveRec.Active__c = TRUE;
                    }
                    rewardforUpdateList.add(earnAdjustInactiveRec);
                    break;
                }
            }
        } else if(oldRecord.PointsAmount__c < reward.PointsAmount__c) {
            Decimal actualPoints = reward.PointsAmount__c - oldRecord.PointsAmount__c;

            for(Reward__c earnAdjustRec : earnAddRewardMap.values()) {
                if(reward.Contact__c == earnAdjustRec.Contact__c) {
                    if(actualPoints <= earnAdjustRec.PointsAmount__c) {
                        earnAdjustRec.PointsAmount__c  = earnAdjustRec.PointsAmount__c - actualPoints;
                        earnAdjustRec.Consumed__c = earnAdjustRec.Consumed__c + actualPoints;
                        if(earnAdjustRec.PointsAmount__c == 0) {
                            earnAdjustRec.Active__c = FALSE;
                        }
                        rewardforUpdateList.add(earnAdjustRec);
                        break;
                    } 
                    else if(actualPoints > earnAdjustRec.PointsAmount__c) {
                        earnAdjustRec.Consumed__c = earnAdjustRec.Consumed__c + earnAdjustRec.PointsAmount__c;
                        actualPoints = actualPoints - earnAdjustRec.PointsAmount__c;
                        earnAdjustRec.PointsAmount__c = earnAdjustRec.PointsAmount__c - earnAdjustRec.PointsAmount__c;
                        //actualPoints = actualPoints - earnAdjustRec.Consumed__c;
                        //actualPoints = actualPoints - earnAdjustRec.PointsAmount__c;
                        if(earnAdjustRec.PointsAmount__c == 0) {
                            earnAdjustRec.Active__c = FALSE;
                        }
                        rewardforUpdateList.add(earnAdjustRec);
                    }
                }
            }
        }
        return rewardforUpdateList;          
    }
    /* This method to get the total reward points and put it in the related membership record*/
    public static void sumOfTotalPoints(List<Reward__c> newList){
        Id adjustAddRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_ADD_RECORDTYPE).getRecordTypeId();
        Id adjustSubRecordTypeId = Schema.SObjectType.Reward__c.getRecordTypeInfosByName().get(CommonConstant.REWARD_ADJUST_SUBTRACT_RECORDTYPE).getRecordTypeId();
        
        Set<Id> memIdSet = new Set<Id>();
        Map<Id, Membership__c> rewardMemMap = new Map<Id, Membership__c>(); // maps the Reward and Membership Record   
        
        for(Reward__c reward : newList) {
            if(reward.Membership__c != null) {
                memIdSet.add(reward.Membership__c);
            }
        }
        
        
        if(!memIdSet.isEmpty()){
            
            Map<Id, Membership__c> membershipMap = new Map<Id, Membership__c>([SELECT Id, Total_Reward__c FROM Membership__c WHERE Id IN :memIdSet]);
            for(Reward__c reward : newList){ //maps the rewardMemMap
                if(!rewardMemMap.containsKey(reward.Id)){
                    rewardMemMap.put(reward.Id, membershipMap.get(reward.Membership__c));
                }
            }
            
            List<Reward__c> rewardAddMap = new List<Reward__c> ([Select id, PointsAmount__c, recordtype.name
                                                                 FROM Reward__c
                                                                 WHERE Membership__c IN :memIdSet
                                                                 AND RecordTypeId = :adjustAddRecordTypeId
                                                                 AND Active__c = True]);
            
            List<Reward__c> rewardSubstractMap = new List<Reward__c> ([Select id, PointsAmount__c, recordtype.name
                                                                       FROM Reward__c
                                                                       WHERE Membership__c IN :memIdSet
                                                                       AND RecordTypeId = :adjustSubRecordTypeId
                                                                       AND Active__c = True]);
            Decimal finalPoints = 0;
            Decimal addFinalPoints = 0;
            Decimal subtractFinalPoints = 0;
            
            for(Reward__c rewardAdd : rewardAddMap){
                if(rewardAdd.PointsAmount__c != null)
                addFinalPoints = addFinalPoints + rewardAdd.PointsAmount__c;
            }
            
            for(Reward__c rewardSubtract : rewardSubstractMap){
                if(rewardSubtract.PointsAmount__c != null)
                subtractFinalPoints = subtractFinalPoints + rewardSubtract.PointsAmount__c;
            }
            
            finalPoints = addFinalPoints - subtractFinalPoints;
            
            List<Membership__c> memListToUpdate = new List<Membership__c>();
            
            for(Reward__c reward : newList) {
                if(reward.RecordTypeId == adjustAddRecordTypeId || reward.RecordTypeId == adjustSubRecordTypeId) {
                    if(rewardMemMap.containsKey(reward.Id)){
                        Membership__c rewardMembership = rewardMemMap.get(reward.Id);
                        if(!memListToUpdate.contains(rewardMembership)){                    
                            rewardMembership.Total_Reward__c = finalPoints;
                            memListToUpdate.add(rewardMembership);
                        }
                    }
                }
                /* commented by Crissar Ibarra - 11/15/2021*/
                /*
                else{
                reward.addError('Unable to save record - Insufficient points on Contact\'s Reward Points Balance');
                }
                */
                
            } 
            if(!memListToUpdate.IsEmpty()){                
                update memListToUpdate;
            }        
        }
        
    }
   
}