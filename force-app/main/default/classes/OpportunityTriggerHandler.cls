/*Whenever an opportunity is created, updated, or deleted, if the StageName is 'Closed Won', 
update the Total_Opportunity_Amount__c field with the sum of amounts for opportunities that are not 'Closed Won', 
and regardless of the stage name, update the Total_Opportunity_Count__c */
public with sharing class OpportunityTriggerHandler {
   /* private static Boolean isExecuting = false;
    public static void handleOpportunityChanges(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
      if (!isExecuting) {
        isExecuting = true;
      Set<Id> accountIds = new Set<Id>();
      for (Opportunity opp : newOpportunities) {
          accountIds.add(opp.AccountId);
      }
  
      List<AggregateResult> countResults = [
          SELECT AccountId, COUNT(Id) opptCount
          FROM Opportunity 
          WHERE AccountId IN :accountIds
          GROUP BY AccountId
      ];
  
      List<AggregateResult> amountResults = [
          SELECT AccountId, SUM(Amount) oppAmount 
          FROM Opportunity 
          WHERE AccountId IN :accountIds
          AND StageName != 'Closed Won'
          GROUP BY AccountId
      ];
  
      List<Account> accountsToUpdate = new List<Account>();
      for (AggregateResult countResult : countResults) {
          Id accountId = (Id) countResult.get('AccountId');
          Integer count = (Integer) countResult.get('opptCount');
  
          Decimal amountSum = 0;
          for (AggregateResult amountResult : amountResults) {
              if ((Id) amountResult.get('AccountId') == accountId) {
                  amountSum = (Decimal) amountResult.get('oppAmount');
                  break;
              }
          }
  
          accountsToUpdate.add(new Account(
              Id = accountId,
              Total_Opportunity_Count__c = count,
              Total_Opportunity_Amount__c = amountSum
          ));
      }
  
      if (!accountsToUpdate.isEmpty()) {
          update accountsToUpdate;
      }
  
      isExecuting = false;
          }
  }
  
  public static void handleAccountChange(Set<Id> affectedAccountIds) {
      List<Account> accountsToUpdate = new List<Account>();
      for (Id accountId : affectedAccountIds) {
          Integer totalCount = [SELECT COUNT() FROM Opportunity WHERE AccountId = :accountId];
          Decimal totalAmount = (Decimal) [
              SELECT SUM(Amount)
              FROM Opportunity 
              WHERE AccountId = :accountId AND StageName != 'Closed Won'
          ][0].get('expr0');
  
          accountsToUpdate.add(new Account(
              Id = accountId,
              Total_Opportunity_Count__c = totalCount,
              Total_Opportunity_Amount__c = totalAmount
          ));
      }
  
      if (!accountsToUpdate.isEmpty()) {
          update accountsToUpdate;
      }
  }
    */

    /* Update Account Total_Opportunity_Amount__c and Total_Opportunity_Count__c
    based on Total Amount of Related Opportunities. */
public static void updateAccountTotalOppFields(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
    Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
    Set<Id> accIds = new Set<Id>(); // Set to store parent account Ids

    // This part works when opportunity account will be changed
    if (!oppList.isEmpty()) {
        for (Opportunity newOpp : oppList) {
            if (oldMap != null) {
                Opportunity oldOpp = oldMap.get(newOpp.Id);
                if (oldOpp.AccountId != newOpp.AccountId) {
                    accIds.add(oldOpp.AccountId);
                    accIds.add(newOpp.AccountId);
                } else if (oldOpp.Amount != newOpp.Amount || oldOpp.StageName != newOpp.StageName) {
                    accIds.add(newOpp.AccountId);
                }
            } else {
                accIds.add(newOpp.AccountId);
            }
        }
    }

    if (!accIds.isEmpty()) {
        Map<Id, Double> oppTotalAmountMap = new Map<Id, Double>();
        Map<Id, Integer> oppCountMap = new Map<Id, Integer>();

        List<Opportunity> opptyList = [SELECT Id, AccountId, Amount, StageName FROM Opportunity WHERE AccountId IN :accIds];

        if (!opptyList.isEmpty()) {
            for (Opportunity oppObj : opptyList) {
                if (oppObj.StageName != 'Closed Won') {
                    if (oppTotalAmountMap.containsKey(oppObj.AccountId)) {
                        oppTotalAmountMap.put(oppObj.AccountId, oppTotalAmountMap.get(oppObj.AccountId) + oppObj.Amount);
                        oppCountMap.put(oppObj.AccountId, oppCountMap.get(oppObj.AccountId) + 1);
                    } else {
                        oppTotalAmountMap.put(oppObj.AccountId, oppObj.Amount);
                        oppCountMap.put(oppObj.AccountId, 1);
                    }
                }
            }
        }

        for (Id ids : accIds) {
            if (oppTotalAmountMap.containsKey(ids)) {
                Double totalAmount = oppTotalAmountMap.get(ids);
                Integer totalCount = oppCountMap.containsKey(ids) ? oppCountMap.get(ids) : 0;

                if (totalAmount != null && totalAmount > 0) {
                    accountsToUpdate.put(ids, new Account(Id = ids, Total_Opportunity_Amount__c = totalAmount, Total_Opportunity_Count__c = totalCount));
                    System.debug('TotalCount: ' + totalCount);
                    System.debug('OppCountMap: ' + oppCountMap);
                } else {
                    accountsToUpdate.put(ids, new Account(Id = ids, Total_Opportunity_Amount__c = null, Total_Opportunity_Count__c = null));
                }
            } else {
                accountsToUpdate.put(ids, new Account(Id = ids, Total_Opportunity_Amount__c = null, Total_Opportunity_Count__c = null));
            }
        }
    }

    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate.values();
    }
}

    
}

