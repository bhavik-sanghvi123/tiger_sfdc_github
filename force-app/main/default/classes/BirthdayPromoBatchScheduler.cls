/**
* @author        Monika Parihar
* @date          04.08.2021
* @description   Class to execute batch job BirthdayPromoBatch
* @testClass     BirthdayPromoBatchTest
* @revision(s) 
*/
global class BirthdayPromoBatchScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    BirthdayPromoBatch b = new BirthdayPromoBatch();
    database.executebatch(b, 200);
  }
}