// for deletion 
public class BrandRelationshipBatch {} /* implements Database.Batchable<sObject> {
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		 String query = 'SELECT ID, CurrentBrand__c,Active__c,User__c,PrimaryContact__c,KeyBrand__c,ConsumingCompetitorBrand__c,DuplicateChecker__c,BrandRelationship__c '                           
            + ' FROM BrandRelationship__c'
            + ' WHERE'
            + ' (lastmodifieddate = last_n_days:3)'
            + ' AND PrimaryContact__r.Market__c = \'VN\'';
        return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<BrandRelationship__c> scope) {
    
		Map<Id, Contact> toUpdate = new Map<Id, Contact>();
        List<BrandRelationship__c> allRelatedList = new List<BrandRelationship__c>();
       
		for (BrandRelationship__c brand : scope) {   
            if (brand.PrimaryContact__c == brand.User__c) {
                Contact con = New Contact();
                con.Id = brand.PrimaryContact__c;
                con = procesMarketEndUserBrand(brand, con, allRelatedList);
                con = procesMarketPrimaryContactBrand(brand, con, allRelatedList);
                toUpdate.put(con.Id, con);
            } else {
                Contact conEndUser = New Contact();
                conEndUser.Id = brand.User__c;
                conEndUser = procesMarketEndUserBrand(brand, conEndUser, allRelatedList);
                toUpdate.put(conEndUser.Id, conEndUser);

                Contact con = New Contact();
                con.Id = brand.PrimaryContact__c;
                con = procesMarketPrimaryContactBrand(brand, con, allRelatedList);
                toUpdate.put(con.Id, con);
            }               
			
		}

		if (!toUpdate.isEmpty()) {
            Database.DMLOptions dml = new Database.DMLOptions();
        	dml.DuplicateRuleHeader.allowSave = true;
        	dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        
        	List<Database.SaveResult> sr = Database.update(toUpdate.values(), dml);
		}
    	
	}

	public Contact procesMarketEndUserBrand(BrandRelationship__c brand, Contact con, List<BrandRelationship__c> allRelatedList) {
       
        Boolean activeValue =  brand.Active__c;  
        con = updateEndUserMarketField(con, brand.KeyBrand__c, activeValue);
        return con;
    }

    public Contact procesMarketPrimaryContactBrand(BrandRelationship__c brand, Contact con, List<BrandRelationship__c> allRelatedList) {
        //deleting the record should make the check to false, 
        //for update and insert,  it dependes if the active is true or false
        Boolean activeValuePrimary = brand.Active__c;
        Boolean hasActiveCompetitorPrimary = brand.ConsumingCompetitorBrand__c;
       
        con = updatePrimaryContactMarketField(con, brand.KeyBrand__c, activeValuePrimary);
        
        con.MCConversionAttemptRequired__c = hasActiveCompetitorPrimary;

        return con;
    }   

    public Contact updateEndUserMarketField(Contact con, String keyBrand, Boolean activeValue) {
        if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_SIMILAC) {
            con.MCSimilacEndUser__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_GROW) {
            con.MCGrowEndUser__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_PEDIASURE) {
            con.MCPediasureEndUser__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_ENSURE) {
            con.MCEnsureEndUser__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_GLUCERNA) {
            con.MCGlucernaEndUser__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_OTHERS) {
            con.MCOthersEndUser__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_SIMILACMOM) {
            con.MCSimilacMomEndUser__c = activeValue;
        }

        return con;
    }

    public Contact updatePrimaryContactMarketField(Contact con, String keyBrand, Boolean activeValue) {
        if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_SIMILAC) {
            con.MCSimilacMainContact__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_GROW) {
            con.MCGrowMainContact__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_PEDIASURE) {
            con.MCPediasureMainContact__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_ENSURE) {
            con.MCEnsureMainContact__c = activeValue;
        }  else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_GLUCERNA) {
            con.MCGlucernaMainContact__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_OTHERS) {
            con.MCOthersMainContact__c = activeValue;
        } else if (keyBrand == CommonConstant.PRODUCT_KEYBRAND_SIMILACMOM) {
            con.MCSimilacMomMainContact__c = activeValue;
        }

        return con;
    }
	global void finish(Database.BatchableContext BC) {
		
	}
	
} */