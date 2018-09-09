@IsTest
public class ProductListTest {

    @IsTest
    public static void testInitialPageLoad() {
        //Records not found
        ProductList controller = new ProductList();
        System.assertEquals(true, controller.products.isEmpty());
        System.assertEquals(true, controller.wrappedProducts.isEmpty());
        System.assertEquals(ProductList.NO_PRODUCTS_FOUND_ERROR_MESSAGE, ApexPages.getMessages()[0].getDetail());
        //Normal load
        Product_Table__c newProduct = new Product_Table__c(
            Product_Description__c = 'Some description'
        );
        insert newProduct;

        controller = new ProductList();
        System.assertNotEquals(true, controller.products.isEmpty());
        System.assertNotEquals(true, controller.wrappedProducts.isEmpty());
    }

    @IsTest
    public static void testPageLoadWithAttachments() {
        Product_Table__c newProduct1 = new Product_Table__c(
            Product_Description__c = 'Some description'
        );
        Product_Table__c newProduct2 = new Product_Table__c(
            Product_Description__c = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        );
        insert new List<Product_Table__c>{newProduct1, newProduct2};
        System.assertEquals(2, [SELECT count() FROM Product_Table__c]);

        Attachment att1 = new Attachment(
            Name = 'Test Att1',
            Body = EncodingUtil.base64Decode('file content'),
            ParentId = newProduct1.Id
        );
        Attachment att2 = new Attachment(
            Name = 'Test Att2',
            Body = EncodingUtil.base64Decode('file content'),
            ParentId = newProduct1.Id
        );
        insert new List<Attachment>{att1, att2};
        System.assertNotEquals(true, [SELECT Id FROM Attachment].isEmpty());

        ProductList controller = new ProductList();
        System.assertNotEquals(true, controller.wrappedProducts.isEmpty());
        System.assertNotEquals(true, controller.attachments.isEmpty());
    }

}