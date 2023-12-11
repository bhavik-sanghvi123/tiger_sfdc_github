public class ContactTransactionDate_Sched implements Schedulable {
    public void execute(SchedulableContext sc) {
        database.executebatch(new ContactTransactionDate_Batch(''));
    }
}