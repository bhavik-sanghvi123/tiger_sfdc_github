/*
Class Name : DiceHTTPCalloutMockSuccess
Description : Success Http Callout Mock for Dice .
Change Log:
Author              Date                Change
==============================================================
Mario      	        24-Oct-2022        	Created the class
*/

@isTest
global class DiceHTTPCalloutMockSuccess implements HttpCalloutMock {
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"reply":"I am done creating your card! View by going to the link: https://semaphore.dice205.asia/view-card/8QEWf9Our9. Customer agent is saved...","status":"success","process":"salesforce","sms":null,"member_id":"922219621112135654","created_at":"Oct 24 2022 12:20:19"}');
        response.setStatusCode(200);
        response.setStatus('Failed');
        return response; 
    }
}