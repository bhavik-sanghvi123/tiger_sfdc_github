/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Helper class for MY_Contact__c object
History
04/01/2019   rlandeta    Created
09/26/2022   fgomendoza  Updated date validations
-------------------------------------------------------------------------------------------*/

public class MYContactTriggerHelper {

    /* This method get all Affialite Values and check the duplicate;
    */
    public static void validateAffiliateValue(List<MY_Contact__c> myContactList) {
        Integer row = 1;
        List<Product2> productList = new List<Product2>();
        productList = [SELECT ProductCode, Name FROM Product2 WHERE Market__c = 'MY'];
        Set<String> productCodeSet = new Set<String>();
        Set<String> productNameSet = new Set<String>();
        for(Product2 p : productList){      
            productCodeSet.add(p.ProductCode);
            productNameSet.add(p.Name);
        }
        
        List<Channel__c> chanList = new List<Channel__c>();
        chanList = [SELECT Channel_Ref_No__c, Name FROM Channel__c WHERE Market__c = 'MY'];
        Set<String> chanCodeSet = new Set<String>();
        Set<String> chanNameSet = new Set<String>();
        for(Channel__c c : chanList){      
            chanCodeSet.add(c.Channel_Ref_No__c);
            chanNameSet.add(c.Name);
        }
        
        List<Campaign> campList = new List<Campaign>();
        campList = [SELECT ExternalId__c, Name FROM Campaign WHERE Market__c = 'MY'];
        Set<String> campCodeSet = new Set<String>();
        Set<String> campNameSet = new Set<String>();
        for(Campaign c : campList){      
            campCodeSet.add(c.ExternalId__c);
            campNameSet.add(c.Name);
        }
        
        List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
        avList = [SELECT recordtypeID,RecordType.Name, Name FROM Affiliate_Value__c WHERE Market__c = 'MY'];
        Map<String, Set<String>> avMap = new Map<String, Set<String>>();
        for(Affiliate_Value__c av : avList){
            if(avMap.containsKey(av.RecordType.Name)){
                avMap.get(av.RecordType.Name).add(av.Name.toLowerCase());
            } else {
                Set<String> amyameSet = new Set<String>();
                amyameSet.add(av.Name.toLowerCase());
                avMap.put(av.RecordType.Name,amyameSet);
            }
        }
        
        for(MY_Contact__c myContact : myContactList){
            row++;
            Set<String> amyames = new Set<String>();
            if(String.isNotBlank(myContact.Contact_PreferredLanguage__c)){
                amyames = avMap.get('Preferred Language');
                if(!amyames.contains(myContact.Contact_PreferredLanguage__c.toLowerCase())){
                    myContact.addError(myContact.Contact_PreferredLanguage__c + ' Preferred Language not exists');
                    continue;
                }
            }
            
            if(String.isNotBlank(myContact.BR_BrandID__c)){
                if(!productCodeSet.contains(myContact.BR_BrandID__c)){
                    if(!productNameSet.contains(myContact.BR_BrandName__c)){
                        myContact.addError(' BR Brand ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            
           /* if(String.isNotBlank(myContact.BR_CurrPrevBrandID__c)){
                if(!productCodeSet.contains(myContact.BR_CurrPrevBrandID__c)){
                    if(!productNameSet.contains(myContact.BR_CurrPrevBrandName__c)){
                        myContact.addError(' CurrPrev Brand ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }*/
            
            if(String.isNotBlank(myContact.CR_ChannelID__c)){
                if(!chanCodeSet.contains(myContact.CR_ChannelID__c)){
                    if(!chanNameSet.contains(myContact.CR_ChannelName__c)){
                        myContact.addError(' Channel ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            
          /*  if(String.isNotBlank(myContact.CR_CampaignID__c)){
                if(!campCodeSet.contains(myContact.CR_CampaignID__c)){
                    if(!campNameSet.contains(myContact.CR_CampaignName__c)){
                        myContact.addError(' Campaign ID or Name does not exist at row ' + row); 
                        continue;
                    }
                }
            }
            */
            if(String.isNotBlank(myContact.Addr_Ward__c)){
                amyames = avMap.get('Ward');
                if(!amyames.contains(myContact.Addr_Ward__c.toLowerCase())){
                    myContact.addError(myContact.Addr_Ward__c + ' Ward not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(myContact.Addr_District__c)){
                amyames = avMap.get('District');
                if(!amyames.contains(myContact.Addr_District__c.toLowerCase())){
                    myContact.addError(myContact.Addr_District__c + ' District not exists at row ' + row);
                    continue;
                }
            }
            if(String.isNotBlank(myContact.Addr_City__c)){
                amyames = avMap.get('City');
                if(!amyames.contains(myContact.Addr_City__c.toLowerCase())){
                    myContact.addError(myContact.Addr_City__c + ' City not exists at row ' + row);
                    continue;
                }
            }
            if(String.isNotBlank(myContact.Contact_Ethnicity__c)){
                amyames = avMap.get('Ethnicity');
                if(!amyames.contains(myContact.Contact_Ethnicity__c.toLowerCase())){
                    myContact.addError(myContact.Contact_Ethnicity__c + ' Ethnicity not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(myContact.Addr_Region__c)){
                amyames = avMap.get('Region');
                if(!amyames.contains(myContact.Addr_Region__c.toLowerCase())){
                    myContact.addError(myContact.Addr_Region__c + ' Region not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank(myContact.BR_BrandSwitchReason__c)){
                amyames = avMap.get('Brand Switch Reason');
                if(!amyames.contains(myContact.BR_BrandSwitchReason__c.toLowerCase())){
                    myContact.addError(myContact.BR_BrandSwitchReason__c + ' Brand Switch Reason not exists at row ' + row);
                    continue;
                }
            }
            
            if(String.isNotBlank( myContact.Child_DOB__c) ) {
                if(!checkDateFormat(myContact.Child_DOB__c)){
                    myContact.addError(myContact.Child_DOB__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                }   
                else{
                    if(!checkValidDate(myContact.Child_DOB__c)){
                        myContact.addError(myContact.Child_DOB__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }  
            }
            
            if(String.isNotBlank( myContact.Contact_DOB__c) ) {
                if(!checkDateFormat(myContact.Contact_DOB__c)){
                    myContact.addError(myContact.Contact_DOB__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                } 
                else{
                    if(!checkValidDate(myContact.Contact_DOB__c)){
                        myContact.addError(myContact.Contact_DOB__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }      
            }
            
            if(String.isNotBlank( myContact.Contact_EDD__c) ) {
                if(!checkDateFormat(myContact.Contact_EDD__c)){
                    myContact.addError(myContact.Contact_EDD__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                }  
                else{
                    if(!checkValidDate(myContact.Contact_EDD__c)){
                        myContact.addError(myContact.Contact_EDD__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }     
            }
            
            if(String.isNotBlank( myContact.cr_registrationdate__c) ) {
                if(!checkDateFormat(myContact.cr_registrationdate__c)){
                    myContact.addError(myContact.cr_registrationdate__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                } 
                else{
                    if(!checkValidDate(myContact.cr_registrationdate__c)){
                        myContact.addError(myContact.cr_registrationdate__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }      
            }
            
            if(String.isNotBlank( myContact.SourceCreatedDate__c) ) {
                if(!checkDateFormat(myContact.SourceCreatedDate__c)){
                    myContact.addError(myContact.SourceCreatedDate__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                }  
                else{
                    if(!checkValidDate(myContact.SourceCreatedDate__c)){
                        myContact.addError(myContact.SourceCreatedDate__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }     
            }

            if(String.isNotBlank( myContact.BR_MemberExpiryDate__c) ) {
                if(!checkDateFormat(myContact.BR_MemberExpiryDate__c)){
                    myContact.addError(myContact.BR_MemberExpiryDate__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                }    
                else{
                    if(!checkValidDate(myContact.BR_MemberExpiryDate__c)){
                        myContact.addError(myContact.BR_MemberExpiryDate__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }   
            }

            if(String.isNotBlank( myContact.BR_MemberStartDate__c) ) {
                if(!checkDateFormat(myContact.BR_MemberStartDate__c)){
                    myContact.addError(myContact.BR_MemberStartDate__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                }    
                else{
                    if(!checkValidDate(myContact.BR_MemberStartDate__c)){
                        myContact.addError(myContact.BR_MemberStartDate__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }   
            }

            if(String.isNotBlank( myContact.member_expirydate__c) ) {
                if(!checkDateFormat(myContact.member_expirydate__c)){
                    myContact.addError(myContact.member_expirydate__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                }   
                else{
                    if(!checkValidDate(myContact.member_expirydate__c)){
                        myContact.addError(myContact.member_expirydate__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }    
            }

            if(String.isNotBlank( myContact.member_startdate__c) ) {
                if(!checkDateFormat(myContact.member_startdate__c)){
                    myContact.addError(myContact.member_startdate__c + ' is Invalid date format, use dd/mm/yyyy at row ' + row);
                    continue;
                }    
                else{
                    if(!checkValidDate(myContact.member_startdate__c)){
                        myContact.addError(myContact.member_startdate__c + ' is Invalid date, please input a valid date at row ' + row);
                        continue;
                    }
                }   
            }

            if(String.isNotBlank( myContact.BR_RelationType__c) ){
                if(String.isNotBlank(myContact.BR_RelationStatus__c)) {
                    if(myContact.BR_RelationType__c.equalsIgnoreCase('Lead')) {
                        if(!(myContact.BR_RelationStatus__c == 'Contacted' || myContact.BR_RelationStatus__c == 'Uncontacted' || myContact.BR_RelationStatus__c == 'Qualified')){
                            myContact.addError(myContact.BR_RelationStatus__c + ' is not valid Relation Status, select from Contacted|Uncontacted|Qualified at row ' + row);
                            continue;
                        }     
                    } else if(myContact.BR_RelationType__c.equalsIgnoreCase('User')){
                        if(!(myContact.BR_RelationStatus__c == 'New' || myContact.BR_RelationStatus__c == 'Existing' || myContact.BR_RelationStatus__c == 'Lapsed')){
                            myContact.addError(myContact.BR_RelationStatus__c + ' is not valid Relation Status, select from New|Existing|Lapsed at row ' + row);
                            continue;
                        } 
                    }
                } else {
                    myContact.addError('BR RelationStatus is required at row ' + row);
                	continue;
                }
            } else {
                myContact.addError('BR RelationType is required at row ' + row);
                continue;
            }
            
            if (String.isNotBlank( myContact.Contact_Homephone__c) ) {
                if(myContact.Contact_Homephone__c.contains('ph:')){  
                    myContact.Contact_Homephone__c = myContact.Contact_Homephone__c.remove('ph:').trim();
                    if(!checkphone(myContact.Contact_Homephone__c)){
                        myContact.addError(myContact.Contact_Homephone__c + ' Main Contact Home phone is not a valid phone at row ' + row);
                    continue;
                    }
                } else {
                    myContact.addError('Please put ph: in front of Main Contact Home phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( myContact.Contact_Mobilephone__c) ) {
                if(myContact.Contact_Mobilephone__c.contains('ph:')){  
                    myContact.Contact_Mobilephone__c = myContact.Contact_Mobilephone__c.remove('ph:').trim();
                    if(!checkphone(myContact.Contact_Mobilephone__c)){
                        myContact.addError(myContact.Contact_Mobilephone__c + ' Main Contact Mobile phone is not a valid phone at row ' + row);
                    continue;
                    }
                } else {
                    myContact.addError('Please put ph: in front of Main Contact Mobile phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( myContact.Contact_Otherphone__c) ) {
                if(myContact.Contact_Otherphone__c.contains('ph:')){  
                    myContact.Contact_Otherphone__c = myContact.Contact_Otherphone__c.remove('ph:').trim();
                    if(!checkphone(myContact.Contact_Otherphone__c)){
                        myContact.addError(myContact.Contact_Otherphone__c + ' Main Contact Other phone is not a valid phone at row ' + row);
                    continue;
                    }
                } else {
                    myContact.addError('Please put ph: in front of Main Contact Other phone Column at row ' + row);
                    continue;
                }       
            }
            
            if(String.isNotBlank(myContact.contact_email__c)){
                if(!checkEmail(myContact.contact_email__c)){
                    myContact.addError('Invalid Contact Email at row ' + row);
                    continue;
                }
            }
            
            if(String.isBlank(myContact.contact_lastname__c)){
                myContact.addError('Contact Last Name are required at row ' + row);
                continue;
            }
            
            if(String.isNotBlank(myContact.br_currbrandid__c)){
                if(!productCodeSet.contains(myContact.br_currbrandid__c)){
                    myContact.addError(myContact.br_currbrandid__c + ' BR CurrBrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(myContact.br_brandid__c )){
                if(!productCodeSet.contains(myContact.br_brandid__c )){
                    myContact.addError(myContact.br_brandid__c  + ' BR BrandID does not exist at row ' + row); 
                    continue;
                }
            }
            if(String.isNotBlank(myContact.cr_sampleproductid__c )){
                if(!productCodeSet.contains(myContact.cr_sampleproductid__c )){
                    myContact.addError(myContact.cr_sampleproductid__c  + ' Sample Product ID does not exist at row ' + row); 
                    continue;
                }
            }
        }
    }
    
    public static Boolean checkDateFormat(String checkDate) {
        //String datePattern = '(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[012])/((11|12|13|14|15|16|17|18|19|20)\\d\\d)';
        String datePattern = '(^(((0[1-9]|1[0-9]|2[0-8])[\\/](0[1-9]|1[012]))|((29|30|31)[\\/](0[13578]|1[02]))|((29|30)[\\/](0[4,6,9]|11)))[\\/](19|[2-9][0-9])\\d\\d$)|(^29[\\/]02[\\/](19|[2-9][0-9])(00|04|08|12|16|20|24|28|32|36|40|44|48|52|56|60|64|68|72|76|80|84|88|92|96)$)';
        Pattern pat = Pattern.compile(datePattern);
        Matcher mat = pat.matcher(checkDate);
        return mat.matches();
    }

    public static Boolean checkValidDate(String dateStr){
        try{
            String day = dateStr.split('/')[0];
            String month = dateStr.split('/')[1];
            String year = dateStr.split('/')[2];
            String dateValueOfStr = year + '-' + month + '-' + day;
            Date dateValid = Date.valueOf(dateValueOfStr);
        } catch(Exception e){
            return false;
        }
        return true;
    }
    
    public static Boolean checkEmail(String checkemail) {
        String eMailPattern = '^[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$';
        Pattern pat = Pattern.compile(eMailPattern);
        Matcher mat = pat.matcher(checkEMail.toLowerCase());
        return mat.matches();
    }
    public static Boolean checkphone(String checkphone) {
        String phonePattern = '^[0-9]{8,12}$';
        Pattern pat = Pattern.compile(phonePattern);
        Matcher mat = pat.matcher(checkphone);
        if(String.isNotBlank(checkphone )){
            return mat.matches();
        } else {
            return True;
        }
    }
}