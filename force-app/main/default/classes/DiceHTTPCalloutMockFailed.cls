/*
Class Name : DiceHTTPCalloutMockFailed
Description : Failed Http Callout Mock for Dice .
Change Log:
Author              Date                Change
==============================================================
Mario      	        24-Oct-2022        	Created the class
*/

@isTest
global class DiceHTTPCalloutMockFailed implements HttpCalloutMock {
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"error":"Internal Server Error"}');
        response.setStatusCode(500);
        response.setStatus('Failed');
        return response; 
    }
}