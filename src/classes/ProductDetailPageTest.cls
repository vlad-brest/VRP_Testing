@IsTest
public class ProductDetailPageTest {
    @IsTest
    static void testInitialPageLoad() {
        Product_Table__c newProduct = new Product_Table__c();
        insert newProduct;

        Attachment att1 = new Attachment(
            Name = 'Test Att1',
            Body = EncodingUtil.base64Decode('file content'),
            ParentId = newProduct.Id
        );

        insert att1;

        ApexPages.currentPage().getParameters().put('id', newProduct.Id);
        ProductDetailPage controller = new ProductDetailPage();
        System.assertNotEquals(NULL, controller.product);

        PageReference pr1 = controller.goBack();
        System.assertNotEquals(NULL, pr1);
        PageReference pr2 = controller.buy();
        System.assertNotEquals(NULL, pr2);
    }
}