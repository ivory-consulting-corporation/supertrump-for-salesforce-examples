public with sharing class SuperTRUMPRecordType {
    
    @InvocableMethod(label='Set SuperTRUMP Quote Record Type')
    public static void setRecordType(List<RecordTypeRequest> requestList){
        Map<String, Set<Id>> queryMap = new Map<String, Set<Id>>();
        Map<Id, String> recordTypeByQuote = new Map<Id, String>();
        Set<String> quoteTypes = new Set<String>();
        Set<String> recordTypeNames = new Set<String>();
        
        for (RecordTypeRequest request : requestList){
            String typeName = request.quoteId.getSObjectType().getDescribe().getName();
            quoteTypes.add(typeName);
            recordTypeNames.add(request.recordTypeName);
            if (!queryMap.containsKey(typeName)){
                queryMap.put(typeName, new Set<Id>());
            }
            queryMap.get(typeName).add(request.quoteId);
            recordTypeByQuote.put(request.quoteId, request.recordTypeName);
        }
        List<RecordType> recordTypes = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE DeveloperName IN :recordTypeNames AND sObjectType IN :quoteTypes AND IsActive = TRUE];
        
        Map<String, Map<String, RecordType>> recordTypeMap = new Map<String, Map<String, RecordType>>();
        for (Recordtype recordType : recordTypes){
            if (!recordTypeMap.containsKey(recordType.sObjectType)){
                recordTypeMap.put(recordType.sObjectType, new Map<String, RecordType>());
            }
            if (!recordTypeMap.get(recordType.sObjectType).containsKey(recordType.DeveloperName)){
                recordTypeMap.get(recordType.sObjectType).put(recordType.DeveloperName, recordType);
            }
        }
        List<sObject> quotes = new List<sObject>();
        for (String typeName : queryMap.keySet()){
            Set<Id> quoteIds = queryMap.get(typeName);
            quotes.addAll(Database.query('SELECT Id, RecordTypeId FROM ' + String.escapeSingleQuotes(typeName) + ' WHERE Id IN :quoteIds'));
        }
        List<sObject> toUpdate = new List<sObject>();
        for (sObject quote : quotes){
            RecordType recordType = recordTypeMap.get(quote.getSObjectType().getDescribe().getName()).get(recordTypeByQuote.get(quote.Id));
            if (quote.get('RecordTypeId') != recordType.Id){
                quote.put('RecordTypeId', recordType.Id);
                toUpdate.add(quote);
            }
        }
        if (toUpdate.size() > 0){
            update toUpdate;
        }
    }
    
    public class RecordTypeRequest {
    
        @InvocableVariable(label='Quote Id' required=true description='The quote Id of the record whose record type will be updated.')
        public Id quoteId;
        @InvocableVariable(label='Record Type Name' required=true description='The record type name to set on the quote.')
        public String recordTypeName;
        
        public RecordTypeRequest(){}
    }
}