trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete) {
   /* if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            OpportunityTriggerHandler.handleOpportunityChanges(Trigger.new, Trigger.oldMap);
        }
    
        if (Trigger.isUpdate) {
            // Handle the case where the Opportunity's AccountId is changed
            Set<Id> oldAccountIds = new Set<Id>();
            for (Opportunity opp : Trigger.old) {
                oldAccountIds.add(opp.AccountId);
            }
    
            Set<Id> newAccountIds = new Set<Id>();
            for (Opportunity opp : Trigger.new) {
                newAccountIds.add(opp.AccountId);
            }
    
            Set<Id> affectedAccountIds = new Set<Id>(oldAccountIds);
            affectedAccountIds.addAll(newAccountIds);
    
            OpportunityTriggerHandler.handleAccountChange(affectedAccountIds);
        }
    
        if (Trigger.isDelete) {
            Set<Id> deletedAccountIds = new Set<Id>();
            for (Opportunity opp : Trigger.old) {
                deletedAccountIds.add(opp.AccountId);
            }
    
            OpportunityTriggerHandler.handleAccountChange(deletedAccountIds);
        }
    } */

    /*Update Account Total_Opportunity_Amount__c based on Total Amount of Related Opportunities.*/
    if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        OpportunityTriggerHandler.updateAccountTotalOppFields(trigger.new, null);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        OpportunityTriggerHandler.updateAccountTotalOppFields(trigger.new, trigger.oldMap);
    }
    else if(trigger.isAfter && trigger.isDelete){
        OpportunityTriggerHandler.updateAccountTotalOppFields(trigger.old, null);
    }
}
