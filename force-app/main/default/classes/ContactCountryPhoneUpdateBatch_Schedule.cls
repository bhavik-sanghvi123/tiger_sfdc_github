/**
* @author        Sean Cordova
* @date          10.11.2021
* @description   Class to execute batch job ContactCountryPhoneUpdateBatch
* @revision(s) 
*/
global class ContactCountryPhoneUpdateBatch_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        ContactCountryPhoneUpdateBatch ccpub = new ContactCountryPhoneUpdateBatch();
        database.executebatch(ccpub, 200);
    }
}