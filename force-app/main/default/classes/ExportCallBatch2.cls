/*
Author: Jericson Mercado
Description: Batch job that creates record on Call Export object to be extracted via dataloader
Changes: Update based on the new template,

10.6.2020   malviz  Added new fields (Reporting Month,Milestone, Data Shource, Call Category, Call Sub Category)
03.31.2022	fgomendoza	Enhanced Batch job SOQL filters  
*/
public class ExportCallBatch2 implements Database.Batchable<sObject>, Database.Stateful {
    
    String Market;
    public ExportCallBatch2 (String m){
        Market = m;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        Id callRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        
        String queryStr = 'SELECT Id'
            + ' FROM Case'
            + ' WHERE RecordTypeId =: callRecordType';
        
        if(!Test.isRunningTest()){
            Id profileId = [SELECT Id FROM Profile WHERE Name = 'VN Outsource Call Center'][0].Id;
            Id userId = [SELECT Id FROM User WHERE Username = 'vinh.tranngocxuan@abbott.com'][0].Id;
            Map<Id,Campaign> campaignIdMap = new Map<Id, Campaign>([SELECT Id FROM Campaign WHERE External_Call_Execution__c = true]);
            Set<Id> campaignId = campaignIdMap.keySet();

            queryStr += ' AND Status = \'New\''
                + ' AND ExtractedFlag__c = false'
                + ' AND CreatedDate = LAST_N_DAYS:7'
                + ' AND (Owner.ProfileId =: profileId OR OwnerId =: userId)'
                + ' AND Campaign__c IN: campaignId'
                + ' ORDER BY CaseNumber';
        }
        
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> caseList){
        
        Set<Id> mainContactId = new Set<Id>();
        //Set<Id> childContactId = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        
        List<Case> caseListExec = [SELECT CallRegarding__c, Description, UnsuccessfulReason__r.Name, UncontactableReason__r.Name, InvalidReason__r.Name, SuccessfulReason__r.Name, Status, Subject, CaseNumber, Campaign__r.Brand__c, Campaign__r.Name, ContactId,
            Reporting_Month__c, Milestone__r.Name, Data_Source__r.Name, Call_Category__r.Name, Call_Sub_Category__r.Name, Contact.FirstName, Contact.LastName, Contact.Name, Contact.Birthdate, Contact.HomePhone, Contact.Phone,
            Contact.OtherPhone, Contact.Email, Contact.EstimatedDueDate__c, CallRegarding__r.Id, Owner.Name, CallRegarding__r.FirstName, CallRegarding__r.LastName, CallRegarding__r.Birthdate, CreatedDate,
            RelatedBrandRelationship__c,RelatedBrandRelationship__r.BrandRelationship__r.ProductCode, RelatedBrandRelationship__r.BrandRelationship__r.Name, RelatedBrandRelationship__r.CurrentBrand__r.ProductCode, RelatedBrandRelationship__r.CurrentBrand__r.Name,
            RelatedBrandRelationship__r.PreviousBrand__r.ProductCode, RelatedBrandRelationship__r.PreviousBrand__r.Name, RelatedBrandRelationship__r.BrandSwitchReason__r.Name
            FROM Case WHERE Id IN: caseList];
        
        if(!caseListExec.isEmpty()){
            
            for(Case c : caseListExec){
                mainContactId.add(c.ContactId);
                //childContactId.add(c.CallRegarding__c);
                c.ExtractedFlag__c = true;
                caseMap.put(c.Id, c);
            }
            
            mainContactId.remove(null);
            //childContactId.remove(null);
            
            Map<Id, Address__c> mainConAddMap = new Map<Id, Address__c>();
            for(Address__c addr : [SELECT Id, ParentContact__c, Street1__c, Street2__c, Ward2__r.Name, District__r.Name, City2__r.Name, StateProvince__c, Country__c
                                   FROM Address__c WHERE ParentContact__c IN: mainContactId AND DefaultAddress__c = True]){
                                       mainConAddMap.put(addr.ParentContact__c, addr);
                                   }
            
            // List<BrandRelationship__c> brList = new List<BrandRelationship__c>([SELECT BrandRelationship__r.ProductCode, BrandRelationship__r.Name,
            //                                                                            CurrentBrand__r.ProductCode, CurrentBrand__r.Name, PrimaryContact__c,User__c,
            //                                                                            PreviousBrand__r.ProductCode, PreviousBrand__r.Name, BrandSwitchReason__r.Name
            //                                                                       FROM BrandRelationship__c
            //                                                                      WHERE PrimaryContact__c IN: mainContactId
            //                                                                         OR User__c IN: childContactId
            //                                                                   ORDER BY CreatedDate DESC]);
            
            // Map<Id, BrandRelationship__c> mainBRMap = new Map<Id, BrandRelationship__c>();
            // Map<Id, BrandRelationship__c> childBRMap = new Map<Id, BrandRelationship__c>();
            // for(BrandRelationship__c br : brList){
            //     if(!mainBRMap.containsKey(br.PrimaryContact__c))
            //         mainBRMap.put(br.PrimaryContact__c, br);
            
            //     if(!childBRMap.containsKey(br.User__c))
            //         childBRMap.put(br.User__c, br);
            // }
            // System.debug(mainBRMap.size());
            // System.debug(childBRMap.size());
            // System.debug(mainConAddMap.size());
            
            List<CallExport2__c> callExports = new List<CallExport2__c>();
            for(Database.SaveResult sr: Database.update(caseListExec, false)){
                if(sr.isSuccess()){
                    BrandRelationship__c main = new BrandRelationship__c();
                    BrandRelationship__c child = new BrandRelationship__c();
                    Address__c add = new Address__c();
                    System.debug(sr.getId());
                    // if(mainBRMap.containsKey((caseMap.get(sr.getId()).ContactId))){
                    //     main = mainBRMap.get(caseMap.get(sr.getId()).ContactId);
                    // }
                    
                    // if(childBRMap.containsKey((caseMap.get(sr.getId()).ContactId))){
                    //     child = childBRMap.get(caseMap.get(sr.getId()).ContactId);
                    // }
                    
                    if(mainConAddMap.containsKey((caseMap.get(sr.getId()).ContactId))){
                        add = mainConAddMap.get(caseMap.get(sr.getId()).ContactId);
                    }
                    
                    callExports.add( generate(  caseMap.get(sr.getId()), main, child, add ) );
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
            Database.insert(callExports);
        }
    }
    
    public void finish(Database.BatchableContext BC){}
    
    private CallExport2__c generate(Case c, Brandrelationship__c mBR, Brandrelationship__c cBR, Address__c ad) {
        
        CallExport2__c ce = new CallExport2__c();
        ce.Case__c = c.Id;
        ce.Call_Note__c = c.Description;
        ce.Unsuccessful_Reason__c = c.UnsuccessfulReason__r.Name;
        ce.Uncontactable_Reason__c = c.UncontactableReason__r.Name;
        ce.Invalid_Reason__c = c.InvalidReason__r.Name;
        ce.Successful_Reason__c = c.SuccessfulReason__r.Name;
        //ce.Status__c = c.Status;
        ce.Subject__c = c.subject;
        ce.Call_ID__c = c.CaseNumber;
        ce.Brand_To_Be_Discussed__c = c.Campaign__r.Brand__c;
        ce.Campaign_name__c = c.Campaign__r.Name;
        ce.Main_Contact_ID__c = c.ContactId;
        ce.Main_Contact_First_Name__c = c.Contact.FirstName;
        ce.Main_Contact_Last_Name__c = c.Contact.LastName;
        ce.Main_Contact_Full_Name__c = c.Contact.Name;
        ce.Main_Contact_DOB__c = String.valueOf(c.Contact.Birthdate);
        ce.Main_Contact_Home_Phone__c = c.Contact.HomePhone;
        ce.Main_Contact_Mobile_Phone__c = c.Contact.Phone;
        ce.Main_Contact_Other_Phone__c = c.Contact.OtherPhone;
        ce.Main_Contact_Email__c = c.Contact.Email;
        ce.Main_Contact_EDD__c = String.valueOf(c.Contact.EstimatedDueDate__c);
        ce.Outsource_Vendor_Campaign__c = c.Campaign__r.Brand__c;
        ce.Outsource_Vendor_Name__c = c.Owner.Name;
        ce.Reporting_Month__c = c.Reporting_Month__c;
        ce.Milestone__c = c.Milestone__r.Name;
        ce.Data_Source__c = c.Data_Source__r.Name;
        ce.Call_Category__c = c.Call_Category__r.Name;
        ce.Call_Sub_Category__c = c.Call_Sub_Category__r.Name;
        
        if(ad != null){
            ce.Address__c = ad.Id;
            ce.Main_Address_Street_Line_1__c = ad.Street1__c;
            ce.Main_Address_Street_Line_2__c = ad.Street2__c;
            ce.Main_Address_Ward__c = ad.Ward2__r.Name;
            ce.Main_Address_District__c = ad.District__r.Name;
            ce.Main_Address_City__c = ad.City2__r.Name;
            ce.Main_Address_Province__c = ad.StateProvince__c;
            ce.Main_Address_Country__c = ad.Country__c;
        }
        
        if (c.RelatedBrandRelationship__c != null) {
            //ce.MainBrandRelationship__c = c.RelatedBrandRelationship__c;
            ce.Existing_Main_BR_SFID__c = c.RelatedBrandRelationship__c;
            ce.Existing_Main_BR_Brand_ID__c = c.RelatedBrandRelationship__r.BrandRelationship__r.ProductCode;
            ce.Existing_Main_BR_Brand_Name__c = c.RelatedBrandRelationship__r.BrandRelationship__r.Name;
            ce.Existing_Main_BR_Curr_Brand_ID__c = c.RelatedBrandRelationship__r.CurrentBrand__r.ProductCode;
            ce.Existing_Main_BR_Curr_Brand_Name__c = c.RelatedBrandRelationship__r.CurrentBrand__r.Name;
            ce.Existing_Main_BR_Prev_Brand_ID__c = c.RelatedBrandRelationship__r.PreviousBrand__r.ProductCode;
            ce.Existing_Main_BR_Prev_Brand_Name__c = c.RelatedBrandRelationship__r.PreviousBrand__r.Name;
            ce.Existing_Main_Brand_Switch_Reason__c = c.RelatedBrandRelationship__r.BrandSwitchReason__r.Name;
        }   
        
        // if(mBR != null){
        //     ce.MainBrandRelationship__c = mBR.Id;
        //     ce.Existing_Main_BR_SFID__c = mBR.Id;
        //     ce.Existing_Main_BR_Brand_ID__c = mBR.BrandRelationship__r.ProductCode;
        //     ce.Existing_Main_BR_Brand_Name__c = mBR.BrandRelationship__r.Name;
        //     ce.Existing_Main_BR_Curr_Brand_ID__c = mBR.CurrentBrand__r.ProductCode;
        //     ce.Existing_Main_BR_Curr_Brand_Name__c = mBR.CurrentBrand__r.Name;
        //     ce.Existing_Main_BR_Prev_Brand_ID__c = mBR.PreviousBrand__r.ProductCode;
        //     ce.Existing_Main_BR_Prev_Brand_Name__c = mBR.PreviousBrand__r.Name;
        //     ce.Existing_Main_Brand_Switch_Reason__c = mBR.BrandSwitchReason__r.Name;
        // }
        ce.Call_Rgrd_Contact_ID__c = c.CallRegarding__r.Id;
        ce.Call_Rgrd_Contact_First_Name__c = c.CallRegarding__r.FirstName;
        ce.Call_Rgrd_Contact_Last_Name__c = c.CallRegarding__r.LastName;
        ce.Call_Rgrd_Contact_DOB__c = String.valueOf(c.CallRegarding__r.Birthdate);
        
        // if(cBR != null){
        //     ce.ChildBrandRelationship__c = cBR.Id;
        //     ce.Call_Rgrd_Contact_BR_Brand_ID__c = cBR.BrandRelationship__r.ProductCode;
        //     ce.Call_Rgrd_Contact_BR_Brand_Name__c = cBR.BrandRelationship__r.Name;
        //     ce.Call_Rgrd_Contact_BR_Curr_Brand_ID__c = cBR.CurrentBrand__r.ProductCode;
        //     ce.Call_Rgrd_Contact_BR_Curr_Brand_Name__c = cBR.CurrentBrand__r.Name;
        //     ce.Call_Rgrd_Contact_BR_Prev_Brand_ID__c = cBR.PreviousBrand__r.ProductCode;
        //     ce.Call_Rgrd_Contact_BR_Prev_Brand_Name__c = cBR.PreviousBrand__r.Name;
        //     ce.Call_Rgrd_Contact_Brand_Switch_Reason__c = cBR.BrandSwitchReason__r.Name;
        //     ce.Call_Rgrd_Contact_BR_SFID__c = cBR.Id;
        // }
        
        return ce;
    }
}