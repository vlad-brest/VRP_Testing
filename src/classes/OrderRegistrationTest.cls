@isTest
public class OrderRegistrationTest {

    @IsTest
    public static void testWrongUnits() {

        Product_Table__c newProduct = new Product_Table__c(
                Units_Available__c = 5
        );
        insert newProduct;


        ApexPages.currentPage().getParameters().put('id', newProduct.Id);
        OrderRegistration controller = new OrderRegistration();
        controller.order.Units__c = NULL;
        controller.confirmOrder();
        System.assertEquals(OrderRegistration.QUANTITY_ERROR_MESSAGE, ApexPages.getMessages()[0].getDetail());

        controller.order.Units__c = -5;
        controller.confirmOrder();
        System.assertEquals(OrderRegistration.QUANTITY_ERROR_MESSAGE, ApexPages.getMessages()[0].getDetail());
    }

    @IsTest
    public static void testNotEnoughUnits() {

        Product_Table__c newProduct = new Product_Table__c(
                Units_Available__c = 5
        );
        insert newProduct;


        ApexPages.currentPage().getParameters().put('id', newProduct.Id);
        OrderRegistration controller = new OrderRegistration();
        controller.order.Units__c = 7;
        controller.confirmOrder();
        System.assertEquals(OrderRegistration.NOT_ENOUGH_ERROR_MESSAGE, ApexPages.getMessages()[0].getDetail());
    }

    @IsTest
    public static void testConfirmOrderSuccess() {

        Product_Table__c newProduct = new Product_Table__c(
                Units_Available__c = 5,
                Unit_Price__c = 5
        );
        insert newProduct;


        ApexPages.currentPage().getParameters().put('id', newProduct.Id);
        OrderRegistration controller = new OrderRegistration();
        controller.order.Units__c = 4;
        controller.theContact.FirstName = 'Vasya';
        controller.theContact.LastName = 'Ivanov';
        controller.theContact.Email = 'brtii@yandex.ru';
        controller.confirmOrder();
        System.assertEquals(OrderRegistration.SUCCESS_CONFIRM_MESSAGE, ApexPages.getMessages()[0].getDetail());
        List<Order_Table__c> orders = [SELECT  Id, Order_Amount__c FROM Order_Table__c WHERE Product_Table__c = :newProduct.Id];
        System.assertNotEquals(true, orders.isEmpty());
        System.assertEquals(20, orders[0].Order_Amount__c);
    }

    @IsTest
    public static void testConfirmOrderSuccessExistedContact() {
        Contact newContact = new Contact(
                FirstName = 'Vasya',
                LastName = 'Ivanov',
                Email = 'brtii@yandex.ru'
        );
        insert newContact;

        Product_Table__c newProduct = new Product_Table__c(
                Units_Available__c = 5,
                Unit_Price__c = 5
        );
        insert newProduct;


        ApexPages.currentPage().getParameters().put('id', newProduct.Id);
        OrderRegistration controller = new OrderRegistration();
        controller.order.Units__c = 4;
        controller.theContact.FirstName = 'Lena';
        controller.theContact.LastName = 'Petrova';
        controller.theContact.Email = 'brtii@yandex.ru';
        controller.confirmOrder();
        System.assertEquals(OrderRegistration.SUCCESS_CONFIRM_MESSAGE, ApexPages.getMessages()[0].getDetail());
        List<Order_Table__c> orders = [SELECT  Id, Order_Amount__c FROM Order_Table__c WHERE Product_Table__c = :newProduct.Id];
        System.assertNotEquals(true, orders.isEmpty());
        System.assertEquals(20, orders[0].Order_Amount__c);
        System.assertEquals('Petrova', [SELECT LastName FROM Contact WHERE Email = 'brtii@yandex.ru'].LastName);

        PageReference pr1 = controller.goBack();
        System.assertNotEquals(NULL, pr1);
    }
}