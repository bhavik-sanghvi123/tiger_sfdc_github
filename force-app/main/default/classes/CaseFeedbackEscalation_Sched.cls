public class CaseFeedbackEscalation_Sched implements Schedulable {
    
    String market = '';
    public CaseFeedbackEscalation_Sched(String m){ market = m; }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CaseFeedbackEscalation_Batch(market));
    }
}