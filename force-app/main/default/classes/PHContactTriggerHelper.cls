/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Helper class for PH_Contact__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/

public class PHContactTriggerHelper {

    /* This method get all Affialite Values and check the duplicate;
    */
    public static void validateAffiliateValue(List<PH_Contact__c> phContactList) {
        Integer row = 1;
        List<Product2> productList = new List<Product2>();
        productList = [SELECT ProductCode, Name FROM Product2 WHERE Market__c = 'PH'];
        Set<String> productCodeSet = new Set<String>();
        Set<String> productNameSet = new Set<String>();
        for(Product2 p : productList){      
            productCodeSet.add(p.ProductCode);
            productNameSet.add(p.Name);
        }
        
        List<Channel__c> chanList = new List<Channel__c>();
        chanList = [SELECT Channel_Ref_No__c, Name FROM Channel__c WHERE Market__c = 'PH'];
        Set<String> chanCodeSet = new Set<String>();
        Set<String> chanNameSet = new Set<String>();
        for(Channel__c c : chanList){      
            chanCodeSet.add(c.Channel_Ref_No__c);
            chanNameSet.add(c.Name);
        }
        
        List<Campaign> campList = new List<Campaign>();
        campList = [SELECT ExternalId__c, Name FROM Campaign WHERE Market__c = 'PH'];
        Set<String> campCodeSet = new Set<String>();
        Set<String> campNameSet = new Set<String>();
        for(Campaign c : campList){      
            campCodeSet.add(c.ExternalId__c);
            campNameSet.add(c.Name);
        }
        
        List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
        avList = [SELECT recordtypeID,RecordType.Name, Name FROM Affiliate_Value__c WHERE Market__c = 'PH'];
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
        
        for(PH_Contact__c phContact : phContactList){
            row++;
            Set<String> aphames = new Set<String>();
            if(String.isNotBlank(phContact.Contact_PreferredLanguage__c)){
                aphames = avMap.get('Preferred Language');
                if(!aphames.contains(phContact.Contact_PreferredLanguage__c.toLowerCase())){
                    phContact.addError(phContact.Contact_PreferredLanguage__c + ' Preferred Language not exists');
                    continue;
                }
            }
            
            if(String.isNotBlank(phContact.BR_BrandID__c)){
                if(!productCodeSet.contains(phContact.BR_BrandID__c)){
                    if(!productNameSet.contains(phContact.BR_BrandName__c)){
                        phContact.addError(' BR Brand ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            
           /* if(String.isNotBlank(phContact.BR_CurrPrevBrandID__c)){
                if(!productCodeSet.contains(phContact.BR_CurrPrevBrandID__c)){
                    if(!productNameSet.contains(phContact.BR_CurrPrevBrandName__c)){
                        phContact.addError(' CurrPrev Brand ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }*/
            
            if(String.isNotBlank(phContact.CR_ChannelID__c)){
                if(!chanCodeSet.contains(phContact.CR_ChannelID__c)){
                    if(!chanNameSet.contains(phContact.CR_ChannelName__c)){
                        phContact.addError(' Channel ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            
          /*  if(String.isNotBlank(phContact.CR_CampaignID__c)){
                if(!campCodeSet.contains(phContact.CR_CampaignID__c)){
                    if(!campNameSet.contains(phContact.CR_CampaignName__c)){
                        phContact.addError(' Campaign ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            */
            if(String.isNotBlank(phContact.Addr_Ward__c)){
                aphames = avMap.get('Ward');
                if(!aphames.contains(phContact.Addr_Ward__c.toLowerCase())){
                    phContact.addError(phContact.Addr_Ward__c + ' Ward not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(phContact.Addr_District__c)){
                aphames = avMap.get('District');
                if(!aphames.contains(phContact.Addr_District__c.toLowerCase())){
                    phContact.addError(phContact.Addr_District__c + ' District not exists at row ' + row);
                    continue;
                }
            }
            if(String.isNotBlank(phContact.Addr_City__c)){
                aphames = avMap.get('City');
                if(!aphames.contains(phContact.Addr_City__c.toLowerCase())){
                    phContact.addError(phContact.Addr_City__c + ' City not exists at row ' + row);
                    continue;
                }
            }
            if(String.isNotBlank(phContact.Contact_Ethnicity__c)){
                aphames = avMap.get('Ethnicity');
                if(!aphames.contains(phContact.Contact_Ethnicity__c.toLowerCase())){
                    phContact.addError(phContact.Contact_Ethnicity__c + ' Ethnicity not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(phContact.Addr_Region__c)){
                aphames = avMap.get('Region');
                if(!aphames.contains(phContact.Addr_Region__c.toLowerCase())){
                    phContact.addError(phContact.Addr_Region__c + ' Region not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(phContact.BR_BrandSwitchReason__c)){
                aphames = avMap.get('Brand Switch Reason');
                if(!aphames.contains(phContact.BR_BrandSwitchReason__c.toLowerCase())){
                    phContact.addError(phContact.BR_BrandSwitchReason__c + ' Brand Switch Reason not exists at row ' + row);
                    continue;
                }
            }
            
            /*if(String.isNotBlank( phContact.BR_MemberStartDate__c) ) {
                if(!checkDate(phContact.BR_MemberStartDate__c)){
                    phContact.addError(phContact.BR_MemberStartDate__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }*/
            
            if(String.isNotBlank( phContact.Child_DOB__c) ) {
                if(!checkDate(phContact.Child_DOB__c)){
                    phContact.addError(phContact.Child_DOB__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( phContact.Contact_DOB__c) ) {
                if(!checkDate(phContact.Contact_DOB__c)){
                    phContact.addError(phContact.Contact_DOB__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( phContact.Contact_EDD__c) ) {
                if(!checkDate(phContact.Contact_EDD__c)){
                    phContact.addError(phContact.Contact_EDD__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( phContact.cr_registrationdate__c) ) {
                if(!checkDate(phContact.cr_registrationdate__c)){
                    phContact.addError(phContact.cr_registrationdate__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( phContact.SourceCreatedDate__c) ) {
                if(!checkDate(phContact.SourceCreatedDate__c)){
                    phContact.addError(phContact.SourceCreatedDate__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            if(String.isNotBlank( phContact.BR_RelationType__c) ){
                if(String.isNotBlank(phContact.BR_RelationStatus__c)) {
                    if(phContact.BR_RelationType__c.equalsIgnoreCase('Lead')) {
                        if(!(phContact.BR_RelationStatus__c == 'Contacted' || phContact.BR_RelationStatus__c == 'Uncontacted' || phContact.BR_RelationStatus__c == 'Qualified')){
                            phContact.addError(phContact.BR_RelationStatus__c + ' is not valid Relation Status, select from Contacted|Uncontacted|Qualified at row ' + row);
                            continue;
                        }     
                    } else if(phContact.BR_RelationType__c.equalsIgnoreCase('User')){
                        if(!(phContact.BR_RelationStatus__c == 'New' || phContact.BR_RelationStatus__c == 'Existing' || phContact.BR_RelationStatus__c == 'Lapsed')){
                            phContact.addError(phContact.BR_RelationStatus__c + ' is not valid Relation Status, select from New|Existing|Lapsed at row ' + row);
                            continue;
                        } 
                    }
                } else {
                    phContact.addError('BR RelationStatus is required at row ' + row);
                	continue;
                }
            } else {
                phContact.addError('BR RelationType is required at row ' + row);
                continue;
            }
            
            if (String.isNotBlank( phContact.Contact_HomePhone__c) ) {
                if(phContact.Contact_HomePhone__c.contains('ph:')){  
                    phContact.Contact_HomePhone__c = phContact.Contact_HomePhone__c.remove('ph:').trim();
                    if(!checkPhone(phContact.Contact_HomePhone__c)){
                        phContact.addError(phContact.Contact_HomePhone__c + ' Main Contact Home Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    phContact.addError('Please put ph: in front of Main Contact Home Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( phContact.Contact_MobilePhone__c) ) {
                if(phContact.Contact_MobilePhone__c.contains('ph:')){  
                    phContact.Contact_MobilePhone__c = phContact.Contact_MobilePhone__c.remove('ph:').trim();
                    if(!checkPhone(phContact.Contact_MobilePhone__c)){
                        phContact.addError(phContact.Contact_MobilePhone__c + ' Main Contact Mobile Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    phContact.addError('Please put ph: in front of Main Contact Mobile Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( phContact.Contact_OtherPhone__c) ) {
                if(phContact.Contact_OtherPhone__c.contains('ph:')){  
                    phContact.Contact_OtherPhone__c = phContact.Contact_OtherPhone__c.remove('ph:').trim();
                    if(!checkPhone(phContact.Contact_OtherPhone__c)){
                        phContact.addError(phContact.Contact_OtherPhone__c + ' Main Contact Other Phone is not a valid Phone at row ' + row);
                    continue;
                    }
                } else {
                    phContact.addError('Please put ph: in front of Main Contact Other Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if(String.isNotBlank(phContact.contact_email__c)){
                if(!checkEmail(phContact.contact_email__c)){
                    phContact.addError('Invalid Contact Email at row ' + row);
                    continue;
                }
            }
            
            if(String.isBlank(phContact.contact_lastname__c)){
                phContact.addError('Contact Last Name are required at row ' + row);
                continue;
            }
            
            if(String.isNotBlank(phContact.br_currbrandid__c)){
                if(!productCodeSet.contains(phContact.br_currbrandid__c)){
                    phContact.addError(phContact.br_currbrandid__c + ' BR CurrBrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(phContact.br_brandid__c )){
                if(!productCodeSet.contains(phContact.br_brandid__c )){
                    phContact.addError(phContact.br_brandid__c  + ' BR BrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(phContact.cr_sampleproductid__c )){
                if(!productCodeSet.contains(phContact.cr_sampleproductid__c )){
                    phContact.addError(phContact.cr_sampleproductid__c  + ' Sample Product ID does not exist at row ' + row); 
                    continue;
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