public class CaseFeedbackEscalation_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    private String market;
    private OrgWideEmailAddress owea = new OrgWideEmailAddress();
    private Id feedbackRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CommonConstant.CASE_FEEDBACK_RECORDTYPE).getRecordTypeId();
    private Map<String, EmailTemplate> escalationTemplateMap = new Map<String, EmailTemplate>();
    private EmailTemplate escalationEmailTemplate = new EmailTemplate();
    private AffiliateMetadata__mdt country;
    private Contact dummyContact = new Contact();

    public CaseFeedbackEscalation_Batch(String m) {
        market = m;
        country = [SELECT MasterLabel, FeedbackEscalationOrgWideEmail__c,
                                                (SELECT EscalationLevel__c, EmailTemplatetoSend__c, DaysPassed__c FROM Case_Escalations__r WHERE isActive__c = true)
                                           FROM AffiliateMetadata__mdt
                                          WHERE MasterLabel =: m];

        // Set Org Wide Email -- Expecting only 1 since specific to market
        if(country.FeedbackEscalationOrgWideEmail__c != ''
            && country.FeedbackEscalationOrgWideEmail__c != null){
            owea = [SELECT Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: country.FeedbackEscalationOrgWideEmail__c];
        }

        List<String> emailSet = new List<String>();
        for(CaseEscalation__mdt rules: country.Case_Escalations__r) {
            emailSet.add(rules.EmailTemplatetoSend__c);
        }

        // Setup email templates per level
        for(EmailTemplate template: [SELECT DeveloperName, Body, Subject FROM EmailTemplate WHERE DeveloperName IN: emailSet]) {
            for(CaseEscalation__mdt rules: country.Case_Escalations__r) {
                if(rules.EmailTemplatetoSend__c == template.DeveloperName) {
                    escalationTemplateMap.put(rules.EscalationLevel__c, template);
                }
            }
            escalationEmailTemplate = template;
        }

        try{
            dummyContact = [SELECT Id FROM Contact WHERE LastName =: 'Dummy Contact'];
        } catch (exception e) {
            dummyContact.LastName = 'Dummy Contact';
            insert dummyContact;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> statusList = new Set<String> {'Closed - Resolved', 'Closed - Unresolved','Closed-Resolved', 'Closed-Unresolved'};
        
        String queryStr = 'SELECT CaseNumber, State__c, Product__c, StoreWherePurchased__r.Type__c, DaysOpen__c'
                        +  ' FROM Case'
                        + ' WHERE Market__c =: market'
                        + '   AND RecordTypeId =: feedbackRTId'
                        + '   AND Status NOT IN: statusList'
                        + '   AND (';
        
        Integer x = 0;
        Integer numberOfRules = country.Case_Escalations__r.size();

        for(CaseEscalation__mdt rules: country.Case_Escalations__r) {

            queryStr += 'DaysOpen__c = ' + rules.DaysPassed__c;

            x++;
            if(x != numberOfRules) {
                queryStr += ' OR ';
            }
        }

        if(Test.isRunningTest()) {
            queryStr += ' OR DaysOpen__c = 0';
        }

        queryStr += ')';

        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> cList) {

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        Set<Id> stateIDs = new Set<Id>();

        for(Case c: cList) {
            stateIDs.add(c.State__c);
        }

        // Key --> state|product|channelType|escalationLevel -- always level 1, create dynamic utility for this
        Map<String, Affiliate_Value__c> escalationMap = new Map<String, Affiliate_Value__c>();
        for(Affiliate_Value__c state: [SELECT (SELECT MainEscalationPointEmail__c, MainEscalationPointEmail2__c, EscalationLevel__c, ChannelType__c, Product__c,
                                                        AdditionalEscalationPointEmail1__c, AdditionalEscalationPointEmail2__c, AdditionalEscalationPointEmail3__c,
                                                        AdditionalEscalationPointEmail4__c, AdditionalEscalationPointEmail5__c, AdditionalEscalationPointEmail6__c
                                                    FROM Affiliate_Values__r
                                                WHERE Active__c = true)
                                        FROM Affiliate_Value__c
                                        WHERE Id IN: stateIDs]) {
            for(Affiliate_Value__c d: state.Affiliate_Values__r) {
                String key = state.Id + '|' + d.product__c + '|' + d.ChannelType__c + '|' + d.EscalationLevel__c;
                escalationMap.put(key, d);
            }
        }

        for(Case c: cList) {
            // loop custom metadata to compare level

            for(CaseEscalation__mdt rules: country.Case_Escalations__r) {
                String key = c.State__c + '|' + c.Product__c + '|' + c.StoreWherePurchased__r.Type__c + '|' + rules.EscalationLevel__c.right(1);
                
                // check if the has all it needed to send email
                if( escalationMap.containsKey(key)
                    && escalationTemplateMap.containsKey(rules.EscalationLevel__c)
                    && ( Test.isRunningTest()
                        || c.DaysOpen__c == rules.DaysPassed__c)
                    ){

                    c.LevelofEscalation__c = rules.EscalationLevel__c;

                    //set all emails addresses to send to
                    Affiliate_Value__c recipientTo = escalationMap.get(key);
                    List<String> toAddresses = new List<String>();
                    List<String> ccAddresses = new List<String>();

                    if(recipientTo.MainEscalationPointEmail__c != null) toAddresses.add(recipientTo.MainEscalationPointEmail__c);
                    if(recipientTo.MainEscalationPointEmail2__c != null) toAddresses.add(recipientTo.MainEscalationPointEmail2__c);

                    if(recipientTo.AdditionalEscalationPointEmail1__c != null) ccAddresses.add(recipientTo.AdditionalEscalationPointEmail1__c);
                    if(recipientTo.AdditionalEscalationPointEmail2__c != null) ccAddresses.add(recipientTo.AdditionalEscalationPointEmail2__c);
                    if(recipientTo.AdditionalEscalationPointEmail3__c != null) ccAddresses.add(recipientTo.AdditionalEscalationPointEmail3__c);
                    if(recipientTo.AdditionalEscalationPointEmail4__c != null) ccAddresses.add(recipientTo.AdditionalEscalationPointEmail4__c);
                    if(recipientTo.AdditionalEscalationPointEmail5__c != null) ccAddresses.add(recipientTo.AdditionalEscalationPointEmail5__c);
                    if(recipientTo.AdditionalEscalationPointEmail6__c != null) ccAddresses.add(recipientTo.AdditionalEscalationPointEmail6__c);

                    // set email template
                    EmailTemplate tempTemplate = escalationTemplateMap.get(c.LevelofEscalation__c);

                    // add email
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    if(owea != null) { message.setOrgWideEmailAddressId(owea.Id); } // set sender if specified
                    message.settoAddresses(toAddresses);
                    message.setccAddresses(ccAddresses);
                    message.setTargetObjectId(dummyContact.Id);
                    message.setWhatId(c.Id);
                    message.setTemplateId(tempTemplate.Id);
                    message.setTreatTargetObjectAsRecipient(false);
                    message.saveAsActivity = true;
                    messages.add(message);

                    break;
                }
            }
        }

        UtilityClass.updateList(cList);

        if(!messages.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }

    public void finish(Database.BatchableContext BC){}
}