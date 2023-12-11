@isTest
global class ExperianCalloutFormatMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Add-Components', 'true');
        String body = '{"result": {"components": {"postal_code": {"full_name": "208749","primary": "208749"},"sub_building": {"name": "#08-27"},"building": {"building_name": "Citylights","building_number": "90"},"street": {"full_name": "Jellicoe Road","name": "Jellicoe Road"},"locality": {"town": {"name": "Singapore"}}}}}';
        //res.setBody('{"components":[{"subBuilding1": "#08-27"},{"building1": "Citylights"},{"streetNumber1": "90"},{"street1": "Jellicoe Road"},{"locality1": "Singapore"},{"postalCode1": "208749"},{"country1": "REP. OF SINGAPORE"},{"countISO1": "SGP"}]}');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}