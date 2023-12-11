@isTest
private class ExperianCalloutTest {
     @isTest static void testSearchCallout() {
        String postalCode = '208749';
        String unitNumber;
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ExperianCalloutSearchMock());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse res = ExperianCallout.getInfoFromExternalService(postalCode, unitNumber);
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String body = '{"result": {"suggestions": [{"text": "90 Jellicoe Road, #08-27 Citylights, Singapore 208749","format": "https://api.experianaperture.io/address/format/v1/aWQ9OTAgSmVsbGljb2UgUm9hZCwgIzA4LTI3IENpdHlsaWdodHMsIFNpbmdhcG9yZSAyMDg3NDksIFJFUC4gT0YgU0lOR0FQT1JFfmFsdF9rZXk9fmRhdGFzZXQ9U0dQX1BBRn5mb3JtYXRfa2V5PVNHUCQkN2JmYmQzZDktMWFiNi00NmEyLThhMDgtOWQ1MDA0NzE2ODU3JDkwJCR-UUw9Nn5nZW89VHJ1ZQ"}]}}';
        String expectedValue = body;
        //String expectedValue = '{"results":[{"suggestion": "90 Jellicoe Road, #09-27 Citylights, Singapore 208749","format": "https://api.edq.com/capture/address/v2/format?country=SGP&id=b0a3b989-fc97-41a3-9913-c16b2e25c666_U40_24_0_0_0%3D90%24QL6%24GEO0"}]}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }
    
    @isTest static void testFormatCallout() {
        String format = 'https://randolURL.com';
        String token = 'q1defr-1234-derfdsd';
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ExperianCalloutFormatMock());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse res = ExperianCallout.getAddressDetails(format, token);
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String body = '{ "result": { "components": { "postal_code": { "full_name": "208749", "primary": "208749" }, "sub_building": { "name": "#08-27", }, "building": { "building_name": "Citylights", "building_number": "90" }, "street": { "full_name": "Jellicoe Road", "name": "Jellicoe Road" }, "locality": { "town": { "name": "Singapore" } } } } }';
        String expectedValue = body;
        //String expectedValue = '{"components":[{"subBuilding1": "#08-27"},{"building1": "Citylights"},{"streetNumber1": "90"},{"street1": "Jellicoe Road"},{"locality1": "Singapore"},{"postalCode1": "208749"},{"country1": "REP. OF SINGAPORE"},{"countISO1": "SGP"}]}';
        //System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }
}