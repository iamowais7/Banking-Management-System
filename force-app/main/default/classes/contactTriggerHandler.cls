public with sharing class contactTriggerHandler {
    public static void syncContactStatus(List<Contact__c>conList, Map<Id, Contact__c>oldConMap){
        //Set of Contacts with account ids
        Set<Id> setOfConWithAccIds = new Set<Id>();
        for(Contact__c con: conList){
            setOfConWithAccIds.add(con.Id);
        }
        
        List<Acc__c> accList = [SELECT Id, Status__c FROM Acc__c WHERE Id IN: setOfConWithAccIds];
        System.debug(accList);
        
        for(Contact__c con: conList){
            for(Acc__c acc : accList){
                //If contact status is null and account status is not null then fill the contact status
            	if(con.Status__c == null && acc.Status__c != null){
                	con.Status__c = acc.Status__c;
                }
            }
        }
    }

    public static void preventDeleteContactOnTransactionEntry(List<Contact__c>oldConList){

        //set of old contact Id's
        Set<Id> conId = new Set<Id>();

        for(Contact__c con: oldConList){

            conId.add(con.Id);
        }

        //List of transaction entry with respect to contact Id
        Map<Id, Id> transactionEntryMap = new Map<Id, Id>();
        for(Transaction_Entry__c tran : [SELECT Id, Contacts__c FROM Transaction_Entry__c WHERE Contacts__c IN: conId]){

            transactionEntryMap.put(tran.Contacts__c, tran.Id);
        }

        for(Contact__c ConList: oldConList){
            
            //If the contact have transaction list
            if(transactionEntryMap.containsKey(conlist.Id)){
                ConList.addError('Cannot Delete Contact Because Transaction Entry Is Associated With It');
            }
        }
    }






















}