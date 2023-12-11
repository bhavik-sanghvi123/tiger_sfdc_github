/*
Author: Jericson Mercado
Description: Send an email reminder to case which originates from email
This should run per market
*/
public class EmailToCaseReminder_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private static String initResponse = 'Initial Response';
    private static String firstReminder = 'First Reminder';
    private static String secondReminder = 'Second Reminder';
    private static String pendingUncontactable = 'Pending-Uncontactable';

    private String market;
    private Set<String> fieldSet = new Set<String>();
    private Set<String> emailSet = new Set<String>();
    private Map<String, List<EmailToCase__mdt>> recordTypeConditionMap = new Map<String, List<EmailToCase__mdt>>();
    private AffiliateMetadata__mdt  countryValues = new AffiliateMetadata__mdt();

    public EmailToCaseReminder_Batch(String m) {
        market = m;
        countryValues = [SELECT EmailToCaseOrgWideEmailAddress__c, EnableContactDetailRemindersonEmail__c FROM AffiliateMetadata__mdt WHERE Masterlabel =: m];
        for(EmailToCase__mdt e2c: [SELECT RecordType__c, Email_Template_to_Send__c, 
                                          PrimaryFieldAPI__c, PrimaryValueType__c, PrimaryValue__c, PrimaryComparison__c,
                                          SecondaryFieldAPI__c, SecondaryValueType__c, SecondaryValue__c, SecondaryComparison__c,
                                          FieldToUpdateAPI__c, FieldToUpdateType__c, FieldToUpdateValue__c
                                     FROM EmailToCase__mdt
                                    WHERE Market__r.MasterLabel =: market
                                      AND Active__c = true
                                 ORDER BY MasterLabel]) {
            if(!recordTypeConditionMap.containsKey(e2c.RecordType__c)){
                recordTypeConditionMap.put(e2c.RecordType__c, new List<EmailToCase__mdt>());
            }
            recordTypeConditionMap.get(e2c.RecordType__c).add(e2c);

            fieldSet.add(e2c.PrimaryFieldAPI__c);
            fieldSet.add(e2c.SecondaryFieldAPI__c);
            emailSet.add(e2c.Email_Template_to_Send__c);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        // reminder is not enabled in the affiliate value level, throw error here
        if(!countryValues.EnableContactDetailRemindersonEmail__c) {
            throw new UtilityClass.CustomException('Email Reminder is disabled in affiliate level');
        }

        // add mandatory fields
        fieldSet.add('RecordType.Name');
        fieldSet.add('OwnerId');
        fieldSet.add('SuppliedEmail');
        fieldSet.add('Subject');
        fieldSet.add('CaseNumber');
        fieldSet.add('Description');
        fieldSet.add('CreatedById');

        String fieldStr = String.join(new List<String>(fieldSet), ',');

        String queryStr = 'SELECT ' + fieldStr
                        + ', (SELECT ReplyToEmailMessageId, Subject, HtmlBody FROM EmailMessages WHERE Incoming = false ORDER BY CreatedDate DESC LIMIT 1)' // get email
                        + '  FROM Case'
                        + ' WHERE Market__c =: market'
                        + '   AND (';

        Integer recordTypeCount = recordTypeConditionMap.KeySet().size();
        Integer recordTypeCountX = 1;

        for(String recordType: recordTypeConditionMap.KeySet()){

            // add recordtype filter
            queryStr += ' (RecordType.Name = \'' + recordType + '\' AND (';
            
            Integer conditionCount = recordTypeConditionMap.get(recordType).size();
            Integer conditionCountX = 1;

            // add condition per record type
            for(EmailToCase__mdt condition: recordTypeConditionMap.get(recordType)){

                // setup first condition
                queryStr += '(' + condition.PrimaryFieldAPI__c + queryConditonTranslator(condition.PrimaryComparison__c);
                
                if(condition.PrimaryValueType__c == 'Text'){
                    queryStr += '\'' + condition.PrimaryValue__c + '\'';
                } else {
                    queryStr += condition.PrimaryValue__c;
                }

                // check if there is 2nd condition and set it up
                if(condition.SecondaryFieldAPI__c != null){
                    queryStr += ' AND ' + condition.SecondaryFieldAPI__c + queryConditonTranslator(condition.SecondaryComparison__c);

                    if(condition.SecondaryValueType__c == 'Text'){
                        queryStr += '\'' + condition.SecondaryValue__c + '\'';
                    } else {
                        queryStr += condition.SecondaryValue__c;
                    }
                }

                queryStr += ')';

                if(conditionCountX < conditionCount) {
                    queryStr += ' OR ';
                }
                conditionCountX++;
            }

            queryStr += ' )';
            if(recordTypeCountX < recordTypeCount){
                queryStr += ' ) OR ';
            }
            recordTypeCountX++;
        }
        queryStr += ' ))';
        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext BC, List<Case> caseList) {

        // create map of template here
        Map<String, EmailTemplate> templateMap = getEmailTemplate();
        OrgWideEmailAddress owea;
        if(countryValues.EmailToCaseOrgWideEmailAddress__c != null
            && countryValues.EmailToCaseOrgWideEmailAddress__c != '') {
            owea= [SELECT DisplayName FROM OrgWideEmailAddress WHERE Address =: countryValues.EmailToCaseOrgWideEmailAddress__c];
        } 
        // email should only be sent from org wide email address
        if(owea != null
            || Test.isRunningTest()) {

            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

            for(Case c: caseList) {

                EmailTemplate tempTemplate;
                // check for any condition that has been met in the custom metadata
                for(EmailToCase__mdt condition: recordTypeConditionMap.get(c.recordType.Name)){

                    // check for matching condition
                    if(checkCondition(condition, c)){

                        // update case
                        updateCase(condition, c);

                        // send only if there is an email provided
                        if(c.SuppliedEmail != null) {
                            // get email template
                            tempTemplate = templateMap.get(condition.Email_Template_to_Send__c);
                            String sub = Test.isRunningTest() ? 'test subject' : c.EmailMessages.isEmpty() ? c.Subject :c.EmailMessages[0].Subject;
                            String bod = Test.isRunningTest() ? 'test subject' : c.EmailMessages.isEmpty() ? c.Description : tempTemplate.HtmlValue  + '\'n\n' + c.EmailMessages[0].HtmlBody;
                            // add email
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            if(owea != null) message.setOrgWideEmailAddressId(owea.Id);
                            message.toAddresses = new String[] { c.SuppliedEmail };
                            message.setWhatId(c.Id);
                            message.setSubject(sub);
                            message.setHtmlBody(bod);
                            message.saveAsActivity = true;
                            messages.add(message);
                        }


                        // finish checking for the case record for other condition if a condition has already been met.
                        break;
                    }
                }
            }

            // Send email
            if(!messages.isEmpty()){
                Messaging.sendEmail(messages);
            }

            // Update Case
            UtilityClass.updateList(caseList);
        }
    }

    public void finish(Database.BatchableContext BC) {}

    private Map<String, EmailTemplate> getEmailTemplate() {
        Map<String, EmailTemplate> templateMap = new Map<string, EmailTemplate>();

        for(EmailTemplate e: [SELECT DeveloperName, Body, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName IN: emailSet]) {
            templateMap.put(e.DeveloperName, e);
        }

        return templateMap;
    }

    private Boolean checkCondition(EmailToCase__mdt condi, Case c) {
        
        Boolean isMatch = false;

        // primary
        if(condi.PrimaryValueType__c == 'Text') {
            isMatch = conditionMatch(condi.PrimaryValueType__c, condi.PrimaryComparison__c, c.get(condi.PrimaryFieldAPI__c), condi.PrimaryValue__c);
        } else if (condi.PrimaryValueType__c  == 'Number') {
            isMatch = conditionMatch(condi.PrimaryValueType__c, condi.PrimaryComparison__c, c.get(condi.PrimaryFieldAPI__c), condi.PrimaryValue__c);
        }

        // secondary
        if(isMatch && String.isNotBlank(condi.SecondaryValueType__c)) {
            if(condi.SecondaryValueType__c == 'Text') {
                isMatch = conditionMatch(condi.SecondaryValueType__c, condi.SecondaryComparison__c, c.get(condi.SecondaryFieldAPI__c), condi.SecondaryValue__c);
            } else if (condi.SecondaryValueType__c  == 'Number') {
                isMatch = conditionMatch(condi.SecondaryValueType__c, condi.SecondaryComparison__c, c.get(condi.SecondaryFieldAPI__c), condi.SecondaryValue__c);
            }
        }

        return isMatch;
    }

    private void updateCase(EmailToCase__mdt condi, Case c) {

        if(String.isNotBlank(condi.FieldToUpdateAPI__c)) {
            if(condi.FieldToUpdateType__c == 'Text') {
                c.put(condi.FieldToUpdateAPI__c, String.valueOf(condi.FieldToUpdateValue__c));
                system.debug(c.get(condi.FieldToUpdateAPI__c));
            } else if (condi.FieldToUpdateType__c  == 'Number') {
                c.put(condi.FieldToUpdateAPI__c, Integer.valueOf(condi.FieldToUpdateValue__c));
            }
        }
    }

    @TestVisible
    private Boolean conditionMatch(String type, String comparison, Object fieldReference, Object fieldValue) {
        Boolean check = false;

        if(type == 'Text') {
            if(comparison == 'Equal') {
                check = String.valueOf(fieldReference) == String.valueOf(fieldValue);
            } else if( comparison == 'Not Equal' ) {
                check = String.valueOf(fieldReference) != String.valueOf(fieldValue);
            }
        } else if(type == 'Number') {
            if(comparison == 'Equal') {
                check = Integer.valueOf(fieldReference) == Integer.valueOf(fieldValue);
            } else if( comparison == 'Not Equal' ) {
                check = Integer.valueOf(fieldReference) != Integer.valueOf(fieldValue);
            } else if( comparison == 'Greater Than' ) {
                check = Integer.valueOf(fieldReference) > Integer.valueOf(fieldValue);
            } else if( comparison == 'Greater Than or Equal' ) {
                check = Integer.valueOf(fieldReference) >= Integer.valueOf(fieldValue);
            } else if( comparison == 'Less Than' ) {
                check = Integer.valueOf(fieldReference) < Integer.valueOf(fieldValue);
            } else if( comparison == 'Less Than or Equal' ) {
                check = Integer.valueOf(fieldReference) <= Integer.valueOf(fieldValue);
            }
        }

        return check;
    }

    @TestVisible
    private String queryConditonTranslator(String comparison) {
        String ret = '';
        if(comparison == 'Equal') {
            ret = ' = ';
        } else if( comparison == 'Not Equal' ) {
            ret = ' != ';
        } else if( comparison == 'Greater Than' ) {
            ret = ' > ';
        } else if( comparison == 'Greater Than or Equal' ) {
            ret = ' >= ';
        } else if( comparison == 'Less Than' ) {
            ret = ' < ';
        } else if( comparison == 'Less Than or Equal' ) {
            ret = ' <= ';
        }
        return ret;
    }
}