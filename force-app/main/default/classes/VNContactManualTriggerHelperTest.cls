@isTest
private class VNContactManualTriggerHelperTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
        System.runAs(sysad) {
	    	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
	    	lProduct.get(0).Market__c = 'VN';
	    	lProduct.get(0).ProductCode = '123';
	    	Update lProduct;

	    	List<Channel__c>  lChannel = TestDataFactory.createTestChannel(1);
	    	lChannel.get(0).Market__c = 'VN';
	    	lChannel.get(0).Channel_Ref_No__c = 'FB';
	    	lChannel.get(0).Name = 'FB';
			lChannel.get(0).RecordTypeId = Schema.SObjectType.Channel__c.getRecordTypeInfosByName().get(CommonConstant.CHANNEL_OTHER_ONLINE_RECORDTYPE).getRecordTypeId();
	    	update lChannel;

	        TestDataFactory.createAffiliate('VN','English');
	        TestDataFactory.createAffiliate('VN','Malay');

	        Campaign cam = TestDataFactory.createCampaign('Cam','Similac','VN');
	        cam.ExternalId__c = '123';
	        Insert cam;

	        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
	        lCity.get(0).Market__c = 'VN';
	        update lCity;

	        List<Affiliate_Value__c> lRegion = TestDataFactory.createTestRegion(1);
	        lRegion.get(0).Market__c = 'VN';
	        update lRegion;

	        TestDataFactory.createTestWard(1, 'VN');
	        TestDataFactory.createTestDistrict(1, 'VN');
	        TestDataFactory.createTestEthnicity(1, 'VN');
	        TestDataFactory.createTestSwitchReason(1, 'VN');
	      
		}
    }

	@isTest static void test_insertRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
				//validate language
				VN_Contact_Manual__c rec = new VN_Contact_Manual__c();
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
				
				rec = validData();		
				try {
					rec.child_dob__c = '23/23/2015';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}
				
				rec = validData();		
				try {
					rec.contact_edd__c = '23/23/2015';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				rec = validData();		
				try {
					rec.sourcecreateddate__c = '23/23/2015';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				rec = validData();		
				try {
					rec.cr_registrationdate__c = '23/23/2015';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				

				//validate address
				rec = validData();		
				try {
					rec.addr_city__c = 'Invalid';				
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

				rec = validData();		
				try {
					rec.addr_ward__c = 'Invalid';				
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate reason
				rec = validData();		
				try {
					rec.br_brandswitchreason__c = 'Invalid';				
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

				rec = validData();		
				try {
					rec.contact_mobilephone__c = 'Invalid';				
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
					rec.contact_fullname__c = 'Full';
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				//validate brand
				rec = validData();		
				try {
					rec.br_currbrandid__c = 'Invalid';				
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

				//validate channel
				rec = validData();		
				try {
					rec.cr_channelid__c = '';
					rec.cr_channelname__c = 'Invalid';
					insert rec;
				} catch(Exception ex) {
					hasError = true;
				}

				System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}

	public 	static VN_Contact_Manual__c validData() {
		VN_Contact_Manual__c rec = new VN_Contact_Manual__c();
		rec.br_brandid__c = '123';
		rec.br_brandname__c = 'ProductName -1';
		rec.cr_channelid__c = 'FB' ;
		rec.cr_channelname__c = 'FB';
		rec.contact_lastname__c = 'Last';
		rec.br_relationstatus__c = 'New';
		rec.addr_streetline1__c = 'add';
		rec.addr_city__c = 'Test City';
		rec.addr_country__c = 'country';
		rec.contact_mobilephone__c = '09053444444';
		rec.br_relationtype__c = 'User';
		rec.cr_registrationdate__c = '5/5/2019';
		rec.contact_email__c = 'test@test.com';
		rec.cr_sampleproductid__c = '123';

		return rec;
	}
	
}