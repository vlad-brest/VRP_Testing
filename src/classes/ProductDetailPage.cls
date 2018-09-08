public with sharing class ProductDetailPage {

    private String productId;

    public Product_Table__c product {get; set;}
    public String theImage {get; set;}
    public String contentType {get; set;}

    public ProductDetailPage() {
        productId = ApexPages.currentPage().getParameters().get('id');
        product = [
            SELECT Id, Name, Product_Description__c, Unit_Price__c, Features__c
            FROM Product_Table__c
            WHERE Id = :productId LIMIT 1
        ];

        List<Attachment> attachments = [
            SELECT Id, Body, ContentType
            FROM Attachment
            WHERE ParentId = :productId LIMIT 1
        ];

        if (!attachments.isEmpty()) {
            theImage = EncodingUtil.Base64Encode(attachments[0].Body);
            contentType = attachments[0].ContentType;
        }
    }

    public PageReference goBack() {
        return Page.Product_List.setRedirect(true);
    }

    public PageReference buy() {
        PageReference pr = Page.OrderRegistration;
        pr.getParameters().put('id', productId);
        pr.setRedirect(true);
        return pr;
    }

}