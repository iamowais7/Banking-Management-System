public with sharing class miniStatementController {
    @AuraEnabled(cacheable=true)
    public static list<DataTableWrapper> getTransactionDetails(Id recordKey, Integer recordLimit){






        List<Transaction_Entry__c> transactionList = [SELECT Id, Name, Amount__c, Type__c, Status__c,Transaction_Date__c, Contacts__c FROM Transaction_Entry__c
                                                WHERE Status__c != 'Cancelled' AND Contacts__c =: recordKey 
                                                ORDER BY Transaction_Date__c DESC  LIMIT :recordLimit];


        //Data Wrapper Object
        List<DataTableWrapper> response = new List<DataTableWrapper>();
        for(Transaction_Entry__c trx: transactionList){


            DataTableWrapper obj = new DataTableWrapper();
            obj.trxId = trx.Id;
            obj.name = trx.Name;
            obj.nameUrl = '/'+trx.Id;
            obj.amount = trx.Amount__c;
            obj.type = trx.Type__c;
            obj.status = trx.Status__c;
           // obj.Transaction_Date__c = trx.Transaction_Date__c;
            obj.contact = trx.Contacts__c;
            response.add(obj);
        }
        return response;
    }


    private class DataTableWrapper {
        @AuraEnabled public String trxId;
        @AuraEnabled public String name;
        @AuraEnabled public String nameUrl;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String type;
        @AuraEnabled public String status;
       // @AuraEnabled public Date Transaction_Date__c;
        @AuraEnabled public Id contact;
        
    }

}