/**
* @author        Rey Austral
* @date          3.28.2019
* @description   Controller of RewardReportGenerator (Lightning Component)
* @testClass     RewardReportGeneratorControllerTest
* @revision(s)

* History
* 06/04/2019   vmirandilla    Added LIMIT 1000 to query to prevent Collection Size Error when extracting the report.
*/
public with sharing class RewardReportGeneratorController {
	public List<Reward__c> rewardItemList { get; set; }

    public RewardReportGeneratorController() {
        //will be called when the excel is being loaded
        rewardItemList = queryRewardItemReport();
    }
    @AuraEnabled
    public static List<Reward__c> queryRewardItemReport() {
        String query= '',  submitted = CommonConstant.ORDER_STATUS_SUBMITTED, redeem = CommonConstant.REWARD_REDEEM_RECORDTYPE;       
        
        query = 'Select Name, RedemptionDate__c, Contact__r.Name, Contact__r.Phone, DeliveryStatus__c, FileExportDate__c,' +
                       ' DeliveryAddress__r.Name, DeliveryAddress__r.Country__c, DeliveryAddress__r.City2__r.Name, DeliveryAddress__r.PostalCode__c, DeliveryAddress__r.Ward2__r.Name,' +
                       ' DeliveryAddress__r.District__r.Name, DeliveryAddress__r.Region__r.Name, DeliveryAddress__r.Street1__c, DeliveryAddress__r.Street2__c, DeliveryAddress__r.StateProvince__c,' +
                       ' ProductForRedemption__r.Name, ProductForRedemption__r.ProductCode, Quantity__c, PointsAmount__c, Price__c, TotalPointsAmount__c, CreatedBy.Name,' +
                       ' Contact__r.LoyaltyID__c, Contact__r.Source_Loyalty_Id__c, Contact__r.NationalID__c, Contact__r.Email' +
                ' From Reward__c where isVoid__c != TRUE AND DeliveryStatus__c =: submitted AND RecordType.Name =: redeem ' +               
                'Order by Name LIMIT 1000';
        return database.query(query);
    }

    @AuraEnabled 
    public static RewardReportWrapper getExcelFileAsBase64String() {
        PageReference excelPage = Page.RewardExportPage;
        //excelPage.getParameters().put('cid',contactId);
        Blob excelBlob;
        if(System.Test.isRunningTest()) { 
          excelBlob = blob.valueOf('Unit.Test');
        } else {
          excelBlob = excelPage.getContent();
        }
        String base64Excel = EncodingUtil.base64Encode(excelBlob);
        User usr = [Select Id, Market__c from User where Id=: UserInfo.getUserId()];

        Datetime now = Datetime.now(); Integer offset = UserInfo.getTimezone().getOffset(now); 
        Datetime local = now.addSeconds(offset/1000);
        createFile('ExtractedRewardReport_' + usr.Market__c + '_' + local + '.xls', excelBlob, usr.Market__c);

        RewardReportWrapper result = new RewardReportWrapper();
        result.userMarket =  usr.Market__c;
        result.fileContent = base64Excel;
        return result;
    }  

    public static void createFile (String filename, Blob content, String market) {
        String libraryName = 'Orders & Purchases - ' + market;
        
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
            
            updateOrderStatus();
        } catch(QueryException qex) {
            throw new AuraHandledException('You have no access to the "' + libraryName + '" folder');      
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }

    public static void updateOrderStatus() {
        List<Reward__c> rewardList = new List<Reward__c>();
       
        rewardList = [SELECT Id, DeliveryStatus__c FROM Reward__c 
                    WHERE DeliveryStatus__c =: CommonConstant.ORDER_STATUS_SUBMITTED AND RecordType.Name =: CommonConstant.REWARD_REDEEM_RECORDTYPE 
                    ORDER BY Name LIMIT 1000];
      
        
        for(Reward__c reward : rewardList) {
            reward.DeliveryStatus__c = CommonConstant.ORDER_STATUS_TRANSFERRED;         
            reward.Extracted__c = true;
            reward.FileExportDate__c = Date.today();
        }

        update rewardList;
    }

    public class RewardReportWrapper {
        @AuraEnabled
        public string userMarket { get; set; }
        @AuraEnabled
        public string fileContent { get; set; }
    }
}