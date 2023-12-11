@IsTest
public class NameComparisonLoopActionTest {
    
    @testVisible static List<MY_Name_Ethnicity_Mapping__mdt> dummyMapping { 
    get {
        if ( dummyMapping == null )
            dummyMapping = [ SELECT DeveloperName, Ethnicity__c FROM MY_Name_Ethnicity_Mapping__mdt ]; 
        return dummyMapping;
    } set; }
    
    @IsTest
    static void nameComparisonLoopTest(){
        NameComparisonLoopAction.ActionInput[] actionInputs = getFlowActionInputs(
        dummyMapping,
        'test',
        new String[]{'Abu', 'Ali'},
        'DeveloperName',
        'Ethnicity__c'    
        );
        
        Test.startTest();
        NameComparisonLoopAction.ActionOutput[] outputs = NameComparisonLoopAction.getNameComparison(actionInputs);
        Test.stopTest();
    }
    
    static NameComparisonLoopAction.ActionInput[] getFlowActionInputs(
        SObject[] records,
        String firstName,
        String[] lastName,
        String comparisonApiName,
        String resultApiName        
    ){
        NameComparisonLoopAction.ActionInput[] actionInputs = new NameComparisonLoopAction.ActionInput[]{};
            
            for(String lname : lastName){
                NameComparisonLoopAction.ActionInput input = new NameComparisonLoopAction.ActionInput();
                input.lastName = lname;
                input.firstName = firstName;
                input.records = records;
                input.comparisonApiName = comparisonApiName;
                input.resultApiName = resultApiName;
                
                actionInputs.add(input);
            }
        return actionInputs;
    }

}