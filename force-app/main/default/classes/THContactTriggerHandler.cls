/*------------------------------------------------------------
Author:      Rey Austral
Description: Handler class for TH_Contact_Manual__c object
History
08/08/2019   raustral    Created
-------------------------------------------------------------------------------------------*/
public with sharing class THContactTriggerHandler implements ITriggerHandler{
    public void BeforeInsert(List<SObject> newList) { 
    	validateRecord(newList);
    }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) {     }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){  }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){    }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){    }

    public void validateRecord(List<TH_Contact_Manual__c> newList) {
        Integer row = 1;
        List<Product2> productList = new List<Product2>();
        productList = [SELECT ProductCode, Name FROM Product2 WHERE Market__c = 'TH'];
        Set<String> productCodeSet = new Set<String>();
        Set<String> productNameSet = new Set<String>();
        for(Product2 p : productList){      
            productCodeSet.add(p.ProductCode);
            productNameSet.add(p.Name);
        }
        
        List<Channel__c> chanList = new List<Channel__c>();
        chanList = [SELECT Channel_Ref_No__c, Name FROM Channel__c WHERE Market__c = 'TH'];
        Set<String> chanCodeSet = new Set<String>();
        Set<String> chanNameSet = new Set<String>();
        for(Channel__c c : chanList){      
            chanCodeSet.add(c.Channel_Ref_No__c);
            chanNameSet.add(c.Name);
        }
        
        List<Campaign> campList = new List<Campaign>();
        campList = [SELECT ExternalId__c, Name FROM Campaign WHERE Market__c = 'TH'];
        Set<String> campCodeSet = new Set<String>();
        Set<String> campNameSet = new Set<String>();
        for(Campaign c : campList){      
            campCodeSet.add(c.ExternalId__c);
            campNameSet.add(c.Name);
        }
        
        List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
        avList = [SELECT recordtypeID,RecordType.Name, Name FROM Affiliate_Value__c WHERE Market__c = 'TH'];
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
        
        for(TH_Contact_Manual__c thContact : newList){
            row++;
            Set<String> aphames = new Set<String>();
            if(String.isNotBlank(thContact.Contact_PreferredLanguage__c)){
                aphames = avMap.get('Preferred Language');
                if(!aphames.contains(thContact.Contact_PreferredLanguage__c.toLowerCase())){
                    thContact.addError(thContact.Contact_PreferredLanguage__c + ' Preferred Language not exists');
                    continue;
                }
            }
            
            if(String.isNotBlank(thContact.BR_BrandID__c)){
                if(!productCodeSet.contains(thContact.BR_BrandID__c)){
                    if(!productNameSet.contains(thContact.BR_BrandName__c)){
                        thContact.addError(' BR Brand ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            
            if(String.isNotBlank(thContact.CR_ChannelID__c)){
                if(!chanCodeSet.contains(thContact.CR_ChannelID__c)){
                    if(!chanNameSet.contains(thContact.CR_ChannelName__c)){
                        thContact.addError(' Channel ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            } 
            if(String.isNotBlank(thContact.Addr_District__c)){
                aphames = avMap.get('District');
                if(!aphames.contains(thContact.Addr_District__c.toLowerCase())){
                    thContact.addError(thContact.Addr_District__c + ' District not exists at row ' + row);
                    continue;
                }
            }

            if(String.isNotBlank(thContact.Addr_SubDistrict__c)){
                aphames = avMap.get('Sub-District');
                if(!aphames.contains(thContact.Addr_SubDistrict__c.toLowerCase())){
                    thContact.addError(thContact.Addr_SubDistrict__c + ' District not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(thContact.Contact_Ethnicity__c)){
                aphames = avMap.get('Ethnicity');
                if(!aphames.contains(thContact.Contact_Ethnicity__c.toLowerCase())){
                    thContact.addError(thContact.Contact_Ethnicity__c + ' Ethnicity not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(thContact.Addr_Province__c)){
                aphames = avMap.get('City');
                if(!aphames.contains(thContact.Addr_Province__c.toLowerCase())){
                    thContact.addError(thContact.Addr_Province__c + ' Province not exists at row ' + row);
                    continue;
                }
            }            
            /* moved to validation rule
            if(String.isNotBlank( thContact.Child_DOB__c) ) {
                if(!checkDate(thContact.Child_DOB__c)){
                    thContact.addError(thContact.Child_DOB__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }*/
            
            if(String.isNotBlank( thContact.Contact_DOB__c) ) {
                if(!checkDate(thContact.Contact_DOB__c)){
                    thContact.addError(thContact.Contact_DOB__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( thContact.Contact_EDD__c) ) {
                if(!checkDate(thContact.Contact_EDD__c)){
                    thContact.addError(thContact.Contact_EDD__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            /* moved to validation rule
            if(String.isNotBlank( thContact.cr_registrationdate__c) ) {
                if(!checkDate(thContact.cr_registrationdate__c)){
                    thContact.addError(thContact.cr_registrationdate__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            } else {
                thContact.addError('Registration Date are required at row ' + row);
                continue;
            }*/
            
            if(String.isNotBlank( thContact.BR_RelationType__c) ){
                if(String.isNotBlank(thContact.BR_RelationStatus__c)) {
                    if(thContact.BR_RelationType__c.equalsIgnoreCase('Lead')) {
                        if(!(thContact.BR_RelationStatus__c == 'Contacted' || thContact.BR_RelationStatus__c == 'Uncontacted' || thContact.BR_RelationStatus__c == 'Qualified')){
                            thContact.addError(thContact.BR_RelationStatus__c + ' is not valid Relation Status, select from Contacted|Uncontacted|Qualified at row ' + row);
                            continue;
                        }     
                    } else if(thContact.BR_RelationType__c.equalsIgnoreCase('User')){
                        if(!(thContact.BR_RelationStatus__c == 'New' || thContact.BR_RelationStatus__c == 'Existing' || thContact.BR_RelationStatus__c == 'Lapsed')){
                            thContact.addError(thContact.BR_RelationStatus__c + ' is not valid Relation Status, select from New|Existing|Lapsed at row ' + row);
                            continue;
                        } 
                    }
                } else {
                    thContact.addError('BR RelationStatus is required at row ' + row);
                	continue;
                }
            } else {
                thContact.addError('BR RelationType is required at row ' + row);
                continue;
            }
            
            if (String.isNotBlank( thContact.Contact_HomePhone__c) ) {
                if(thContact.Contact_HomePhone__c.contains('ph:')){  
                    thContact.Contact_HomePhone__c = thContact.Contact_HomePhone__c.remove('ph:').trim();
                    if(!checkPhone(thContact.Contact_HomePhone__c)){
                        thContact.addError(thContact.Contact_HomePhone__c + ' Main Contact Home Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    thContact.addError('Please put ph: in front of Main Contact Home Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( thContact.Contact_MobilePhone__c) ) {
                if(thContact.Contact_MobilePhone__c.contains('ph:')){  
                    thContact.Contact_MobilePhone__c = thContact.Contact_MobilePhone__c.remove('ph:').trim();
                    if(!checkPhone(thContact.Contact_MobilePhone__c)){
                        thContact.addError(thContact.Contact_MobilePhone__c + ' Main Contact Mobile Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    thContact.addError('Please put ph: in front of Main Contact Mobile Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( thContact.Contact_OtherPhone__c) ) {
                if(thContact.Contact_OtherPhone__c.contains('ph:')){  
                    thContact.Contact_OtherPhone__c = thContact.Contact_OtherPhone__c.remove('ph:').trim();
                    if(!checkPhone(thContact.Contact_OtherPhone__c)){
                        thContact.addError(thContact.Contact_OtherPhone__c + ' Main Contact Other Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    thContact.addError('Please put ph: in front of Main Contact Other Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if(String.isNotBlank(thContact.contact_email__c)){
                if(!checkEmail(thContact.contact_email__c)){
                    thContact.addError('Invalid Contact Email at row ' + row);
                    continue;
                }
            }
            
            if(String.isBlank(thContact.contact_lastname__c)){
                thContact.addError('Contact Last Name are required at row ' + row);
                continue;
            }
            
            if(String.isNotBlank(thContact.BR_CurrentBrandID__c)){
                if(!productCodeSet.contains(thContact.BR_CurrentBrandID__c)){
                    thContact.addError(thContact.BR_CurrentBrandID__c + ' BR CurrBrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(thContact.br_brandid__c )){
                if(!productCodeSet.contains(thContact.br_brandid__c )){
                    thContact.addError(thContact.br_brandid__c  + ' BR BrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(thContact.cr_sampleproductid__c )){
                if(!productCodeSet.contains(thContact.cr_sampleproductid__c )){
                    thContact.addError(thContact.cr_sampleproductid__c  + ' Sample Product ID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(thContact.CR_CampaignID__c)){
                if(!campCodeSet.contains(thContact.CR_CampaignID__c)){
                    if(String.isNotBlank(thContact.CR_CampaignName__c)){
                        if(!campNameSet.contains(thContact.CR_CampaignName__c)){
                            thContact.addError(' Campaign ID and Name does not exist at row ' + row); 
                            continue;
                        }
                    } else {
                        thContact.addError(' Campaign ID does not exist at row ' + row); 
                        continue;
                    }
                }
            } else {
                if(String.isNotBlank(thContact.CR_CampaignName__c)){
                    if(!campNameSet.contains(thContact.CR_CampaignName__c)){
                        thContact.addError(' Campaign Name does not exist at row ' + row); 
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