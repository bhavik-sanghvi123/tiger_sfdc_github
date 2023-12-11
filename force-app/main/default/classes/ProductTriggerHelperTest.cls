@isTest
public class ProductTriggerHelperTest {
    private static testMethod void checkDuplicateProductCode(){
        List<Product2> lProduct = TestDataFactory.createTestBrandProduct(2);           
        lProduct[0].ProductCode = 'Code01';
        update lProduct;
        
        System.Test.startTest();
            try {
                lProduct[1].ProductCode = 'Code01';
                update lProduct;
            } catch(DMLException e) {
                System.assert(e.getMessage().contains('There is already an existing product with the same Product Code. Please update the Product Code before saving'), 'message=' + e.getMessage());
            }
        System.Test.stopTest();
    }

}