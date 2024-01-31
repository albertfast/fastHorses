trigger ContactTrigger on Contact (after insert, after update) {
    ContactTriggerHandler.handleAfterInsertUpdate(Trigger.new, Trigger.oldMap);
}
