public class AddMultipleSkillsController {

    /**
    * Fetch current user's role to restrict page access
    **/
    @AuraEnabled
    public static ServiceResource retrieveServiceResourceDetails(Id srId) {
       ServiceResource srRecord = [SELECT Id, Name FROM ServiceResource WHERE Id =: srId];
      
       return srRecord;
    }
    
    @AuraEnabled
    public static void saveServiceResourceSkills(List<ServiceResourceSkill> skillList) {
        try {
            system.debug(skillList);
            insert skillList;
        } catch(DmlException dex) {
            throw new AuraHandledException(dex.getDmlMessage(0));
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }   
    	
}