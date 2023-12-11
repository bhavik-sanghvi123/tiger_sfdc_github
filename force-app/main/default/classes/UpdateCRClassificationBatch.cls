/*----------------------------------------------------------------------------------------
Author:      Rey Austral
Description: Batch to fixed update exising cr if the newly created cr is not the latest date

History
10/14/2019   raustral   Created
10/29/201    raustral   Update to process null classification only
-------------------------------------------------------------------------------------------*/
// for deletion
public class UpdateCRClassificationBatch {} /* implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID , BrandRelationship__c,  RegistrationDate__c'                       
            + ' FROM ChannelResponse__c '
            + ' WHERE'            
            + ' BrandRelationship__r.PrimaryContact__r.Market__c = \'SG\''
            + ' AND Classification__c = null';
            
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ChannelResponse__c> scope) {
        String firsttime = CommonConstant.CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME;
        String samebrand = CommonConstant.CHANNELRESPONSE_CLASSIFICATION_SAMEBRAND;
        DateTime dt = Datetime.newInstance(2018, 11, 9);
        for (ChannelResponse__c cr : scope) {
            if (cr.RegistrationDate__c >= dt ) {
                cr.Classification__c = firsttime;
            } else {
                cr.Classification__c = samebrand;
            }
        }

        Update scope;
      
    }
   
    global void finish(Database.BatchableContext BC) {
        
    }
} */