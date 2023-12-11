@isTest
private class THContactTriggerHandlerTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'TH');
        insert sysad;
        
        System.runAs(sysad) {
	    	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
	    	lProduct.get(0).Market__c = 'TH';
	    	lProduct.get(0).ProductCode = '123';
	    	Update lProduct;

			Id idRecType = Schema.sObjectType.Channel__c.getRecordTypeInfosByName().get(CommonConstant.CHANNEL_SOCIAL_RECORDTYPE).getRecordTypeId();
	    	List<Channel__c>  lChannel = TestDataFactory.createTestChannel(1);
	    	lChannel.get(0).Market__c = 'TH';
	    	lChannel.get(0).Channel_Ref_No__c = 'FB';
	    	lChannel.get(0).Name = 'FB';
			lChannel.get(0).RecordTypeId = idRecType;
	    	update lChannel;

	        TestDataFactory.createAffiliate('TH','English');
	        TestDataFactory.createAffiliate('TH','Malay');

	        Campaign cam = TestDataFactory.createCampaign('Cam','Similac','TH');
	        cam.ExternalId__c = '123';
	        Insert cam;

	       
	        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
	        lRegion.get(0).Market__c = 'TH';
	        update lRegion;

	        TestDataFactory.createTestWard(1, 'TH');
	        TestDataFactory.createTestDistrict(1, 'TH');
	        TestDataFactory.createTestEthnicity(1, 'TH');
	        TestDataFactory.createTestSwitchReason(1, 'TH');
	      
		}
    }

	@isTest static void test_insertRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
				//validate language
				TH_Contact_Manual__c rec = new TH_Contact_Manual__c();
				rec.contact_preferredlanguage__c = 'Tagalog';
				Boolean hasError = false;
				try {
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}
				//validate product
				rec = validData();
				try {
					rec.cr_sampleproductid__c = '1234';
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				rec = validData();		
				//validate brand
				try {
					rec.br_brandid__c = '1235';
					rec.br_brandname__c = 'ProductName -12';
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate campaign
				rec = validData();
				try {
					rec.cr_campaignid__c = '1234';
					rec.cr_campaignname__c = 'Invalid';
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				try {
					rec.cr_campaignid__c = '1234';
					rec.cr_campaignname__c = '';
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate dates
				rec = validData();		
				try {
					rec.contact_dob__c = '23/23/2015';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}
				/*
				rec = validData();		
				try {
					rec.child_dob__c = '23/23/2015';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}*/
				
				rec = validData();		
				try {
					rec.contact_edd__c = '23/23/2015';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				
				/*
				rec = validData();		
				try {
					rec.cr_registrationdate__c = '23/23/2015';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}*/

				//validate channel
				rec = validData();		
				try {
					rec.cr_channelid__c = '';
					rec.cr_channelname__c = 'Invalid';
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate channel
				rec = validData();		
				try {
					rec.cr_channelid__c = 'FB';
					rec.cr_channelname__c = 'Invalid';
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}


				rec = validData();		
				try {
					rec.addr_district__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				rec = validData();		
				try {
					rec.addr_region__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				
				//validate phone
				rec = validData();		
				try {
					rec.contact_homephone__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				try {
					rec.contact_homephone__c = 'ph:Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				rec = validData();		
				try {
					rec.contact_mobilephone__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				rec = validData();		
				try {
					rec.contact_mobilephone__c = 'ph:Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				rec = validData();		
				try {
					rec.contact_otherphone__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				rec = validData();		
				try {
					rec.contact_otherphone__c = 'ph:Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate email
				rec = validData();		
				try {
					rec.contact_email__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate lastname
				rec = validData();		
				try {
					rec.contact_lastname__c = '';				
					
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}


				rec = validData();		
				try {
					rec.br_brandid__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate contact_ethnicity__c
				rec = validData();		
				try {
					rec.contact_ethnicity__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate status
				rec = validData();		
				try {
					rec.br_relationstatus__c = 'Contacted';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}
				//validate type
				rec = validData();		
				try {
					rec.br_relationtype__c = 'Lead';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}
               
				System.assertEquals(true, hasError,'There should be an error');

                 //test other dml
                rec = validData();		
                try {
                    insert rec;
                    update rec;
                    delete rec;
                }catch(Exception ex) {
					hasError = false;
				}

                System.assertEquals(true, hasError,'There should be no error');
			System.Test.stopTest();
		}
	}

	public 	static TH_Contact_Manual__c validData() {
		TH_Contact_Manual__c rec = new TH_Contact_Manual__c();
		rec.br_brandid__c = '123';
		rec.br_brandname__c = 'ProductName -1';
		rec.cr_channelid__c = 'FB' ;
		rec.cr_channelname__c = 'FB';
		rec.contact_lastname__c = 'Last';
		rec.br_relationstatus__c = 'New';		
		rec.addr_country__c = 'country';
		rec.contact_mobilephone__c = 'ph:09053444444';
		rec.br_relationtype__c = 'User';
		rec.cr_registrationdate__c = '10/01/2020';
		rec.contact_email__c = 'test@test.com';
		rec.cr_sampleproductid__c = '123';

		return rec;
	}
	
}