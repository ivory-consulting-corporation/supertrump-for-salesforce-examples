@IsTest
public with sharing class SuperTRUMPQuoteInsertControllerTests {

    private static List<SelectOption> getOptions(){
        ApexPages.StandardController sc = new ApexPages.StandardController(new SuperTRUMP_Quote__c());
        SuperTRUMPQuoteInsertController contr = new SuperTRUMPQuoteInsertController(sc);
        return contr.getTemplateOptions();
    }

    public static testMethod void testGetTemplateOptions_None(){
        Test.startTest();
        List<SelectOption> options = getOptions();
        Test.stopTest();

        System.assertEquals(1, options.size());
    }

    public static testMethod void testGetTemplateOptions(){
        List<IST__SuperTRUMP_Template__c> templateList = new List<IST__SuperTRUMP_Template__c>{
            new IST__SuperTRUMP_Template__c(Name = 'Test')
        };
        insert templateList;

        Test.startTest();
        List<SelectOption> options = getOptions();
        Test.stopTest();

        System.assertEquals(2, options.size());
    }
}