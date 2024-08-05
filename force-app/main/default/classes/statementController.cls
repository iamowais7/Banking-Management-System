public with sharing class statementController {
    
        @AuraEnabled(cacheable=true)
        public static list<Transaction_Entry__c> getTransactionDetails(String recordKey, Date startDate, Date endDate){
    
    
            List<Transaction_Entry__c> transactionList = [SELECT Id, Name, Amount__c, Type__c, Status__c, CreatedDate FROM Transaction_Entry__c
                                                    WHERE Status__c != 'Cancelled' AND Contacts__c =: recordKey AND CreatedDate >= :startDate AND CreatedDate <= :endDate
                                                    ORDER BY CreatedDate DESC];
            System.debug(transactionList);
            return transactionList;
        }
    }
    
