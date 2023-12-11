@isTest
public class AddMultipleSkillsControllerTest {
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
    
    private static testMethod void retrieveServiceResourceDetailsTest() {
        ServiceResource srRec = new ServiceResource();
        Id srId = [SELECT Id, Name FROM ServiceResource LIMIT 1].Id;
        User sysAd = [SELECT Id FROM User WHERE Alias = 'tstSysAd'];
        
        System.Test.startTest();
        System.runAs(sysAd) {
            srRec = AddMultipleSkillsController.retrieveServiceResourceDetails(srId);   
        }
        System.Test.stopTest();
        
        System.assertNotEquals(srRec.Name, null, 'Service Resource Name must be returned.');
    }
    
    private static testMethod void saveServiceResourceSkillsTest() {
        List<Skill> skillList = [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel = 'Language - Hindi'];
        Id srId = [SELECT Id FROM ServiceResource LIMIT 1].Id;
        List<ServiceResourceSkill> srSkillList = new List<ServiceResourceSkill>();
        
        ServiceResourceSkill srSkillRec = new ServiceResourceSkill();
        srSkillRec.SkillId = skillList[0].Id;
        srSkillRec.ServiceResourceId = srId;
        srSkillRec.EffectiveStartDate = Date.Today();
        srSkillRec.EffectiveEndDate = Date.Today().addDays(30);
        srSkillList.add(srSkillRec);
        
        User sysAd = [SELECT Id FROM User WHERE Alias = 'tstSysAd'];
        
        System.Test.startTest();
        System.runAs(sysAd) {
            AddMultipleSkillsController.saveServiceResourceSkills(srSkillList);   
        }
        System.Test.stopTest();
        
       	List<ServiceResourceSkill> srSkilllListAfterInsert = [Select Id, SkillId FROM ServiceResourceSkill WHERE SkillId = :skillList[0].Id];
        System.assertEquals(skillList.size(), 1, 'Service Resource Skill should be created.');
    }
}