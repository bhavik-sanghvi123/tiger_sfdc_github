/**
* @author        Rey Austral
* @date          2.11.2019
* @description   Class primarily responsible in handling trigger execution per object.
* @revision(s)

History
07/20/2020   malviz         bypass delete when To be Archived is true
*/
public with sharing class AccountTriggerHandler implements ITriggerHandler{
	public void BeforeInsert(List<SObject> newList) { }
    
    public void BeforeUpdate(List<SObject> newList, Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems) { }
    
    public void BeforeDelete(List<SObject> oldList, Map<Id, SObject> oldItems){ }
    
    public void AfterInsert(List<SObject> newList, Map<Id, SObject> newMapItems){ }
    
    public void AfterUpdate(List<SObject> newList , Map<Id, SObject> newMapItems, List<SObject> oldList, Map<Id, SObject> oldMapItems){ }
    
    public void AfterDelete(List<SObject> oldList, Map<Id, SObject> oldMapItems){ 
        List<Account> oldAccount = (List<Account>) oldList;
        List<Account> accountToProcess = new List<Account>();
       
        for(Account acc: oldAccount ){
           If(acc.To_be_Archived__c == false){
               accountToProcess.add(acc);
           }
        }
        
        if(!accountToProcess.isEmpty()) updateMergeContact(accountToProcess);
    }

	public static void updateMergeContact(List<Account> oldList) {
		Set<Id> accountIdSet = new Set<Id>();
		Set<Account> invalidAccount = new Set<Account>();

		for (Account acc : oldList) {
			//this function only process merge account
			//when there is a value of masterrecordid it means that the record has been merge to another account
			if (acc.MasterRecordId  != null)
				accountIdSet.add(acc.Id);
			else 
				invalidAccount.add(acc);
		}
		//for non admin, prevent user for deleting the record except for merging
		if (!invalidAccount.isEmpty()) {
			Id userId = UserInfo.getProfileId();
			String profileName;
			List<PermissionSetAssignment> permissionSetList =  [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND 
																(PermissionSet.Name =: CommonConstant.PERMISSIONSET_SGADDITIONAL OR PermissionSet.Name =: CommonConstant.PERMISSIONSET_MYADDITIONAL)];
			for (Profile pName : [Select Name from Profile where Id =: userId]) {
				profileName = pName.Name;
			}
			if (profileName != CommonConstant.PROFILE_ADMIN && permissionSetList.size() == 0) {
				for (Account acc : invalidAccount) {	            
					acc.addError('You have no access to delete this record');
				}
			}
		}
		if (!accountIdSet.isEmpty()) {
			updateListOfContact(accountIdSet);
		}
	}

	@future 
	public static void updateListOfContact(Set<Id> accountIdSet) {
		//future is used because the duplicate manage prevent updating the current household 
		//another problem is, the merge does not trigger the contact trigger, need to manually update the contact record
		//in order to trigger the contact process
		List<Contact> dupPrimaryContactList =  [Select Id,PrimaryContact__c,HouseHoldHistoryId__c, AccountId from Contact Where HouseHoldHistoryId__c IN: accountIdSet];
		//HouseHoldHistoryId__c this field is auto populate by the worflow upon record creation
		//AccountId will now be the new account, so we need to update the householdhistory field with the new account
		//the changing of value is also the criteria for the contact trigger merge function
		for(Contact con : dupPrimaryContactList) {
			con.HouseHoldHistoryId__c = con.AccountId;
			if (con.PrimaryContact__c) {
				con.PrimaryContact__c = false;
			}
		}

		if (!dupPrimaryContactList.isEmpty()) {
			Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; 
            
            List<Database.SaveResult> sr = Database.update(dupPrimaryContactList, dml);
			//Update dupPrimaryContactList;
		}

	}
}