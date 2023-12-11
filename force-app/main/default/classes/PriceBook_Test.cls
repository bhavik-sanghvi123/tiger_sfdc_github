@isTest
public class PriceBook_Test {

    static testMethod void updateActiveStatus()
    {
        List<PriceBook2> newPB = TestDataFactory.createPriceBook2(1);
        system.test.startTest();
        newPB[0].StartDate__c = date.today();
        newPB[0].EndDate__c = date.today();
        database.update(newPB);
        system.test.stopTest();
    }
}