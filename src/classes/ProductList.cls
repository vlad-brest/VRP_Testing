public with sharing class ProductList {

    public List<ProductWrapper> wrappedProducts {get; set;}

    private Map<Id, List<Attachment>> productMap;
    private List<Product_Table__c> products;
    private List<Attachment> attachments;
    
    public ProductList() {
        this.wrappedProducts = new List<ProductList.ProductWrapper>();
        this.products = queryProducts();

        if (!products.isEmpty()) {
            this.attachments = queryAttachments();
            this.productMap = bindAttachmentsWithProducts();

            wrapProducts();
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'No products were found.'));
        }
    }
    
    private List<Product_Table__c> queryProducts() {
        List<Product_Table__c> result = [
            SELECT  Id,
                    Name,
                    Product_Description__c,
                    Unit_Price__c,
                    Features__c
            FROM Product_Table__c
        ];

        return result;
    }

    private List<Attachment> queryAttachments() {
        List<Attachment> result = [
            SELECT Id, Body, ContentType, ParentId
            FROM Attachment
            WHERE ParentId IN :products
        ];
        return result;
    }

    private Map<Id, List<Attachment>> bindAttachmentsWithProducts() {
        Map<Id, List<Attachment>> productIdToAttachments = new Map<Id, List<Attachment>>();
        for (Attachment att : attachments) {
            if (productIdToAttachments.containsKey(att.ParentId)) {
                productIdToAttachments.get(att.ParentId).add(att);
            }
            else {
                productIdToAttachments.put(att.ParentId, new List<Attachment>{att});
            }
        }

        return productIdToAttachments;
    }

    private void wrapProducts() {
        for (Product_Table__c pr : products) {
            ProductWrapper tempWrappedProduct;
            if (productMap.get(pr.Id) != NULL) {
                tempWrappedProduct = new ProductWrapper(pr, productMap.get(pr.Id)[0]);
            }
            else {
                tempWrappedProduct = new ProductWrapper(pr);
            }

            wrappedProducts.add(tempWrappedProduct);
        }
    }

    public class ProductWrapper {
        public Product_Table__c product {get; set;}
        public String image {get; set;}
        public String contentType {get; set;}
        public String description {get; set;}

        public ProductWrapper(Product_Table__c product, Attachment attachment) {
            this.product = product;
            getContent(attachment);
            this.description = buildDescriptionString();
        }

        public ProductWrapper(Product_Table__c product) {
            this.product = product;
            this.description = buildDescriptionString();
        }

        private void getContent(Attachment att) {
            image = EncodingUtil.Base64Encode(att.Body);
            contentType = att.ContentType;
        }

        private String buildDescriptionString() {
            if (product.Product_Description__c.length() > 100) {
                return product.Product_Description__c.left(100) + '...';
            }
            else {
                return product.Product_Description__c;
            }
        }
    }

    
}