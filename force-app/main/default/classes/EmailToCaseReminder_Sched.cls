public class EmailToCaseReminder_Sched implements Schedulable {
    
    String market = '';
    public EmailToCaseReminder_Sched(String m){ market = m; }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new EmailToCaseReminder_Batch(market), 50);
    }
}