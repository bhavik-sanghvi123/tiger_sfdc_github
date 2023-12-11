@isTest
public class ContactUpdateRestAPITest { 
    static testmethod void testNoContact() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        wrapperClass wrapper = new wrapperClass();
        wrapper.Phone = '6509111111';
        
        req.requestURI = '/services/apexrest/messagebird/contactFlow';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(wrapper));
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ResponseHandler response = ContactUpdateRestAPI.post();
        Test.stopTest();
        List<Contact> conList = [SELECT Id FROM Contact WHERE Phone = '09111111'];
        System.assertEquals('FAILED', response.Status);
        System.assertEquals(0, conList.size());
    }
    
    static testmethod void testWithContact() {
        Test.enableChangeDataCapture();
        Account a = TestDataFactory.createTestHousehold(1, 'SG')[0];
        Contact adult = TestDataFactory.createContact(true, a.Id, null, Date.parse('01/01/1990'), '09111111');
        Contact child = TestDataFactory.createContact(false, a.Id, adult.Id, Date.parse('01/01/2022'), '');
        Test.getEventBus().deliver();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        wrapperClass wrapper = new wrapperClass();
        wrapper.Phone = '+6509111111';
        
        req.requestURI = '/services/apexrest/messagebird/contactFlow';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(wrapper));
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ResponseHandler response = ContactUpdateRestAPI.post();
        Test.stopTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Phone = '09111111'];
        System.assertEquals('SUCCESS', response.Status);
        System.assertEquals(1, conList.size());
    }
    
    public class wrapperClass{ 
        public String Phone;
    }
}