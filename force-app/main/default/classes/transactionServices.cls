public with sharing class transactionServices {
    public static void processTransaction(Transaction_Entry__c transac) {
        Acc__c  account = [SELECT Id,Balance__c FROM Acc__c WHERE Id = :transac.Account_b__c];

        if(transac.Type__c == 'Credit'){
           // acc.Balance__c += transaction.Amount__c;
        } else if (transac.Type__c == 'Debit') {
           // acc.Balance__c -=transaction.Amount__c;
        }

        update account;
    }
}