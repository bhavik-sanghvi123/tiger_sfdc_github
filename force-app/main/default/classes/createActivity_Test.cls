@isTest 
public class createActivity_Test{

    static testMethod void createActivityTest() {
        //create a case
        //Create Household record
        List<Account> lAccount = TestDataFactory.createTestHousehold(1);
        //Create Non-Primary Child Contact Record
        List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
        //create case
        Case newcase = TestDataFactory.createCaseCall(lAccount.get(0).Id,lContact.get(0).Id);
    
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'Case requires attention';
        email.fromname = 'FirstName LastName';
        email.plaintextbody = 'ref: ' + newcase.id + '';
        env.fromAddress = 'someaddress@email.com';
        
        system.test.startTest();
        // call the email service class and test it with the data in the testMethod
        createActivity emailProcess = new createActivity();
        emailProcess.handleInboundEmail(email, env);
        system.test.stopTest();
        
        // query for the contact the email service created
        Task t = [select id, subject FROM Task
        WHERE Status = 'Completed'];

        System.assertEquals(t.subject,'Case requires attention');
        
    }

      
}