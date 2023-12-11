@isTest
public class ReusableLookupComponentControllerTest {
    @testsetup
    static void setupData() {
        Id phRoleId = [SELECT Id FROM UserRole WHERE Name = 'ANI - Philippines'].Id;
        User testUser = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        testUser.UserRoleId = phRoleId;
        insert testUser;

        System.runAs(testUser) {
            //Create another user
            User testUser2 = TestDataFactory.createUser('System Administrator', 'tstUser2' , 'PH');
            testUser2.UserRoleId = phRoleId;
            testUser2.IsActive = true;
            insert testUser2;
            
            //Query needed skills
            List<Skill> skillList = [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel = 'Language - English'];
            
            //Create Service Resource record
            ServiceResource sr = new ServiceResource();
            sr.RelatedRecordId = testUser2.Id;
            sr.Name = 'tstUser2 tstUser2';
            sr.IsActive = true;
            insert sr;
            
            //Create Service Resource Skill
            ServiceResourceSkill srs = new ServiceResourceSkill();
            srs.ServiceResourceId = sr.Id;
            srs.SkillId = skillList[0].Id;
            srs.EffectiveStartDate = Date.today();
            srs.EffectiveEndDate = Date.today().addYears(10);
            insert srs;
        }
    }
    
	private static testMethod void fetchLookupValuesCaseTest() {
        List<User> returnList = new List<User>();
        String objName = 'Case';
        String userMarket = [SELECT Id, Market__c FROM User WHERE Alias = 'tstSysAd'].Market__c;
        String contactLanguage = 'English';
        User sysAd = [SELECT Id FROM User WHERE Alias = 'tstSysAd'];

        System.Test.startTest();
            System.runAs(sysAd) {
                returnList = ReusableLookupComponentController.fetchLookupValues(objName, userMarket, null, contactLanguage);   
            }
        System.Test.stopTest();

        System.assert(returnList.size() > 0, 'List owner should be returned.');
    }
    
    private static testMethod void fetchLookupValuesSkillTest() {
        List<Skill> returnList = new List<Skill>();
        String objName = 'Skill';
        User sysAd = [SELECT Id FROM User WHERE Alias = 'tstSysAd'];

        System.Test.startTest();
            System.runAs(sysAd) {
                returnList = ReusableLookupComponentController.fetchLookupValues(objName, null, null, null);   
            }
        System.Test.stopTest();

        System.assert(returnList.size() > 0, 'List owner should be returned.');
    }
}