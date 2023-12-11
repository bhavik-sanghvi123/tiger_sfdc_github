/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: This batch will validate with Experian if the Address record created from Heroku are valid or not

History
07/31/2019   vmirandilla   Created
04/14/2021   malviz        TKT-003976: added unit number checking
09/07/2021   malviz        TKT-004526: remove # on unit number search
04/06/2022	 fgomendoza	   optimized query
-------------------------------------------------------------------------------------------*/

global class ExperianAddressValidationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id userId = [SELECT Id FROM User WHERE Name = 'Data Integration' AND IsActive = true][0].Id;
        String query = 'SELECT Id'
            + ' FROM Address__c WHERE ParentContact__r.Market__c = \'' + CommonConstant.MARKET_SG + '\''
            + ' AND Country__c = \'Singapore\''
            + ' AND AddressValidationStatus__c = \'' + CommonConstant.ADDRESS_VALIDATION_PENDING + '\''
            + ' AND CreatedById =: userId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Address__c> scope) {
        List<Address__c> execAddressList = [SELECT Id, Street1__c, Street2__c, UnitNumber__c, Building__c, StateProvince__c, PostalCode__c, ParentContact__r.Market__c, 
                                            AddressValidationStatus__c, CreatedById, CreatedBy.Name FROM Address__c WHERE Id IN: scope AND PostalCode__c != null AND PostalCode__c != ''];
        
        if(!execAddressList.isEmpty()){
            String token = [SELECT MasterLabel, DeveloperName, Token__c FROM AuthenticationToken__mdt WHERE DeveloperName = 'Experian_Token'].Token__c;
            List<Address__c> addressList = new List<Address__c>();
            for(Address__c address : execAddressList) {
                String postalCode = address.PostalCode__c;
                String unitNumber = address.UnitNumber__c;
                
                //remove if unit number contains #
                if(unitnumber != null && unitnumber != ''){
                    if(unitNumber.contains('#')){
                        unitnumber = unitnumber.replace('#','');        
                    }
                }
                
                if(!System.Test.isRunningTest() && token != null) {
                    HttpResponse formatResponse;
                    formatResponse =  ExperianCallout.getInfoFromExternalService(postalCode, unitNumber);
                    
                    if (formatResponse != null) {
                        CommonObjectWrapper.cls_ExperianAddress expAddress = ExperianResponseProcessor.processReponse(formatResponse);            
                        
                        if(expAddress != null) {
                            if(unitNumber != null && unitNumber != ''){
                                if((expAddress.expPostCode == address.PostalCode__c) && (expAddress.expSubBuilding == unitnumber)) {
                                    address.AddressValidationStatus__c = CommonConstant.ADDRESS_VALIDATION_VALID;
                                    
                                    if( (address.Street1__c == '' || address.Street1__c == null) && (address.Street2__c == '' || address.Street2__c == null)){
                                        address.Street1__c = expAddress.expStreet1;
                                    }
                                } else {
                                    address.AddressValidationStatus__c = CommonConstant.ADDRESS_VALIDATION_INVALID;
                                }
                            }
                            else{
                                if(expAddress.expPostCode == address.PostalCode__c) {
                                    address.AddressValidationStatus__c = CommonConstant.ADDRESS_VALIDATION_VALID;
                                    
                                    if( (address.Street1__c == '' || address.Street1__c == null) && (address.Street2__c == '' || address.Street2__c == null)){
                                        address.Street1__c = expAddress.expStreet1;
                                    }
                                } else {
                                    address.AddressValidationStatus__c = CommonConstant.ADDRESS_VALIDATION_INVALID;
                                }
                            }  
                        } 
                    } else {
                        address.AddressValidationStatus__c = CommonConstant.ADDRESS_VALIDATION_INVALID;
                    }
                    addressList.add(address);
                }
            } 
            
            if(!addressList.isEmpty()) {
                Database.update(addressList, false);
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}