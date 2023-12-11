public class ExportCallBatch_Sched_VN implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        String market = Test.isRunningTest() ? 'PH' : 'VN';
        Database.executeBatch(new ExportCallBatch2(Market), 20);
    }
}