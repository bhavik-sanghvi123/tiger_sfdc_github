public class ProcessLREngineBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private Boolean isDelete {get; set;}
    private Integer executionCounter {get; set;}
    private List<LookupRollupSummary__mdt> lrSummary;
    private Integer sizeList;
    
    
    public ProcessLREngineBatch(List<LookupRollupSummary__mdt> lrSummary){
        this.lrSummary = lrSummary;
        this.isDelete = false;
        this.sizeList = lrSummary.size();
        this.executionCounter = 0;
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc){
        String query;
        Set<Id> parentIds = new Set<Id>();
		LookupRollupSummary__mdt lrSum = lrSummary[executionCounter];
        if(!isDelete){
            String historyQuery;
            List<SObject> createdRec = new List<SObject>();
            if(lrSum.ChildObject__c.contains('__c')){
                String histObj = lrSum.ChildObject__c.replace('__c','__History');
                system.debug(histObj);
                historyQuery = 'SELECT Id,ParentId FROM ' + histObj + ' WHERE Field=\'created\' AND Createddate>=Last_N_Days:1';
            }
            else{
                historyQuery = 'SELECT Id,' + lrSum.ChildObject__c + 'Id FROM ' + lrSum.ChildObject__c + 'History WHERE Field=\'created\' AND Createddate>=Last_N_Days:1';
            }
            if(lrSum.History_Filter__c!=null){
                historyQuery += ' AND ' +lrSum.History_Filter__c;
            }

            List<SObject> historyRec = Database.query(historyQuery);
            if(!historyRec.isEmpty()){
                for(SObject hr : historyRec){
                    if(hr.get('ParentId') != null){
                        parentIds.add((Id)hr.get('ParentId'));
                    }
                    else if(hr.get(lrSum.ChildObject__c + 'Id') != null){
                        parentIds.add((Id)hr.get(lrSum.ChildObject__c + 'Id'));
                    }
                }
                
            }
            if(Test.isRunningTest()){
                for(SObject obj: Database.query('SELECT Id FROM ' + lrSum.ChildObject__c )){
                    parentIds.add((Id) obj.get('Id'));
                }
            }
            query = 'SELECT ' + lrSum.RollupFieldname__c + ',' + lrSum.ChildFieldname__c + ' FROM ' + lrSum.ChildObject__c + ' WHERE Id IN :parentIds AND Createddate>=Last_N_Days:' + Integer.valueof(lrSum.No_of_Days__c);
        }
        else{
            query = 'SELECT ' + lrSum.RollupFieldname__c + ',' + lrSum.ChildFieldname__c + ' FROM ' + lrSum.ChildObject__c + ' WHERE Createddate>=Last_N_Days:' + Integer.valueof(lrSum.No_of_Days__c) + ' AND IsDeleted=true ALL ROWS';
        }
        system.debug(query);
        return Database.query(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> objects){
        LookupRollupSummary__mdt lrSum = lrSummary[executionCounter];
        Schema.SObjectType parentSObj = ((SObject) Type.forName(lrSum.ParentObject__c).newInstance()).getSObjectType();
        Schema.SObjectType childSObj = ((SObject) Type.forName(lrSum.ChildObject__c).newInstance()).getSObjectType();
        String lreQuery;
        
        if(String.isEmpty(lrSum.Query__c)){
            lreQuery = 'Createddate>=Last_N_Days:' + Integer.valueof(lrSum.No_of_Days__c);
        }
        else{
            lreQuery = lrSum.Query__c + ' AND Createddate>=Last_N_Days:' + Integer.valueof(lrSum.No_of_Days__c);
        }
        LREngine.Context ctx = new LREngine.Context(parentSObj, // parent object
                                                    childSObj,  // child object
                                                    childSObj.getDescribe().fields.getMap().get(lrSum.ChildFieldname__c).getDescribe(), // relationship field name
                                                    lreQuery);
        if(lrSum.ParentFieldname__c!=null && 
           lrSum.RollupFieldname__c!=null && 
           lrSum.RollupOperation__c!=null &&
           parentSObj !=null &&
           childSObj!=null){
            ctx.add(
            new LREngine.RollupSummaryField(
                parentSObj.getDescribe().fields.getMap().get(lrSum.ParentFieldname__c).getDescribe(),
                childSObj.getDescribe().fields.getMap().get(lrSum.RollupFieldname__c).getDescribe(),
                LREngine.RollupOperation.valueOf(lrSum.RollupOperation__c)
            ));
        }
        
        
        Sobject[] masters = LREngine.rollUp(ctx, objects);    
        
        system.debug(masters);
        if(!masters.isEmpty()){
            //update masters;
        }
        
    }
    
    public void finish(Database.BatchableContext bc){

        
        if(!isDelete){
            ProcessLREngineBatch deleteBatch = new ProcessLREngineBatch(lrSummary);
            deleteBatch.isDelete = true;
            deleteBatch.executionCounter = executionCounter;
            Database.executeBatch(deleteBatch);
        }
        else{
            executionCounter++;
            if(executionCounter < sizeList){
                ProcessLREngineBatch nextSummary = new ProcessLREngineBatch(lrSummary);
                nextSummary.executionCounter = executionCounter;
                Database.executeBatch(nextSummary);
            }
        }
    }

}