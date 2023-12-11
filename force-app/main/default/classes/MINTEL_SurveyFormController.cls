global class MINTEL_SurveyFormController {
	@RemoteAction
    global static Map<String, Object> getDataSetup() {
        Schema.DescribeFieldResult genderDesc = SurveyCampaign__c.Gender__c.getDescribe();
        List<Schema.PicklistEntry> genderPicklist = genderDesc.getPicklistValues();
        List<Map<String, String>> genderList = new List<Map<String, String>>();
        for (Schema.PicklistEntry pickListVal : genderPicklist) {
            Map<String, String> listValues= new Map<String, String>();
            listValues.put('value', pickListVal.getValue());
            listValues.put('label', pickListVal.getValue());
            genderList.add(listValues);
        }
        
        Schema.DescribeFieldResult preferredProductDesc = SurveyCampaign__c.Preferred_Product__c.getDescribe();
        List<Schema.PicklistEntry> preferredProductPicklist = preferredProductDesc.getPicklistValues();
        List<Map<String, String>> preferredProductList = new List<Map<String, String>>();
        for (Schema.PicklistEntry pickListVal : preferredProductPicklist) {
            if (pickListVal.getValue() != 'No') {
                Map<String, String> listValues= new Map<String, String>();
                listValues.put('value', pickListVal.getValue());
                listValues.put('label', pickListVal.getLabel());
                listValues.put('pathImage', 'preferredProduct/'+pickListVal.getValue().replaceAll(' ', '_')+'.png');
                preferredProductList.add(listValues);
            }
        }
        
        Map<String, Object> dataSetup = new Map<String, Object>();
        dataSetup.put('ddlGender', genderList);
        dataSetup.put('ddlPrefferedProduct', preferredProductList);
        // select id from RecordType where name = 'Gain Friends';
        SurveyCondition__c[] detailCondition = [SELECT Detail_Condition__c FROM SurveyCondition__c WHERE Survey_Type__c = 'Gain Friends' LIMIT 1];
        dataSetup.put('detailConditionSubmit', (detailCondition.size() > 0 ? detailCondition[0].Detail_Condition__c : ''));
        // dataSetup.put('AbbottBackgroundImgUrl', URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('SurveyFormBackgroundImgUrl').getUrl());
        // dataSetup.put('AbbottSuccessImgUtl', URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('SurveyFormSuccessImgUtl').getUrl());
        return dataSetup;
    }
    @RemoteAction
    global static Map<String, Object> sendSmsOtp(Map<String, String> paramSendSms) {
        String phoneNumber = paramSendSms.get('phoneNumber');
        String mid = paramSendSms.get('mid');
        SurveyCampaign__c[] chkDupPhone = [SELECT Id FROM SurveyCampaign__c WHERE PhoneNo__c = :phoneNumber LIMIT 1];
        SurveyCampaign__c[] chkDupMid = [SELECT Id FROM SurveyCampaign__c WHERE MID__c = :mid LIMIT 1];
        String userSendOtp = Label.userSendOtp;
        String passSendOtp = Label.passSendOtp;
        Map<String, Object> ret = new Map<String, Object>();
        if (chkDupPhone.size() == 0 && chkDupMid.size() == 0 ) {
            Integer randomOtp = Integer.valueof((Math.random() * 9999));
            System.debug('randomOtp is' + String.valueOf(randomOtp).leftPad(4, '0'));
            String otpSend = String.valueOf(randomOtp).leftPad(4, '0');

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('content-type', 'application/json');
            // String messageOtp = 'Abbott OTP: ' + otpSend + ' (SMS OTP นี้มีอายุใช้งาน 1 นาทีก่อนที่จะหมดอายุ)';
            String messageOtp = 'Use ' + otpSend + ' for authentication on Abbott Campaign';
            // req.setHeader('Authorization', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImJsdWVzY29wZUBjb25uZWN0eC5jb20iLCJ1c2VySWQiOiJFN3NpdlZoYUQxVVhEME9FNVpJUyIsInN1YiI6IkU3c2l2VmhhRDFVWEQwT0U1WklTIiwib3JnYW5pemVJZCI6InJCUGh4UlN6ZnhucEdaT1RVNHlhIiwic3RheUxvZ2luIjp0cnVlLCJjdXN0b21Ub2tlbiI6IlUyRnNkR1ZrWDErZTVYbWhacXFDK1ppeVdVbWMwdTB4akRVT3dkMnNqQzJZVC81cTRJNE1IeFJjM0VuTXVNckIyOGpvYmRrNUpYcmgxdThDVTdpNm8vdjNJZFlia29aaWowZWQ2MUJ3SkxaamhiNzZNT0h3Ylk3VlAwbnVhaEhUV0ZjRFk3Y20wd2ttYSsvSnlPd2NqSWQ1Wkg2WGg0ZHp5QldKckNRZ2Y1Y1lrZS9wRlVHTHQxWU5KRE5BN0tjTDg3YjVpbFk1R1JmQWo3aFhYTUx1M0w1QnNtNCtpTUZOcjBEcC9zQ3ErampTY3I3ZUdLVnc2VGNJcXFva0hTNHVndnNMK2dmdVgzOU4zMG9NTWxpUzREZmI0dWM4Ky9PV0QzVVd4UGtTSkJmaEo5MWF5WEpMcVc3NmRvM01zYkp3OU5tY1NMeS9lUHBTMWJIYUJZZHI1dTRmN0xyRDZ4WlVMZWhwOFFNa0huNTh0UkExQlNld0FlL3J2anUrazFTZEpMaVQ0Sks3N3hnOGtOM28yUFVjcW9wS1lteSt4bkVuSzFEZjZLN1hCK3FEdi9jNlR6anRhc0Uxa1dEQ2Zmd0sxelZ4aWRweXlFV1pFdXdFNEZkQXNSVUY1NEJrREdlR3dOR1oxWEdTV3BzSnV0TUZlc1NYcWk2dFNmVkJ6YUsrMmdXRnlBNmd1MVMzaUNHYjA1d1l4QVhWSU5YUHNnaENBZ3BXT20vZmZMczJSY2VCRTFBU3ZLUjVCVmZRanBvZFdrT0I2b29CazFHNC9OYTVOUjgyVy9lWGpyTCt3VGZCRm4xbHN2UHdTWmRtb0k2NkppaU9CRW1kb21XMURFY1RDZEVpdVdidHZmSkJGaFpQOXNqNUV3dUlac2NQUjFiNmJwZzR5ckJCRURBTG54cVBTSzJzRithTmdVWTBjMFZiWWo5MVhRYjlUeGxsWjk2YUpOL2p3Q0I5amlIdVpGalMyemh5V25TV3ZtQlJ0RzB4TEVzM1ZzdlhXNmVyZEc0ODU1eGxaYXRaeWt0UndkS3RJeHQxYmtPR3FlWDFibEFYVTYzcXo1NmtEb1VVam1veVhtNFZOdVNReTV1WTh3K0lxeFFPVEZCY21nays0c0g3L2xsSk8vTW82RjhnMEZQd1ZsV1dqTjhlY2RjT3BKUWVycThnQ1V2UVoyQ1RFcmp0WlhhMndqOW9WRFFOWDV6eFVDaHU2VmhZMC83WFE3R0o2T3RQZnB0YVpOckdqczF4SGhsY1pmV1hRZWV3c29Wa21ScjdoREZzUUFrVE51aGp1QjZhRTNybG1nR3hyam5QR0xxOVNwMEpaMEtEKzFscU9sUWdmM2xtNE1hRGVRZGdkNzE4QXpJQWtLSWVvTlRyUjZLdFBlbWovZlR1UXFvM2U3TmRiaEVwdUhtZy9aRm5LS0Z4V3g0U3lwaW1nalBBWC9lejNyQ1dJR0hQUW5RR25scVlrRVRsS1FOektxdmlGWWllYWJ2d3ZNZ2tZM2NOV2RidGUvdEdXak9NVFVWYk81bFRuSDhpWTNYZ1l4MHJYNmJ1cFE9PSIsImltYWdlIjoiaHR0cHM6Ly9maXJlYmFzZXN0b3JhZ2UuZ29vZ2xlYXBpcy5jb20vdjAvYi9jb25uZWN0LXgtcHJvZHVjdGlvbi5hcHBzcG90LmNvbS9vL1VzZXJzJTJGRTdzaXZWaGFEMVVYRDBPRTVaSVMlMkZCbHVlc2NvcGUlMjBwaWN0dXJlLnBuZz9hbHQ9bWVkaWEmdG9rZW49N2M2YmNlMjItY2I2NS00ODQ4LThhODEtMjhiYmViZjQ5NzI3IiwiZGlzcGxheU5hbWUiOiJibHVlc2NvcGUgYmx1ZXNjb3BlIiwiaWF0IjoxNjQ2ODA3ODQ3LCJleHAiOjMxNzE5MTI1MDI0N30.zNAsEtHGEOBnS_SDz48B3UK0FTwnDuikHvQOiRPmIEQ');
            req.setEndpoint('callout:SendSMSOTPAPI' + '?ACCOUNT='+userSendOtp+'&PASSWORD='+passSendOtp+'&MOBILE=' + phoneNumber + '&MESSAGE=' + EncodingUtil.urlEncode(messageOtp,'utf-8') + '&OPTION=SENDER=Abbott');

            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            // System.debug('res == ' + res);
            // System.debug('status code == ' + res.getStatusCode());

            if (res.getBody().indexOf('STATUS=0') != -1) {
                ret.put('status', true);
                ret.put('otpNumber', otpSend);
            } else {
                ret.put('status', false);
                System.debug('getBody == ' + res.getBody());
            }
        } else {
            ret.put('status', false);
            ret.put('message', 'ขออภัยค่ะ คุณได้ทำแบบสอบถามนี้แล้ว');
        }
        return ret;
    }
    @RemoteAction
    global static Map<String, Object> saveSurveyForm (Map<String, Object> paramSave) {
        Map<String, Object> responseStatus = new Map<String, Object>();
        String surveyCampaign = JSON.serialize(paramSave);
        SurveyCampaign__c insertSurveyCampaign = (SurveyCampaign__c) JSON.deserialize(surveyCampaign, SurveyCampaign__c.class);
        RecordType recordTypeGainFriends = [SELECT Id FROM RecordType WHERE Name = 'Gain Friends' LIMIT 1];
        insertSurveyCampaign.RecordTypeId = recordTypeGainFriends.Id;
        System.savepoint sp = Database.setSavepoint();
        try {
            insert insertSurveyCampaign;
            responseStatus.put('status', true);
            responseStatus.put('message', 'Save successful!');
        } catch (DmlException ex) {
            responseStatus.put('status', false);
            system.debug('errorMessage update SurveyCampaign__c: '+ex.getMessage());
            responseStatus.put('message','upsert SurveyCampaign__c: '+ex.getMessage());
            Database.rollback(sp);
        }
        return responseStatus;
    }
}