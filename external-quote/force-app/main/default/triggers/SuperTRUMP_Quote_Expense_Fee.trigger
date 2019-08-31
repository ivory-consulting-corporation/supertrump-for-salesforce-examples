trigger SuperTRUMP_Quote_Expense_Fee on SuperTRUMP_Quote_Expense_Fee__c (before update, after update) {
    if (Trigger.isUpdate){
        if (Trigger.isBefore){
            SuperTRUMPSyncCheck.validateBeforeSave(SuperTRUMP_Quote__c.sObjectType, Trigger.newMap, Trigger.oldMap);
        }
        else if (Trigger.isAfter) {
            SuperTRUMPSyncCheck.syncAfterSave(new List<sObjectField>{ sObjectType.SuperTRUMP_Quote_Expense_Fee__c.fields.Quote__c.sObjectField }, Trigger.newMap, Trigger.oldMap);
        }
    }
}