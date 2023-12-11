/*------------------------------------------------------------------------------------------------------
Class Name      : ContactUpdateRestAPI
Author          : Deloitte PDC
Created Date    : 10/26/2022
Functionality   : Test class for ContactUpdateRestAPI
Change History : 
SL No.  |   Date    |   ModifiedBy      |   SR No.      |   Reason 
------------------------------------------------------------------------------------------------------*/ 

@RestResource(urlMapping='/messagebird/contactFlow')

global class ContactUpdateRestAPI{
    
    //====================================================================================
    // *** REST POST *** :  method for Account Callback Api
    //====================================================================================
    /*====================================================================================
    Method Name: post
    Author Name: Rhoda Solita
    Description: This method will update the contact record of the given phone number
    Parameters: 
    ======================================================================================*/
    
    @HttpPost
    global static ResponseHandler post(){
        //wrapperClass jsonBody;
        Map<String, Object> jsonBody;
        RestRequest request = RestContext.request;
        ResponseHandler response = new ResponseHandler();
        system.debug('### requestbody = ' + request.requestBody.toString());

        //jsonBody = (wrapperClass) JSON.deserialize(request.requestBody.toString(),wrapperClass.class); 
        jsonBody =  (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
        system.debug('### jsonBody = ' + jsonBody);
        
        if(jsonBody.get('Phone') == null) return response;

        /******************************************************/
        /**** FORMAT PHONE NUMBER WITHOUT SG COUNTRY CODE *****/
        /******************************************************/
        //String Phone = jsonBody.Phone;
        
        String Phone = String.valueOf(jsonBody.get('Phone'));
        
        Phone = (Phone.startsWith('+65')) ? Phone.removeStart('+65') : Phone; // Remove the '+65' in front
        Phone = (Phone.startsWith('65')) ? Phone.removeStart('65') : Phone; // Remove the '65' in front
        
        // Remove '-' if it has any
        if(Phone.contains('-'))
            Phone = Phone.remove('-'); 

        //jsonBody.Phone = Phone;
        jsonBody.put('Phone', Phone);
        
        system.debug('### jsonBody.Phone = ' + jsonBody.get('Phone'));
        /*** END FORMATTING ***/
        
        List<Contact> contactLst = new List<Contact>();
        contactLst = [SELECT Id, Name, Phone, WhatsappOptOut__c
                                         FROM Contact 
                                        WHERE Phone =: Phone
                                          AND Market__c = 'SG'];
                                          
        system.debug('### contactLst = ' + contactLst );
        
        if(contactLst.size() < 1) {
            response.Status = 'FAILED';
            response.Message = 'No Contact found!'; 
        } else {
            try{
                System.debug('### DML ops');
                
                contactLst[0].WhatsappOptOut__c = true;
                update contactLst;
                
                response.Status = 'SUCCESS';
                response.Message = 'Contact ' + contactLst[0].Name + ' has been updated';
                response.Id = contactLst[0].Id;
                
            } catch(DmlException e) {
                response.Status = CommonConstant.API_STATUS_FAILURE;
                response.Message = e.getMessage(); 
            }
        }
        
        system.debug('### response = ' + response);
        return response;
    }
    
    /*====================================================================================
    Method Name: wrapperClass
    Author Name: RSolita
    Description: This is the wrapper utilised for Post Request by the same class
    Parameters: 
    ======================================================================================*
    public class wrapperClass{ 
        public String Phone;
    }
    */
    
}