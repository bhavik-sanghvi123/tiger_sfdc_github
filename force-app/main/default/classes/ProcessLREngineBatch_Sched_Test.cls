@IsTest
public class ProcessLREngineBatch_Sched_Test {
	@isTest static void testMethod1() {
        Test.startTest();
        ProcessLREngineBatch_Sched plrEngineBatch = new ProcessLREngineBatch_Sched();
        String sch = '0 30 9 * * ?'; 
        system.schedule('ProcessLREngineBatch_Sched_TC', sch, plrEngineBatch); 
        Test.stopTest();
       
    }
}