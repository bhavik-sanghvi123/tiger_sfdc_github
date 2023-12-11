/*----------------------------------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Batch Class to Deactivate Rewards based on Expiry Date value

History
01/15/2019   vmirandilla   Created
02/22/2021   malviz        TKT-003431: Added checking on primary contact mobile
-------------------------------------------------------------------------------------------*/
public class DeactivateRewardsBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Active__c,'
                            + ' ExpiryDate__c,'
                            + ' Contact__c,Contact__r.Phone,Contact__r.PrimaryContact__c,'
                            + ' RecordType.Name,'
                            + ' PointsAmount__c'
                            + ' FROM Reward__c'
                            + ' WHERE'
                            + ' (RecordType.Name = \'Earn\' OR RecordType.Name = \'Adjust (Add)\') AND Active__c = TRUE AND ExpiryDate__c <= TODAY';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Reward__c > scope) {
        
        Set<Id> conIdSet = new Set<Id>();
        Boolean hasMobile = true;
        for(Reward__c rec : scope) {
            //phone is mandatory for primary contacts
            //check if primary contact has mobile to prevent validation error upon saving contact
            if(rec.Contact__r.PrimaryContact__c = true && rec.Contact__r.Phone == null){
                hasMobile = false;
            }
            if(rec.Contact__c != null && hasMobile) {
                conIdSet.add(rec.Contact__c);
            }
        }
        
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select Id, RewardPoints__c
                                                            FROM Contact
                                                            WHERE Id IN :conIdSet]);
        Map<Id, Contact> conUpdateMap = new Map<Id, Contact>();
        List<Reward__c> rewardUpdateList = new List<Reward__c>();
        for(Reward__c reward : scope) {
            if(conMap.containsKey(reward.Contact__c)) {
                Decimal rewardPointsAmount;
                Decimal conRewardPoints;
                Contact updatedCon;
                Contact con = conMap.get(reward.Contact__c);
                if(!conUpdateMap.containsKey(con.Id)){
                    updatedCon = con;
                }
                else{
                    updatedCon = conUpdateMap.get(con.Id);
                }

                rewardPointsAmount = reward.PointsAmount__c != null ? reward.PointsAmount__c : 0;
                conRewardPoints = updatedCon.RewardPoints__c != null ? updatedCon.RewardPoints__c : 0;
                if(rewardPointsAmount > conRewardPoints) {
                    updatedCon.RewardPoints__c = 0;
                } else {
                    updatedCon.RewardPoints__c = conRewardPoints - rewardPointsAmount;
                }
                reward.Active__c = FALSE;
                conUpdateMap.put(updatedCon.Id, updatedCon);
                rewardUpdateList.add(reward);
            }
        }

        if(!rewardUpdateList.isEmpty()) UtilityClass.updateList(rewardUpdateList);
        if(!conUpdateMap.keySet().isEmpty()) UtilityClass.updateList(conUpdateMap.values());
    }
    
    public void finish(Database.BatchableContext BC) {
    }
}