public with sharing class transactionTriggerHandler {
    public static void updateAccountBalance(List<Transaction_Entry__c> transactions) {
        List<Acc__c> accountsToUpdate = new List<Acc__c>();
        Map<Id, Acc__c> accountsMap = new Map<Id, Acc__c>();

        for (Transaction_Entry__c trans : transactions) {
            if (accountsMap.containsKey(trans.Account_b__c)) {
                Acc__c acc = accountsMap.get(trans.Account_b__c);
                if (trans.Type__c == 'Credit') {
                    acc.Balance__c += trans.Amount__c;
                } else if (trans.Type__c == 'Debit') {
                    acc.Balance__c -= trans.Amount__c;
                }
                accountsMap.put(trans.Account_b__c, acc);
            } else {
                Acc__c acc = [SELECT Id, Balance__c FROM Acc__c WHERE Id = :trans.Account_b__c LIMIT 1];
                if (trans.Type__c == 'Credit') {
                    acc.Balance__c += trans.Amount__c;
                } else if (trans.Type__c == 'Debit') {
                    acc.Balance__c -= trans.Amount__c;
                }
                accountsMap.put(trans.Account_b__c, acc);
            }
        }

        accountsToUpdate.addAll(accountsMap.values());
        update accountsToUpdate;
    }

    public static void adjustBalanceOnTransaction(List<Transaction_Entry__c> transList) {
        Set<Id> contactIds = new Set<Id>();
        for (Transaction_Entry__c trans : transList) {
            contactIds.add(trans.Contacts__c);
        }

        // Query related Contacts
        Map<Id, Contact__c> contactsMap = new Map<Id, Contact__c>([SELECT Id, Available__c, Status__c FROM Contact__c WHERE Id IN :contactIds]);

        for (Transaction_Entry__c trans : transList) {
            Contact__c con = contactsMap.get(trans.Contacts__c);
            if (con != null && con.Status__c == 'Active') {
                if (trans.Type__c == 'Debit') {
                    if (con.Available__c >= trans.Amount__c) {
                        con.Available__c -= trans.Amount__c;
                    } else {
                        trans.addError('Insufficient balance for debit transaction.');
                    }
                } else if (trans.Type__c == 'Credit') {
                    con.Available__c += trans.Amount__c;
                }
            }
        }
        update contactsMap.values();
    }

    public static void validateContactStatus(List<Transaction_Entry__c> transList) {
        Set<Id> contactIds = new Set<Id>();
        for (Transaction_Entry__c trans : transList) {
            contactIds.add(trans.Contacts__c);
        }

        // Query related Contacts
        Map<Id, Contact__c> contactsMap = new Map<Id, Contact__c>([SELECT Id, Status__c FROM Contact__c WHERE Id IN :contactIds]);

        for (Transaction_Entry__c trans : transList) {
            Contact__c con = contactsMap.get(trans.Contacts__c);
            if (con != null && con.Status__c != 'Active') {
                trans.addError('Transactions cannot be created for deactivated contacts.');
            }
        }
    }

    public static void adjustBalanceOnCancellation(List<Transaction_Entry__c> transList){
        Set<Id> contactIds = new Set<Id>();
        for (Transaction_Entry__c trans : transList) {
            contactIds.add(trans.Contacts__c);
        }
        
        // Query related Contacts
        Map<Id, Contact__c> contactsMap = new Map<Id, Contact__c>([SELECT Id, Available__c FROM Contact__c WHERE Id IN :contactIds]);
        
        for (Transaction_Entry__c trans : transList) {
            // Query the related Transaction Entry
            Transaction_Entry__c transEntry = [SELECT Id, Status__c, Amount__c, Contacts__c FROM Transaction_Entry__c WHERE Id = :trans.Id LIMIT 1];
            
            if (transEntry.Status__c == 'Cancelled') {
                Contact__c con = contactsMap.get(transEntry.Contacts__c);
                if (con != null) {
                    con.Available__c += transEntry.Amount__c;
                    update con;
                }
            }
        }
    }

    public static void beforeInsert(List<Transaction_Entry__c> newEntries, Map<Id, Transaction_Entry__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Transaction_Entry__c te : newEntries) {
            if (te.Contacts__c != null) {
                contactIds.add(te.Contacts__c);
            }
        }

        if (!contactIds.isEmpty()) {
            Map<Id, Contact__c> contactMap = new Map<Id, Contact__c>([SELECT Id, Available__c, Status__c FROM Contact__c WHERE Id IN :contactIds]);
            for (Transaction_Entry__c te : newEntries) {
                if (te.Contacts__c != null) {
                    Contact__c con = contactMap.get(te.Contacts__c);
                    if (con != null) {
                        if (con.Status__c == 'Inactive') {
                            te.addError('Cannot create transactions for deactivated contacts.');
                        }
                        if (te.Type__c == 'Debit' && con.Available__c < te.Amount__c) {
                            te.addError('Insufficient balance.');
                        }
                    }
                }
            }
        }
    }

    public static void afterInsert(List<Transaction_Entry__c> newEntries, Map<Id, Transaction_Entry__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Transaction_Entry__c te : newEntries) {
            if (te.Contacts__c != null) {
                contactIds.add(te.Contacts__c);
            }
        }
    
        if (!contactIds.isEmpty()) {
            Map<Id, Contact__c> contactMap = new Map<Id, Contact__c>([SELECT Id, Available__c, Email__c, Status__c FROM Contact__c WHERE Id IN :contactIds]);
            List<Contact__c> contactsToUpdate = new List<Contact__c>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
            for (Transaction_Entry__c te : newEntries) {
                if (te.Contacts__c != null) {
                    Contact__c con = contactMap.get(te.Contacts__c);
                    if (con.Status__c == 'Active') {
                        if (te.Type__c == 'Debit') {
                            con.Available__c -= te.Amount__c;
                        } else if (te.Type__c == 'Credit') {
                            con.Available__c += te.Amount__c;
                        }
                        contactsToUpdate.add(con);
    
                        // Prepare and send email
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] { con.Email__c });
                        email.setSubject('Transaction Notification');
                        email.setPlainTextBody('Your A/c ' + con.Id + ' is ' + te.Type__c.toLowerCase() + 'ed by Rs. ' + te.Amount__c + ' on ' + te.Transaction_Date__c + '. Available Bal: Rs. ' + con.Available__c + '.');
                        emails.add(email);
                    }
                }
            }
    
            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
            }
    
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
      
}






