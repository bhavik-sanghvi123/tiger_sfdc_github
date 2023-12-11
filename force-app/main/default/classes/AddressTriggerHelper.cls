/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: Helper class for Address object

History
01/18/2019   vmirandilla    Created
11/06/2020   malviz         Added updateProvince, getCity
-------------------------------------------------------------------------------------------*/

public class AddressTriggerHelper {

    /* This method will get the Contact's Household value to auto-populates Reward's Parent Household field
    */
    public static void getHousehold(List<Address__c> addressList) {
        Map<Id,Contact> conMap = getRelatedContact(addressList);

        for(Address__c address : addressList) {
            if(conMap.containsKey(address.ParentContact__c)) {
                address.ParentHousehold__c = conMap.get(address.ParentContact__c).AccountId;
            }
        }
    }

    /* This method wil check if the Contact has an existing default address
    
    public static void checkDefaultAddress(List<Address__c> addressList) {
        Map<Id,Contact> conMap = getRelatedContact(addressList);
        Set<Id> conIdSet = new Set<Id>();

        for(Address__c address : addressList) {
            if(address.ParentContact__c != null) {
                conIdSet.add(address.ParentContact__c);
            }
        }

        List<Address__c> addressConList = [SELECT Id, ParentContact__c 
                                            FROM Address__c 
                                            WHERE ParentContact__c IN :conIdSet AND DefaultAddress__c = TRUE];

        for(Address__c address : addressList) {
            for(Address__c conDefaultAdd : addressConList) {
                if(address.DefaultAddress__c == TRUE) {
                    if(address.ParentContact__c == conDefaultAdd.ParentContact__c && address.Id != conDefaultAdd.Id) {
                        address.addError('Unable to save record - There is an existing Default Address for this Contact.');  
                    } else {
                        conMap.get(address.ParentContact__c).Region__c = address.Region__c;
                    }
                }
            }
        }

        update conMap.values();
    }*/

    /* This method wil populate the Contact's Region field based on the Region value of the Default Address.
    
    public static void updateDefaultAddress(Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {
        Map<Id,Contact> conMap = getRelatedContact(newMap.values());
        Set<Id> conIdSet = new Set<Id>();

        for(Address__c address : (List<Address__c>)newMap.values()) {
            if(address.ParentContact__c != null) {
                conIdSet.add(address.ParentContact__c);
            }
        }

        List<Address__c> addressConList = [SELECT Id, ParentContact__c 
                                            FROM Address__c 
                                            WHERE ParentContact__c IN :conIdSet AND DefaultAddress__c = TRUE];

        for(Address__c address : (List<Address__c>)newMap.values()) {    
            Address__c oldRecord = (Address__c) oldMap.get(address.Id);

            if(!addressConList.isEmpty()) {
                for(Address__c conDefaultAdd : addressConList) {
                    if(oldRecord.DefaultAddress__c == FALSE && address.DefaultAddress__c == TRUE) {
                        if(address.ParentContact__c == conDefaultAdd.ParentContact__c && address.Id != conDefaultAdd.Id) {
                            address.addError('Unable to save record - There is an existing Default Address for this Contact.');  
                        } else {
                            conMap.get(address.ParentContact__c).Region__c = address.Region__c;
                        }
                    }
                    
                    else if(oldRecord.DefaultAddress__c == TRUE && address.DefaultAddress__c == FALSE) {
                        conMap.get(address.ParentContact__c).Region__c = null;
                    }
    
                    else if (oldRecord.Region__c != address.Region__c) {
                        conMap.get(address.ParentContact__c).Region__c = address.Region__c;
                    }
                }
            } else {
                if(oldRecord.DefaultAddress__c == FALSE && address.DefaultAddress__c == TRUE){
                    conMap.get(address.ParentContact__c).Region__c = address.Region__c;
                }

                else if(oldRecord.DefaultAddress__c == TRUE && address.DefaultAddress__c == FALSE) {
                    conMap.get(address.ParentContact__c).Region__c = null;
                }
            }
        }

        update conMap.values();
    }*/

    /* This method will delete the Contact's Region value whenever the default address got deleted.
    
    public static void deleteRegion(List<Address__c> addressList) {
        Map<Id,Contact> conMap = getRelatedContact(addressList);

        for(Address__c address : addressList) {
            if(conMap.containsKey(address.ParentContact__c)) {
                if(address.DefaultAddress__c == TRUE) {
                    conMap.get(address.ParentContact__c).Region__c = null;
                }
            }
        }

    update conMap.values();
    }*/

    public static Map<Id,Contact> getRelatedContact(List<Address__c> addressList) {
        Set<Id> conIdSet = new Set<Id>();
        
        for(Address__c add : addressList) {
            if(add.ParentContact__c != null) {
                conIdSet.add(add.ParentContact__c);
            }
        }
        
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select AccountId, Region__c, Default_Address__c
                                                            FROM Contact
                                                            WHERE Id IN :conIdSet]);

        return conMap ;
    }

    public static void checkDefaultAddress(List<Address__c> newList, Map<Id,sObject> oldMap) {

        Map<Id, Contact> conMap = getRelatedContact(newList);
        Map<Id, Contact> conMapUpdate = new Map<Id, Contact>();
        for(Address__c address: newList) {
            Address__c old = new Address__c();

            if(Trigger.isInsert
                && address.DefaultAddress__c
                && address.ParentContact__c != null) {

                // check if there is an existing default
                if(conMap.get(address.ParentContact__c).Default_Address__c != null
                    || (conMapUpdate.containsKey(address.ParentContact__c)
                        && conMapUpdate.get(address.ParentContact__c).Default_Address__c != null) // check if in the same transaction, it inserted 2 default address for the same contact
                    ) {
                    address.addError('Unable to save record - There is an existing Default Address for this Contact.'); 
                } else {
                    conMap.get(address.ParentContact__c).Region__c = address.Region__c;
                    conMap.get(address.ParentContact__c).Default_Address__c = address.Id;
                    conMapUpdate.put(address.ParentContact__c, conMap.get(address.ParentContact__c));
                }
            }

            else if(Trigger.isUpdate) {
                old = (Address__c) oldMap.get(address.Id);
                Boolean noError = true;

                // check if changed 
                if(address.DefaultAddress__c != old.DefaultAddress__c) {

                    // default
                    if(address.DefaultAddress__c) {
                        // check if there is already an existing 
                        if(conMap.get(address.ParentContact__c).Default_Address__c != null
                            || (conMapUpdate.containsKey(address.ParentContact__c)
                                && conMapUpdate.get(address.ParentContact__c).Default_Address__c != null) // check if in the same transaction, it inserted 2 default address for the same contact
                            ) {
                            address.addError('Unable to save record - There is an existing Default Address for this Contact.'); 
                            noError = false;
                        } else {
                            conMap.get(address.ParentContact__c).Region__c = address.Region__c;
                            conMap.get(address.ParentContact__c).Default_Address__c = address.Id;
                            conMapUpdate.put(address.ParentContact__c, conMap.get(address.ParentContact__c));
                        }
                    }
                    else {
                        // reset
                        if(conMap.get(address.ParentContact__c) != null) {
                            conMapUpdate.put(old.ParentContact__c, new Contact(Id = old.ParentContact__c, Default_Address__c = null, Region__c = null));
                        }
                    }

                    // check old contact
                    if(noError
                        && old.DefaultAddress__c
                        && address.ParentContact__c != old.ParentContact__c) {
                        conMapUpdate.put(old.ParentContact__c, new Contact(Id = old.ParentContact__c, Default_Address__c = null, Region__c = null));
                    }
                }
            }

            else if(Trigger.isDelete) {
                if(address.DefaultAddress__c
                    && address.ParentContact__c != null
                    && conMap.get(address.ParentContact__c).Region__c != null) {
                    conMapUpdate.put(old.ParentContact__c, new Contact(Id = address.ParentContact__c, Region__c = null));
                }
            }
        }
        if(!conMapUpdate.isEmpty()) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            List<Database.SaveResult> sr = Database.update(conMapUpdate.values(), dml);
        }
    }

    public static void checkExternalId(List<Address__c> newList, Map<Id,sObject> newMap) {
        List<Address__c> updateAddressList = new List<Address__c>();
        
        for(Address__c addr : newList){
            if(String.isBlank(addr.External_Reference_Number__c)){
                Address__c addrUpdate = new Address__c(Id = addr.Id);
                Blob requestBlob = Blob.valueOf(addr.Id);
                Blob hash = Crypto.generateDigest('MD5', requestBlob);
                String requestSignature = EncodingUtil.convertToHex(hash);
                addrUpdate.External_Reference_Number__c = 'SFMD5-'+requestSignature;
                updateAddressList.add(addrUpdate);
            }
        }

        if(!updateAddressList.isEmpty()){
            update updateAddressList;
        }
    }

    // TKT-002676: Auto-populate Province field when City is within Metro Manila
    // Only for PH
    public static void updateProvince(List<Address__c> addressList) {
        String cities = Label.PH_Cities;
        Map<Id,Affiliate_Value__c> cityMap = getCity(addressList);
        
        for(Address__c address : addressList) {
            if(cities.containsIgnoreCase(cityMap.get(address.City2__c).Name) && address.StateProvince__c == null) {
                address.StateProvince__c = 'Metro Manila';
            }
        } 
    }
    
    public static Map<Id,Affiliate_Value__c> getCity(List<Address__c> addressList) {
        Set<Id> cityId = new Set<Id>();
        for(Address__c add : addressList) {
            if(add.City2__c != null) {
                cityId.add(add.City2__c);
            }
        }
        
        Map<Id,Affiliate_Value__c> cityMap = new Map<Id,Affiliate_Value__c>([Select Id, Name
                                                            FROM Affiliate_Value__c
                                                            WHERE Id IN :cityId]);
        return cityMap ;
    }

}