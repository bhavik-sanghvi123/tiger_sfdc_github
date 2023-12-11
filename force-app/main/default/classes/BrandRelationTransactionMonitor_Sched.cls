/**
* @author        Jericson Mercado
* @date          11.04.2019
* @description   Class to execute batch job BrandRelationTransactionMonitor
* @testClass     BrandRelationTransactionMonitor_Test
* @revision(s) 
*/
public class BrandRelationTransactionMonitor_Sched implements Schedulable {
    public void execute(SchedulableContext sc) {
        database.executebatch(new BrandRelationTransactionMonitor(false), 50);
    }
}