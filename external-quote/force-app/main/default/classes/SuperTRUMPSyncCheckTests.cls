@IsTest
public with sharing class SuperTRUMPSyncCheckTests {

    private class SyncApi implements SuperTRUMPSyncCheck.ISyncApi {
        public void updateQuotes(List<sObject> quotes){
            System.assertEquals(SuperTRUMP_Quote__c.sObjectType, quotes.getSObjectType());
            update quotes;
        }
        public void syncQuotes(List<Id> quoteIds){
            System.assert(quoteIds.size() > 0);
            System.assertEquals(SuperTRUMP_Quote__c.sObjectType, quoteIds[0].getSobjectType());
        }
    }

    private static SuperTRUMP_Quote__c validateBeforeSave(String fieldName, Object prevValue, Object newValue, Boolean syncToSalesforce){
        insert new List<IST__SuperTRUMP_Mapping__c> {
            new IST__SuperTRUMP_Mapping__c(
                IST__Allow_Salesforce_Changes__c = false,
                IST__External_Binding__c = null,
                IST__IsSynch__c = syncToSalesforce,
                IST__IsSynch_In__c = !syncToSalesforce,
                IST__SF_Field_Name__c = fieldName,
                IST__SF_Master_Object_Name__c = 'SuperTRUMP_Quote__c',
                IST__SF_Object_Level__c = '1',
                IST__SF_Object_Name__c = 'SuperTRUMP_Quote__c',
                IST__SOR__c = 'ST',
                IST__ST_Field_Name__c = 'Opportunity.Quotes.Quote[].Transaction.QuoteStatus',
                IST__ST_Update_Priority__c = 0
            )
        };
        sObjectType quoteType = SuperTRUMP_Quote__c.sObjectType;
        Id quoteId = Id.valueOf(sObjectType.SuperTRUMP_Quote__c.getKeyPrefix() + '000000000000');
        SuperTRUMP_Quote__c newQuote = new SuperTRUMP_Quote__c(Id = quoteId);
        newQuote.put(fieldName, newValue);

        Map<Id, SuperTRUMP_Quote__c> newMap = new Map<Id, SuperTRUMP_Quote__c>{
            quoteId => newQuote
        };
        SuperTRUMP_Quote__c oldQuote = new SuperTRUMP_Quote__c(Id = quoteId);
        oldQuote.put(fieldName, prevValue);
        Map<Id, SuperTRUMP_Quote__c> oldMap = new Map<Id, SuperTRUMP_Quote__c>{
            quoteId => oldQuote
        };

        SuperTRUMPSyncCheck.validateBeforeSave(quoteType, newMap, oldMap);

        return newQuote;
    }

    private static sObject syncAfterSave(sObjectType sObjType, String fieldName, Object prevValue, Object newValue, Boolean syncToSalesforce){
        SuperTRUMPSyncCheck.syncApiType = SyncApi.class;
        Set<sObjectType> childTypes = new Set<sObjectType>{
            sObjectType.SuperTRUMP_Quote_Asset__c.sObjectType,
            sObjectType.SuperTRUMP_Quote_Rent__c.sObjectType,
            sObjectType.SuperTRUMP_Quote_Loan__c.sObjectType,
            sObjectType.SuperTRUMP_Quote_Income_Fee__c.sObjectType,
            sObjectType.SuperTRUMP_Quote_Expense_Fee__c.sObjectType
        };
        String sObjTypeName = String.valueOf(sObjType);
        Boolean isChild = childTypes.contains(sObjType);

        insert new IST__SuperTRUMP_Object_Relationships__c(
            Name = 'SuperTRUMP_Quote__c',
            IST__Child_To_Master_Field_Name__c = 'Quote__c',
            IST__Child_To_Master_Relationship_Name__c = 'Quote__r'
        );

        insert new List<IST__SuperTRUMP_Mapping__c> {
            new IST__SuperTRUMP_Mapping__c(
                IST__Allow_Salesforce_Changes__c = false,
                IST__External_Binding__c = null,
                IST__IsSynch__c = syncToSalesforce,
                IST__IsSynch_In__c = !syncToSalesforce,
                IST__SF_Field_Name__c = fieldName,
                IST__SF_Master_Object_Name__c = 'SuperTRUMP_Quote__c',
                IST__SF_Object_Level__c = isChild ? '2' : '1',
                IST__SF_Object_Name__c = sObjTypeName,
                IST__SF_Parent_Name__c = isChild ? 'SuperTRUMP_Quote__c' : null,
                IST__SOR__c = 'ST',
                IST__ST_Field_Name__c = 'Opportunity.Quotes.Quote[].Transaction.QuoteStatus',
                IST__ST_Update_Priority__c = 0
            )
        };
        List<sObjectField> fieldRelationships = new List<sObjectField>();
        SuperTRUMP_Quote__c quote = null;
        if (isChild){
            fieldRelationships.add(sObjType.getDescribe().fields.getMap().get('Quote__c'));
            quote = new SuperTRUMP_Quote__c(stExternalId__c = 'test');
            insert quote;
        }
        sObject newSObj = sObjType.newSObject();
        newSObj.put('stExternalId__c', 'test');
        newSObj.put(fieldName, newValue);
        if (isChild){
            newSObj.put('Quote__c', quote.Id);
        }
        insert newSObj;
        Id sObjId = newSObj.Id;

        sObject oldSObj = newSObj.clone(true, false, true, true);
        oldSObj.put(fieldName, prevValue);
        Map<Id, sObject> newMap = (Map<Id, sObject>) Type.forName('Map<Id, ' + sObjTypeName + '>').newInstance();
        newMap.put(sObjId, newSObj);
        Map<Id, sObject> oldMap = (Map<Id, sObject>) Type.forName('Map<Id, ' + sObjTypeName + '>').newInstance();
        oldMap.put(sObjId, oldSObj);

        SuperTRUMPSyncCheck.syncAfterSave(fieldRelationships, newMap, oldMap);

        return newSObj;
    }

    public static testMethod void testValidateBeforeSave_validate(){
        System.assertEquals(0, ApexPages.getMessages().size());
        Test.startTest();
        validateBeforeSave('Mode__c', 'Lender', 'Lessor', true);
        Test.stopTest();
        System.assertEquals(1, ApexPages.getMessages().size());
    }

    public static testMethod void testValidateBeforeSave_sync(){
        Test.startTest();
        SuperTRUMP_Quote__c newQuote = validateBeforeSave('Mode__c', 'Lender', 'Lessor', false);
        Test.stopTest();
        System.assertEquals(false, newQuote.Is_Synchronized__c);
    }

    public static testMethod void testSyncAfterSave_Quote(){
        Test.startTest();
        SuperTRUMP_Quote__c newQuote = (SuperTRUMP_Quote__c) syncAfterSave(SuperTRUMP_Quote__c.sObjectType, 'Mode__c', 'Lender', 'Lessor', true);
        Test.stopTest();
        System.assertEquals(false, newQuote.Is_Synchronized__c);
    }

    public static testMethod void testSyncAfterSave_Quote_Sync(){
        Test.startTest();
        SuperTRUMP_Quote__c newQuote = (SuperTRUMP_Quote__c) syncAfterSave(SuperTRUMP_Quote__c.sObjectType, 'Mode__c', 'Lender', 'Lessor', false);
        Test.stopTest();
        System.assertEquals(false, newQuote.Is_Synchronized__c);
    }

    public static testMethod void testSyncAfterSave_Asset(){
        Test.startTest();
        SuperTRUMP_Quote_Asset__c newAsset = (SuperTRUMP_Quote_Asset__c) syncAfterSave(SuperTRUMP_Quote_Asset__c.sObjectType, 'Description__c', 'Default', '', true);
        Test.stopTest();

        SuperTRUMP_Quote__c quote = [SELECT Id, Is_Synchronized__c FROM SuperTRUMP_Quote__c];
        System.assertEquals(false, quote.Is_Synchronized__c);
    }

    public static testMethod void testSyncAfterSave_Asset_Sync(){
        Test.startTest();
        SuperTRUMP_Quote_Asset__c newAsset = (SuperTRUMP_Quote_Asset__c) syncAfterSave(SuperTRUMP_Quote_Asset__c.sObjectType, 'Description__c', 'Default', '', false);
        // make update trigger run
        update newAsset;
        Test.stopTest();

        SuperTRUMP_Quote__c quote = [SELECT Id, Is_Synchronized__c FROM SuperTRUMP_Quote__c];
        System.assertEquals(false, quote.Is_Synchronized__c);
    }

    public static testMethod void testSyncAfterSave_Rent_Sync(){
        Test.startTest();
        SuperTRUMP_Quote_Rent__c newRent = (SuperTRUMP_Quote_Rent__c) syncAfterSave(SuperTRUMP_Quote_Rent__c.sObjectType, 'Description__c', 'Default', '', false);
        // make update trigger run
        update newRent;
        Test.stopTest();

        SuperTRUMP_Quote__c quote = [SELECT Id, Is_Synchronized__c FROM SuperTRUMP_Quote__c];
        System.assertEquals(false, quote.Is_Synchronized__c);
    }

    public static testMethod void testSyncAfterSave_Loan_Sync(){
        Test.startTest();
        SuperTRUMP_Quote_Loan__c newLoan = (SuperTRUMP_Quote_Loan__c) syncAfterSave(SuperTRUMP_Quote_Loan__c.sObjectType, 'Description__c', 'Default', '', false);
        // make update trigger run
        update newLoan;
        Test.stopTest();

        SuperTRUMP_Quote__c quote = [SELECT Id, Is_Synchronized__c FROM SuperTRUMP_Quote__c];
        System.assertEquals(false, quote.Is_Synchronized__c);
    }

    public static testMethod void testSyncAfterSave_IncomeFee_Sync(){
        Test.startTest();
        SuperTRUMP_Quote_Income_Fee__c newFee = (SuperTRUMP_Quote_Income_Fee__c) syncAfterSave(SuperTRUMP_Quote_Income_Fee__c.sObjectType, 'Description__c', 'Default', '', false);
        // make update trigger run
        update newFee;
        Test.stopTest();

        SuperTRUMP_Quote__c quote = [SELECT Id, Is_Synchronized__c FROM SuperTRUMP_Quote__c];
        System.assertEquals(false, quote.Is_Synchronized__c);
    }

    public static testMethod void testSyncAfterSave_ExpenseFee_Sync(){
        Test.startTest();
        SuperTRUMP_Quote_Expense_Fee__c newFee = (SuperTRUMP_Quote_Expense_Fee__c) syncAfterSave(SuperTRUMP_Quote_Expense_Fee__c.sObjectType, 'Description__c', 'Default', '', false);
        // make update trigger run
        update newFee;
        Test.stopTest();

        SuperTRUMP_Quote__c quote = [SELECT Id, Is_Synchronized__c FROM SuperTRUMP_Quote__c];
        System.assertEquals(false, quote.Is_Synchronized__c);
    }
}