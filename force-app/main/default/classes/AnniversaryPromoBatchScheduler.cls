/**
* @author        Monika Parihar
* @date          04.08.2021
* @description   Class to execute batch job AnniversaryPromoBatch
* @testClass     AnniversaryPromoBatchTest
* @revision(s) 
*/
global class AnniversaryPromoBatchScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    AnniversaryPromoBatch b = new AnniversaryPromoBatch();
    database.executebatch(b, 200);
  }
}