@isTest
public with sharing class MINTEL_SurveyFormControllerTest {
    public class MINTEL_HTTPCallAPISuccessMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            
            response.setBody('{"status": "success","message": "SMS has been sent.","data": {"ref": "5IB3e"}}');
            response.setStatusCode(200);
            return response;  
        }
    }
    @testSetup static void Data() {

    }
    static testmethod void testData() {
        Test.startTest();
        MINTEL_SurveyFormController.getDataSetup();
        MAP<String, String> paramSendSmsOtp = new Map<String, String>{'phoneNumber' => '0123456789', 'mid' => '11111'};

        Test.setMock(HttpCalloutMock.class, new MINTEL_HTTPCallAPISuccessMock());  
        MINTEL_SurveyFormController.sendSmsOtp(paramSendSmsOtp);
        
        MINTEL_SurveyFormController.saveSurveyForm(paramSendSmsOtp);

        Test.stopTest();
    }
}