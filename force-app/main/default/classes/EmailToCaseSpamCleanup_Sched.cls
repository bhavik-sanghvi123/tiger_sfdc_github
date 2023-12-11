public class EmailToCaseSpamCleanup_Sched implements Schedulable {
    
    String market = '';
    public EmailToCaseSpamCleanup_Sched(String m){ market = m; }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new EmailToCaseSpamCleanup_Batch(market), 50);
    }
}