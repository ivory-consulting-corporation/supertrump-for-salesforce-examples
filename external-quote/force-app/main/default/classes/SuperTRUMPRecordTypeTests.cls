@IsTest
public with sharing class SuperTRUMPRecordTypeTests {

    public static testMethod void testSetRecordType_Loan(){
        SuperTRUMP_Quote__c quote = new SuperTRUMP_Quote__c(stExternalId__c = 'test', Mode__c = 'Lender');
        insert quote;
        quote = [SELECT Id, RecordTypeId FROM SuperTRUMP_Quote__c WHERE Id = :quote.Id];
        RecordType recordType = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE DeveloperName = 'Loan' AND sObjectType = 'SuperTRUMP_Quote__c' AND IsActive = TRUE];
        System.assertEquals(recordType.Id, quote.RecordTypeId);
    }

    public static testMethod void testSetRecordType_Lease(){
        SuperTRUMP_Quote__c quote = new SuperTRUMP_Quote__c(stExternalId__c = 'test', Mode__c = 'Lessor');
        insert quote;
        quote = [SELECT Id, RecordTypeId FROM SuperTRUMP_Quote__c WHERE Id = :quote.Id];
        RecordType recordType = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE DeveloperName = 'Lease' AND sObjectType = 'SuperTRUMP_Quote__c' AND IsActive = TRUE];
        System.assertEquals(recordType.Id, quote.RecordTypeId);
    }

    public static testMethod void testSetRecordType_Both(){
        SuperTRUMP_Quote__c quote = new SuperTRUMP_Quote__c(stExternalId__c = 'test', Mode__c = 'Both');
        insert quote;
        quote = [SELECT Id, RecordTypeId FROM SuperTRUMP_Quote__c WHERE Id = :quote.Id];
        RecordType recordType = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE DeveloperName = 'Both' AND sObjectType = 'SuperTRUMP_Quote__c' AND IsActive = TRUE];
        System.assertEquals(recordType.Id, quote.RecordTypeId);
    }
}