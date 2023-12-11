/**
* @author        Rey Austral
* @date          1.14.2019
* @description   Class use by the BrandRelationship_Path component
* @testClass     BrandRelationship_PathControllerTest
* @revision(s)
*/
public class BrandRelationship_PathController {
    
    // @author        Rey Austral
    // @date          1.14.2019
    // @description   Method that will return the active value of the status field and will be used in the path
    // @revision(s)
    @AuraEnabled 
    public static List<StatusPathWrapper> getPath(String recId) { 
        BrandRelationship__c brand = [Select Type__c, Status__c From BrandRelationship__c Where Id =: recId];
        
        Map<String, List<String>> rawMap = UtilityClass.getDependentMap(brand, 'Type__c', 'Status__c');
        
        List<StatusPathWrapper> result = new List<StatusPathWrapper>();
        if (rawMap.containskey(brand.Type__c)) {        
            Boolean inactiveOther = false;
            List<String> picklistValueList = rawMap.get(brand.Type__c);
            Integer currentRow = 1;
            for(String depValue : picklistValueList) {
                StatusPathWrapper path = new StatusPathWrapper();
                path.pathName = depvalue;                
                if (depValue == brand.Status__c) {
                    //if the last value is the selected, mark that as completed and not active
                    if (currentRow == picklistValueList.size()) {
                        path.isCompleted = true;                       
                    } else {
                         path.isActive = true;
                    }
                    //the next item should be inactive state
                    inactiveOther = true;
                } else if (inactiveOther == false) {
                    //if the path is not selected then it is already completed
                    path.isCompleted = true;                     
                } 
                currentRow++;
                result.add(path);
            }
        }
        return result;
    }
    
    public class StatusPathWrapper {
        @AuraEnabled
        public String pathName { get; set; }
        @AuraEnabled
        public Boolean isCompleted { get; set; }
        @AuraEnabled
        public Boolean isActive { get; set; }	
        
        public StatusPathWrapper() {
            isCompleted = false;
            isActive = false;
        }
    }
}