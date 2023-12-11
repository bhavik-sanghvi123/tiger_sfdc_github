@isTest
private class VNCallManualTriggerHelperTest {
	@testsetup
    static void setupData() {
    	User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'VN');
        insert sysad;
        
        System.runAs(sysad) {
	    	List<Product2> lProduct = TestDataFactory.createTestBrandProduct(1);
	    	lProduct.get(0).Market__c = 'VN';
	    	lProduct.get(0).ProductCode = '123';
	    	Update lProduct;

	        List<Affiliate_Value__c> lCity = TestDataFactory.createTestCity(1);
	        lCity.get(0).Market__c = 'VN';
	        update lCity;        

	        TestDataFactory.createTestWard(1, 'VN');
	        TestDataFactory.createTestDistrict(1, 'VN');
	        TestDataFactory.createTestSuccessfulReason(1, 'VN');
	        TestDataFactory.createTestUncontactableReason(1, 'VN');
	        TestDataFactory.createTestUnsuccessfulReason(1, 'VN');
	        TestDataFactory.createTestInvalidReason(1, 'VN');
	      
		}
    }

	@isTest static void test_insertAddressRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_call_manual__c rec = new VN_call_manual__c();

			//validate address
			rec = new VN_call_manual__c();
			try {
				rec.main_address_city__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.new_address_city__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.main_address_district__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_address_district__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.main_address_ward__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_address_ward__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}
	
	@isTest static void test_insertCallOutcomeRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_call_manual__c rec = new VN_call_manual__c();

			//validate call
			rec = new VN_call_manual__c();
			try {
				rec.call_outcome__c = 'Successful';
				rec.successful_reason__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.call_outcome__c = 'Uncontactable';
				rec.uncontactable_reason__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.call_outcome__c = 'Unsuccessful';
				rec.unsuccessful_reason__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.call_outcome__c = 'Invalid';
				rec.invalid_reason__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}

	@isTest static void test_insertCreateOrder() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_call_manual__c rec = new VN_call_manual__c();

			//validate order 1
			rec = new VN_call_manual__c();
			rec.create_order__c = 'True';

			try {
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_1__c = 'invalid';								
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_1__c = '123';	
				rec.order_quantity_1__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_1__c = '123';	
				rec.order_quantity_1__c = '';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_1__c = '123';	
				rec.order_quantity_1__c = '1';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			//validate order 2
			rec = new VN_call_manual__c();
			rec.create_order__c = 'True';
			try {
				rec.order_product_code_2__c = 'invalid';								
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_2__c = '123';	
				rec.order_quantity_2__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_2__c = '123';	
				rec.order_quantity_2__c = '';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_2__c = '123';	
				rec.order_quantity_2__c = '1';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			//validate order 3
			rec = new VN_call_manual__c();
			rec.create_order__c = 'True';
			try {
				rec.order_product_code_3__c = 'invalid';								
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_3__c = '123';	
				rec.order_quantity_3__c = 'Invalid';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_3__c = '123';	
				rec.order_quantity_3__c = '';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.order_product_code_3__c = '123';	
				rec.order_quantity_3__c = '1';
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}

	@isTest static void test_insertPhoneRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_call_manual__c rec = new VN_call_manual__c();

			//validate phone
			rec = new VN_call_manual__c();
			try {
				rec.main_contact_home_phone__c = 'Invalid';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.main_contact_mobile_phone__c= 'Invalid';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.main_contact_other_phone__c= 'Invalid';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_adult_home_phone__c= 'Invalid';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_adult_mobile_phone__c= 'Invalid';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_adult_home_phone__c= '09055555555';	
				rec.new_adult_mobile_phone__c= '09055555555';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}
			
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}

	@isTest static void test_insertDateRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_call_manual__c rec = new VN_call_manual__c();

			//validate Date
			rec = new VN_call_manual__c();
			try {
				rec.call_rgrd_contact_dob__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.main_contact_dob__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.main_contact_edd__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_adult_dob__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_child_dob__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}

	@isTest static void test_insertAdditionalRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_call_manual__c rec = new VN_call_manual__c();

			//validate new child
			rec = new VN_call_manual__c();
			try {
				rec.create_new_child__c = 'True';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.create_new_child__c = 'True';		
				rec.new_child_full_name__c = 'Invalid';		
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.create_new_child__c = 'True';	
				rec.new_child_last_name__c = 'Invalid';	
				rec.new_child_full_name__c = 'Invalid';
				rec.new_child_br_brand_id__c = 'Invalid';		
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			//validate new adult
			rec = new VN_call_manual__c();
			try {
				rec.create_new_adult__c = 'True';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.create_new_adult__c = 'True';		
				rec.new_adult_full_name__c = 'Invalid';		
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			try {
				rec.create_new_adult__c = 'True';	
				rec.new_adult_last_name__c = 'Invalid';	
				rec.new_adult_full_name__c = 'Invalid';
				rec.new_adult_br_brand_id__c = 'Invalid';		
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}			

			
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}

	@isTest static void test_inserBRRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_call_manual__c rec = new VN_call_manual__c();

			//validate Adult
			rec = new VN_call_manual__c();
			try {
				rec.new_adult_br_type__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}	

			rec = new VN_call_manual__c();
			try {
				rec.new_adult_br_type__c = 'Lead';	
				rec.new_adult_br_status__c = 'New';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_adult_br_type__c = 'User';	
				rec.new_adult_br_status__c = 'Contacted';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}	

			//validate Child
			rec = new VN_call_manual__c();
			try {
				rec.new_child_br_type__c = 'Invalid';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}	

			rec = new VN_call_manual__c();
			try {
				rec.new_child_br_type__c = 'Lead';	
				rec.new_child_br_status__c = 'New';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			rec = new VN_call_manual__c();
			try {
				rec.new_child_br_type__c = 'User';	
				rec.new_child_br_status__c = 'Contacted';			
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}

			
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}

	@isTest static void test_inserExtraFieldsRecord() {
		User sysad = [Select Id From User where LastName = 'tstSysAd'];
		System.runAs(sysad) {
			System.Test.startTest();
			Boolean hasError = false;
			VN_call_manual__c rec = new VN_call_manual__c();

			//validate Adult
			rec = new VN_call_manual__c();
			try {
				rec.create_new_address__c = 'True';				
				insert rec;
			} catch(Exception ex) {
				hasError = true;
			}	

			System.assertEquals(true, VNCallManualTriggerHelper.checkEmail('test@test.com') );
		
			System.assertEquals(true, hasError,'There should be an error');
			System.Test.stopTest();
		}
	}
	
}