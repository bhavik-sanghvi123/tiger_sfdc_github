public class OrderMonitoring_Sched implements Schedulable {
    public void execute(SchedulableContext sc) {
        OrderMonitoring om = new OrderMonitoring ();
        Database.executebatch(om);
    }
}