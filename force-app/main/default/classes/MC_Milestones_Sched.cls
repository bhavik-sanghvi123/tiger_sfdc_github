public class MC_Milestones_Sched implements Schedulable {

    public void execute(SchedulableContext SC) {
        System.enqueueJob(new MC_Milestones_Queueable(true, null));
    }
}