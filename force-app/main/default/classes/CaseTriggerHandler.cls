
//This is not working correct!
public with sharing class CaseTriggerHandler {
    public static void countCaseStatus(List<Case> caseList, Map<Id, Case> oldMap) {
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        Set<Id> accIds = new Set<Id>(); // Set to store parent account Ids

        // This part works when Case account will be changed or Case Status is updated
        for (Case newCs : caseList) {
            Id accId = newCs.AccountId;

            if (oldMap != null) {
                Case oldCs = oldMap.get(newCs.Id);
                if (oldCs != null && (oldCs.AccountId != accId || oldCs.Status != newCs.Status)) {
                    accIds.add(accId);
                }
            } else {
                accIds.add(accId);
            }
        }

        if (!accIds.isEmpty()) {
            for (AggregateResult aggResult : [
                SELECT AccountId, Status, COUNT(Id) caseCount
                FROM Case
                WHERE AccountId IN :accIds AND Status IN ('New', 'Working', 'Escalated')
                GROUP BY AccountId, Status
            ]) {
                Id accId = (Id)aggResult.get('AccountId');
                String caseStatus = (String)aggResult.get('Status');
                Integer caseCount = (Integer)aggResult.get('caseCount');

                Account acc = accountsToUpdate.containsKey(accId) ? accountsToUpdate.get(accId) : new Account(Id = accId);

                if (caseStatus == 'New') {
                    acc.Number_Of_New_Cases__c = caseCount;
                } else if (caseStatus == 'Working') {
                    acc.Number_Of_Working_Cases__c = caseCount;
                } else if (caseStatus == 'Escalated') {
                    acc.Number_Of_Escalated_Cases__c = caseCount;
                }

                accountsToUpdate.put(accId, acc);
            }

            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate.values();
            }
        }
    }
}
