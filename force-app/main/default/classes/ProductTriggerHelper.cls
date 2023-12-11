/*------------------------------------------------------------
Author:      Jennifer Alviz
Description: Helper class for Product object
             
History
07/25/2019   malviz   Created
14/09/2021   mparihar  add null and blank check 
-------------------------------------------------------------------------------------------*/
public class ProductTriggerHelper {
    public static void checkDuplicateProductCode(List<Product2> productList, Map<id, sObject> oldProductMap){
        
        Map<String, Product2> productCodeMap = new Map<String, Product2>(); 
        
        for(Product2 p : productList){ 
            String oldProductCode;
            String oldMarket;
            if(Trigger.IsUpdate && oldProductMap.containsKey(p.Id)){
                Product2 oldProduct = (Product2) oldProductMap.get(p.Id);
                oldProductCode = oldProduct.ProductCode;
                oldMarket = oldProduct.Market__c;
            }
            
            if((Trigger.IsInsert && p.ProductCode != null) || 
               (Trigger.IsUpdate && p.ProductCode != null && p.ProductCode != oldProductCode) || ( Trigger.IsUpdate && p.Market__c != null && p.Market__c != oldMarket)){
                productCodeMap.put(p.ProductCode, p);
            }
        }
        
        List<Product2> duplicateList = [Select Name, ProductCode, Market__c FROM Product2 WHERE ProductCode IN :productCodeMap.Keyset()];
        if(!duplicateList.isEmpty()){//added by Monika /***emptycheck***/
            for(Product2 p :  duplicateList){
                Product2 newProduct = productCodeMap.get(p.ProductCode);
                if(p.Market__c != null && newProduct.Market__c != null && p.Market__c == newProduct.Market__c){//added by Monika /***nullcheck***/
                    system.debug('Error: ' + p.Name + ' ' + p.ProductCode);
                    newProduct.ProductCode.addError('There is already an existing product with the same Product Code. Please update the Product Code before saving.');
                }
            }
        }
                
    }
    
    public static void updateMinMaxBirthMonth(Map<Id, SObject> newProductMap, Map<Id, SObject> oldProductMap){
        Map<Id, List<OrderItem>> productToOrderItemListMap = new Map<Id, List<OrderItem>>();
        List<OrderItem> updateOrderItemList = new List<OrderItem>();

        for(OrderItem o : [SELECT Id, Product2Id, Product_Min_Birth_Month__c, Product_Max_Birth_Month__c FROM OrderItem WHERE Product2Id IN: newProductMap.keySet()]){
            if(!productToOrderItemListMap.isEmpty() && productToOrderItemListMap.containsKey(o.Product2Id)){   
                productToOrderItemListMap.get(o.Product2Id).add(o);
            }
            else{
                productToOrderItemListMap.put(o.Product2Id, new List<OrderItem>{o});
            }
        }
        
        for(Product2 p : (List<Product2>) newProductMap.values()){
            Product2 oldProduct = (Product2) oldProductMap.get(p.Id);
            Boolean maxBirthMonthChanged = p.Max_Birth_Month__c != oldProduct.Max_Birth_Month__c;
            Boolean minBirthMonthChanged = p.Min_Birth_Month__c != oldProduct.Min_Birth_Month__c;
            if(maxBirthMonthChanged || minBirthMonthChanged){
                if(productToOrderItemListMap.containsKey(p.Id)){
                    List<OrderItem> orderItemList = productToOrderItemListMap.get(p.Id);
                    for(OrderItem oi : orderItemList){
                        if(maxBirthMonthChanged) oi.Product_Max_Birth_Month__c = p.Max_Birth_Month__c == null ? 0 : p.Max_Birth_Month__c;
                        if(minBirthMonthChanged) oi.Product_Min_Birth_Month__c = p.Min_Birth_Month__c == null ? 0 : p.Min_Birth_Month__c;
                        updateOrderItemList.add(oi);
                    }
                }
            }
        }
		
        if(!updateOrderItemList.isEmpty()){
            update updateOrderItemList;
        }
    }
    
}