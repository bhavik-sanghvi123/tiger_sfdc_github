/**
* @author           Marlon Ocillos
* @date             1.29.2019
* @description      Class used for Skills Based Routing
* @TestClass        SkillsBasedRoutingTest
* @revision(s)
    May 29, 2020    Jericson    have all skills inserted in 1 go for all market rather than doing it 1 market at a time
*/
public class SkillsBasedRouting {
    public static Id callRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call').getRecordTypeId();
    
    /**
    * @author           Marlon Ocillos
    * @date             1.29.2019
    * @description      Method is called by the Process builder and passes list of cases to appropriate filters
    * @revision(s)
    */
    public static void routeUsingSkills(List<String> newCalls) {
        List<Case> callsToFilter = new List<Case>();
        List<Case> callsToRoutePrevAgent = new List<Case>();
        List<Case> callsToRoute = new List<Case>();
        List<Case> callsToFilterOut = new List<Case>();
        List<Case> callsToQueue = new List<Case>();
        
        List<Case> caseList = [select Id, OwnerId, Description, RecordTypeId, ContactId, CreatedDate, Campaign__c, Campaign__r.Market__c, Campaign__r.Group__c,Campaign__r.SalesCall__c,
                         Market__c, Campaign__r.Brand__c, Campaign__r.Product__r.Family, Contact.Region__r.Name, Contact.Region__c , Contact.PreferredLanguage__r.Name,
                         Channel__c, Category__c, Highest_Priority__c, Campaign__r.Name, Channel__r.Category__c
                        from Case where Id in :newCalls];
        if(!caseList.isEmpty()){               
            for(Case cs : caseList){
                //existing Call Routing Logic is work for all market and for TW Non Sales Cases
                if(cs.Market__c != commonConstant.Market_TW || (cs.Market__c == CommonConstant.Market_TW && !cs.Campaign__r.SalesCall__c)){
                    callsToFilter.add(cs);
                }
                //new Call Routing Logic is work for TW Sales Cases
                if(cs.Market__c == CommonConstant.Market_TW && cs.Campaign__r.SalesCall__c){
                    callsToFilterOut.add(cs);
                }
            }
        }
        if(!callsToFilter.isEmpty()){
            callsToRoutePrevAgent = customCallsFilter(callsToFilter, 'ID');
        }
        if(!callsToFilterOut.isEmpty()){
            callsToQueue = routeToPreviousAgentofOrdersIfApplicable(callsToFilterOut);
        }
        if(!callsToRoutePrevAgent.isEmpty()) {
            callsToRoute = routeToPreviousAgentIfApplicable(callsToRoutePrevAgent);
        }
        if(!callsToRoute.isEmpty()) {
            createPendingServiceRouting(callsToRoute);
        }
        if(!callsToQueue.isEmpty()) {
            assignCasetoQueue(callsToQueue);
        }
    }
    
    /**
    * @author           Marlon Ocillos
    * @date             1.29.2019
    * @description      Method to check if a previous call has been logged fot the same Contact. Assigns the call again to the same agent that handled the previous call 
    * @revision(s)

    * 6.11.2021   malviz  TKT-004309: Previous Call will be based on Keybrand
    */
    static List<Case> routeToPreviousAgentIfApplicable(List<Case> callsToFilter) {
        Map<Id, Case> caseCRMap = new Map<Id, Case>();
        Map<Id, User> userOwnerMap = new Map<Id, User>();
        Map<Id, Set<String>> agentSkillSet = new Map<Id, Set<String>>();
        Map<Id, Set<String>> callsSkillsReq = new Map<Id, Set<String>>();
        Map<Id, Id> casePrevOwner = new Map<Id, Id>();
        Map<id, String> conBrandMap = new Map<id,String>();
        List<Case> callsToReturn = new List<Case>();
        List<Case> existingCalls = new List<Case>();
        List<Case> callsWithActivePrevAgents = new List<Case>();
        List<Case> callsToUpdate = new List<Case>();
        Set<Id> crContacts = new Set<Id>();
        Set<Id> usersOwner = new Set<Id>();
        Set<Id> activeUsers = new Set<Id>();
        
        for (Case caseRec : callsToFilter) {
            crContacts.add(caseRec.ContactId);
            String crBrand = caseRec.Campaign__r.Brand__c;
            conBrandMap.put(caseRec.ContactId,crBrand); 
        }
        
        // Query previous calls related to Call Regarding
        existingCalls = [select Id, OwnerId, Description, RecordTypeId, ContactId, CreatedDate, Campaign__c, Campaign__r.Market__c, 
                        Campaign__r.Brand__c, Campaign__r.Product__r.Family, Contact.Region__r.Name, Contact.Region__c , Contact.PreferredLanguage__r.Name, Channel__c, Category__c,
                        Campaign__r.Name, Channel__r.Category__c
                        from Case where Id not in :callsToFilter and RecordTypeId = :callRTId and ContactId in :crContacts];
        
        if(!existingCalls.isEmpty()) {
            for (Case caseRec : existingCalls) {

                String brand = conBrandMap.get(caseRec.ContactId);

                system.debug('=== campaign brand:'+ brand);
                // Determine if owner of Call is a user and add it in a set if true
                if(String.valueOf(caseRec.OwnerId).startsWith('005')) {
                    usersOwner.add(caseRec.OwnerId);
                }
                
                if(caseRec.Campaign__r.Brand__c != null){
            
                    // Create a map with Call Regarding as key and the latest Call record as the value
                    // TKT-004309 Get Previous Case based on Brand
                    if(!caseCRMap.containsKey(caseRec.ContactId) && (brand == caseRec.Campaign__r.Brand__c)) {
                        caseCRMap.put(caseRec.ContactId, caseRec);        
                    } else {
                        Case prevCase = caseCRMap.get(caseRec.ContactId);
                        if(prevCase != null){
                            system.debug('=== prev case check :'+ prevCase );
                            if((caseRec.CreatedDate > prevCase.CreatedDate) && (brand == caseRec.Campaign__r.Brand__c)) {
                                caseCRMap.put(caseRec.ContactId, caseRec);
                            }
                        }
                    }
                }
            }
            // Query active users that owned previous Call records and store them in a set
            if(!usersOwner.isEmpty()) {
                for(User userRec : [select Id from User where Id in :usersOwner and IsActive = true]) {
                    activeUsers.add(userRec.Id);
                }
                
                if(!activeUsers.isEmpty()) {
                    for(ServiceResource srRec : [select Id, RelatedRecordId, (select Id, Skill.MasterLabel from ServiceResourceSkills) from ServiceResource where RelatedRecordId in :activeUsers and IsActive = True and ResourceType = 'A']) {
                        agentSkillSet.put(srRec.RelatedRecordId, new Set<String>());
                        if(srRec.ServiceResourceSkills != null) {
                            List<ServiceResourceSkill> srsList = srRec.ServiceResourceSkills;
                            for(ServiceResourceSkill srsRec : srsList) {
                                agentSkillSet.get(srRec.RelatedRecordId).add(srsRec.Skill.MasterLabel);
                            }
                        }
                    }
                }
            }
            
            // Filter Calls that can be assigned to previous agent and Calls to return
            for (Case caseRec : callsToFilter) {
                if(caseCRMap.containsKey(caseRec.ContactId)) {
                    Case prevCase = caseCRMap.get(caseRec.ContactId);
                    system.debug('=== prev case ' + prevCase);
                    // If previous Call's owner is active, assign call to them otheriwse, add it to return list
                    if(activeUsers.contains(prevCase.OwnerId)) {
                        callsWithActivePrevAgents.add(caseRec);
                        casePrevOwner.put(caseRec.Id, prevCase.OwnerId);
                    } else {
                        callsToReturn.add(caseRec);
                    }
                } else {
                    callsToReturn.add(caseRec);
                }
            }
            
            if(!callsWithActivePrevAgents.isEmpty()) {
                callsSkillsReq = determineRequiredSkillsForCallsWithAgent(callsWithActivePrevAgents);                
                for(Case caseRec : callsWithActivePrevAgents) {
                    if(callsSkillsReq.containsKey(caseRec.Id) && !callsSkillsReq.get(caseRec.Id).isEmpty() ){
                        Set<String> callsReq = callsSkillsReq.get(caseRec.Id);
                        if(casePrevOwner.containsKey(caseRec.Id)) {
                            if(agentSkillSet.containsKey(casePrevOwner.get(caseRec.Id))) {
                                Set<String> prevAgentSkills = agentSkillSet.get(casePrevOwner.get(caseRec.Id));
                                if(prevAgentSkills.containsAll(callsReq)) {
                                    caseRec.OwnerId = casePrevOwner.get(caseRec.Id);
                                    callsToUpdate.add(caseRec);
                                } else {
                                    callsToReturn.add(caseRec);
                                }
                            } else {
                                callsToReturn.add(caseRec);
                            }
                        } 
                    }
                }
            }
        } else {
            callsToReturn = callsToFilter;
        }
        // Update if there are Calls to update
        if(!callsToUpdate.isEmpty()) { UtilityClass.updateList(callsToUpdate); }
        return callsToReturn;
    }

    public static List<Case> customCallsFilter(List<Case> callsToFilter, String market){
        Set<Id> channelIds = new Set<Id>();
        Map<Id, Channel__c> channelMap = new Map<Id, Channel__c>();
        Map<String, List<String>> callExcludeMap = new Map<String, List<String>>();
        for(Case c : callsToFilter) {
            if(c.Channel__c != null) {
                channelIds.add(c.Channel__c);
            }
        }
        if(!channelIds.isEmpty()) {
            channelMap = new Map<Id, Channel__c>([SELECT Id, Category__c FROM Channel__c WHERE Id IN :channelIds]);
        }
        for(CallRoutingExclusion__mdt cre : [SELECT Id, Field__c, Value__c FROM CallRoutingExclusion__mdt WHERE Market__c =: market]){
            if(callExcludeMap.containsKey(cre.Field__c)){
                callExcludeMap.get(cre.Field__c).add(cre.Value__c);
            }
            else{
                callExcludeMap.put(cre.Field__c, new List<String>{cre.Value__c});
            }
        }

        for (Integer i = (callsToFilter.size()-1) ; i >= 0 ; i--){
            Case caseRec = callsToFilter[i];
            if(caseRec.Market__c == market){
                if(caseRec.Campaign__c != null && callExcludeMap.containsKey('Campaign') && callExcludeMap.get('Campaign').contains(caseRec.Campaign__r.Name)){
                    callsToFilter.remove(i);
                }
                if(caseRec.Channel__c != null && channelMap.containsKey(caseRec.Channel__c) && callExcludeMap.containsKey('Channel Category')) {
                    Channel__c ch = channelMap.get(caseRec.Channel__c);
                    if(ch.Category__c != null && callExcludeMap.get('Channel Category').contains(ch.Category__c) ){
                        callsToFilter.remove(i);
                    }
                }
            }
        }
        return callsToFilter;
    }
    
    /**
    * @author           Marlon Ocillos
    * @date             1.29.2019
    * @description      Method that creates the Pending Service Routing record for the calls
    * @revision(s)
            4.29.2021   TKT-003996: Update priority structure for SG
    */
    public static void createPendingServiceRouting(List<Case> callsToRoute) {
        Map<Id, PendingServiceRouting> psrMap = new Map<Id, PendingServiceRouting>();
        Set<id> channelIdSet = new Set<id>();
        List<PendingServiceRouting> psrList = new List<PendingServiceRouting>();

        for(Case caseRec : callsToRoute){
            if(caseRec.Market__c == 'SG' && caseRec.Channel__c != null){
                channelIdSet.add(caseRec.Channel__c);
            }
        }
        
        Map<Id,Channel__c> channelMap = new Map<Id,Channel__c>([Select Id, Priority_Formula__c from Channel__c where Id in :channelIdSet]);
        
        ServiceChannel channel = [Select Id From ServiceChannel Where RelatedEntity = 'Case'];
        
        for(Case caseRec : callsToRoute) {
            PendingServiceRouting psrRec = new PendingServiceRouting();
            psrRec.CapacityWeight = 1;
            psrRec.IsReadyForRouting = False;
            psrRec.RoutingModel  = 'MostAvailable';
            psrRec.RoutingPriority = 1;
            psrRec.RoutingType = 'SkillsBased';
            psrRec.ServiceChannelId = channel.Id;
            psrRec.WorkItemId = caseRec.Id;
            psrRec.PushTimeout = 36000;

            //new priority structure for SG
            if(caseRec.Market__c == 'SG'){
                psrRec.RoutingPriority = 3; // regular calls

                if(caseRec.Highest_Priority__c){ // campaign-based
                    psrRec.RoutingPriority = 2;

                    if(caseRec.Channel__c != null){ // channel-based
                        if(channelMap.get(caseRec.Channel__c).Priority_Formula__c){
                            psrRec.RoutingPriority = 1;
                        }
                        
                    }
                }

            }
            
            psrList.add(psrRec);
        }
        
        if(!psrList.isEmpty()) {
            insert psrList;
            
            for(PendingServiceRouting psrRec : [select Id, WorkItemId, IsReadyForRouting from PendingServiceRouting where Id in :psrList]) {
                psrMap.put(psrRec.WorkItemId, psrRec);
            }
            
            determineRequiredSkills(callsToRoute, psrMap);
        }
    }
    
    /**
    * @author           Marlon Ocillos
    * @date             1.29.2019
    * @description      Method to determine which skills are required for a particular call
    * @revision(s)
    May 28, 2020 Jericson - have all skills inserted in 1 go for all market rather than doing it 1 market at a time
    */
    static void determineRequiredSkills(List<Case> casesToDetermine, Map<Id, PendingServiceRouting> psrMap) {
        List<Case> phCalls = new List<Case>();
        List<Case> vnCalls = new List<Case>();
        List<Case> myCalls = new List<Case>();
        List<Case> sgCalls = new List<Case>();
        List<Case> thCalls = new List<Case>();
        List<Case> inCalls = new List<Case>();
        List<Case> idCalls = new List<Case>();
        List<Case> twCalls = new List<Case>();
        
        for(Case caseRec : casesToDetermine) {
            if(caseRec.Campaign__c != null) {
                if(caseRec.Campaign__r.Market__c == 'PH') {
                    phCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'VN') {
                    vnCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'MY') {
                    myCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'SG') {
                    sgCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'TH') {
                    thCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'IN') {
                    inCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'ID') {
                    idCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'TW') {
                    twCalls.add(caseRec);
                }
            }
        }

        Map<Id, Set<String>> skillsMap = new Map<Id, Set<String>>();
        if(!phCalls.isEmpty()) skillsMap.putAll(SkillsBasedCriteria.determineRequiredSkillsPH(phCalls));
        if(!vnCalls.isEmpty()) skillsMap.putAll(SkillsBasedCriteria.determineRequiredSkillsVN(vnCalls));
        if(!myCalls.isEmpty()) skillsMap.putAll(SkillsBasedCriteria.determineRequiredSkillsMY(myCalls));
        if(!sgCalls.isEmpty()) skillsMap.putAll(SkillsBasedCriteria.determineRequiredSkills(sgCalls));
        if(!thCalls.isEmpty()) skillsMap.putAll(SkillsBasedCriteria.determineRequiredSkillsTH(thCalls));
        if(!inCalls.isEmpty()) skillsMap.putAll(SkillsBasedCriteria.determineRequiredSkills(inCalls));
        if(!idCalls.isEmpty()) skillsMap.putAll(SkillsBasedCriteria.determineRequiredSkillsID(idCalls));
        if(!twCalls.isEmpty()) skillsMap.putAll(SkillsBasedCriteria.determineRequiredSkillsTW(twCalls));
        if(!skillsMap.isEmpty()) createSkillRequirements(skillsMap, psrMap);
    }

    /**
    * @author           Marlon Ocillos
    * @date             1.29.2019
    * @description      Method to determine which skills are required for a particular call
    * @revision(s)
    */
    static Map<Id, Set<String>> determineRequiredSkillsForCallsWithAgent(List<Case> casesToDetermine) {
        Map<Id, Set<String>> callSkillsToReturn = new Map<Id, Set<String>>();
        List<Case> phCalls = new List<Case>();
        List<Case> vnCalls = new List<Case>();
        List<Case> myCalls = new List<Case>();
        List<Case> sgCalls = new List<Case>();
        List<Case> thCalls = new List<Case>();
        List<Case> inCalls = new List<Case>();
        List<Case> idCalls = new List<Case>();
        List<Case> twCalls = new List<Case>();
        
        for(Case caseRec : casesToDetermine) {
            if(caseRec.Campaign__c != null) {
                if(caseRec.Campaign__r.Market__c == 'PH') {
                    phCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'VN') {
                    vnCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'MY') {
                    myCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'SG') {
                    sgCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'TH') {
                    thCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'IN') {
                    inCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'ID') {
                    idCalls.add(caseRec);
                } else if(caseRec.Campaign__r.Market__c == 'TW') {
                    twCalls.add(caseRec);
                }
            }
        }
        
        if(!phCalls.isEmpty()) callSkillsToReturn.putAll(SkillsBasedCriteria.determineRequiredSkillsPH(phCalls));        
        if(!vnCalls.isEmpty()) callSkillsToReturn.putAll(SkillsBasedCriteria.determineRequiredSkillsVN(vnCalls));        
        if(!myCalls.isEmpty()) callSkillsToReturn.putAll(SkillsBasedCriteria.determineRequiredSkillsMY(myCalls));
        if(!sgCalls.isEmpty()) callSkillsToReturn.putAll(SkillsBasedCriteria.determineRequiredSkills(sgCalls));
        if(!thCalls.isEmpty()) callSkillsToReturn.putAll(SkillsBasedCriteria.determineRequiredSkillsTH(thCalls));
        if(!inCalls.isEmpty()) callSkillsToReturn.putAll(SkillsBasedCriteria.determineRequiredSkills(inCalls));
        if(!idCalls.isEmpty()) callSkillsToReturn.putAll(SkillsBasedCriteria.determineRequiredSkillsID(idCalls));        
        if(!twCalls.isEmpty()) callSkillsToReturn.putAll(SkillsBasedCriteria.determineRequiredSkillsTW(twCalls));
        return callSkillsToReturn;
    }
    
    /**
    * @author           Marlon Ocillos
    * @date             1.29.2019
    * @description      Method that creates skill requirement record to attach to the appropriate pending service routing record
    * @revision(s)
    */
    static void createSkillRequirements(Map<Id, Set<String>> callsAndSkillsRequirement, Map<Id, PendingServiceRouting> psrMap) {
        Map<String, Skill> skillMap = new Map<String, Skill>();
        List<SkillRequirement> srToInsert = new List<SkillRequirement>();
        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(Case caseRec : [SELECT Id, Campaign__c, Campaign__r.Market__c, RelatedBrandRelationship__c, RelatedBrandRelationship__r.FirstTransactionDate__c FROM Case WHERE Id IN :callsAndSkillsRequirement.keySet() OR Id IN :psrMap.keySet()]){
            caseMap.put(caseRec.Id, caseRec);
        }
        
        // Get Skills
        for(Skill skillRec : [Select Id, MasterLabel, DeveloperName From Skill]) {
            skillMap.put(skillRec.MasterLabel, skillRec);
        }

        for(Id casrKey : callsAndSkillsRequirement.keySet()) {
            Set<String> skillSet = callsAndSkillsRequirement.get(casrKey);
            for(String skillReq : skillSet) {
                SkillRequirement srRec = new SkillRequirement();
                if(psrMap.containsKey(casrKey)) {
                    srRec.RelatedRecordId = psrMap.get(casrKey).Id;
                }

                if(srRec.RelatedRecordId != null
                    && skillMap.containsKey(skillReq)) {
                    srRec.SkillId = skillMap.get(skillReq).Id;
                    srToInsert.add(srRec);
                }
            }
        }

        if(!srToInsert.isEmpty()) {
            UtilityClass.insertList(srToInsert);
            
            for(PendingServiceRouting psrRec : psrMap.values()) {
                if(caseMap.containsKey(psrRec.WorkItemId)){
                    Case c = caseMap.get(psrRec.WorkItemId);
                    if(c.Campaign__c != null && c.Campaign__r.Market__c == 'PH' && c.RelatedBrandRelationship__c != null && c.RelatedBrandRelationship__r.FirstTransactionDate__c == null){
                        psrRec.IsReadyForRouting = false;
                    }
                    else{
                        psrRec.IsReadyForRouting = true;
                    }
                }
                else{
                    psrRec.IsReadyForRouting = true;
                }
            }

            UtilityClass.updateList(psrMap.values());
        }
    }
    /*****************************************************************************************
    * @author           Monika Parihar
    * @date             16/09/2021
    * @description      Method to check if a previous order has been created for the same Contact. Assigns the call again to the same agent associated with existing Order
    * @revision(s)

    * 
    *********************************************************************************************/
    static List<Case> routeToPreviousAgentofOrdersIfApplicable(List<Case> callsToFilter) {
        Map<Id, Order> orderCRMap = new Map<Id, Order>();
        Map<Id, User> userOwnerMap = new Map<Id, User>();
        Map<Id, Set<String>> agentSkillSet = new Map<Id, Set<String>>();
        Map<Id, Set<String>> callsSkillsReq = new Map<Id, Set<String>>();
        Map<Id, Id> casePrevOwner = new Map<Id, Id>();
        Map<Id, String> conBrandMap = new Map<Id,String>();
        List<Case> callsToReturn = new List<Case>();
        List<Order> existingOrder = new List<Order>();
        List<Case> callsWithActivePrevAgents = new List<Case>();
        List<Case> callsToUpdate = new List<Case>();
        Set<Id> crContacts = new Set<Id>();
        Set<Id> usersOwner = new Set<Id>();
        Set<Id> activeUsers = new Set<Id>();
        
        for (Case caseRec : callsToFilter) {
            crContacts.add(caseRec.ContactId);
            String crBrand = caseRec.Campaign__r.Brand__c;
            conBrandMap.put(caseRec.ContactId,crBrand); 
        }
        
        // Query previous orders related to Contact associated with incoming call(case)
        existingOrder = [select Id,Abbott_Sales_Person__r.CallAgent__c, OwnerId, Description, OrderedBy__c, CreatedDate, RelatedCampaign__c, RelatedCampaign__r.Market__c, 
                        RelatedCampaign__r.Brand__c, RelatedCampaign__r.Product__r.Family, OrderedBy__r.Region__c , OrderedBy__r.PreferredLanguage__r.Name, Channel__c
                        from Order where   OrderedBy__c in :crContacts  and Status IN (:CommonConstant.ORDER_STATUS_COMPLETED, :CommonConstant.ORDER_STATUS_SUBMITTED) 
                        and Abbott_Sales_Person__r.CallAgent__c != null]  ;
        
        //check if order exist on Contact
        if(!existingOrder.isEmpty()) {
            for (Order orRec : existingOrder) {
                //brand of call(case)
                String brand = conBrandMap.get(orRec.OrderedBy__c);

                system.debug('=== campaign brand:'+ brand);
                // Determine if owner of Call is a user and add it in a set if true
                if(String.valueOf(orRec.Abbott_Sales_Person__r.CallAgent__c).startsWith('005')) {
                    usersOwner.add(orRec.Abbott_Sales_Person__r.CallAgent__c);
                }
                //campaign is not always there on Order
                //if(orRec.RelatedCampaign__r.Brand__c != null){
            
                    // Create a map with Call Regarding as key and the latest Call record as the value
                    // TKT-004309 Get Previous Case based on Brand
                    //add contactid and its associated existing orderId
                    if(!orderCRMap.containsKey(orRec.OrderedBy__c)) {
                        orderCRMap.put(orRec.OrderedBy__c, orRec);        
                    } else {
                        //compare new order with existing order for same contact and then add contact and orderid
                        Order prevOrder = orderCRMap.get(orRec.OrderedBy__c);
                        if(prevOrder != null){
                            system.debug('=== prev case check :'+ prevOrder );
                            if(orRec.CreatedDate > prevOrder.CreatedDate) {
                                orderCRMap.put(orRec.OrderedBy__c, orRec);
                            }
                        }
                    }
                //}
            }
            // Query active users that owned previous Call records and store them in a set
            if(!usersOwner.isEmpty()) {
                for(User userRec : [select Id from User where Id in :usersOwner and IsActive = true]) {
                    activeUsers.add(userRec.Id);
                }
                
                if(!activeUsers.isEmpty()) {
                    for(ServiceResource srRec : [select Id, RelatedRecordId, (select Id, Skill.MasterLabel from ServiceResourceSkills) from ServiceResource where RelatedRecordId in :activeUsers and IsActive = True and ResourceType = 'A']) {
                        agentSkillSet.put(srRec.RelatedRecordId, new Set<String>());
                        if(srRec.ServiceResourceSkills != null) {
                            List<ServiceResourceSkill> srsList = srRec.ServiceResourceSkills;
                            for(ServiceResourceSkill srsRec : srsList) {
                                agentSkillSet.get(srRec.RelatedRecordId).add(srsRec.Skill.MasterLabel);
                            }
                        }
                    }
                }
            }
            
            // Filter Calls that can be assigned to previous agent and Calls to return
            for (Case caseRec : callsToFilter) {
                if(orderCRMap.containsKey(caseRec.ContactId)) {
                    Order prevOrder = orderCRMap.get(caseRec.ContactId);
                    system.debug('=== prev case ' + prevOrder);
                    // If previous Call's owner is active, assign call to them otheriwse, add it to return list
                    if(activeUsers.contains(prevOrder.Abbott_Sales_Person__r.CallAgent__c) && prevOrder.Abbott_Sales_Person__r.CallAgent__c != null) {
                        callsWithActivePrevAgents.add(caseRec);
                        casePrevOwner.put(caseRec.Id, prevOrder.Abbott_Sales_Person__r.CallAgent__c);
                    } else {
                        callsToReturn.add(caseRec);
                    }
                } else {
                    callsToReturn.add(caseRec);
                }
            }
            
            if(!callsWithActivePrevAgents.isEmpty()) {
                callsSkillsReq = determineRequiredSkillsForCallsWithAgent(callsWithActivePrevAgents);                
                for(Case caseRec : callsWithActivePrevAgents) {
                    if(callsSkillsReq.containsKey(caseRec.Id) && !callsSkillsReq.get(caseRec.Id).isEmpty() ){
                        Set<String> callsReq = callsSkillsReq.get(caseRec.Id);
                        if(casePrevOwner.containsKey(caseRec.Id)) {
                            if(agentSkillSet.containsKey(casePrevOwner.get(caseRec.Id))) {
                                Set<String> prevAgentSkills = agentSkillSet.get(casePrevOwner.get(caseRec.Id));
                                if(prevAgentSkills.containsAll(callsReq)) {
                                    caseRec.OwnerId = casePrevOwner.get(caseRec.Id);
                                    callsToUpdate.add(caseRec);
                                } else {
                                    callsToReturn.add(caseRec);
                                }
                            } else {
                                callsToReturn.add(caseRec);
                            }
                        } 
                    }
                }
            }
            //if order doesnt exist on Contact
        } else {
            callsToReturn = callsToFilter;
        }
        // Update if there are Calls to update
        if(!callsToUpdate.isEmpty()) { UtilityClass.updateList(callsToUpdate); }
        return callsToReturn;
    }
    /*****************************************************************************************
    * @author           Monika Parihar
    * @date             16/09/2021
    * @description      Remaining cases from method routeToPreviousAgentofOrdersIfApplicable and cases that dont have existing order will assign to associated PED or AND queue
    * @revision(s)

    * 
    *********************************************************************************************/
    static void assignCasetoQueue(List<Case> casesToDetermine) {
        List<Case> csList = new List<Case>();
        Group queueAND = [Select Id from Group WHERE Type = : CommonConstant.QUEUE AND DeveloperName  =: CommonConstant.QUEUECALLROUTINGAND LIMIT 1];
        Group queuePED = [Select Id from Group WHERE Type = : CommonConstant.QUEUE  AND DeveloperName =: CommonConstant.QUEUECALLROUTINGPED LIMIT 1];
        For(Case cs : [Select Id,Campaign__r.Product__r.Family from Case where ID IN :casesToDetermine]){
            if(cs.Campaign__r.Product__r.Family == CommonConstant.PEDPRODUCT){
               cs.OwnerId= queuePED.Id;
            }
            if(cs.Campaign__r.Product__r.Family == CommonConstant.ANDPRODUCT){
               cs.OwnerId= queueAND.Id;
            }
            csList.add(cs);
        }  
        if(!csList.isEmpty()){ 
            update csList;
        } 
    }
}