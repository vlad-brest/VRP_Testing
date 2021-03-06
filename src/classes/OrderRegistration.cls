public with sharing class OrderRegistration {
    public static final String QUANTITY_ERROR_MESSAGE = 'Quantity ordered must be greater than 0.';
    public static final String NOT_ENOUGH_ERROR_MESSAGE = 'Not enough products in stock.';
    public static final String SUCCESS_CONFIRM_MESSAGE = 'The purchase has been successfully completed!';

    private Id productId;

    public Contact theContact {get; set;}
    public Product_Table__c product {get; set;}
    public Order_Table__c order {get; set;}

    public OrderRegistration() {
        productId = ApexPages.currentPage().getParameters().get('id');
        product = [
             SELECT Id,
                    Name,
                    Product_Description__c,
                    Unit_Price__c,
                    Features__c,
                    Units_Available__c
               FROM Product_Table__c
              WHERE Id = :productId LIMIT 1
        ];

        theContact = new Contact();
        order = new Order_Table__c(Units__c = 1);
    }

    public PageReference confirmOrder() {
        if (order.Units__c == NULL || order.Units__c < 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, QUANTITY_ERROR_MESSAGE));
        }
        else if (order.Units__c > product.Units_Available__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, NOT_ENOUGH_ERROR_MESSAGE));
        }
        else {
            List<Contact> existedContacts = [
                SELECT Id,
                    FirstName,
                    LastName
                FROM Contact
                WHERE Email = :theContact.Email
            ];

            if (!existedContacts.isEmpty()) {
                Contact contactToUpdate = existedContacts[0];
                contactToUpdate.FirstName = theContact.FirstName;
                contactToUpdate.LastName = theContact.LastName;
                update contactToUpdate;
                theContact = contactToUpdate;
            }
            else {
                insert theContact;
            }

            order.Contact__c = theContact.Id;
            order.Order_Amount__c = order.Units__c * product.Unit_Price__c;
            order.Product_Table__c = productId;
            order.Units__c = order.Units__c;
            insert order;

            product.Units_Available__c = product.Units_Available__c - order.Units__c;
            update product;

            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.CONFIRM, SUCCESS_CONFIRM_MESSAGE));
        }

        return NULL;
    }

    public PageReference goBack() {
        PageReference pr = Page.ProductDetailPage;
        pr.getParameters().put('id', productId);
        pr.setRedirect(true);
        return pr;
    }

}