/**
* @author        Rayson Landeta
* @date          4.1.2019
* @description   Controller of ExportVNCall (Lightning Component)
* @testClass     
* @revision(s)
*/
public with sharing class ExportVNCallController {
    //public List<OrderItem> orderItemList { get; set; }
    public List<callWrapper> cWrapperList { get; set; }

    public ExportVNCallController() {
        //will be called when the excel is being loaded
        if(ApexPages.currentPage().getParameters().get('agentid') != null){
            String agentId = ApexPages.currentPage().getParameters().get('agentid').escapeHTML4();
            cWrapperList = queryRecordData(agentId);
        }
    }
    
    @AuraEnabled
    public static List<User> queryAgentName() {
        return [Select Id, Name from User where Profile.Name = 'ANI Call Center Agent'];
    }

    @AuraEnabled
    public static List<callWrapper> queryRecordData(String agentId) {
        System.debug(agentId);
        List<callWrapper> callListWrapper = new List<callWrapper>();
        Set<Id> mainContactId = new Set<Id>();
        Set<Id> childContactId = new Set<Id>();
        List<Case> caseList = new List<Case>();
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        caseList = [SELECT ID, Status, CaseNumber, ExtractedFlag__c, Campaign__r.Name,Campaign__r.Brand__c,Campaign__r.External_Call_Execution__c, ContactId, Contact.FirstName, Contact.LastName, Contact.Name, Contact.Birthdate, Contact.HomePhone, Contact.Phone,
                           Contact.OtherPhone, Contact.Email, Contact.EstimatedDueDate__c, CallRegarding__r.Id, CallRegarding__r.FirstName, CallRegarding__r.LastName, CallRegarding__r.BirthDate, Subject, SuccessfulReason__c, UncontactableReason__c, UnsuccessfulReason__c, 
                           InvalidReason__c, Description, CallCompletedDateExternal__c
                    FROM Case WHERE Status = 'New'
                    and Campaign__r.External_Call_Execution__c = True
                    and ExtractedFlag__c = False
                    and Market__c = 'VN'
                    and RecordTypeId = :callRTId ORDER BY CaseNumber LIMIT 1000];
                    //Owner.Profile.Name = 'ANI Call Center Agent'
         List<Id> testId2 = new List<Id>();
         for(Case c : caseList){
             mainContactId.add(c.ContactId);
             testId2.add(c.ContactId);
             childContactId.add(c.CallRegarding__c);
         }
        
         List<Address__c> mainConAddList = new List<Address__c>([SELECT Id, ParentContact__c, Street1__c, Street2__c, Ward2__r.Name,
                                                                        District__r.Name, City2__r.Name, StateProvince__c, Country__c
                                                                 FROM Address__c WHERE ParentContact__c IN: mainContactId AND DefaultAddress__c = True]);
                                                                                                 
         Map<Id, Address__c> mainConAddMap = new Map<Id, Address__c>();
         for(Address__c addr : mainConAddList){
             mainConAddMap.put(addr.ParentContact__c, addr);
         }
        
         List<BrandRelationship__c> mainBRList = new List<BrandRelationship__c>([SELECT ID, BrandRelationship__r.ProductCode, BrandRelationship__r.Name,
                                                                                             CurrentBrand__r.ProductCode, CurrentBrand__r.Name, PrimaryContact__c,User__c,
                                                                                             PreviousBrand__r.ProductCode, PreviousBrand__r.Name, BrandSwitchReason__r.Name
                                                                                      FROM BrandRelationship__c WHERE PrimaryContact__c IN: mainContactId ORDER BY CreatedDate DESC]);
         Map<Id, BrandRelationship__c> mainBRMap = new Map<Id, BrandRelationship__c>();
         for(BrandRelationship__c mBR : mainBRList){
             if(!mainBRMap.containsKey(mBR.PrimaryContact__c))
                mainBRMap.put(mBR.PrimaryContact__c, mBR);
         }
        
         List<BrandRelationship__c> childBRList = new List<BrandRelationship__c>([SELECT ID, BrandRelationship__r.ProductCode, BrandRelationship__r.Name,
                                                                                             CurrentBrand__r.ProductCode, CurrentBrand__r.Name, PrimaryContact__c, User__c,
                                                                                             PreviousBrand__r.ProductCode, PreviousBrand__r.Name, BrandSwitchReason__r.Name
                                                                                      FROM BrandRelationship__c WHERE User__c IN: childContactId ORDER BY CreatedDate DESC]);
         Map<Id, BrandRelationship__c> childBRMap = new Map<Id, BrandRelationship__c>();
         for(BrandRelationship__c cBR : childBRList){
             if(!childBRMap.containsKey(cBR.User__c))
                childBRMap.put(cBR.User__c, cBR);
         }
        
         for(Case cs : caseList){
             callWrapper cw = new callWrapper(cs, mainBRMap.get(cs.ContactId), childBRMap.get(cs.CallRegarding__c), mainConAddMap.get(cs.ContactId));
             callListWrapper.add(cw);
         }                  
         return callListWrapper;
    }

    @AuraEnabled 
    public static CallReportWrapper getExcelFileAsBase64String(String agentUserId) {
        PageReference excelPage = Page.VNCallData;
        //excelPage.getParameters().put('cid',contactId);
        Blob excelBlob;
        if(System.Test.isRunningTest()) { 
          excelBlob = blob.valueOf('Unit.Test');
        } else {
          excelBlob = excelPage.getContent();
        }
        String base64Excel = EncodingUtil.base64Encode(excelBlob);
        User usr = [Select Id, Market__c from User where Id=: UserInfo.getUserId()];

        createFile('ExtractedCallReport_' + usr.Market__c + '_' + Datetime.now() + '.xls', excelBlob, usr.Market__c);

        CallReportWrapper result = new CallReportWrapper();
        result.userMarket =  usr.Market__c;
        result.fileContent = base64Excel;
        return result;
    }  
  /*  public static CallReportWrapper getExcelFileAsBase64String(String agentUserId) {
        system.debug(agentUserId);
        //PageReference excelPage = Page.VNCallData;
        //excelPage.getParameters().put('agentid',agentUserId);
        List<callWrapper> extractCallList = queryRecordData(agentUserId);

        String generatedCSVFile ='';
        
        String fileRow = '';
        generatedCSVFile = 'Call ID,Brand to be discussed,Campaign name,Main Contact ID,Main Contact First Name,Main Contact Last Name,Main Contact Full Name,Main Contact DOB,Main Contact Home Phone,Main Contact Mobile Phone,Main Contact Other Phone,Main Contact Email,Main Contact EDD,Main Address Street Line 1,Main Address Street Line 2,Main Address Ward,Main Address District,Main Address City,Main Address Province,Main Address Country,Existing Main BR SFID,Existing Main BR Brand ID,Existing Main BR Brand Name,Existing Main BR Curr Brand ID,Existing Main BR Curr Brand Name,Existing Main BR prev Brand ID,Existing Main BR prev Brand Name,Existing Main Brand Switch Reason,Call Rgrd Contact ID,Call Rgrd Contact First Name,Call Rgrd Contact Last Name,Call Rgrd Contact DOB,Call Rgrd Contact BR Brand ID,Call Rgrd Contact BR Brand Name,Call Rgrd Contact BR SFID,Call Rgrd Contact BR Curr Brand ID,Call Rgrd Contact BR Curr Brand Name,Call Rgrd Contact BR prev Brand ID,Call Rgrd Contact BR prev Brand Name,Call Rgrd Contact Brand Switch Reason,Call Outcome,Product Discussed,Product Discussed 2,Uncontactable Reason,Successful Reason,Unsuccessful Reason,Invalid Reason,Subject,Call Note,Create Order,Order Payment Method,Order Type,Order Start Date,Order Description,Order Product Code 1,Order Quantity 1,Order Product Category 1,Order Product Code 2,Order Quantity 2,Order Product Category 2,Order Product Code 3,Order Quantity 3,Order Product Category 3,Create New Child,New Child First Name,New Child Last Name,New Child Full Name,New Child DOB,New Child BR Brand ID,New Child Curr Brand ID,New Child prev Brand ID,New Child BR Type,New Child BR Status,Create New Adult,New Adult First Name,New Adult Last Name,New Adult Full Name,New Adult DOB,New Adult BR Brand ID,New Adult Curr Brand ID,New Adult prev Brand ID,New Adult Home Phone,New Adult Mobile Phone,New Adult Email,New Adult BR Type,New Adult BR Status,Create New Address,New Address Street Line 1,New Address Street Line 2,New Address Ward,New Address District,New Address City,New Address Province,Call Status'+ '\n';


        for(callWrapper calls : extractCallList){
            fileRow = '';
            fileRow = fileRow +','+ calls.callID;        
            fileRow = fileRow +','+ calls.brandToBeDiscussed;        
            fileRow = fileRow +','+ calls.campaignName;
            fileRow = fileRow +','+ calls.mainContactID;        
            fileRow = fileRow +','+ calls.mainContactFirstName;        
            fileRow = fileRow +','+ calls.mainContactLastName;        
            fileRow = fileRow +','+ calls.mainContactFullName; 
            if(String.isNotBlank( calls.mainContactDOB)){
                calls.mainContactDOB = formatDateString(calls.mainContactDOB);
            }
            fileRow = fileRow +','+ calls.mainContactDOB;        
            fileRow = fileRow +','+ calls.mainContactHomePhone;       
            fileRow = fileRow +','+ calls.mainContactMobilePhone;       
            fileRow = fileRow +','+ calls.mainContactOtherPhone;         
            fileRow = fileRow +','+ calls.mainContactEmail;
            if(String.isNotBlank(calls.mainContactEDD)){
                calls.mainContactEDD = formatDateString(calls.mainContactEDD);
            }
            fileRow = fileRow +','+ calls.mainContactEDD;        
            fileRow = fileRow +',"'+ calls.mainAddressStreetLine1 + '"';        
            fileRow = fileRow +',"'+ calls.mainAddressStreetLine2 + '"';        
            fileRow = fileRow +','+ calls.mainAddressWard;        
            fileRow = fileRow +','+ calls.mainAddressDistrict;        
            fileRow = fileRow +','+ calls.mainAddressCity;        
            fileRow = fileRow +','+ calls.mainAddressProvince;        
            fileRow = fileRow +','+ calls.mainAddressCountry;        
            fileRow = fileRow +','+ calls.mainBRSFID;        
            fileRow = fileRow +','+ calls.mainBRBrandID;        
            fileRow = fileRow +','+ calls.mainBRBrandName;       
            fileRow = fileRow +','+ calls.mainBRCurrBrandID;        
            fileRow = fileRow +','+ calls.mainBRCurrBrandName;        
            fileRow = fileRow +','+ calls.mainBRPrevBrandID;        
            fileRow = fileRow +','+ calls.mainBRPrevBrandName;        
            fileRow = fileRow +','+ calls.mainBrandSwitchReason;        
            fileRow = fileRow +','+ calls.callRgrdContactID;        
            fileRow = fileRow +','+ calls.callRgrdFirstName;        
            fileRow = fileRow +','+ calls.callRgrdLastName; 
            if(String.isNotBlank(calls.callRgrdDOB)){
                calls.callRgrdDOB = formatDateString(calls.callRgrdDOB);
            }
            fileRow = fileRow +','+ calls.callRgrdDOB;        
            fileRow = fileRow +','+ calls.callRgrdBRBrandID;        
            fileRow = fileRow +','+ calls.callRgrdBRBrandName;      
            fileRow = fileRow +','+ calls.callRgrdContactBRSFID;    
            fileRow = fileRow +','+ calls.callRgrdBRCurrBrandID;        
            fileRow = fileRow +','+ calls.callRgrdBRCurrBrandName;        
            fileRow = fileRow +','+ calls.callRgrdBRPrevBrandID;        
            fileRow = fileRow +','+ calls.callRgrdBRPrevBrandName;        
            fileRow = fileRow +','+ calls.callRgrdBrandSwitchReason;        
            
            fileRow = fileRow.replaceFirst(',','');
            fileRow = fileRow.replace('\'null', '');
            fileRow = fileRow.replace('null', '');            
            fileRow = fileRow + ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,';
            fileRow = fileRow +calls.callStatus;  
            generatedCSVFile = generatedCSVFile + fileRow + '\n';
        }

        Blob excelBlob;
        if(System.Test.isRunningTest()) { 
          excelBlob = blob.valueOf('Unit.Test');
        } else {    
          excelBlob = blob.valueOf(generatedCSVFile); //excelPage.getContent();
        }
        String base64Excel = EncodingUtil.base64Encode(excelBlob);
        User usr = [Select Id, Market__c from User where Id=: UserInfo.getUserId()];

		createFile('ExtractedOrderReport_' + usr.Market__c + '_' + Datetime.now() + '.xls', excelBlob, usr.Market__c);
        CallReportWrapper result = new CallReportWrapper();
        result.userMarket =  usr.Market__c;
        result.fileContent = base64Excel;
        return result;
    }  */
    
    //public static String formatDateString(String vnCallDate) {
    //    String[] dateString = vnCallDate.split('-');
    //    String newDate = dateString[2] + '/' + dateString[1] + '/' + dateString[0];
    //    return newDate;
    //}

    public static void createFile (String filename, Blob content, String market) {
        String libraryName = 'Call Export Library - VN';
        
        try { 
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = content;
            cv.Title = filename;
            cv.PathOnClient = filename;     
            insert cv;

            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            if(System.Test.isRunningTest()) { 
                libraryName = 'Asset Library';
            }
            System.debug(libraryName);
            ContentWorkspace ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name =: libraryName LIMIT 1];

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId  = ws.Id;
            insert cdl;
           
            List<ContentFolderMember> memberFolder = new List<ContentFolderMember>();
            for (ContentFolderMember cfm : [SELECT Id, ChildRecordId, ParentContentFolderId
                                      FROM ContentFolderMember
                                      WHERE ChildRecordId = :cv.ContentDocumentId
                                      LIMIT 1]) {
                ContentFolderMember updatedCfm = new ContentFolderMember(Id = cfm.Id,
                                                                     ChildRecordId = cdl.ContentDocumentId,
                                                                     ParentContentFolderId = ws.RootContentFolderId);
                memberFolder.add(updatedCfm);

            }                          
            if (!memberFolder.isEmpty()) {
                update memberFolder;    
            }
            
            updateCaseExtractedFlag();
        } catch(QueryException qex) {
            throw new AuraHandledException('You have no access to the ' + libraryName + ' folder');      
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

    public static void updateCaseExtractedFlag() {
        List<Case> cList = new List<Case>();
        Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
        cList = [SELECT ID, Status,ExtractedFlag__c,Campaign__r.External_Call_Execution__c FROM Case WHERE Status = 'New'
                    and Campaign__r.External_Call_Execution__c = True
                    and ExtractedFlag__c = False
                 	and Market__c = 'VN'
                    and RecordTypeId = :callRTId ORDER BY CaseNumber LIMIT 1000];
        if(!cList.isEmpty()){
            for(Case c : cList) {         
                c.ExtractedFlag__c = true;
            }
            update cList;
    	}
    }

    public class CallReportWrapper {
        @AuraEnabled
        public string userMarket { get; set; }
        @AuraEnabled
        public string fileContent { get; set; }
    }
    
    
    public class callWrapper{
        @AuraEnabled
        public String callID { get; set; }
        @AuraEnabled
        public String brandToBeDiscussed { get; set; }
        @AuraEnabled
        public String campaignName { get; set; }
        @AuraEnabled
        public String mainContactID { get; set; }
        @AuraEnabled
        public String mainContactFirstName { get; set; }
        @AuraEnabled
        public String mainContactLastName { get; set; }
        @AuraEnabled
        public String mainContactFullName { get; set; }
        @AuraEnabled
        public String mainContactDOB { get; set; }
        @AuraEnabled
        public String mainContactHomePhone { get; set; }
        @AuraEnabled
        public String mainContactMobilePhone { get; set; }
        @AuraEnabled
        public String mainContactOtherPhone { get; set; }
        @AuraEnabled
        public String mainContactEmail { get; set; }
        @AuraEnabled
        public String mainContactEDD { get; set; }
        @AuraEnabled
        public String mainAddressStreetLine1 { get; set; }
        @AuraEnabled
        public String mainAddressStreetLine2 { get; set; }
        @AuraEnabled
        public String mainAddressWard { get; set; }
        @AuraEnabled
        public String mainAddressDistrict { get; set; }
        @AuraEnabled
        public String mainAddressCity { get; set; }
        @AuraEnabled
        public String mainAddressProvince { get; set; }
        @AuraEnabled
        public String mainAddressCountry { get; set; }
        @AuraEnabled
        public String mainBRSFID { get; set; }
        @AuraEnabled
        public String mainBRBrandID { get; set; }
        @AuraEnabled
        public String mainBRBrandName { get; set; }
        @AuraEnabled
        public String mainBRCurrBrandID { get; set; }
        @AuraEnabled
        public String mainBRCurrBrandName { get; set; }
        @AuraEnabled
        public String mainBRPrevBrandID { get; set; }
        @AuraEnabled
        public String mainBRPrevBrandName { get; set; }
        @AuraEnabled
        public String mainBrandSwitchReason { get; set; }
        @AuraEnabled
        public String callRgrdContactID { get; set; }
        @AuraEnabled
        public String callRgrdFirstName { get; set; }
        @AuraEnabled
        public String callRgrdLastName { get; set; }
        @AuraEnabled
        public String callRgrdDOB { get; set; }
        @AuraEnabled
        public String callRgrdBRBrandID { get; set; }
        @AuraEnabled
        public String callRgrdBRBrandName { get; set; }
        @AuraEnabled
        public String callRgrdBRCurrBrandID { get; set; }
        @AuraEnabled
        public String callRgrdBRCurrBrandName { get; set; }
        @AuraEnabled
        public String callRgrdBRPrevBrandID { get; set; }
        @AuraEnabled
        public String callRgrdBRPrevBrandName { get; set; }
        @AuraEnabled
        public String callRgrdBrandSwitchReason { get; set; }
        @AuraEnabled
        public String callRgrdContactBRSFID { get; set; }
        @AuraEnabled
        public String callStatus { get; set; }
        @AuraEnabled
        public String invalidReason { get; set; }
        @AuraEnabled
        public String subject { get; set; }
        @AuraEnabled
        public String successfulReason { get; set; }
        @AuraEnabled
        public String uncontactableReason { get; set; }
        @AuraEnabled
        public String unsuccessfulReason { get; set; }
        @AuraEnabled
        public String callNote { get; set; }
        @AuraEnabled
        public String callCompletedExternal { get; set; }
        
        public callWrapper(Case c, Brandrelationship__c mBR, Brandrelationship__c cBR, Address__c ad){
            if(String.isNotBlank(c.Description)){
            	callNote = c.Description;
            }
            if(String.isNotBlank(c.UnsuccessfulReason__c)){
            	unsuccessfulReason = c.UnsuccessfulReason__c;
            }
            if(String.isNotBlank(c.UncontactableReason__c)){
            	uncontactableReason = c.UncontactableReason__c;
            }
            if(String.isNotBlank(c.InvalidReason__c)){
            	invalidReason = c.InvalidReason__c;
            }
            if(String.isNotBlank(c.SuccessfulReason__c)){
            	successfulReason = c.SuccessfulReason__c;
            }
            callStatus = c.Status;
            subject = c.subject;
            callID = c.CaseNumber;
            brandToBeDiscussed = c.Campaign__r.Brand__c;
            campaignName = c.Campaign__r.Name;
            mainContactID = c.ContactId;
            mainContactFirstName = c.Contact.FirstName;
            mainContactLastName = c.Contact.LastName;
            mainContactFullName = c.Contact.Name;
            mainContactDOB = String.valueOf(c.Contact.Birthdate);
            mainContactHomePhone = c.Contact.HomePhone;
            mainContactMobilePhone = c.Contact.Phone;
            mainContactOtherPhone = c.Contact.OtherPhone;
            mainContactEmail = c.Contact.Email;
            mainContactEDD = String.valueOf(c.Contact.EstimatedDueDate__c);
            //added call completed
            callCompletedExternal = String.valueOf(c.CallCompletedDateExternal__c);
            if(ad != null){
                mainAddressStreetLine1 = ad.Street1__c;
                mainAddressStreetLine2 = ad.Street2__c;
                mainAddressWard = ad.Ward2__r.Name;
                mainAddressDistrict = ad.District__r.Name;
                mainAddressCity = ad.City2__r.Name;
                mainAddressProvince = ad.StateProvince__c;
                mainAddressCountry = ad.Country__c;
            }
            if(mBR != null){
                mainBRSFID = mBR.ID;
                mainBRBrandID = mBR.BrandRelationship__r.ProductCode;
                mainBRBrandName = mBR.BrandRelationship__r.Name;
                mainBRCurrBrandID = mBR.CurrentBrand__r.ProductCode;
                mainBRCurrBrandName = mBR.CurrentBrand__r.Name;
                mainBRPrevBrandID = mBR.PreviousBrand__r.ProductCode;
                mainBRPrevBrandName = mBR.PreviousBrand__r.Name;
                mainBrandSwitchReason = mBR.BrandSwitchReason__r.Name;
            }
            callRgrdContactID = c.CallRegarding__r.Id;
            callRgrdFirstName = c.CallRegarding__r.FirstName;
            callRgrdLastName = c.CallRegarding__r.LastName;
            callRgrdDOB = String.valueOf(c.CallRegarding__r.Birthdate);
            if(cBR != null){
                callRgrdBRBrandID = cBR.BrandRelationship__r.ProductCode;
                callRgrdBRBrandName = cBR.BrandRelationship__r.Name;
                callRgrdBRCurrBrandID = cBR.CurrentBrand__r.ProductCode;
                callRgrdBRCurrBrandName = cBR.CurrentBrand__r.Name;
                callRgrdBRPrevBrandID = cBR.PreviousBrand__r.ProductCode;
                callRgrdBRPrevBrandName = cBR.PreviousBrand__r.Name;
                callRgrdBrandSwitchReason = cBR.BrandSwitchReason__r.Name;
                callRgrdContactBRSFID = cBR.Id;
            }
        }
    }

}