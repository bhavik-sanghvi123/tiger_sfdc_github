@isTest
global class ExperianCalloutSearchMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = '{"result": {"suggestions": [{"text": "90 Jellicoe Road, #08-27 Citylights, Singapore 208749","format": "https://api.experianaperture.io/address/format/v1/aWQ9OTAgSmVsbGljb2UgUm9hZCwgIzA4LTI3IENpdHlsaWdodHMsIFNpbmdhcG9yZSAyMDg3NDksIFJFUC4gT0YgU0lOR0FQT1JFfmFsdF9rZXk9fmRhdGFzZXQ9U0dQX1BBRn5mb3JtYXRfa2V5PVNHUCQkN2JmYmQzZDktMWFiNi00NmEyLThhMDgtOWQ1MDA0NzE2ODU3JDkwJCR-UUw9Nn5nZW89VHJ1ZQ"}]}}';
        //res.setBody('{"results":[{"suggestion": "90 Jellicoe Road, #09-27 Citylights, Singapore 208749","format": "https://api.edq.com/capture/address/v2/format?country=SGP&id=b0a3b989-fc97-41a3-9913-c16b2e25c666_U40_24_0_0_0%3D90%24QL6%24GEO0"}]}');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }

}