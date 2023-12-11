/*----------------------------------------------------------------------------------------
Author:      Binh Dang
Description: Batch to delete duplicate contacts for India market (TKT-003754)

History
05/17/2021   Binh   	Created
06/09/2021   Jennifer   Comment out entire code, one-time use only
-------------------------------------------------------------------------------------------*/
// for deletion
public class DeleteIN3754AccountBatch {} /* implements Database.Batchable<sObject> {
global class DeleteIN3754AccountBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('Select Id, Name, Phone, LastModifiedDate  From Account Where Market__C=\'IN\' AND Phone !=null AND Phone !=\'0\' ORDER BY Phone');
    }

    global void execute(Database.BatchableContext context, List<Account> scope) {
        Map<String,String> Phone_IdDateMap = new Map<String,String>();  
		List<String> deleteIdList = new List<String>();  
		String delimiter = '_';  
		for(Account a : scope)  

		{ //Where Market__C='IN' order by Phone Limit 5000   
			 if(Phone_IdDateMap.containsKey(a.Phone))  
			 {  
			     String input = Phone_IdDateMap.get(a.Phone); // analyse String to get Id and lastest CreatedDate    
				 List<String> lstInput = input.split(delimiter); 
				 String currentMaxId = lstInput[0]; 
				 String currentMaxName = lstInput[1]; 
				 DateTime currentMaxDate = DateTime.valueof(lstInput[2]);  
				 if(currentMaxName == 'InboundAbandon'){ 
					 if(a.Name =='InboundAbandon'){ 
						 if(a.LastModifiedDate< currentMaxDate)  deleteIdList.add(a.Id);  
						 else{ 
							 Phone_IdDateMap.put(a.Phone, a.Id + delimiter + a.Name + delimiter + a.LastModifiedDate); // set new max value  
							 deleteIdList.add(currentMaxId);  
						 } 

					 }else{ 
						 Phone_IdDateMap.put(a.Phone, a.Id + delimiter + a.Name + delimiter + a.LastModifiedDate);  
						 deleteIdList.add(currentMaxId);  
					 } 
				 }else{ 
					 if(a.Name =='InboundAbandon') deleteIdList.add(a.Id); 
					 else{ 
						if(a.LastModifiedDate< currentMaxDate)  deleteIdList.add(a.Id);  
						else{  
							 Phone_IdDateMap.put(a.Phone, a.Id + delimiter + a.Name + delimiter + a.LastModifiedDate); // set new max value  
							 deleteIdList.add(currentMaxId);  
						}  
					 } 
				 } 
			 }  
			 else  
			 {  
				   Phone_IdDateMap.put(a.Phone,a.Id + delimiter + a.Name + delimiter + a.LastModifiedDate);  
			 }  
		}  

		if(!deleteIdList.isEmpty()) {  
			List<Account> myAccs = [SELECT Id FROM Account WHERE Id IN:deleteIdList];  
			//System.debug('###List delete:' + myAccs);  
			delete myAccs;   
		}  
	}
    
    
    global void finish(Database.BatchableContext context) {
        
    }
}*/