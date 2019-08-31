public with sharing class SuperTRUMPSyncCheck {

    public interface ISyncApi {
        void updateQuotes(List<sObject> quotes);
        void syncQuotes(List<Id> quoteIds);
    }

    private class SyncApi implements ISyncApi {

        public void updateQuotes(List<sObject> quotes){
            update quotes;
        }

        public void syncQuotes(List<Id> quoteIds){
            IST.SuperTRUMPController.synchSFtoST(String.join(quoteIds, ','));
        }
    }

    @TestVisible
    private static Type syncApiType = SyncApi.class;

    private static String getNamespace(String name){
        if (!String.isEmpty(name)){
            List<String> tokens = name.split('__', 0);
            if (tokens.size() > 2 && tokens[0].length() <= 15){
                return tokens[0] + '__';
            }
        }
        return '';
    }

    private static String getSyncFieldName(String objName){
        String fieldName = null;
        IST__SuperTRUMP_Object_Definition__c objDef = IST__SuperTRUMP_Object_Definition__c.getInstance(objName);
        if (objDef == null){
            String namespace = getNamespace(objName);
            fieldName = namespace + 'Is_Synchronized__c';
        }
        else {
            fieldName = objDef.IST__Is_Synchronized__c;
        }
        return fieldName;
    }
    
    public static void validateBeforeSave(sObjectType masterObjType, Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        if (IST.SuperTRUMPController.isSuperTrumpUpdate){
            return;
        }
        sObjectType objType = newMap.getSObjectType();
        String masterObjName = String.valueOf(masterObjType);
        String objName = String.valueOf(objType);
        
        List<IST__SuperTRUMP_Mapping__c> mappingList = [SELECT Id, IST__SF_Master_Object_Name__c, IST__SF_Object_Name__c, IST__SF_Field_Name__c,
            IST__SF_Object_Level__c, IST__SF_Parent_Name__c, IST__IsSynch__c, IST__IsSynch_In__c,
            IST__ST_Field_Name__c, IST__ST_Update_Priority__c, IST__External_Binding__c, IST__Allow_Salesforce_Changes__c
            FROM IST__SuperTRUMP_Mapping__c
            WHERE IST__SF_Object_Name__c = :objName
            AND IST__SF_Master_Object_Name__c = :masterObjName
            AND (IST__IsSynch_In__c = true OR IST__IsSynch__c = true)];
        
        final String isSynchronizedFieldName = getSyncFieldName(objName);
        Map<String, sObjectField> fieldMap = objType.getDescribe().fields.getMap();
        sObjectField syncFieldType = null;
        if (fieldMap.containsKey(isSynchronizedFieldName)){
            syncFieldType = fieldMap.get(isSynchronizedFieldName);
        }
        
        String[] fieldNamesWithValidationError = new List<String>();
        Boolean isSynced = null;
        for (Id objId : newMap.keySet()){
            sObject sObj = newMap.get(objId);
            
            for (IST__SuperTRUMP_Mapping__c mapping : mappingList){
                String fieldName = mapping.IST__SF_Field_Name__c;
                if (sObj.get(fieldName) != oldMap.get((Id) objId).get(fieldName)){
                    if (!mapping.IST__IsSynch_In__c && mapping.IST__IsSynch__c && !mapping.IST__Allow_Salesforce_Changes__c){
                        // validation error
                        fieldNamesWithValidationError.add(fieldMap.containsKey(fieldName) ? fieldMap.get(fieldName).getDescribe().getLabel() : fieldName);
                    }
                    else {
                        isSynced = false;
                    }
                }
            }
            if (fieldNamesWithValidationError.size() > 0){
                sObj.addError('The following fields are synced to data in SuperTRUMP and are configured to be read-only unless changed via SuperTRUMP: "'
                    + String.join(fieldNamesWithValidationError, '", "') + '"', true);
            }
            if (syncFieldType != null && isSynced != null && sObj.get(syncFieldType) != isSynced){
                sObj.put(syncFieldType, isSynced);
            }
        }
    }
    
    public static void syncAfterSave(List<sObjectField> fieldRelationships, Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        if (IST.SuperTRUMPController.isSuperTrumpUpdate){
            return;
        }
        sObjectType objType = newMap.getSObjectType();
        Set<Id> parentIds = new Set<Id>();
        sObjectType parentType = null;
        sObjectField parentField = null;
        List<Map<Id, sObject>> queryResults = new List<Map<Id, sObject>>();
        if (fieldRelationships != null){
            for (Integer idx = 0; idx < fieldRelationships.size(); ++idx){
                parentField = fieldRelationships[idx];
                parentType = parentField.getDescribe().getReferenceTo()[0];
                Map<Id, sObject> results = null;
                if (idx == 0){
                    results = newMap;
                }
                else {
                    String query = 'SELECT Id, ' + String.valueOf(parentField) + ' FROM ' + String.escapeSingleQuotes(String.valueOf(parentType)) + ' WHERE Id IN :parentIds';
                    results = new Map<Id, sObject>(Database.query(query));
                }
                queryResults.add(results);
                parentIds.clear();
                for (sObject sObj : results.values()){
                    parentIds.add((Id) sObj.get(parentField));
                }
            }
        }
        sObjectType masterObjType = parentType != null ? parentType : objType;
        String masterObjName = String.valueOf(masterObjType);
        String objName = String.valueOf(objType);
        
        String[] fieldNameList = new List<String>();
        List<IST__SuperTRUMP_Mapping__c> mappingList = [
            SELECT Id, IST__SF_Field_Name__c, IST__IsSynch_In__c, IST__IsSynch__c
            FROM IST__SuperTRUMP_Mapping__c
            WHERE IST__SF_Object_Name__c = :objName
            AND IST__SF_Master_Object_Name__c = :masterObjName
            AND (IST__IsSynch_In__c = true OR IST__IsSynch__c = true)
        ];
        
        if (mappingList.size() == 0){
            return;
        }
        String isSynchronizedFieldName = getSyncFieldName(masterObjName);
        sObjectField syncFieldType = null;
        if (!String.isEmpty(isSynchronizedFieldName)){
            Map<String, sObjectField> fieldMap = masterObjType.getDescribe().fields.getMap();
            if (fieldMap.containsKey(isSynchronizedFieldName)){
                syncFieldType = fieldMap.get(isSynchronizedFieldName);
                if (syncFieldType != null && syncFieldType.getDescribe().getSOAPType() != Schema.SOAPType.Boolean){
                    syncFieldType = null;
                }
            }
        }
        
        Map<Id, sObject> masterObjMap = new Map<Id, sObject>();
        if (syncFieldType != null){
            if (fieldRelationships != null && fieldRelationships.size() > 0){ 
                masterObjMap = new Map<Id, sObject>(Database.query('SELECT Id, ' + String.valueOf(syncFieldType) + ' FROM ' + String.escapeSingleQuotes(masterObjName) + ' WHERE Id IN :parentIds'));
            }
            else {
                masterObjMap = newMap;
            }
        }
        
        Set<Id> objectsToSync = new Set<Id>();
        Map<Id, sObject> toUpdate = (Map<Id, sObject>) Type.forName('Map<Id, ' + masterObjName + '>').newInstance();
        new Map<Id, sObject>();
        for (Id sObjId : newMap.keySet()){
            Boolean syncRequired = false;
            Boolean outOfSync = false;
            for (IST__SuperTRUMP_Mapping__c mapping : mappingList){
                if (newMap.get(sObjId).get(mapping.IST__SF_Field_Name__c) != oldMap.get(sObjId).get(mapping.IST__SF_Field_Name__c)){
                    // syncRequired means we need to sync the Salesforce fields to the PRM
                    // outOfSync means mapped fields may not match the PRM, but we're not going to sync because such changes are allowed,
                    // (mapping has Allow Salesforce Changes set to true) otherwise, a validation error should have been previously thrown.
                    if (mapping.IST__IsSynch_In__c){
                        syncRequired = true;
                    }
                    else {
                        outOfSync = true;
                    }
                    break;
                }
            }
            if (syncRequired || outOfSync){
                Id currentId = sObjId;
                if (fieldRelationships != null){
                    for (Integer idx = 0; idx < fieldRelationships.size(); ++idx){
                        Map<Id, sObject> result = queryResults[idx];
                        currentId = (Id) result.get(currentId).get(fieldRelationships[idx]);
                    }
                }
                if (syncRequired && !objectsToSync.contains(currentId)){
                    // only add Id if this object needs to sync with SuperTRUMP PRM
                    objectsToSync.add(currentId);
                }
                if (syncFieldType != null && !toUpdate.containsKey(currentId)){
                    // if syncRequired or outOfSync is true, we want the sync field to be false
                    sObject sObj = masterObjMap.get(currentId);
                    if (sObj != null){
                        Boolean isSynced = (Boolean) sObj.get(syncFieldType);
                        if (isSynced == null || isSynced){
                            sObj.put(syncFieldType, false);
                            toUpdate.put(currentId, sObj);
                        }
                    }
                }
            }
        }
        ISyncApi syncApi = (ISyncApi) syncApiType.newInstance();
        if (toUpdate.size() > 0 && masterObjType.getDescribe().isUpdateable() && syncFieldType.getDescribe().isUpdateable()){
            syncApi.updateQuotes(toUpdate.values());
        }
        
        if (objectsToSync.size() > 0){
            syncApi.syncQuotes(new List<Id>(objectsToSync));
        }
    }
}