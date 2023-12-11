public class MC_Milestones_Queueable implements Queueable {
    
    private Boolean isNew = false;
    private Set<Id> milestones;
    public MC_Milestones_Queueable(Boolean i, Set<Id> milestoneIds){
        isNew = i;
        milestones = milestoneIds; 
    }
    
    public void execute(QueueableContext context) {
        Map<Id, Milestone__c> milestoneMap = new Map<Id, Milestone__c>();
        // get all milestone
        if(isNew) {
            Datetime dt = Datetime.now();
            Datetime dtEightHrsBefore = dt.addHours(-8);
            milestoneMap = new Map<Id, Milestone__c>(
                [SELECT Id, Market__c
                 FROM Milestone__c
                 WHERE isActive__c = true
                 AND (Last_Processed_Datetime__c = null OR Last_Processed_Datetime__c < :dtEightHrsBefore)
                 ORDER BY Last_Processed_Datetime__c,Market__c ASC]);
            milestones = new Set<Id>();
            milestones.addAll(milestoneMap.keySet());
            System.debug(milestones.size());
        }
        else{
            milestoneMap = new Map<Id, Milestone__c>(
                [SELECT Id, Market__c
                 FROM Milestone__c
                 WHERE Id IN: milestones]);
        }
        
        // get number of queued
        /*Integer queued = [SELECT Id
                          FROM AsyncApexJob
                          WHERE Status != 'Completed'
                          AND Status != 'Failed'
                          AND Status != 'Aborted'].size();*/
        
        List<Milestone__c> msUpdateList = new List<Milestone__c>();
        //Process Milestone
        for(Integer x = 1; x != 5; x++){ // set 5 jobs at a time, jobs run 5 at a time anyway
            
            Set<Id> milestoneToProcess = new Set<Id>();
            for(Id msId: milestones.clone()){
                
                if(milestoneMap.containsKey(msId)){
                    Milestone__c msRec = milestoneMap.get(msId);
                
                    // VN market 1 at a time due to large set of Contact data - reaching apex soql limit
                    if(msRec.Market__c == 'VN'){
                        if(milestoneToProcess.isEmpty()){
                            milestoneToProcess.add(msId);
                            milestones.remove(msId);
                            msRec.Last_Processed_Datetime__c = Datetime.now();
                            msUpdateList.add(msRec);
                        }
                        Database.executebatch(new MC_Milestones(milestoneToProcess), 50);
                        break;
                    }
                    else{
                        milestoneToProcess.add(msId);
                        milestones.remove(msId);
                        msRec.Last_Processed_Datetime__c = Datetime.now();
                        msUpdateList.add(msRec);
                        // track 2 milestones at a time
                        if(milestoneToProcess.size() == 2 || milestones.isEmpty()){
                            Database.executebatch(new MC_Milestones(milestoneToProcess), 50);
                            break;
                        }
                    }
                }
            }
        }

        if(!msUpdateList.isEmpty()){
            update msUpdateList;
        }

        
        // if there is still milestone to process. EnqueueJob
        if(!milestones.isEmpty()) System.enqueueJob(new MC_Milestones_Queueable(false, milestones));
    }
}