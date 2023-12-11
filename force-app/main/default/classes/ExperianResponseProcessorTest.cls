@isTest
public class ExperianResponseProcessorTest {
    public static testMethod  void processReponseTest() {
        String format = 'https://randolURL.com';
        String token = 'q1defr-1234-derfdsd';
        
        System.Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ExperianCalloutFormatMock());
        	HttpResponse res = ExperianCallout.getAddressDetails(format, token);
        
        	ExperianResponseProcessor.processReponse(res);
        
            // Verify response received contains fake values
            String contentType = res.getHeader('Content-Type');
            System.assert(contentType == 'application/json');
            String actualValue = res.getBody();
            String body = '{"result": {"components": {"postal_code": {"full_name": "208749","primary": "208749"},"sub_building": {"name": "#08-27"},"building": {"building_name": "Citylights","building_number": "90"},"street": {"full_name": "Jellicoe Road","name": "Jellicoe Road"},"locality": {"town": {"name": "Singapore"}}}}}';
            String expectedValue = body;
            //String expectedValue = '{"components":[{"subBuilding1": "#08-27"},{"building1": "Citylights"},{"streetNumber1": "90"},{"street1": "Jellicoe Road"},{"locality1": "Singapore"},{"postalCode1": "208749"},{"country1": "REP. OF SINGAPORE"},{"countISO1": "SGP"}]}';
            System.assertEquals(actualValue, expectedValue);
            System.assertEquals(200, res.getStatusCode());
        System.Test.stopTest();
   	} 
}