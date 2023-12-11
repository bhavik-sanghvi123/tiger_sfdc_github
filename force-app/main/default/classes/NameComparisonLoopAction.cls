public class NameComparisonLoopAction {
    
     @InvocableMethod(label='Name Comparison Action')
    public static ActionOutput[] getNameComparison(ActionInput[] inputs) {
        ActionOutput[] outputs = new ActionOutput[]{};
        for(ActionInput input : inputs){
            ActionOutput output = new ActionOutput();
            String fname = input.firstName.toUpperCase();
            String lname = input.lastName.toUpperCase();
            String comparison = input.comparisonApiName;
            String result = input.resultApiName;
            for(SObject rec : input.records){
                String comparisonValue = (String) rec.get(comparison);
                if(fname.contains(comparisonValue) || lname.contains(comparisonValue)){
                	output.match = true;
                    output.result = (String) rec.get(result);
                }
             }
            outputs.add(output);        
        }
        
        return outputs;
      }
           
        


     /* Input parameters for the Apex action */
    public class ActionInput {

        @InvocableVariable(label='First Name' )
        public String firstName;

        @InvocableVariable(label='Last Name' required=true )
        public String lastName;
        
        @InvocableVariable(label='List of Names' required=true )
        public SObject[] records;
        
        @InvocableVariable(label='Comparison API Name' required=true )
        public String comparisonApiName;
        
        @InvocableVariable(label='Result API Name' required=true )
        public String resultApiName;
    }
    
     /* Output parameters of the Apex action */
    public class ActionOutput {
        
        @InvocableVariable(label='Match')
        public Boolean match;
        
        @InvocableVariable(label='Result')
        public String result;
        
    }
    
 }