/*------------------------------------------------------------
Author:      Rayson Landeta
Description: Helper class for VN_call_manual__c object
History
04/01/2019   rlandeta    Created
-------------------------------------------------------------------------------------------*/

public class VNCallManualTriggerHelper {

    /* This method get all Affialite Values and check the duplicate;
    */
    public static void validateAffiliateValue(List<VN_call_manual__c> vnCallList) {
        Integer row = 1;
        List<Product2> productList = new List<Product2>();
        productList = [SELECT ProductCode FROM Product2 WHERE Market__c = 'VN'];
        Set<String> productCodeSet = new Set<String>();
        for(Product2 p : productList){      
            productCodeSet.add(p.ProductCode);
        }
        List<Affiliate_Value__c> avList = new List<Affiliate_Value__c>();
        avList = [SELECT recordtypeID,RecordType.Name, Name FROM Affiliate_Value__c WHERE Market__c = 'VN'];
        Map<String, Set<String>> avMap = new Map<String, Set<String>>();
        for(Affiliate_Value__c av : avList){
            if(avMap.containsKey(av.RecordType.Name)){
                avMap.get(av.RecordType.Name).add(av.Name.toLowerCase());
            } else {
                Set<String> avNameSet = new Set<String>();
                avNameSet.add(av.Name.toLowerCase());
                avMap.put(av.RecordType.Name,avNameSet);
            }
        }
        
        for(VN_call_manual__c vnCall : vnCallList){
            row++;
           /* if(String.isBlank(vnCall.Call_Id__c)){
                vnCall.addError('Call Id is required at row ' + row);
                continue;
            }*/
            Set<String> avNames = new Set<String>();
            if (String.isNotBlank( vnCall.Main_Address_Ward__c) ) {
                avNames = avMap.get('Ward');
                if(!avNames.contains(vnCall.Main_Address_Ward__c.toLowerCase())){
                    vnCall.addError(vnCall.Main_Address_Ward__c + ' Ward not exists at row ' + row);
                    continue;
                }
            }
            
            if (String.isNotBlank( vnCall.New_Address_Ward__c) ) {
                avNames = avMap.get('Ward');
                if(!avNames.contains(vnCall.New_Address_Ward__c.toLowerCase())){
                    vnCall.addError(vnCall.New_Address_Ward__c + ' Ward not exists at row ' + row);
                    continue;
                }
            }
            
            if (String.isNotBlank( vnCall.Main_Address_District__c) ) {
                avNames = avMap.get('District');
                if(!avNames.contains(vnCall.Main_Address_District__c.toLowerCase())){
                    vnCall.addError(vnCall.Main_Address_District__c + ' District not exists at row ' + row);
                    continue;
                }
            }
            if (String.isNotBlank( vnCall.New_Address_District__c) ) {
                avNames = avMap.get('District');
                if(!avNames.contains(vnCall.New_Address_District__c.toLowerCase())){
                    vnCall.addError(vnCall.New_Address_District__c + ' District not exists at row ' + row);
                    continue;
                }
            }
            
            if (String.isNotBlank( vnCall.Main_Address_City__c) ) {
                avNames = avMap.get('City');
                if(!avNames.contains(vnCall.Main_Address_City__c.toLowerCase())){
                    vnCall.addError(vnCall.Main_Address_City__c + ' City not exists at row ' + row);
                    continue;
                }
            }
            
            if (String.isNotBlank( vnCall.New_Address_City__c) ) {
                avNames = avMap.get('City');
                if(!avNames.contains(vnCall.New_Address_City__c.toLowerCase())){
                    vnCall.addError(vnCall.New_Address_City__c + ' City not exists at row ' + row);
                    continue;
                }
            }
             
            if (String.isNotBlank( vnCall.Call_Outcome__c) ) { 
                if(vnCall.Call_Outcome__c.equalsIgnoreCase('Successful')){
                    if (String.isNotBlank( vnCall.Successful_Reason__c) ) { 
                        avNames = avMap.get('Successful Reason');
                        if(!avNames.contains(vnCall.Successful_Reason__c.toLowerCase())){
                            vnCall.addError(vnCall.Successful_Reason__c + ' Successful Reason not exists at row ' + row);
                            continue;
                        }
                    } else {
                        vnCall.addError(' Successful Reason is required at row '+ row);
                        continue;
                    }
                } else if(vnCall.Call_Outcome__c.equalsIgnoreCase('Uncontactable')){
                    if (String.isNotBlank( vnCall.Uncontactable_Reason__c) ) {
                        avNames = avMap.get('Uncontactable Reason');
                        if(!avNames.contains(vnCall.Uncontactable_Reason__c.toLowerCase())){
                            vnCall.addError(vnCall.Uncontactable_Reason__c + ' Uncontactable Reason not exists at row ' + row);
                            continue;
                        }
                    }else {
                        vnCall.addError(' Uncontactable Reason is required at row ' + row);
                        continue;
                    }
                } else if(vnCall.Call_Outcome__c.equalsIgnoreCase('Unsuccessful')){
                    if (String.isNotBlank( vnCall.Unsuccessful_Reason__c) ) { 
                        avNames = avMap.get('Unsuccessful Reason');
                        if(!avNames.contains(vnCall.Unsuccessful_Reason__c.toLowerCase())){
                            vnCall.addError(vnCall.Unsuccessful_Reason__c + ' Unsuccessful Reason not exists at row ' + row);
                            continue;
                        }
                    }else {
                        vnCall.addError(' Unsuccessful Reason is required at row ' + row);
                        continue;
                    }
                }else if(vnCall.Call_Outcome__c.equalsIgnoreCase('Invalid')){
                    if (String.isNotBlank( vnCall.Invalid_Reason__c) ) { 
                        avNames = avMap.get('Invalid Reason');
                        if(!avNames.contains(vnCall.Invalid_Reason__c.toLowerCase())){
                            vnCall.addError(vnCall.Invalid_Reason__c + 'Invalid Reason not exists at row ' + row);
                            continue;
                        }
                    }else {
                        vnCall.addError(' Invalid Reason is required at row ' + row);
                        continue;
                    }
                }
            }
            
            
            if (String.isNotBlank( vnCall.create_order__c) ) {
                Boolean hasProduct = false;
                if(vnCall.create_order__c.equalsIgnoreCase('True')){
                    String p1 = 'blank1';
                    String p2 = 'blank2';
                    if(String.isNotBlank(vnCall.order_product_code_1__c)){
                        p1 = vnCall.order_product_code_1__c;
                        hasProduct = True;
                        if(!productCodeSet.contains(vnCall.order_product_code_1__c)){
                            vnCall.addError(vnCall.order_product_code_1__c + ' Product Code does not exist at row ' + row);
                            continue;
                        } else {
                            if(String.isBlank(vnCall.order_quantity_1__c)){
                                vnCall.addError(' Product Quantity 1 is required at row ' + row);    
                                continue;
                            } else if(!vnCall.order_quantity_1__c.isNumeric()){
                                vnCall.addError(' Product Quantity 1 should be numeric at row ' + row); 
                                continue;
                            }
                            
                            if(String.isBlank(vnCall.order_product_category_1__c)){
                                vnCall.addError('Order Product Category 1 is required at row ' + row);    
                                continue;
                            }
                        }
                    }
                    if(String.isNotBlank(vnCall.order_product_code_2__c)){
                        if(p1 == vnCall.order_product_code_2__c){
                            vnCall.addError(' Product Code should be unique at row ' + row);
                            continue;
                        }
                        p2 = vnCall.order_product_code_2__c;
                        hasProduct = True;
                        if(!productCodeSet.contains(vnCall.order_product_code_2__c)){
                            vnCall.addError(vnCall.order_product_code_2__c + ' Product Code does not exist at row ' + row);
                            continue;
                        } else {
                            if(String.isBlank(vnCall.order_quantity_2__c)){
                                vnCall.addError(' Product Quantity 2 is required at row ' + row);    
                                continue;
                            } else if(!vnCall.order_quantity_2__c.isNumeric()){
                                vnCall.addError(' Product Quantity 2 should be numeric at row ' + row); 
                                continue;
                            }
                            
                            if(String.isBlank(vnCall.order_product_category_2__c)){
                                vnCall.addError('Order Product Category 2 is required at row ' + row);    
                                continue;
                            }
                        }
                    }
                    if(String.isNotBlank(vnCall.order_product_code_3__c)){
                        if(p1 == vnCall.order_product_code_3__c || p2 == vnCall.order_product_code_3__c){
                            vnCall.addError(' Product Code should be unique at row ' + row);
                            continue;
                        }
                        hasProduct = True;
                        if(!productCodeSet.contains(vnCall.order_product_code_3__c)){
                            vnCall.addError(vnCall.order_product_code_3__c + ' Product Code does not exist at row ' + row);
                            continue;
                        } else {
                            if(String.isBlank(vnCall.order_quantity_3__c)){
                                vnCall.addError(' Product Quantity 3 is required at row ' + row);    
                                continue;
                            } else if(!vnCall.order_quantity_3__c.isNumeric()){
                                vnCall.addError(' Product Quantity 3 should be numeric at row ' + row); 
                                continue;
                            }
                            
                            if(String.isBlank(vnCall.order_product_category_3__c)){
                                vnCall.addError('Order Product Category 3 is required at row ' + row);    
                                continue;
                            }
                        }
                    }
                    
                    if(!hasProduct){
                        vnCall.addError('Atleast 1 product is required to create order at row ' + row); 
                        continue;
                    }
                } 
            }
            if (String.isNotBlank( vnCall.create_new_child__c) ) {
                if(vnCall.create_new_child__c.equalsIgnoreCase('True')){
                    if(String.isBlank(vnCall.new_child_last_name__c)){
                        if(String.isNotBlank( vnCall.new_child_full_name__c)){
                            vnCall.addError('Please copy the full name to last name. Can\'t keep last name unfilled at row ' + row);
                            continue;
                        }
                        vnCall.addError('Child Last Name is required at row ' + row);
                        continue;
                    }
                    // if(String.isNotBlank(vnCall.new_child_br_brand_id__c)){
                    //     if(!productCodeSet.contains(vnCall.new_child_br_brand_id__c)){
                    //         vnCall.addError(vnCall.new_child_br_brand_id__c + ' New Child BR Brand ID does not exist at row ' + row); 
                    //         continue;
                    //     }
                    // }
                } 
            }
            
            if (String.isNotBlank( vnCall.create_new_adult__c) ) {
                if(vnCall.create_new_adult__c.equalsIgnoreCase('True')){
                    if(String.isBlank(vnCall.new_adult_last_name__c)){
                        if(String.isNotBlank( vnCall.new_adult_full_name__c)){
                            vnCall.addError('Please copy the full name to last name. Can\'t keep last name unfilled at row ' + row);
                            continue;
                        }
                        vnCall.addError('New Adult Last Name required at row ' + row);
                        continue;
                    }
                }
                
                /**
                if(String.isBlank(vnCall.new_adult_mobile_phone__c)){
                    vnCall.addError(' Adult Mobile phone is required at row ' + row); 
                    continue;
                }
                **/
                
                // if(String.isNotBlank(vnCall.new_adult_br_brand_id__c)){
                //     if(!productCodeSet.contains(vnCall.new_adult_br_brand_id__c)){
                //         vnCall.addError(vnCall.new_adult_br_brand_id__c + ' New Adult BR Brand ID does not exist at row ' + row); 
                //         continue;
                //     }
                // } 
            }
            if (String.isNotBlank( vnCall.create_new_address__c) ) { 
                if(vnCall.create_new_address__c.equalsIgnoreCase('True')){
                    if(!(String.isNotBlank(vnCall.new_address_street_line_1__c) && String.isNotBlank(vnCall.new_address_city__c))){
                        vnCall.addError('New Street 1 and New City are required at row ' + row);
                        continue;
                    }
                } 
            }
            
          /*  Set<String> allPhone = new Set<String>();
            
             if (String.isNotBlank( vnCall.Main_Contact_Home_Phone__c) ) {
                if(vnCall.Main_Contact_Home_Phone__c.contains('ph:')){  
                    vnCall.Main_Contact_Home_Phone__c = vnCall.Main_Contact_Home_Phone__c.remove('ph:').trim();
                    allPhone.add(vnCall.Main_Contact_Home_Phone__c);
                    if(!checkPhone(vnCall.Main_Contact_Home_Phone__c)){
                        vnCall.addError(vnCall.Main_Contact_Home_Phone__c + ' Main Contact Home Phone is not a valid Phone at row ' + row);
                        continue;
                    }
                } else {
                    vnCall.addError('Please put ph: in front of Main Contact Home Phone Column at row ' + row);
                    continue;
                }       
            }
            
             if (String.isNotBlank( vnCall.Main_Contact_Mobile_Phone__c) ) {
                if(vnCall.Main_Contact_Mobile_Phone__c.contains('ph:')){  
                    vnCall.Main_Contact_Mobile_Phone__c = vnCall.Main_Contact_Mobile_Phone__c.remove('ph:').trim();
                    allPhone.add(vnCall.Main_Contact_Mobile_Phone__c);
                    if(!checkPhone(vnCall.Main_Contact_Mobile_Phone__c)){
                        vnCall.addError(vnCall.Main_Contact_Mobile_Phone__c + ' Main Contact Mobile Phone is not a valid Phone at row ' + row);
                        continue;
                    }
                } else {
                    vnCall.addError('Please put ph: in front of Main Contact Mobile Phone Column at row ' + row);
                    continue;
                }       
            }

          
            
            if (String.isNotBlank( vnCall.Main_Contact_Other_Phone__c) ) {
                if(vnCall.Main_Contact_Other_Phone__c.contains('ph:')){  
                    vnCall.Main_Contact_Other_Phone__c = vnCall.Main_Contact_Other_Phone__c.remove('ph:').trim();
                    allPhone.add(vnCall.Main_Contact_Other_Phone__c);
                    if(!checkPhone(vnCall.Main_Contact_Other_Phone__c)){
                        vnCall.addError(vnCall.Main_Contact_Other_Phone__c + ' Main Contact Other Phone is not a valid Phone at row ' + row);
                        continue;
                    }
                } else {
                    vnCall.addError('Please put ph: in front of Main Contact Other Phone Column at row ' + row);
                    continue;
                }       
            }
            
            if (String.isNotBlank( vnCall.new_adult_home_phone__c) ) {
                if(vnCall.new_adult_home_phone__c.contains('ph:')){  
                    vnCall.new_adult_home_phone__c = vnCall.new_adult_home_phone__c.remove('ph:').trim();
                    if(allPhone.contains(vnCall.new_adult_home_phone__c)){
                        vnCall.addError('New Adult Home Phone '+ vnCall.new_adult_home_phone__c +' already exist at row ' + row);
                        continue;
                    } else if(!checkPhone(vnCall.new_adult_home_phone__c)){
                        vnCall.addError(vnCall.new_adult_home_phone__c + ' New Adult Home Phone is not a valid Phone at row ' + row);
                        continue;
                    }
                } else {
                    vnCall.addError('Please put ph: in front of New Adult Home Phone Column at row ' + row);
                    continue;
                } 
            }

            if (String.isNotBlank( vnCall.new_adult_mobile_phone__c) ) {
                if(vnCall.new_adult_mobile_phone__c.contains('ph:')){  
                    vnCall.new_adult_mobile_phone__c = vnCall.new_adult_mobile_phone__c.remove('ph:').trim();
                    if(allPhone.contains(vnCall.new_adult_mobile_phone__c)){
                        vnCall.addError('New Adult Mobile Phone '+ vnCall.new_adult_mobile_phone__c +' already exist at row ' + row);
                        continue;
                    }  else if(!checkPhone(vnCall.new_adult_mobile_phone__c)){
                        vnCall.addError(vnCall.new_adult_mobile_phone__c + ' New Adult Mobile Phone is not a valid Phone at row ' + row);
                        continue;
                    }
                } else {
                    vnCall.addError('Please put ph: in front of New Adult Mobile Phone Column at row ' + row);
                    continue;
                }
            }*/
            
            Set<String> allPhone = new Set<String>();      
            if (String.isNotBlank( vnCall.Main_Contact_Home_Phone__c) ) {
                allPhone.add(vnCall.Main_Contact_Home_Phone__c);
                if(!checkPhone(vnCall.Main_Contact_Home_Phone__c)){
                    vnCall.addError(vnCall.Main_Contact_Home_Phone__c + ' Main Contact Home Phone is not a valid Phone at row ' + row);
                    continue;
                }
            }
            if (String.isNotBlank( vnCall.Main_Contact_Mobile_Phone__c) ) {
                allPhone.add(vnCall.Main_Contact_Mobile_Phone__c);
                if(!checkPhone(vnCall.Main_Contact_Mobile_Phone__c)){
                    vnCall.addError(vnCall.Main_Contact_Mobile_Phone__c + ' Main Contact Mobile Phone is not a valid Phone at row ' + row);
                    continue;
                }
            }
            if (String.isNotBlank( vnCall.Main_Contact_Other_Phone__c) ) {
                allPhone.add(vnCall.Main_Contact_Other_Phone__c);
                if(!checkPhone(vnCall.Main_Contact_Other_Phone__c)){
                    vnCall.addError(vnCall.Main_Contact_Other_Phone__c + ' Main Contact other Phone is not a valid Phone at row ' + row);
                    continue;
                }
            }
            if (String.isNotBlank( vnCall.new_adult_home_phone__c) ) {
                allPhone.add(vnCall.new_adult_home_phone__c);
                if(!checkPhone(vnCall.new_adult_home_phone__c)){
                    vnCall.addError(vnCall.new_adult_home_phone__c + ' New Adult Home Phone is not a valid Phone at row ' + row);
                    continue;
                }
            }
            if (String.isNotBlank( vnCall.new_adult_mobile_phone__c) ) {
                allPhone.add(vnCall.new_adult_mobile_phone__c);
                if(!checkPhone(vnCall.new_adult_mobile_phone__c)){
                    vnCall.addError(vnCall.new_adult_mobile_phone__c + ' New Adult Mobile Phone is not a valid Phone at row ' + row);
                    continue;
                }
            }
            
            if (String.isNotBlank( vnCall.new_adult_mobile_phone__c) && String.isNotBlank( vnCall.new_adult_home_phone__c)) {
                if(vnCall.new_adult_mobile_phone__c == vnCall.new_adult_home_phone__c){
                    vnCall.addError('New Adult Mobile Phone Column and New Adult Home Phone Column are same at row ' + row);
                    continue;
                }
            }
            if (String.isNotBlank( vnCall.Existing_Main_BR_SFID__c) ) {
                vnCall.Existing_Main_BR_SFID__c = vnCall.Existing_Main_BR_SFID__c.remove('\'');      
                vnCall.Existing_Main_BR_SFID__c = vnCall.Existing_Main_BR_SFID__c.remove('"');           
            }

            // if (String.isNotBlank( vnCall.Call_Rgrd_Contact_BR_SFID__c) ) {
            //     vnCall.Call_Rgrd_Contact_BR_SFID__c = vnCall.Call_Rgrd_Contact_BR_SFID__c.remove('\'');  
            // }

            if (String.isNotBlank( vnCall.Main_Address_Street_Line_1__c) ) {
                vnCall.Main_Address_Street_Line_1__c = vnCall.Main_Address_Street_Line_1__c.removeStart('"').removeEnd('"');      
            }

            if (String.isNotBlank( vnCall.Main_Address_Street_Line_2__c) ) {
                vnCall.Main_Address_Street_Line_2__c = vnCall.Main_Address_Street_Line_2__c.removeStart('"').removeEnd('"');      
            }
            if (String.isNotBlank( vnCall.call_rgrd_contact_dob__c) ) {
                if(!checkDate(vnCall.call_rgrd_contact_dob__c)){
                    vnCall.addError('Call Rgrd contact DOB is not valid date at row ' + row);
                    continue;
                }     
            }
            if (String.isNotBlank( vnCall.main_contact_dob__c) ) {
                if(!checkDate(vnCall.main_contact_dob__c)){
                    vnCall.addError('Main contact DOB is not valid date at row ' + row);
                    continue;
                }     
            }
            if (String.isNotBlank( vnCall.main_contact_edd__c) ) {
                if(!checkDate(vnCall.main_contact_edd__c)){
                    vnCall.addError('Main contact EDD is not valid date at row ' + row);
                    continue;
                }     
            }
            if (String.isNotBlank( vnCall.new_adult_dob__c) ) {
                if(!checkDate(vnCall.new_adult_dob__c)){
                    vnCall.addError('New Adult DOB is not valid date at row ' + row);
                    continue;
                }     
            }
            if (String.isNotBlank( vnCall.new_child_dob__c) ) {
                if(!checkDate(vnCall.new_child_dob__c)){
                    vnCall.addError('New Child DOB is not valid date at row ' + row);
                    continue;
                }     
            }
            
            //  if(String.isNotBlank( vnCall.new_adult_br_type__c ) ){
            //     if(vnCall.new_adult_br_type__c.equalsIgnoreCase('Lead')) {
            //         if(!(vnCall.new_adult_br_status__c  == 'Contacted' || vnCall.new_adult_br_status__c == 'Uncontacted' || vnCall.new_adult_br_status__c == 'Qualified')){
            //             vnCall.addError(vnCall.new_adult_br_status__c + ' is not valid BR Status, select from Contacted|Uncontacted|Qualified at row ' + row);
            //             continue;
            //         }     
            //     } else if(vnCall.new_adult_br_type__c.equalsIgnoreCase('User')){
            //         if(!(vnCall.new_adult_br_status__c == 'New' || vnCall.new_adult_br_status__c == 'Existing' || vnCall.new_adult_br_status__c == 'Lapsed')){
            //             vnCall.addError(vnCall.new_adult_br_status__c + ' is not valid BR Status, select from New|Existing|Lapsed at row ' + row);
            //             continue;
            //         } 
            //     } else {
            //         vnCall.addError(vnCall.new_adult_br_type__c + ' is not valid BR Type, select from Lead or User at row ' + row);
            //         continue;
            //     }
            // }
            
            // if(String.isNotBlank( vnCall.new_child_br_type__c ) ){
            //     if(vnCall.new_child_br_type__c.equalsIgnoreCase('Lead')) {
            //         if(!(vnCall.new_child_br_status__c   == 'Contacted' || vnCall.new_child_br_status__c  == 'Uncontacted' || vnCall.new_child_br_status__c == 'Qualified')){
            //             vnCall.addError(vnCall.new_child_br_status__c + ' is not valid BR Status, select from Contacted|Uncontacted|Qualified at row ' + row);
            //             continue;
            //         }     
            //     } else if(vnCall.new_child_br_type__c.equalsIgnoreCase('User')){
            //         if(!(vnCall.new_child_br_status__c == 'New' || vnCall.new_child_br_status__c == 'Existing' || vnCall.new_child_br_status__c == 'Lapsed')){
            //             vnCall.addError(vnCall.new_child_br_status__c + ' is not valid BR Status, select from New|Existing|Lapsed at row ' + row);
            //             continue;
            //         } 
            //     } else {
            //         vnCall.addError(vnCall.new_child_br_type__c + ' is not valid BR Type, select from Lead or User at row ' + row);
            //         continue;
            //     }
            // }

            if (String.isNotBlank( vnCall.create_converted_br__c) ) {
                if(vnCall.create_converted_br__c.equalsIgnoreCase('True')){                    
                    if(String.isNotBlank(vnCall.converted_br_brand_id__c)){
                        if(!productCodeSet.contains(vnCall.converted_br_brand_id__c)){
                            vnCall.addError(vnCall.converted_br_brand_id__c + ' Converted BR Brand ID does not exist at row ' + row); 
                            continue;
                        }
                    } else {
                        vnCall.addError(' Converted BR Brand ID is required at row ' + row);
                        continue;
                    }

                    if (String.isBlank(vnCall.converted_br_brand_name__c)) {
                        vnCall.addError(' Converted BR Brand Name is required at row ' + row);
                        continue;
                    }

                    if(String.isNotBlank(vnCall.converted_br_curr_brand_id__c)){
                        if(!productCodeSet.contains(vnCall.converted_br_curr_brand_id__c)){
                            vnCall.addError(vnCall.converted_br_curr_brand_id__c + ' Converted BR Curr Brand ID does not exist at row ' + row); 
                            continue;
                        }
                    }

                    if(String.isNotBlank(vnCall.converted_br_prev_brand_id__c)){
                        if(!productCodeSet.contains(vnCall.converted_br_prev_brand_id__c)){
                            vnCall.addError(vnCall.converted_br_prev_brand_id__c + ' Converted BR Prev Brand ID does not exist at row ' + row); 
                            continue;
                        }
                    }

                    if(String.isNotBlank( vnCall.converted_br_type__c ) ){
                        if(vnCall.converted_br_type__c.equalsIgnoreCase('Lead')) {
                            if(!(vnCall.converted_br_status__c  == 'Contacted' || vnCall.converted_br_status__c == 'Uncontacted' || vnCall.converted_br_status__c == 'Qualified')){
                                vnCall.addError(vnCall.converted_br_status__c + ' is not valid Converted BR Status, select from Contacted|Uncontacted|Qualified at row ' + row);
                                continue;
                            }     
                        } else if(vnCall.converted_br_type__c.equalsIgnoreCase('User')){
                            if(!(vnCall.converted_br_status__c == 'New' || vnCall.converted_br_status__c == 'Existing' || vnCall.converted_br_status__c == 'Lapsed')){
                                vnCall.addError(vnCall.converted_br_status__c + ' is not valid Converted BR Status, select from New|Existing|Lapsed at row ' + row);
                                continue;
                            } 
                        } else {
                            vnCall.addError(vnCall.converted_br_type__c + ' is not valid Converted BR Type, select from Lead or User at row ' + row);
                            continue;
                        }
                    } else {
                        vnCall.addError(' Converted BR Type is required at row ' + row);
                        continue;
                    }

                    
                    if (String.isNotBlank( vnCall.converted_brand_switch_reason__c) ) { 
                        avNames = avMap.get('Brand Switch Reason');
                        if(!avNames.contains(vnCall.converted_brand_switch_reason__c.toLowerCase())){
                            vnCall.addError(vnCall.converted_brand_switch_reason__c + ' Converted Brand Switch Reason not exists at row ' + row);
                            continue;
                        }
                    }                  
                } 
            }

            if (String.isNotBlank( vnCall.date_of_diagnosis__c) ) {
                if(!checkDate(vnCall.date_of_diagnosis__c)){
                    vnCall.addError('Date of Diagnosis is not valid date at row ' + row);
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