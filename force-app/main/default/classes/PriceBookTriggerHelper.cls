/*------------------------------------------------------------
Author:      Marc Anthony Bondoc
Description: Helper class for PriceBook object
                 
History
02/19/2019   mbondoc   Createdd
-------------------------------------------------------------------------------------------*/

public class PriceBookTriggerHelper {
    
    public static void insertActivePriceBook(List<PriceBook2> listPriceBook) {
        
        List<PriceBook2> listOfPriceBook = new List<PriceBook2>();
        for(PriceBook2 pb : listPriceBook) {
            if(pb.StartDate__c == date.today()) {
                pb.IsActive = True;
            }

            if(pb.EndDate__c == date.today()) {
                pb.IsActive = False;
            }

            if(pb.DefaultForTelesales__c) {
                List<PriceBook2> existingDefaultPricebook = getDefaultPricebook(pb.Market__c);

                if(!existingDefaultPricebook.isEmpty()) {
                    pb.addError('There is already a default Price Book for Telesales set for your market.');
                }
            }

            listOfPriceBook.add(pb);
        }
    }

    
    public static void updateActivePriceBook(List<PriceBook2> pbList, Map<Id, sObject> oldPriceBookMap) {
        Set<Id> pbIdSet = new Set<Id>();
        
        List<PriceBook2> pbListToUpdate = new List<PriceBook2>();
		for(PriceBook2 pb: pbList) {
            if(trigger.isUpdate) {
                PriceBook2 oldPB = (PriceBook2) oldPriceBookMap.get(pb.id);
                
                if(pb.StartDate__c == date.today()) {
                   pb.IsActive = true;
                }

                if(pb.EndDate__c == date.today()) {
                    pb.IsActive = false;
                }

                if(oldPB.Market__c != pb.Market__c || oldPB.DefaultForTelesales__c != pb.DefaultForTelesales__c) {
                    if(pb.DefaultForTelesales__c) {
                        List<PriceBook2> existingDefaultPricebook = getDefaultPricebook(pb.Market__c);

                        if(!existingDefaultPricebook.isEmpty()) {
                            pb.addError('There is already a default Price Book for Telesales set for your market.');
                        }
                    }
                }
            }
        }
    }

    public static List<PriceBook2> getDefaultPricebook(String pbMarket) {
        List<PriceBook2> defaultPricebookList = [SELECT Id, Market__c, DefaultForTelesales__c 
                                                    FROM PriceBook2 
                                                    WHERE Market__c =: pbMarket AND DefaultForTelesales__c = TRUE AND IsActive = TRUE];
        return defaultPricebookList;
    }        
}