@isTest
public class AbbottWorkplaceTriggerHandlerTest {
    
    static testmethod void testOnInsert(){
        AbbottPartner__c ap = new AbbottPartner__c();
        ap.RecordTypeId = Schema.SObjectType.AbbottPartner__c.getRecordTypeInfosByDeveloperName().get('Dietician').getRecordTypeId();
        ap.PartnerName__c = 'Test Abbott Partner';
        ap.Active__c = true;
        insert ap;
        
        List<AbbottWorkplace__c> awpNewList = new List<AbbottWorkplace__c>();
        AbbottWorkplace__c awp1 = new AbbottWorkplace__c();
        awp1.AbbottPartner__c = ap.Id;
        awp1.InstitutionEmail__c = 'test@test.com';
        awpNewList.add(awp1);        
        AbbottWorkplace__c awp2 = new AbbottWorkplace__c();
        awp2.AbbottPartner__c = ap.Id;
        awp2.InstitutionEmail__c = 'test@sample.com';
        awpNewList.add(awp2);
        insert awpNewList;
        
        Test.startTest();
        AbbottWorkplace__c awp3 = new AbbottWorkplace__c();
        awp3.AbbottPartner__c = ap.Id;
        awp3.InstitutionEmail__c = 'test@test.com';
        awp3.EmailOptOut__c = true;
        awp3.EmailOptOutDate__c = Date.today();
        insert awp3;
        Test.stopTest();
        
        List<AbbottWorkplace__c> awpList = new List<AbbottWorkplace__c>([SELECT EmailOptOut__c, EmailOptOutDate__c FROM AbbottWorkplace__c]);
        System.assertEquals(true, awpList[0].EmailOptOut__c);
        System.assertEquals(false, awpList[1].EmailOptOut__c);
        System.assertEquals(true, awpList[2].EmailOptOut__c);
        System.assertEquals(awpList[0].EmailOptOutDate__c, awpList[2].EmailOptOutDate__c);        
        System.assertNotEquals(awpList[1].EmailOptOutDate__c, awpList[2].EmailOptOutDate__c);
       
    }
    static testmethod void testOnUpdate(){
        AbbottPartner__c ap = new AbbottPartner__c();
        ap.RecordTypeId = Schema.SObjectType.AbbottPartner__c.getRecordTypeInfosByDeveloperName().get('Dietician').getRecordTypeId();
        ap.PartnerName__c = 'Test Abbott Partner';
        ap.Active__c = true;
        insert ap;
        
        List<AbbottWorkplace__c> awpNewList = new List<AbbottWorkplace__c>();
        AbbottWorkplace__c awp1 = new AbbottWorkplace__c();
        awp1.AbbottPartner__c = ap.Id;
        awp1.InstitutionEmail__c = 'test@test.com';
        awpNewList.add(awp1);
        AbbottWorkplace__c awp2 = new AbbottWorkplace__c();
        awp2.AbbottPartner__c = ap.Id;
        awp2.InstitutionEmail__c = 'test@sample.com';
        awpNewList.add(awp2);
        AbbottWorkplace__c awp3 = new AbbottWorkplace__c();
        awp3.AbbottPartner__c = ap.Id;
        awp3.InstitutionEmail__c = 'test@test.com';
        awpNewList.add(awp3);
        insert awpNewList;
        
        Test.startTest();
        awp3.EmailOptOut__c = true;
        awp3.EmailOptOutDate__c = Date.today();
        update awp3;
        Test.stopTest();
        
        List<AbbottWorkplace__c> awpList = new List<AbbottWorkplace__c>([SELECT EmailOptOut__c, EmailOptOutDate__c FROM AbbottWorkplace__c]);
        System.assertEquals(true, awpList[0].EmailOptOut__c);
        System.assertEquals(false, awpList[1].EmailOptOut__c);
        System.assertEquals(true, awpList[2].EmailOptOut__c);
        System.assertEquals(awpList[0].EmailOptOutDate__c, awpList[2].EmailOptOutDate__c);        
        System.assertNotEquals(awpList[1].EmailOptOutDate__c, awpList[2].EmailOptOutDate__c);       
    }

}