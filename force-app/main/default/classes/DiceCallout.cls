/*------------------------------------------------------------
Author      : Mario Christ
Description : API Callout to Dice Third-Party

History
13-Oct-2022   Mario Christ   Created class
-------------------------------------------------------------------------------------------*/
public class DiceCallout {
    public static DiceCalloutResponseWrapper diceCreateCard(String firstName, String lastName, String contactNumber, String emailId, String brandName) {
        
        //generate request body
        DiceWrapper wrapper = new DiceWrapper();
        if(firstName == null) {
            firstName = 'BLANK';
        }

        if(brandName == 'Pediasure') {
            brandName = 'PediaSure Plus';
        }else if (brandName == 'Similac') {
            brandName = 'Similac GainSchool';
        }

        wrapper.firstname = firstName;
        wrapper.lastname = lastName;
        wrapper.contact = contactNumber;
        wrapper.email = emailId;
        wrapper.brand = brandName;
        String requestBody = JSON.serialize(wrapper);

        HttpResponse response = new HttpResponse();
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:'+ CommonConstant.DICE_CREATE_CARD_CREDENTIAL+'/api/salesforce/create-card');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(requestBody);
            request.setTimeout(120000);
            response = http.send(request);
        } catch(exception e) {
            System.debug(e);
        }
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            DiceCalloutResponseWrapper outputWrapper = new DiceCalloutResponseWrapper();
            outputWrapper.reply = String.valueOf(responseMap.get('reply'));
            outputWrapper.status = String.valueOf(responseMap.get('status'));
            outputWrapper.sms = String.valueOf(responseMap.get('sms'));
            outputWrapper.process = String.valueOf(responseMap.get('process'));

            if(responseMap.get('member_id') != null) {
                outputWrapper.member_id = String.valueOf(responseMap.get('member_id'));
            }

            if(responseMap.get('created_at') != null) {
                outputWrapper.created_at = String.valueOf(responseMap.get('created_at'));
            }

        	return outputWrapper;
        } else {
            return null;
        }
    }

    public class DiceWrapper {
        public String firstname;
        public String lastname;
        public String contact;
        public String email;
        public String brand;
    }

    public class DiceCalloutResponseWrapper {
        public String reply;
        public String status;
        public String process;
        public String sms;
        public String member_id;
        public String created_at;
    }

}