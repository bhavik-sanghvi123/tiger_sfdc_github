/*------------------------------------------------------------
Author      : Mario Christ
Description : Failed Http Callout Mock for Dice .

History
22-Nov-2022   Mario Christ   Created class
-------------------------------------------------------------------------------------------*/

@isTest
global class DiceHTTPCalloutMockFailed3 implements HttpCalloutMock {
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"reply":"Card Creation Failed. Contact number has exceeded the limit (2) on {brand} cards","status":"failed","process":"salesforce","sms":"Failed"}');
        response.setStatusCode(200);
        response.setStatus('Success');
        return response; 
    }
}