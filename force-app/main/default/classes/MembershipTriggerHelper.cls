/*
Author: Frank Gomendoza
Description: Helper class for Membership object
History:
08/04/2022   fgomendoza    Created copyMembershipToContact and all method dependencies
*/
public class MembershipTriggerHelper {
    public static Map<String, String> brandCodeMap = new Map<String, String>{'92221' => 'Ensure', '92222' => 'Glucerna', '92224' => 'Pediasure', '92225' => 'Similac'};
    public static Map<Id, Product2> productMap = new Map<Id, Product2>();
    public static Map<Id, Contact> conUpdateMap = new Map<Id, Contact>();  
    
    public static void copyMembershipToContact(Map<Id, SObject> oldMap, Map<Id, Membership__c> newMap){
        if(Trigger.isInsert || Trigger.isUpdate){
            Set<Id> productIdSet = new Set<Id>();
            List<Membership__c> membershipList = new List<Membership__c>();
            Map<Id, Map<String, Membership__c>> contactNewBrandMembershipMap = new Map<Id, Map<String, Membership__c>>();
            Map<Id, Map<String, Membership__c>> contactExistingBrandMembershipMap = new Map<Id, Map<String, Membership__c>>();
            System.debug('newMap: '+newMap);
            System.debug('oldMap: '+oldMap);
            //Get New Valid Membership records
            for(Membership__c memNew : newMap.values()){
                if(!String.isBlank(memNew.MembershipId__c) && memNew.Contact__c != null){
                    contactNewBrandMembershipMap = createBrandMembershipMap(contactNewBrandMembershipMap, memNew);
                    if(memNew.Recent_Product_Purchased__c != null){
                        productIdSet.add(memNew.Recent_Product_Purchased__c);
                    }
                }
            }
            //Get Existing Membership records to compare 
            for(Membership__c existingMem : [SELECT Id, Contact__c, MembershipId__c, Status__c, NumberOfDaysDormant__c, NumberOfTransactions__c, MembershipStartDate__c, Recent_Product_Purchased__c, CreatedDate FROM Membership__c 
                                             WHERE Contact__c IN: contactNewBrandMembershipMap.keySet() AND Id NOT IN: newMap.keySet() AND MembershipId__c != null])
            {
                contactExistingBrandMembershipMap = createBrandMembershipMap(contactExistingBrandMembershipMap, existingMem);
                if(existingMem.Recent_Product_Purchased__c != null){
                    productIdSet.add(existingMem.Recent_Product_Purchased__c);
                }
            }
            for(Product2 p : [SELECT Id, Name FROM Product2 WHERE Id IN: productIdSet]){
                productMap.put(p.Id, p);
            }
            for(Id conId : contactNewBrandMembershipMap.keySet()){
                Map<String, Membership__c> memMap = contactNewBrandMembershipMap.get(conId);
                membershipList.addAll(memMap.values());
            }
            //Compare incoming membership to existing membership
            for(Membership__c mem : membershipList){
                String rawMembershipId = mem.MembershipId__c.replaceAll('(\\s+)', '');
                String brand = brandCodeMap.get(rawMembershipId.left(5));
                if(contactExistingBrandMembershipMap.containsKey(mem.Contact__c)){
                    if(contactExistingBrandMembershipMap.get(mem.Contact__c).containsKey(brand)){
                        Membership__c existingMem = contactExistingBrandMembershipMap.get(mem.Contact__c).get(brand);
                        if(existingMem.Status__c == 'Expired' && mem.Status__c != 'Expired'){
                            conUpdateMap = processContactUpdateMap(mem, brand);
                        }
                        else if(existingMem.Status__c != 'Expired' && mem.Status__c == 'Expired'){
                            conUpdateMap = processContactUpdateMap(existingMem, brand);
                        }
                        else if( (existingMem.Status__c == 'Activated' || existingMem.Status__c == 'New') && 
                                (mem.Status__c == 'Activated' || mem.Status__c == 'New') && existingMem.CreatedDate < mem.CreatedDate){
                            conUpdateMap = processContactUpdateMap(mem, brand);
                        }
                        else if( (existingMem.Status__c == 'Activated' || existingMem.Status__c == 'New') && 
                                (mem.Status__c == 'Activated' || mem.Status__c == 'New') && existingMem.CreatedDate > mem.CreatedDate){
                            conUpdateMap = processContactUpdateMap(existingMem, brand);
                        }
                        else if( (existingMem.Status__c == 'Activated' || existingMem.Status__c == 'New') && 
                                (mem.Status__c == 'Activated' || mem.Status__c == 'New') && existingMem.CreatedDate == mem.CreatedDate 
                                && String.isBlank(existingMem.Recent_Product_Purchased__c) && !String.isBlank(mem.Recent_Product_Purchased__c))
                        {
                            conUpdateMap = processContactUpdateMap(mem, brand);
                        }
                        
                    }
                    else{
                        conUpdateMap = processContactUpdateMap(mem, brand);
                    }
                }
                else{
                    conUpdateMap = processContactUpdateMap(mem, brand);
                }
            }
            
        }
        else if(Trigger.isDelete){
        }
        
        if(!conUpdateMap.keySet().isEmpty()){
            update conUpdateMap.values();
        }
    }
    
    public static Map<Id, Contact> processContactUpdateMap(Membership__c mem, String brand){
        if(conUpdateMap.containsKey(mem.Contact__c)){
            Contact con = conUpdateMap.get(mem.Contact__c);
            conUpdateMap.put(mem.Contact__c, updateContactMembershipInfo(mem, brand, con));
        }
        else{
            conUpdateMap.put(mem.Contact__c, updateContactMembershipInfo(mem, brand, null));
        }
        return conUpdateMap;
    }
    
    public static Contact updateContactMembershipInfo(Membership__c member, String brand, Contact con){
        Contact c = new Contact();
        if(con == null){
            c.Id = member.Contact__c;
        }
        else{
            c = con;
        }
        if(brand == 'Ensure'){
            c.MembershipId_Ensure__c = member.MembershipId__c;
            c.MembershipNumberOfDaysDormant_Ensure__c = member.NumberOfDaysDormant__c;
            c.MembershipNumberOfTransactions_Ensure__c = member.NumberOfTransactions__c;
            c.MembershipStartDate_Ensure__c = member.MembershipStartDate__c;
            c.MembershipStatus_Ensure__c = member.Status__c;
            c.MembershipRecentProduct_Ensure__c = productMap.containsKey(member.Recent_Product_Purchased__c) ? productMap.get(member.Recent_Product_Purchased__c).Name : null;
        }
        else if(brand == 'Glucerna'){
            c.MembershipId_Glucerna__c = member.MembershipId__c;
            c.MembershipNumberOfDaysDormant_Glucerna__c = member.NumberOfDaysDormant__c;
            c.MembershipNumberOfTransactions_Glucerna__c = member.NumberOfTransactions__c;
            c.MembershipStartDate_Glucerna__c = member.MembershipStartDate__c;
            c.MembershipStatus_Glucerna__c = member.Status__c;
            c.MembershipRecentProduct_Glucerna__c = productMap.containsKey(member.Recent_Product_Purchased__c) ? productMap.get(member.Recent_Product_Purchased__c).Name : null;
        }
        else if(brand == 'Pediasure'){
            c.MembershipId_Pediasure__c = member.MembershipId__c;
            c.MembershipNumberOfDaysDormant_Pediasure__c = member.NumberOfDaysDormant__c;
            c.MembershipNumberOfTransactions_Pediasure__c = member.NumberOfTransactions__c;
            c.MembershipStartDate_Pediasure__c = member.MembershipStartDate__c;
            c.MembershipStatus_Pediasure__c = member.Status__c;
            c.MembershipRecentProduct_Pediasure__c = productMap.containsKey(member.Recent_Product_Purchased__c) ? productMap.get(member.Recent_Product_Purchased__c).Name : null;
        }
        else if(brand == 'Similac'){
            c.MembershipId_Similac__c = member.MembershipId__c;
            c.MembershipNumberOfDaysDormant_Similac__c = member.NumberOfDaysDormant__c;
            c.MembershipNumberOfTransactions_Similac__c = member.NumberOfTransactions__c;
            c.MembershipStartDate_Similac__c = member.MembershipStartDate__c;
            c.MembershipStatus_Similac__c = member.Status__c;
            c.MembershipRecentProduct_Similac__c = productMap.containsKey(member.Recent_Product_Purchased__c) ? productMap.get(member.Recent_Product_Purchased__c).Name : null;
        }
        return c;
    }
    
    public static Map<Id, Map<String, Membership__c>> createBrandMembershipMap(Map<Id, Map<String, Membership__c>> contactBrandMembershipMap, Membership__c mem){
        String rawMembershipId = mem.MembershipId__c.replaceAll('(\\s+)', '');
        if(brandCodeMap.keySet().contains(rawMembershipId.left(5)) ){
            String brand = brandCodeMap.get(rawMembershipId.left(5));
            if(!contactBrandMembershipMap.containsKey(mem.Contact__c)){
                contactBrandMembershipMap.put(mem.Contact__c, new Map<String, Membership__c>());
            }
            if(contactBrandMembershipMap.get(mem.Contact__c).containsKey(brand)){
                Membership__c memberBrand = contactBrandMembershipMap.get(mem.Contact__c).get(brand);
                if(memberBrand.Status__c == 'Expired' && mem.Status__c != 'Expired'){
                    contactBrandMembershipMap.get(mem.Contact__c).put(brand, mem);
                }
                else if( (memberBrand.Status__c == 'Activated' || memberBrand.Status__c == 'New') && 
                        (mem.Status__c == 'Activated' || mem.Status__c == 'New') && memberBrand.CreatedDate < mem.CreatedDate){
                            contactBrandMembershipMap.get(mem.Contact__c).put(brand, mem);
                        }
                else if((memberBrand.Status__c == 'Activated' || memberBrand.Status__c == 'New') && 
                        (mem.Status__c == 'Activated' || mem.Status__c == 'New') && memberBrand.CreatedDate == mem.CreatedDate 
                        && String.isBlank(memberBrand.Recent_Product_Purchased__c) && !String.isBlank(mem.Recent_Product_Purchased__c))
                {
                    contactBrandMembershipMap.get(mem.Contact__c).put(brand, mem);
                }
            }
            else{
                contactBrandMembershipMap.get(mem.Contact__c).put(brand, mem);
            }
        }
        return contactBrandMembershipMap;
    }
    
}