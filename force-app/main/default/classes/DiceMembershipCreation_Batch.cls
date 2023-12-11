/*------------------------------------------------------------
Author      : Mario Christ
Description : Batch class to create membership by calling Dice API

History
17-Oct-2022   Mario Christ   Created class
-------------------------------------------------------------------------------------------*/
public class DiceMembershipCreation_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts  {

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('test');

        //String diceDate = Dice_Custom_Setting__c.getInstance().Value__c;
        //DateTime diceDateTime = UtilityClass.convertStringToDateTime(diceDate);

        String queryStr = 'SELECT Id, CreatedDate, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Phone, Contact__r.Email, BrandRelationship__r.KeyBrand__c, LastModifiedDate FROM ChannelResponse__c WHERE '+
        'BrandRelationship__c != null AND Contact__r.Active__c = true AND Contact__r.Market__c = \'PH\' AND Contact__r.ChildrenUnderMilkCodeRestriction__c = 0 AND '+
        'Contact__r.Type__c= \'Adult\' AND Contact__r.SMSOptOut__c = false AND Contact__r.DoNotCall = false AND Contact__r.Phone LIKE \'09%\' AND '+
        'Discount_Card__c != \'no\' AND '+//TKT-011545 - only process Dice Membership of CRs where Discount_Card__c = 'yes' or blank
        'BrandRelationship__r.Active__c = true AND BrandRelationship__r.FirstTransactionDate__c = null AND DiceEcardStatus__c = null AND CreatedDate >= Last_N_Days:7 AND '+ //TKT-011545 - Changed from CreatedDate >= :diceDateTime
        '((BrandRelationship__r.KeyBrand__c =\'Ensure\' AND (Channel__r.Name LIKE \'%Facebook%\' OR Channel__r.Name LIKE \'%Youtube%\' OR Channel__r.Name = \'Abbott Nutrition - Ensure Website\')) OR '+
        '(BrandRelationship__r.KeyBrand__c =\'Glucerna\' AND (Channel__r.Name LIKE \'%Facebook%\' OR Channel__r.Name LIKE \'%Youtube%\')) OR '+
        '(BrandRelationship__r.KeyBrand__c =\'Pediasure\' AND (Channel__r.Name LIKE \'%Facebook%\' OR Channel__r.Name LIKE \'%Youtube%\' OR Channel__r.Name = \'Abbott Nutrition - PediaSure Website\')) OR '+
        '(BrandRelationship__r.KeyBrand__c =\'Similac\' AND (Channel__r.Name LIKE \'%Facebook%\' OR Channel__r.Name LIKE \'%Youtube%\' OR Channel__r.Name = \'Abbott Nutrition - Similac GainSchool Website\')))';
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<ChannelResponse__c> channelResponseList){
        String successString = 'success';
        String failedString = 'failed';
        List<Membership__c> newMembershipList = new List<Membership__c>();
        List<ChannelResponse__c> updateCRList = new List<ChannelResponse__c>();        

        for(ChannelResponse__c crRec :channelResponseList ){
            DiceCallout.DiceCalloutResponseWrapper diceResponse = new DiceCallout.DiceCalloutResponseWrapper();
            diceResponse = DiceCallout.diceCreateCard(crRec.Contact__r.FirstName, crRec.Contact__r.LastName, crRec.Contact__r.Phone, crRec.Contact__r.Email, crRec.BrandRelationship__r.KeyBrand__c);
            
            if(diceResponse != null ){
                if(diceResponse.status == successString && diceResponse.member_id != null){
                    Date memCreatedDate = UtilityClass.convertDiceDateFormat(diceResponse.created_at);
                    String membershipId = UtilityClass.convertDiceMembershipIdFormat(diceResponse.member_id);

                    Membership__c newMember = new Membership__c();
                    newMember.MembershipId__c = membershipId;
                    newMember.Contact__c = crRec.Contact__c;
                    newMember.Integration_Src__c = 'PH_DICE_ECard_API';
                    newMember.MembershipStartDate__c = memCreatedDate;
                    newMember.Status__c = 'New';
                    newMembershipList.add(newMember);
    
                    crRec.DiceEcardStatus__c = 'Created';
                    updateCRList.add(crRec);
                } else if (diceResponse.status == failedString && diceResponse.reply.contains('Brand')) {
                    crRec.DiceEcardStatus__c = 'Failed-BrandError';
                    updateCRList.add(crRec);
                } else if (diceResponse.status == failedString && diceResponse.reply.contains('exceeded')) {
                    crRec.DiceEcardStatus__c = 'Failed-LimitExceeded';
                    updateCRList.add(crRec);
                } else if (diceResponse.status == failedString && diceResponse.reply.contains('no more available')) {
                    crRec.DiceEcardStatus__c = 'Failed-ECardsNotAvailable';
                    updateCRList.add(crRec);
                } else {
                    crRec.DiceEcardStatus__c = 'Failed';
                    updateCRList.add(crRec);
                }   
            } else {
                crRec.DiceEcardStatus__c = 'Failed';
                updateCRList.add(crRec);
            }   
        }

        if(newMembershipList.size() > 0) {

            Database.insert(newMembershipList, false);
        }
        
        if(updateCRList.size() > 0) {
            Database.update(updateCRList, false);
        }
        
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()];
    }
}