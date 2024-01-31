/*
“I have a custom checkbox field IsPrimary__c in the Contact object, 
and a custom field CountOfPrimaryContacts__c in the Account object. 
I would like to increment the CountOfPrimaryContacts__c field on the Account object
whenever a Contact is created or updated with IsPrimary__c set to true.
Could you guide me on how to achieve this functionality?”
*/
public with sharing class ContactTriggerHandler {
    public static void handleAfterInsertUpdate
    (List<Contact> newContacts, Map<Id, Contact> oldMap) {
        // Collect all account Ids from the contacts
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            accountIds.add(con.AccountId);
        }

        // Fetch the count of primary contacts for these accounts
        List<AggregateResult> results = [
            SELECT AccountId, COUNT(Id) cnt
            FROM Contact
            WHERE AccountId IN :accountIds AND Is_Primary__c = true
            GROUP BY AccountId
        ];

        // Prepare the accounts for update
        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult result : results) {
            Id accountId = (Id)result.get('AccountId');
            Integer count = (Integer)result.get('cnt');
            accountsToUpdate.add(new Account(Id = accountId, CountOfPrimaryContacts__c = count));
        }

        // Update the accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}


