/**
* @author        Rey Austral
* @date          1.14.2019           
* @description   Class responsible for constant value accross all object
* @revision(s)
*/
public class CommonConstant {
    //Profile
    public static final String PROFILE_ADMIN = 'System Administrator';
    //Contact Record Type
    public static final String CONTACT_CHILD_RECORDTYPE = 'Child'; 
    public static final String CONTACT_ADULT_RECORDTYPE = 'Adult';
    //Contact Child Record
    public static final String CONTACT_CHILD_LASTNAME = 'New Child';
    public static final String CONTACT_CHILD_TYPE = 'Child';
    public static final String CONTACT_ADULT_TYPE = 'Adult';
    //Reward Record Type
    public static final String REWARD_EARN_RECORDTYPE = 'Earn';
    public static final String REWARD_REDEEM_RECORDTYPE = 'Redeem';
    public static final String REWARD_ADJUST_ADD_RECORDTYPE = 'Adjust (Add)';
    public static final String REWARD_ADJUST_SUBTRACT_RECORDTYPE = 'Adjust (Subtract)';
    //Affiliate Metadata
    public static final String AFFILIATE_MASTERLABEL = 'MasterLabel';
    public static final String AFFILIATE_MILKRESTRICTION = 'MilkCodeRestrictionPeriod__c';
    public static final String AFFILIATE_MONTHPERIODREQUEST = 'PeriodtRequest__c';
    public static final String AFFILIATE_SAMPLEPRICEBOOK = 'SampleRequestPricebook__c';
    public static final String AFFILIATE_NEWREG = 'ChannelNewRegistrationValidity__c';
    public static final String AFFILIATE_PREFERREDDELIVERYDATE = 'PreferredDeliveryDateWaitTime__c';
  public static final String AFFILIATE_NEXTATTEMPT = 'NextAttemptDueDateinDays__c';
    //Affiliaye Record Type
    public static final String AFFILIATE_REGION_RECORDTYPE = 'Region';
    public static final String AFFILIATE_CITY_RECORDTYPE = 'City';
    public static final String AFFILIATE_OCR_RECORDTYPE = 'Order Cancellation Reason';
    //ASSET Status
    public static final String ASSET_STATUS_AVAILABLE = 'Available';
    //Case Record Type
    public static final String CASE_CALL_RECORDTYPE = 'Call';
    public static final String CASE_INQUIRY_RECORDTYPE = 'Inquiry';
    public static final String CASE_FEEDBACK_RECORDTYPE = 'Feedback';
    //Order Status
    public static final String ORDER_STATUS_COMPLETED = 'Completed';
    public static final String ORDER_STATUS_DRAFT = 'Draft';
    public static final String ORDER_STATUS_SAMPLEGIVENONGROUND = 'Sample Given on Ground';
    public static final String ORDER_STATUS_TRANSFERRED = 'Transferred';
    public static final String ORDER_STATUS_SUBMITTED = 'Submitted';
    public static final String ORDER_STATUS_DELIVERED = 'Out for Delivery';
    public static final String ORDER_STATUS_CANCELLED_ABANDONED = 'Cancelled - Abandoned';
    public static final String ORDER_STATUS_CANCELLED_UPONDELIV = 'Cancelled - Upon Delivery';
    //Order Payment Method
    public static final String ORDER_PAYMENT_METHOD_CASH = 'Cash on Delivery';
    public static final String ORDER_PAYMENT_METHOD_CREDIT_CARD = 'Credit Card';
    //Order Type
    public static final String ORDER_TYPE_TELESALES_INBOUND = 'Telesales - Inbound';
    public static final String ORDER_TYPE_TELESALES_OUTBOUND = 'Telesales - Outbound';
    public static final String ORDER_TYPE_OTHER = 'Other';
    public static final String ORDER_TYPE_SAMPLEREQUEST = 'Sample Request';
    public static final String ORDER_TYPE_TRADE = 'Trade';
    //Order VAT
    public static final String ORDER_VAT = 'VAT II';
    public static final String ORDER_TYPE_ASSETSAMPLE = 'Asset Sample';
    //Order Item Object
    public static final String ORDERITEM_CATEGORY_TRIAL = 'Trial';
    //Skill Prefix
    public static final String SKILL_LANGUAGE = 'Language - ';
    public static final String SKILL_CHANNEL = 'Channel - ';
    public static final String SKILL_BRAND = 'Brand - ';
    public static final String SKILL_MARKET = 'Market - ';
    public static final String SKILL_REGION = 'Region - ';
    public static final String SKILL_GROUP = 'Group - ';
    public static final String SKILL_CAMPAIGN = 'Campaign - ';
    public static final String SKILL_PRODUCT_FAMILY = 'Product Family - ';
    //Skill
    public static final String SKILL_CONVERSION = 'Conversion - Conversion';
    public static final String SKILL_POST_CONVERSION = 'Conversion - Post-Conversion';
    //Brand Relationship 
    public static final String BRAND_TYPE_LEAD = 'Lead';
    public static final String BRAND_TYPE_USER = 'User';
    public static final String BRAND_STATUS_NEW = 'New';
    public static final String BRAND_STATUS_EXISTING = 'Existing';
    public static final String BRAND_STATUS_LAPSED = 'Lapsed';
    public static final String MILESTONE_STATUS_READY_TO_SEND = 'Ready to Send';
    //Case Call Type
    public static final String CASE_CALL_TYPE_INBOUND = 'Inbound';
    public static final String CASE_CALL_TYPE_OUTBOUND = 'Outbound';  
    //sObject List
    public static final String CASE_OBJECT = 'Case';
    public static final String CONTACT_OBJECT = 'Contact';
    public static final String PRICEBOOK_OBJECT = 'Pricebook2';
    public static final String PRODUCT_OBJECT = 'Product2';
    public static final String ADRESS_OBJECT = 'Address__c';
    public static final String CHANNEL_OBJECT = 'Channel__c';
    public static final String SKILL_OBJECT = 'Skill';
    public static final String AFFILIATEMETADATA_OBJECT = 'AffiliateMetadata__mdt';
    public static final String ASSET_OBJECT = 'Asset';
    public static final String ACCOUNT_OBJECT = 'Account';
    //User Role List
    public static final String USER_ROLE_MALAYSIA = 'ANI - Malaysia';
    public static final String USER_ROLE_PHILIPPINES = 'ANI - Philippines';
    public static final String USER_ROLE_SINGAPORE = 'ANI - Singapore';
    public static final String USER_ROLE_THAILAND = 'ANI - Thailand';
    public static final String USER_ROLE_VIETNAM = 'ANI - Vietnam';
    public static final String USER_ROLE_INDIA = 'ANI - India';
    public static final String USER_ROLE_ANZ = 'ANI - ANZ';
    public static final String USER_ROLE_INDONESIA = 'ANI - Indonesia';
    public static final String USER_ROLE_TAIWAN = 'ANI - Taiwan';
    public static final String USER_ROLE_ASEAPAC = 'ANI - ASEAPAC';
    //Market List
    public static final String MARKET_MY = 'MY';
    public static final String MARKET_PH = 'PH';
    public static final String MARKET_SG = 'SG';
    public static final String MARKET_TH = 'TH';
    public static final String MARKET_VN = 'VN';
    public static final String MARKET_IN = 'IN';
    public static final String MARKET_ANZ = 'ANZ';
    public static final String MARKET_ID = 'ID';
    public static final String MARKET_TW = 'TW';
    public static final String MARKET_ASEAPAC = 'ASEAPAC';
    //Channel Response
    public static final String CHANNELRESPONSE_ORDERSTATUS_MISSINGADDRESS = 'Unsuccessful - Missing Address';
    public static final String CHANNELRESPONSE_ORDERSTATUS_PRODUCTUNAVAILABLE = 'Unsuccessful - Product Unavailable';
    public static final String CHANNELRESPONSE_ORDERSTATUS_INELIGBLE = 'Unsuccessful - Ineligible';
    public static final String CHANNELRESPONSE_ORDERSTATUS_SUCCESSFUL = 'Successful';
    public static final String CHANNELRESPONSE_ORDERSTATUS_SUCCESSFULSAMPLEGIVENONGROUND = 'Successful - Sample Given on Ground';
    public static final String CHANNELRESPONSE_ORDERSTATUS_PENDING = 'Pending';
    public static final String CHANNELRESPONSE_ORDERSTATUS_PENDINGMILKCODE = 'Pending - Milk Code Restriction';
    public static final String CHANNELRESPONSE_CLASSIFICATION_SAMEBRAND = 'Previous Registration - Same Brand';
    public static final String CHANNELRESPONSE_CLASSIFICATION_FIRSTTIME = 'New Registration';
    //Pricebook
    public static final String TESTPRICEBOOK2 = 'Test PriceBook - B';
    public static final String TESTPRICEBOOK = 'Test PriceBook - A';
    public static final String TW_PED_STANDARD_PRICEBOOK = 'TW Pediatric Standard Price book';
    //Campaign
    public static final String TESTCAMPAIGN = 'Test Camp - A';
    public static final String TESTCAMPAIGN2 = 'Test Camp - B';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String PLANNED = 'Planned';
    public static final String APPROVED = 'Approved';
    //Product
    public static final String PRODUCT_KEYBRAND_SIMILAC = 'Similac';
    public static final String PRODUCT_KEYBRAND_GROW = 'Grow';
    public static final String PRODUCT_KEYBRAND_PEDIASURE = 'Pediasure';
    public static final String PRODUCT_KEYBRAND_ENSURE = 'Ensure';
    public static final String PRODUCT_KEYBRAND_GLUCERNA = 'Glucerna';
    public static final String PRODUCT_KEYBRAND_OTHERS = 'Others';
    public static final String PRODUCT_KEYBRAND_SIMILACMOM = 'Similac Mom';
    //Promotion Status
    public static final String PROMOTION_STATUS_INPROGRESS = 'In Progress';
    //Membership Status
    public static final String MEMBERSHIP_STATUS_NEW = 'New';
    public static final String MEMBERSHIP_STATUS_ACTIVATED = 'Activated';
    public static final String MEMBERSHIP_STATUS_EXPIRED = 'Expired';
    //External Id Metadata Developer Name
    public static final String PH_ORPHAN_TANGENT_ORDERS = 'PH_Orphan_Tangent_Orders';
    //Channel Record Type
    public static final String CHANNEL_SOCIAL_RECORDTYPE = 'Social';
    public static final String CHANNEL_OTHER_ONLINE_RECORDTYPE = 'Other - Online';
    public static final String CHANNEL_WEB_RECORDTYPE = 'Web';
    //Affiliate Brand Metadata
    public static final String AFFILIATEBRAND_MASTERLABEL = 'MasterLabel';
    public static final String AFFILIATEBRAND_MARKET = 'Market__c';
    public static final String AFFILIATEBRAND_MONTHPERIODREQUEST = 'PeriodRequest__c';
    //Shortened Days of the Week
    public static final String SUNDAY = 'Sun';
    //Product Record Type
    public static final String PRODUCT_PACKAGE_RECORDTYPE = 'Package';
    public static final String PRODUCT_PRODUCT_RECORDTYPE = 'Product';
    //Address Validation Status
    public static final String ADDRESS_VALIDATION_PENDING = 'Pending';
    public static final String ADDRESS_VALIDATION_VALID = 'Valid Address';
    public static final String ADDRESS_VALIDATION_INVALID = 'Invalid Address';
    //Integration User Names
    public static final String USER_DATA_INTEGRATION = 'Data Integration';
    //public static final String USER_DATA_INTEGRATION = 'Test User';
    //Named Credentials
    public static final String NAMED_CREDENTIAL_EXPERIAN_SEARCH = 'ExperianSearchNamedCredential';
    public static final String DICE_CREATE_CARD_CREDENTIAL = 'Dice_Create_Card_Credential';
    //Permission Set
    public static final String PERMISSIONSET_SGADDITIONAL = 'SG_Additional_Permission';
    public static final String PERMISSIONSET_MYADDITIONAL = 'MY_Additional_Permission';
    //Experian Integration
    public static final String ESCAPE_NUMBER_SIGN = ',%23';
    public static final String COUNTRY_CODE_WITH_TAKE = '&country=SGP&take=1';
    public static final String COUNTRY_CODE_WITHOUT_TAKE = '&country=SGP';

    //CASE FIELD
    public static final String CASE_ORIGIN_EMAIL = 'Email';
    public static final String CASE_STATUS_ESCALATED = 'Escalated';
    public static final String CASE_STATUS_CANCELLED = 'Cancelled';

    //EMAILTEMPLATE
    public static final String EMAILTEMPLATE_CASE_ESCALATION = 'Caseescalation';

    //AssetRelationship FIELD
    public static final String ASSETRELATIONSHIP_TYPE = 'Replacement';
    
    //Account MessageBird creation added by sharad
    public static final String STATUS_UNCONTACTED = 'Uncontacted';
    public static final String API_STATUS_SUCCESS = 'Success';
    public static final String API_STATUS_FAILURE = 'Failure';
    public static final String BRAND_AND_CHANNELRES_CREATED = 'BrandRelationship and ChannelResponse created';
    public static final String CHANNELRES_CREATED = 'ChannelResponse created';
    public static final String ACCOUNT_ALL_CREATED = 'Account Create Successful.';
    public static final String PEDIASURE_FIRSTNAME = 'WhatsApp';
    public static final String PEDIASURE_LASTNAME = 'child';
    
    //QUEUE AND GROUP
    public static final String QUEUE = 'Queue';
    
    //PRODUCTTYPE
    public static final String ANDPRODUCT = 'Adult';
    public static final String PEDPRODUCT = 'Pediatric';
    
    //QUEUE NAME
    public static final String QUEUECALLROUTINGAND = 'TW_CallRouting_AND_Queue';
    public static final String QUEUECALLROUTINGPED = 'TW_CallRouting_PED_Queue';

    //Month Map
    public static final Map<String,Integer> MONTH_MAP = new Map <String, Integer> {'Jan'=>1, 'Feb'=>2, 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 'Oct'=>10, 'Nov'=>11, 'Dec'=>12};
}