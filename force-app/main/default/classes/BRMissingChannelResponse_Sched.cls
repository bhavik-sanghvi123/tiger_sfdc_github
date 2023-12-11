public class BRMissingChannelResponse_Sched implements Schedulable {
    public void execute(SchedulableContext sc) {
        database.executebatch(new BRMissingChannelResponse_Batch(''));
    }
}