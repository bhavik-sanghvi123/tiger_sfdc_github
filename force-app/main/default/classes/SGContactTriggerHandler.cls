/*------------------------------------------------------------
Author:      Rey Austral
Description: Handler class for SG_Contact_Manual__c object
History
08/08/2019   raustral    Created
-------------------------------------------------------------------------------------------*/
public with sharing class SGContactTriggerHandler implements ITriggerHandler {
    public void BeforeInsert(List<SObject> newList) { 
    	validateRecord(newList);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) {     }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){  }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){    }

    public void validateRecord(List<SG_Contact_Manual__c> newList) {
        Integer row = 1;
        List<Product2> productList = new List<Product2>();
        productList = [SELECT ProductCode, Name FROM Product2 WHERE Market__c = 'SG'];
        Set<String> productCodeSet = new Set<String>();
        Set<String> productNameSet = new Set<String>();
        for(Product2 p : productList){      
            productCodeSet.add(p.ProductCode);
            productNameSet.add(p.Name);
        }
        
        List<Channel__c> chanList = new List<Channel__c>();
        chanList = [SELECT Channel_Ref_No__c, Name FROM Channel__c WHERE Market__c = 'SG'];
        Set<String> chanCodeSet = new Set<String>();
        Set<String> chanNameSet = new Set<String>();
        for(Channel__c c : chanList){      
            chanCodeSet.add(c.Channel_Ref_No__c);
            chanNameSet.add(c.Name);
        }
        
        List<Campaign> campList = new List<Campaign>();
        campList = [SELECT ExternalId__c, Name FROM Campaign WHERE Market__c = 'SG'];
        Set<String> campCodeSet = new Set<String>();
        Set<String> campNameSet = new Set<String>();
        for(Campaign c : campList){      
            campCodeSet.add(c.ExternalId__c);
            campNameSet.add(c.Name);
        }
        
        List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
        avList = [SELECT recordtypeID,RecordType.Name, Name FROM Affiliate_Value__c WHERE Market__c = 'SG'];
        Map<String, Set<String>> avMap = new Map<String, Set<String>>();
        for(Affiliate_Value__c av : avList){
            if(avMap.containsKey(av.RecordType.Name)){
                avMap.get(av.RecordType.Name).add(av.Name.toLowerCase());
            } else {
                Set<String> aphameSet = new Set<String>();
                aphameSet.add(av.Name.toLowerCase());
                avMap.put(av.RecordType.Name,aphameSet);
            }
        }
        
        for(SG_Contact_Manual__c sgContact : newList){
            row++;
            Set<String> aphames = new Set<String>();
            if(String.isNotBlank(sgContact.Contact_PreferredLanguage__c)){
                aphames = avMap.get('Preferred Language');
                if(!aphames.contains(sgContact.Contact_PreferredLanguage__c.toLowerCase())){
                    sgContact.addError(sgContact.Contact_PreferredLanguage__c + ' Preferred Language not exists');
                    continue;
                }
            }
            
            if(String.isNotBlank(sgContact.BR_BrandID__c)){
                if(!productCodeSet.contains(sgContact.BR_BrandID__c)){
                    if(!productNameSet.contains(sgContact.BR_BrandName__c)){
                        sgContact.addError(' BR Brand ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            
            if(String.isNotBlank(sgContact.CR_ChannelID__c)){
                if(!chanCodeSet.contains(sgContact.CR_ChannelID__c)){
                    if(!chanNameSet.contains(sgContact.CR_ChannelName__c)){
                        sgContact.addError(' Channel ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            
            if(String.isNotBlank(sgContact.Addr_City__c)){
                aphames = avMap.get('City');
                if(!aphames.contains(sgContact.Addr_City__c.toLowerCase())){
                    sgContact.addError(sgContact.Addr_City__c + ' City not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(sgContact.Contact_Ethnicity__c)){
                aphames = avMap.get('Ethnicity');
                if(!aphames.contains(sgContact.Contact_Ethnicity__c.toLowerCase())){
                    sgContact.addError(sgContact.Contact_Ethnicity__c + ' Ethnicity not exists at row ' + row);
                    continue;
                }
            }           
           
            if(String.isNotBlank( sgContact.Child_DOB__c) ) {
                if(!checkDate(sgContact.Child_DOB__c)){
                    sgContact.addError(sgContact.Child_DOB__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( sgContact.Contact_DOB__c) ) {
                if(!checkDate(sgContact.Contact_DOB__c)){
                    sgContact.addError(sgContact.Contact_DOB__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( sgContact.Contact_EDD__c) ) {
                if(!checkDate(sgContact.Contact_EDD__c)){
                    sgContact.addError(sgContact.Contact_EDD__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( sgContact.cr_registrationdate__c) ) {
                if(!checkDate(sgContact.cr_registrationdate__c)){
                    sgContact.addError(sgContact.cr_registrationdate__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            } else {
                sgContact.addError('Registration Date are required at row ' + row);
                continue;
            }
            
           
            if(String.isNotBlank( sgContact.BR_RelationType__c) ){
                if(String.isNotBlank(sgContact.BR_RelationStatus__c)) {
                    if(sgContact.BR_RelationType__c.equalsIgnoreCase('Lead')) {
                        if(!(sgContact.BR_RelationStatus__c == 'Contacted' || sgContact.BR_RelationStatus__c == 'Uncontacted' || sgContact.BR_RelationStatus__c == 'Qualified')){
                            sgContact.addError(sgContact.BR_RelationStatus__c + ' is not valid Relation Status, select from Contacted|Uncontacted|Qualified at row ' + row);
                            continue;
                        }     
                    } else if(sgContact.BR_RelationType__c.equalsIgnoreCase('User')){
                        if(!(sgContact.BR_RelationStatus__c == 'New' || sgContact.BR_RelationStatus__c == 'Existing' || sgContact.BR_RelationStatus__c == 'Lapsed')){
                            sgContact.addError(sgContact.BR_RelationStatus__c + ' is not valid Relation Status, select from New|Existing|Lapsed at row ' + row);
                            continue;
                        } 
                    }
                } else {
                    sgContact.addError('BR RelationStatus is required at row ' + row);
                	continue;
                }
            } else {
                sgContact.addError('BR RelationType is required at row ' + row);
                continue;
            }
            
            if (String.isNotBlank( sgContact.Contact_HomePhone__c) ) {
                if(sgContact.Contact_HomePhone__c.contains('ph:')){  
                    sgContact.Contact_HomePhone__c = sgContact.Contact_HomePhone__c.remove('ph:').trim();
                    if(!checkPhone(sgContact.Contact_HomePhone__c)){
                        sgContact.addError(sgContact.Contact_HomePhone__c + ' Main Contact Home Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    sgContact.addError('Please put ph: in front of Main Contact Home Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( sgContact.Contact_MobilePhone__c) ) {
                if(sgContact.Contact_MobilePhone__c.contains('ph:')){  
                    sgContact.Contact_MobilePhone__c = sgContact.Contact_MobilePhone__c.remove('ph:').trim();
                    if(!checkPhone(sgContact.Contact_MobilePhone__c)){
                        sgContact.addError(sgContact.Contact_MobilePhone__c + ' Main Contact Mobile Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    sgContact.addError('Please put ph: in front of Main Contact Mobile Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( sgContact.Contact_OtherPhone__c) ) {
                if(sgContact.Contact_OtherPhone__c.contains('ph:')){  
                    sgContact.Contact_OtherPhone__c = sgContact.Contact_OtherPhone__c.remove('ph:').trim();
                    if(!checkPhone(sgContact.Contact_OtherPhone__c)){
                        sgContact.addError(sgContact.Contact_OtherPhone__c + ' Main Contact Other Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    sgContact.addError('Please put ph: in front of Main Contact Other Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if(String.isNotBlank(sgContact.contact_email__c)){
                if(!checkEmail(sgContact.contact_email__c)){
                    sgContact.addError('Invalid Contact Email at row ' + row);
                    continue;
                }
            }
            
            if(String.isBlank(sgContact.contact_lastname__c)){
                sgContact.addError('Contact Last Name are required at row ' + row);
                continue;
            }
            
            if(String.isNotBlank(sgContact.BR_CurrentBrandID__c)){
                if(!productCodeSet.contains(sgContact.BR_CurrentBrandID__c)){
                    sgContact.addError(sgContact.BR_CurrentBrandID__c + ' BR CurrBrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(sgContact.br_brandid__c )){
                if(!productCodeSet.contains(sgContact.br_brandid__c )){
                    sgContact.addError(sgContact.br_brandid__c  + ' BR BrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(sgContact.cr_sampleproductid__c )){
                if(!productCodeSet.contains(sgContact.cr_sampleproductid__c )){
                    sgContact.addError(sgContact.cr_sampleproductid__c  + ' Sample Product ID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(sgContact.CR_CampaignID__c)){
                if(!campCodeSet.contains(sgContact.CR_CampaignID__c)){
                    if(String.isNotBlank(sgContact.CR_CampaignName__c)){
                        if(!campNameSet.contains(sgContact.CR_CampaignName__c)){
                            sgContact.addError(' Campaign ID and Name does not exist at row ' + row); 
                            continue;
                        }
                    } else {
                        sgContact.addError(' Campaign ID does not exist at row ' + row); 
                        continue;
                    }
                }
            } else {
                if(String.isNotBlank(sgContact.CR_CampaignName__c)){
                    if(!campNameSet.contains(sgContact.CR_CampaignName__c)){
                        sgContact.addError(' Campaign Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
        }
    }

    public static Boolean checkDate(String checkDate) {
        String datePattern = '(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[012])/((11|12|13|14|15|16|17|18|19|20)\\d\\d)';
        Pattern pat = Pattern.compile(datePattern);
        Matcher mat = pat.matcher(checkDate);
        return mat.matches();
    }
    
    public static Boolean checkEmail(String checkemail) {
        String eMailPattern = '^[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$';
        Pattern pat = Pattern.compile(eMailPattern);
        Matcher mat = pat.matcher(checkEMail.toLowerCase());
        return mat.matches();
    }
    public static Boolean checkphone(String checkphone) {
        String phonePattern = '^[0-9]{7,12}$';
        Pattern pat = Pattern.compile(phonePattern);
        Matcher mat = pat.matcher(checkphone);
        if(String.isNotBlank(checkphone )){
            return mat.matches();
        } else {
            return True;
        }
    }
}