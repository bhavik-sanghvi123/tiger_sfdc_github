/*------------------------------------------------------------
Author:      Viana Flor Mirandilla
Description: API Callout to Experian Third-Party

History
07/31/2019   vmirandilla   Created
04/13/2021   malviz        Updated API Call from Global Intuitive to Experian Address Validation 
-------------------------------------------------------------------------------------------*/

public class ExperianCallout {
    public static HttpResponse getInfoFromExternalService(String postalCode, String unitNumber) {
    	String searchEndpoint = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :CommonConstant.NAMED_CREDENTIAL_EXPERIAN_SEARCH].Endpoint;
        String token = [SELECT MasterLabel, DeveloperName, Token__c FROM AuthenticationToken__mdt WHERE DeveloperName = 'Experian_Token'].Token__c;
        //String searchEndpointURL;
        String searchString;
        String body;
        HttpResponse formatResponse;
        
        /*if(unitNumber != null && unitNumber != '') {
        	searchEndpointURL = searchEndpoint + postalCode + CommonConstant.ESCAPE_NUMBER_SIGN + unitNumber + CommonConstant.COUNTRY_CODE_WITHOUT_TAKE;
        } else {
            searchEndpointURL = searchEndpoint + postalCode + CommonConstant.COUNTRY_CODE_WITH_TAKE;
        }*/

        if(unitNumber != null && unitNumber != '') {
        	searchString = postalCode + ',#' + unitNumber;
        } else {
            searchString = postalCode;
        }
        
        Http httpSearch = new Http();
        HttpRequest requestSearch = new HttpRequest();
        requestSearch.setEndpoint(searchEndpoint);
        requestSearch.setHeader('Auth-Token', token);
        requestSearch.setHeader('Content-Type', 'application/json');
        requestSearch.setHeader('Accept', 'application/json');
        requestSearch.setMethod('POST');

        // valid test: 682490, #12-263
        body = '{"country_iso": "SGP","components": {"unspecified": ["' + searchString + '"]},"location": "","dataset": ""}';
        requestSearch.setBody(body);
        HttpResponse searchResponse = httpSearch.send(requestSearch);

        // If the request is successful, parse the JSON searchResponse.
        if (searchResponse.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            AddressWrapper searchResponseWrap = (AddressWrapper)JSON.deserialize(searchResponse.getBody(), AddressWrapper.class);
            system.debug('================ response wrap =======' + searchResponseWrap);
            //List<AddressWrapper.cls_Results> searchResultList = searchResponseWrap.result;
            List<AddressWrapper.cls_Suggestions> resultSuggestionsList = new List<AddressWrapper.cls_Suggestions>();
            if(searchResponseWrap.result != null){
                AddressWrapper.Result searchResultList = searchResponseWrap.result;
                if(searchResultList.suggestions != null && !searchResultList.suggestions.isEmpty())
                resultSuggestionsList = searchResultList.suggestions;
            }
            
            if(!resultSuggestionsList.isEmpty()) {
                //experian returns multiple results, take first match - normally the exact match
                String formatEndpointURL = resultSuggestionsList[0].format;
                system.debug('================ first result =======' + formatEndpointURL);
                formatResponse = getAddressDetails(formatEndpointURL, token);
                
                /*if(unitNumber != null && searchResultList.size() > 1) {
                    formatResponse = null;
                } else {
                    formatResponse = getAddressDetails(formatEndpointURL, token);
				}*/
                
            }
        }
        return formatResponse;
    }
    
    public static HttpResponse getAddressDetails(String formatEndpointURL, String token) {
        Http httpFormat = new Http();
        HttpRequest requestFormat = new HttpRequest();
        requestFormat.setEndpoint(formatEndpointURL);
        requestFormat.setHeader('Auth-Token', token);
        requestFormat.setHeader('Accept', 'application/json');
        requestFormat.setHeader('Add-Components', 'true');
        requestFormat.setMethod('GET');
        HttpResponse formatResponse = httpFormat.send(requestFormat);

        if (formatResponse.getStatusCode() == 200) {
        	return formatResponse;
        } else {
            return null;
        }
    }
}