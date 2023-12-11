/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Helper class for VN_Contact_Manual__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/

public class VNContactManualTriggerHelper {

    /* This method get all Affialite Values and check the duplicate;
    */
    public static void validateAffiliateValue(List<VN_Contact_Manual__c> vnContactList) {
        Integer row = 1;
        //Set<String> channelRecTypeSet = new Set<String>{CommonConstant.CHANNEL_SOCIAL_RECORDTYPE, CommonConstant.CHANNEL_OTHER_ONLINE_RECORDTYPE, CommonConstant.CHANNEL_WEB_RECORDTYPE};

        List<Product2> productList = new List<Product2>();
        productList = [SELECT ProductCode, Name FROM Product2 WHERE Market__c = 'VN' AND IsActive = True];
        Set<String> productCodeSet = new Set<String>();
        Set<String> productNameSet = new Set<String>();
        for(Product2 p : productList){      
            productCodeSet.add(p.ProductCode);
            productNameSet.add(p.Name);
        }
        
        List<Channel__c> chanList = new List<Channel__c>();
        chanList = [SELECT Channel_Ref_No__c, Name FROM Channel__c WHERE Market__c = 'VN' AND RecordType.Name != 'Trade'];// AND RecordType.Name IN :channelRecTypeSet];
        Set<String> chanCodeSet = new Set<String>();
        Set<String> chanNameSet = new Set<String>();
        for(Channel__c c : chanList){      
            chanCodeSet.add(c.Channel_Ref_No__c);
            chanNameSet.add(c.Name);
        }
        
        List<Campaign> campList = new List<Campaign>();
        campList = [SELECT ExternalCampaignReference__c, Name FROM Campaign WHERE Market__c = 'VN' AND IsActive = True];
        Set<String> campCodeSet = new Set<String>();
        Set<String> campNameSet = new Set<String>();
        for(Campaign c : campList){      
            campCodeSet.add(c.ExternalCampaignReference__c);
            campNameSet.add(c.Name);
        }
        
        List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
        avList = [SELECT recordtypeID,RecordType.Name, Name FROM Affiliate_Value__c WHERE Market__c = 'VN'];
        Map<String, Set<String>> avMap = new Map<String, Set<String>>();
        for(Affiliate_Value__c av : avList){
            if(avMap.containsKey(av.RecordType.Name)){
                avMap.get(av.RecordType.Name).add(av.Name.toLowerCase());
            } else {
                Set<String> avnameSet = new Set<String>();
                avnameSet.add(av.Name.toLowerCase());
                avMap.put(av.RecordType.Name,avnameSet);
            }
        }
        
        for(VN_Contact_Manual__c vnContact : vnContactList){
            row++;
            Set<String> avnames = new Set<String>();
            if(String.isNotBlank(vnContact.Contact_PreferredLanguage__c)){
                avnames = avMap.get('Preferred Language');
                if(!avnames.contains(vnContact.Contact_PreferredLanguage__c.toLowerCase())){
                    vnContact.addError(vnContact.Contact_PreferredLanguage__c + ' Preferred Language not exists');
                    continue;
                }
            }
            
           /* if(String.isNotBlank(vnContact.BR_BrandID__c)){
                if(!productCodeSet.contains(vnContact.BR_BrandID__c)){
                    if(!productNameSet.contains(vnContact.BR_BrandName__c)){
                        vnContact.addError(' BR Brand ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }*/
            
           if(String.isNotBlank(vnContact.br_brandid__c)){
                if(!productCodeSet.contains(vnContact.br_brandid__c)){
                    if(String.isNotBlank(vnContact.br_brandname__c)){
                        if(!productNameSet.contains(vnContact.br_brandname__c)){
                            vnContact.addError(' Brand ID and Name does not exist at row ' + row); 
                            continue;
                        }
                    } else {
                        vnContact.addError(' Brand ID does not exist at row ' + row); 
                        continue;
                    }
                }
            } else {
                if(String.isNotBlank(vnContact.br_brandname__c)){
                    if(!productNameSet.contains(vnContact.br_brandname__c)){
                        vnContact.addError(' Brand Name does not exist at row ' + row); 
                        continue;
                    }
                } else {
                    vnContact.addError(' Brand ID or Brand Name is required at row ' + row); 
                    continue;
                }
            }
            
             if(String.isNotBlank(vnContact.CR_ChannelID__c)){
                if(!chanCodeSet.contains(vnContact.CR_ChannelID__c)){
                    if(String.isNotBlank(vnContact.CR_ChannelName__c)){
                        if(!chanNameSet.contains(vnContact.CR_ChannelName__c)){
                            vnContact.addError(' Channel ID and Name does not exist at row ' + row); 
                            continue;
                        }
                    } else {
                        vnContact.addError(' Channel ID does not exist at row ' + row); 
                        continue;
                    }
                }
            } else {
                if(String.isNotBlank(vnContact.CR_ChannelName__c)){
                    if(!chanNameSet.contains(vnContact.CR_ChannelName__c)){
                        vnContact.addError(' Channel Name does not exist at row ' + row); 
                        continue;
                    }
                } else {
                    vnContact.addError(' Channel ID or Channel Name is required at row ' + row); 
                    continue;
                }
            }
            
            if(String.isNotBlank(vnContact.CR_CampaignID__c)){
                if(!campCodeSet.contains(vnContact.CR_CampaignID__c)){
                    if(String.isNotBlank(vnContact.CR_CampaignName__c)){
                        if(!campNameSet.contains(vnContact.CR_CampaignName__c)){
                            vnContact.addError(' Campaign ID and Name does not exist at row ' + row); 
                            continue;
                        }
                    } else {
                        vnContact.addError(' Campaign ID does not exist at row ' + row); 
                        continue;
                    }
                }
            } else {
                if(String.isNotBlank(vnContact.CR_CampaignName__c)){
                    if(!campNameSet.contains(vnContact.CR_CampaignName__c)){
                        vnContact.addError(' Campaign Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            
            if(String.isNotBlank(vnContact.Addr_Ward__c)){
                avnames = avMap.get('Ward');
                if(!avnames.contains(vnContact.Addr_Ward__c.toLowerCase())){
                    vnContact.addError(vnContact.Addr_Ward__c + ' Ward not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(vnContact.Addr_District__c)){
                avnames = avMap.get('District');
                if(!avnames.contains(vnContact.Addr_District__c.toLowerCase())){
                    vnContact.addError(vnContact.Addr_District__c + ' District not exists at row ' + row);
                    continue;
                }
            }
            if(String.isNotBlank(vnContact.Addr_City__c)){
                avnames = avMap.get('City');
                if(!avnames.contains(vnContact.Addr_City__c.toLowerCase())){
                    vnContact.addError(vnContact.Addr_City__c + ' City not exists at row ' + row);
                    continue;
                }
            }
            if(String.isNotBlank(vnContact.Contact_Ethnicity__c)){
                avnames = avMap.get('Ethnicity');
                if(!avnames.contains(vnContact.Contact_Ethnicity__c.toLowerCase())){
                    vnContact.addError(vnContact.Contact_Ethnicity__c + ' Ethnicity not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(vnContact.Addr_Region__c)){
                avnames = avMap.get('Region');
                if(!avnames.contains(vnContact.Addr_Region__c.toLowerCase())){
                    vnContact.addError(vnContact.Addr_Region__c + ' Region not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(vnContact.BR_BrandSwitchReason__c)){
                avnames = avMap.get('Brand Switch Reason');
                if(!avnames.contains(vnContact.BR_BrandSwitchReason__c.toLowerCase())){
                    vnContact.addError(vnContact.BR_BrandSwitchReason__c + ' Brand Switch Reason not exists at row ' + row);
                    continue;
                }
            }
            
            /*if(String.isNotBlank( vnContact.BR_MemberStartDate__c) ) {
                if(!checkDate(vnContact.BR_MemberStartDate__c)){
                    vnContact.addError(vnContact.BR_MemberStartDate__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }*/
            
            if(String.isNotBlank( vnContact.Child_DOB__c) ) {
                if(!checkDate(vnContact.Child_DOB__c)){
                    vnContact.addError(vnContact.Child_DOB__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( vnContact.Contact_DOB__c) ) {
                if(!checkDate(vnContact.Contact_DOB__c)){
                    vnContact.addError(vnContact.Contact_DOB__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( vnContact.Contact_EDD__c) ) {
                if(!checkDate(vnContact.Contact_EDD__c)){
                    vnContact.addError(vnContact.Contact_EDD__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( vnContact.cr_registrationdate__c) ) {
                if(!checkDate(vnContact.cr_registrationdate__c)){
                    vnContact.addError(vnContact.cr_registrationdate__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            
            if(String.isNotBlank( vnContact.SourceCreatedDate__c) ) {
                if(!checkDate(vnContact.SourceCreatedDate__c)){
                    vnContact.addError(vnContact.SourceCreatedDate__c + ' is Invalid date, use dd/mm/yyyy at row ' + row);
                    continue;
                }     
            }
            if(String.isNotBlank( vnContact.BR_RelationType__c) ){
                if(String.isNotBlank(vnContact.BR_RelationStatus__c)) {
                    if(vnContact.BR_RelationType__c.equalsIgnoreCase('Lead')) {
                        if(!(vnContact.BR_RelationStatus__c == 'Contacted' || vnContact.BR_RelationStatus__c == 'Uncontacted' || vnContact.BR_RelationStatus__c == 'Qualified')){
                            vnContact.addError(vnContact.BR_RelationStatus__c + ' is not valid Relation Status, select from Contacted|Uncontacted|Qualified at row ' + row);
                            continue;
                        }     
                    } else if(vnContact.BR_RelationType__c.equalsIgnoreCase('User')){
                        if(!(vnContact.BR_RelationStatus__c == 'New' || vnContact.BR_RelationStatus__c == 'Existing' || vnContact.BR_RelationStatus__c == 'Lapsed')){
                            vnContact.addError(vnContact.BR_RelationStatus__c + ' is not valid Relation Status, select from New|Existing|Lapsed at row ' + row);
                            continue;
                        } 
                    }
                } else {
                    vnContact.addError('BR RelationStatus is required at row ' + row);
                	continue;
                }
            } else {
                vnContact.addError('BR RelationType is required at row ' + row);
                continue;
            }
            
       /*     if (String.isNotBlank( vnContact.Contact_Homephone__c) ) {
                if(vnContact.Contact_Homephone__c.contains('vn:')){  
                    vnContact.Contact_Homephone__c = vnContact.Contact_Homephone__c.remove('ph:').trim();
                    if(!checkphone(vnContact.Contact_Homephone__c)){
                        vnContact.addError(vnContact.Contact_Homephone__c + ' Main Contact Home phone is not a valid phone at row ' + row);
                    continue;
                    }
                } else {
                    vnContact.addError('Please put ph: in front of Main Contact Home phone Column at row ' + row);
                    continue;
                }       
            }
            
            if(String.isBlank(vnContact.Contact_Mobilephone__c.remove('ph:').trim())){
                vnContact.addError('Contact Mobile is required at row ' + row);
                continue;
            }
            if (String.isNotBlank( vnContact.Contact_Mobilephone__c) ) {
                if(vnContact.Contact_Mobilephone__c.contains('ph:')){  
                    vnContact.Contact_Mobilephone__c = vnContact.Contact_Mobilephone__c.remove('ph:').trim();
                    if(!checkphone(vnContact.Contact_Mobilephone__c)){
                        vnContact.addError(vnContact.Contact_Mobilephone__c + ' Main Contact Mobile phone is not a valid phone at row ' + row);
                        continue;
                    }
                } else {
                    vnContact.addError('Please put ph: in front of Main Contact Mobile phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( vnContact.Contact_Otherphone__c) ) {
                if(vnContact.Contact_Otherphone__c.contains('ph:')){  
                    vnContact.Contact_Otherphone__c = vnContact.Contact_Otherphone__c.remove('ph:').trim();
                    if(!checkphone(vnContact.Contact_Otherphone__c)){
                        vnContact.addError(vnContact.Contact_Otherphone__c + ' Main Contact Other phone is not a valid phone at row ' + row);
                    continue;
                    }
                } else {
                    vnContact.addError('Please put ph: in front of Main Contact Other phone Column at row ' + row);
                    continue;
                }       
            }
            */
            
            if (String.isNotBlank( vnContact.Contact_Homephone__c) ) {
                if(!checkPhone(vnContact.Contact_Homephone__c)){
                    vnContact.addError(vnContact.Contact_Homephone__c + ' Contact Home Phone is not a valid Phone at row ' + row);
                    continue;
                }
            }
            if (String.isNotBlank( vnContact.Contact_Mobilephone__c) ) {
                if(!checkPhone(vnContact.Contact_Mobilephone__c)){
                    vnContact.addError(vnContact.Contact_Mobilephone__c + ' Main Contact Mobile Phone is not a valid Phone at row ' + row);
                    continue;
                }
            }
            if (String.isNotBlank( vnContact.Contact_Otherphone__c) ) {
                if(!checkPhone(vnContact.Contact_Otherphone__c)){
                    vnContact.addError(vnContact.Contact_Otherphone__c + ' Main Contact Other Phone is not a valid Phone at row ' + row);
                    continue;
                }
            }
            if(String.isNotBlank(vnContact.contact_email__c)){
                if(!checkEmail(vnContact.contact_email__c)){
                    vnContact.addError('Invalid Contact Email at row ' + row);
                    continue;
                }
            }
            
             if(String.isBlank(vnContact.contact_lastname__c)){
                if(String.isNotBlank( vnContact.contact_fullname__c)){
                    vnContact.addError('Please copy the full name to last name. Can\'t keep last name unfilled at row ' + row);
                    continue;
                }
                vnContact.addError('Contact Last Name are required at row ' + row);
                continue;
            }
            
            if(String.isNotBlank(vnContact.br_currbrandid__c)){
                if(!productCodeSet.contains(vnContact.br_currbrandid__c)){
                    vnContact.addError(vnContact.br_currbrandid__c + ' BR CurrBrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(vnContact.br_brandid__c )){
                if(!productCodeSet.contains(vnContact.br_brandid__c )){
                    vnContact.addError(vnContact.br_brandid__c  + ' BR BrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(vnContact.cr_sampleproductid__c )){
                if(!productCodeSet.contains(vnContact.cr_sampleproductid__c )){
                    vnContact.addError(vnContact.cr_sampleproductid__c  + ' Sample Product ID does not exist at row ' + row); 
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
        String phonePattern = '^0[0-9]{6,11}$';
        Pattern pat = Pattern.compile(phonePattern);
        Matcher mat = pat.matcher(checkphone);
        if(String.isNotBlank(checkphone )){
            return mat.matches();
        } else {
            return True;
        }
    }
}