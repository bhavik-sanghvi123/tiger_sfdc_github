/**
* @author        Rey Austral
* @date          1.17.2019
* @description   Batch job to run daily to update the milk code restriction field of the contact object
* @testClass     MilkCodeRestrictionBatchTest
* @revision(s)
*/
global class MilkCodeRestrictionBatch implements Database.Batchable<sObject> {	
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//get the largest month to be used in the filter
		//to include all country 
		//AffiliateMetadata__mdt is a custom meta data 

		List<AffiliateMetadata__mdt> am = [Select MasterLabel, MilkCodeRestrictionPeriod__c 
											From AffiliateMetadata__mdt Where MilkCodeRestrictionPeriod__c != null
											order by MilkCodeRestrictionPeriod__c desc limit 1];
		//Birthday = THIS_MONTH is not working properly. it gets all the date from other year
		//Birthdate  >= LAST_N_MONTHS will not get the current month				
		//LAST_N_MONTHS not working when exceed 11 months
		//Weird behavior when include Birthday < TODAY, only current year is being selected
		Date startDate = Date.today().addMonths(-am.get(0).MilkCodeRestrictionPeriod__c.intValue());
		String stringStartDate= String.valueOf(startDate); 

        String query = 'SELECT ID , MilkCodeRestriction__c, Account.Market__c, Birthdate'                           
            + ' FROM Contact'
            + ' WHERE'
            + ' Type__c  = \'' + CommonConstant.CONTACT_CHILD_TYPE + '\''
            + ' AND MilkCodeRestriction__c = false'           
            + ' AND Birthdate  >= ' + stringStartDate.remove(' 00:00:00');
        System.debug(query);
        return Database.getQueryLocator(query);
    }

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
   		List<AffiliateMetadata__mdt> am = [Select MasterLabel, MilkCodeRestrictionPeriod__c 
											From AffiliateMetadata__mdt Where MilkCodeRestrictionPeriod__c != null
											];
		Map<String, String> acs = UtilityClass.convertObjToMap(am, CommonConstant.AFFILIATE_MASTERLABEL , CommonConstant.AFFILIATE_MILKRESTRICTION);
   		System.debug(acs);
   		List<Contact> contactToUpdate = New List<Contact>();
		for(Contact con : scope) {  
			if (acs.containsKey(con.Account.Market__c)) {
				String settings = acs.get(con.Account.Market__c);
				Date computedDate = con.Birthdate.addMonths(Integer.valueOf(settings));
				//the current date should be between bday and (bday+custom settings)
				if (Date.today() >= con.Birthdate && Date.today() <= computedDate) {
					con.MilkCodeRestriction__c = true;
					contactToUpdate.add(con);
				}
			}			
		}
		
		if(!contactToUpdate.isEmpty()) {
			Update contactToUpdate;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}