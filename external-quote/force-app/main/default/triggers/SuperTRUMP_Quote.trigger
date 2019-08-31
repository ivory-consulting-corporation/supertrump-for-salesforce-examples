trigger SuperTRUMP_Quote on SuperTRUMP_Quote__c (before update, after update) {
    if (Trigger.isUpdate){
        if (Trigger.isBefore){
            SuperTRUMPSyncCheck.validateBeforeSave(SuperTRUMP_Quote__c.sObjectType, Trigger.newMap, Trigger.oldMap);
        }
        else if (Trigger.isAfter) {
            SuperTRUMPSyncCheck.syncAfterSave(new List<sObjectField>(), Trigger.newMap, Trigger.oldMap);
        }
    }
}