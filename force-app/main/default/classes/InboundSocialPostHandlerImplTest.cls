@isTest
public class InboundSocialPostHandlerImplTest {

    static Map<String, Object> sampleSocialData;
    static InboundSocialPostHandlerImpl handler;
    //static String imageUrl;

    static {
    	handler = new InboundSocialPostHandlerImpl();
        sampleSocialData = getSampleSocialData('1');
        
        /*imageUrl = PageReference.forResource('sampleimage').getUrl();
        imageUrl = imageUrl.subString(0, imageUrl.indexOf('?'));
        imageUrl = URL.getSalesforceBaseUrl().toExternalForm() + imageUrl;*/
    }
    
    static testMethod void verifyNewRecordCreation() {
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        
        Account a1 = new Account(Name = 'SG Social Contacts', Market__c = 'SG');
        insert a1;
        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        List<SocialPost> p1 = [select Id from SocialPost limit 1];
        System.assertEquals(true, !p1.isEmpty());
    }
    
    static testMethod void verifyExistingRecordCreation() {
        SocialPost post = getSocialPost(sampleSocialData);
        post.ReviewScore = 5.00;
        SocialPersona persona = getSocialPersona(sampleSocialData);
        
        SocialPost post2 = getSocialPost(sampleSocialData);
        SocialPersona persona2 = getSocialPersona(sampleSocialData);
        
        Account a1 = new Account(Name = 'SG Social Contacts', Market__c = 'SG');
        insert a1;
        
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        
        test.startTest();
        handler.handleInboundSocialPost(post2, persona2, sampleSocialData);
        test.stopTest();
        
        List<Contact> c1 = [select Id from Contact where AccountId = :a1.Id limit 1];
        System.assertEquals(true, !c1.isEmpty());
    }
    
    static testMethod void callOtherMethods() {
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        
        Account a1 = new Account(Name = 'SG Social Contacts', Market__c = 'SG');
        insert a1;
        
        List<InboundSocialPostHandlerImpl.PostAttachment> paList = new List<InboundSocialPostHandlerImpl.PostAttachment>();
        InboundSocialPostHandlerImpl.PostAttachment pa1 = new InboundSocialPostHandlerImpl.PostAttachment('Image', 'https://www.google.com/');
        paList.add(pa1);
        
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        
        List<SocialPost> spListToPass = [select Id from SocialPost limit 1];
        
        test.startTest();
        List<Case> caseList = new List<Case>{handler.findParentCaseFromPostReply(post)};
        Boolean bol1 = handler.isSocialPostRecipientSameAsPersona(post, persona);
        List<Case> caseList2 = new List<Case>{handler.findParentCaseFromPersona(post, persona)};
        List<SocialPost> spList1 = new List<SocialPost>{handler.findReplyToBasedOnReplyToId(post)};
        List<SocialPost> spList2 = new List<SocialPost>{handler.findReplyToBasedOnExternalPostIdAndProvider(post)};
        List<SocialPost> spList3 = new List<SocialPost>{handler.findReplyToBasedOnResponseContextExternalPostIdAndProvider(post)};
        List<SocialPost> spList4 = new List<SocialPost>{handler.findLatestInboundPostBasedOnPersonaAndRecipient(post, persona)};
        List<SocialPost> spList5 = new List<SocialPost>{handler.findLatestInboundPostBasedOnPersona(post, persona)};
        //handler.createAttachments(spListToPass[0], paList);
        test.stopTest();
    }
    
    static SocialPost getSocialPost(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
       	post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.Classification = 'Product / Service Complaints';
        post.PostPriority = 'High';
        return post;
    }
    
    static SocialPersona getSocialPersona(Map<String, Object> socialData) {
        SocialPersona persona = new SocialPersona();
        persona.Name = String.valueOf(socialData.get('author'));
        persona.RealName = String.valueOf(socialData.get('realName'));
        persona.Provider = String.valueOf(socialData.get('mediaProvider'));
        persona.MediaProvider = String.valueOf(socialData.get('mediaProvider'));
        persona.ExternalId = String.valueOf(socialData.get('externalUserId'));
        persona.AuthorLabels = '0001234,SG Market';
        return persona;
    }

    static Map<String, Object> getSampleSocialData(String suffix) {
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postTags', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        socialData.put('content', 'Content' + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Facebook');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'Facebook');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Private');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        socialData.put('unsentParent', 'false');
        return socialData;
    }
}