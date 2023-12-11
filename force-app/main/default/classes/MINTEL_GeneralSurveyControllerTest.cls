/*------------------------------------------------------------
Author      : Weerayut W.
Company     : Accenture
Create Date : 2023-06-30
Test Class  : -
Description : General Survey Form Test Class
--------------------------------------------------------------
History Log :
<Change Code>      <Date>        <Authors Name>       <Desciption>
                    -             Weerayut W.          Initial file
------------------------------------------------------------*/
@isTest
public with sharing class MINTEL_GeneralSurveyControllerTest {
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
        MINTEL_GeneralSurveyController.getDataSetup();
        MAP<String, String> paramSendSmsOtp = new Map<String, String>{'phoneNumber' => '0123456789', 'mid' => '11111'};

        Test.setMock(HttpCalloutMock.class, new MINTEL_HTTPCallAPISuccessMock());  
        MINTEL_GeneralSurveyController.checkDupGeneralSurvey(paramSendSmsOtp);
        MINTEL_GeneralSurveyController.sendSmsOtp(paramSendSmsOtp);
        
        MINTEL_GeneralSurveyController.saveGeneralSurvey(paramSendSmsOtp);

        Test.stopTest();
    }
}