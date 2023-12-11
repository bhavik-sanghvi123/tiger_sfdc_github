@isTest
private class SummarizedOrderReportGeneratorTest {
    @testsetup
    static void setupData() {
        User sysad = TestDataFactory.createUser('System Administrator', 'tstSysAd' , 'PH');
        insert sysad;
        
        System.runAs(sysad) {                       
            List<Account> lAccount = TestDataFactory.createTestHousehold(1);
            List<Contact> lContact = TestDataFactory.createTestAdultContact(1, lAccount.get(0).Id);
            PricebookEntry entry = TestDataFactory.createPricebookEntry();
            Insert entry;

            List<Order> lOrder = TestDataFactory.createOrder(1, lAccount.get(0).Id, lContact.get(0).Id, Test.getStandardPricebookId());
            Insert lOrder;          
            
            OrderItem item = TestDataFactory.createOrderItem(lOrder.get(0).Id, entry.Id);
            insert item;

            lOrder.get(0).Status = CommonConstant.ORDER_STATUS_SUBMITTED;
            update lOrder;
        }
    }

    @isTest
    static void test_queryOrderItemReport() {
        User sysad = [Select id from User where Alias='tstSysAd' Limit 1];
        System.runAs(sysad) {           
            System.Test.startTest();
            System.debug([SELECT Id, Name FROM ContentWorkspace]);
                List<CommonObjectWrapper.cls_SummarizedOrder> orderList = SummarizedOrderReportGeneratorController.queryOrderReport();
                SummarizedOrderReportGeneratorController controller = new SummarizedOrderReportGeneratorController();
                SummarizedOrderReportGeneratorController.OrderReportWrapper filestring = SummarizedOrderReportGeneratorController.getExcelFileAsBase64String();
            System.Test.stopTest();
        

            System.assertEquals(1 , orderList.size());
            System.assertEquals('VW5pdC5UZXN0', filestring.fileContent);
        }
    }
}