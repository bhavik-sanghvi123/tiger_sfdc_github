public class PostChannelResponseTrigger_Sched {} /*implements Schedulable {

    static Boolean checkHistory = true;
    static String queryOverride = '';
    public PostChannelResponseTrigger_Sched(Boolean isHistory, String queryOverrideStr){
        if(!isHistory) {
            checkHistory = false;
            queryOverride = queryOverrideStr;
        }
    }

    public void execute(SchedulableContext SC) {
        if(!UtilityClass.IsTriggerActive('PostChannelResponseTriggerviaTrigger'))
            Database.executeBatch(new PostChannelResponseTrigger_Batch(checkHistory, queryOverride));
    }
}*/