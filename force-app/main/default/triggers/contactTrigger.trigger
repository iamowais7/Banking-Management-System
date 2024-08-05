trigger contactTrigger on Contact__c (before insert , after insert , before delete , after delete , before update , after update) {
    if(Trigger.isDelete){
        if (Trigger.isBefore) {
            ContactTriggerHandler.preventDeleteContactOnTransactionEntry(Trigger.old);  
        }    
    }

    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            contactTriggerHandler.syncContactStatus(Trigger.new, Trigger.oldMap);
        }
    }

}