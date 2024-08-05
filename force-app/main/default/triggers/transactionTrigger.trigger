trigger transactionTrigger on Transaction_Entry__c (before insert, after insert , before update , after update,before delete , after delete) {
    
    Map<Id, Contact__c> contactsMap = new Map<Id, Contact__c>();
    for (Transaction_Entry__c txn : Trigger.isDelete ? Trigger.old : Trigger.new) {
        if (txn.Contacts__c != null) {
            contactsMap.put(txn.Contacts__c, new Contact__c(Id = txn.Contacts__c));
        }
    }

   if (Trigger.isInsert) {
         if(Trigger.isBefore){
          //  transactionTriggerHandler.beforeInsert(Trigger.new, Trigger.oldMap);
             transactionTriggerHandler.validateContactStatus(Trigger.new);
           }
       if (Trigger.isAfter) {
           transactionTriggerHandler.updateAccountBalance(Trigger.new);
          //   transactionTriggerHandler.afterInsert(Trigger.new, Trigger.oldMap);
          transactionTriggerHandler.adjustBalanceOnTransaction(Trigger.new);
       }   
   }
  
   if (Trigger.isUpdate){
       if (Trigger.isBefore) {
           transactionTriggerHandler.validateContactStatus(Trigger.new);
       }
       if (Trigger.isAfter) {
           transactionTriggerHandler.updateAccountBalance(Trigger.new);
           transactionTriggerHandler.adjustBalanceOnCancellation(Trigger.new);
           transactionTriggerHandler.adjustBalanceOnTransaction(Trigger.new);
       
       }
   }

   if (Trigger.isDelete) {
    // if (Trigger.isBefore) {
    //   contactTriggerHandler.beforeDelete(Trigger.old);
    //  }
     if (Trigger.isAfter) {
        transactionTriggerHandler.adjustBalanceOnTransaction(Trigger.new);
     }
  }


}