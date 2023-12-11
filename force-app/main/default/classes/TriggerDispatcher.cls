/**
* @author        Rey Austral
* @date          1.1.2019   
* @description   Class primarily responsible in handling trigger execution per object.
* @revision(s)
*/
public class TriggerDispatcher {
    
    /**
    * @author        Rey Austral
    * @date          1.1.2019         
    * @description   Call this method from your trigger, passing in an instance of a trigger handler which implements ITriggerHandler.
    *                This method will fire the appropriate methods on the handler depending on the trigger context.
    * @revision(s)
    */
    public static void Run(ITriggerHandler handler) {        
        
        // Before trigger logic
        if (Trigger.IsBefore) {        
            if (Trigger.IsInsert)
                handler.BeforeInsert(trigger.new);
            
            if (Trigger.IsUpdate)
                handler.BeforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
            if (Trigger.IsDelete)
                handler.BeforeDelete(trigger.old, trigger.oldMap);
        }
        
        // After trigger logic
        if (Trigger.IsAfter) {
            if (Trigger.IsInsert)
                handler.AfterInsert(trigger.new, trigger.newMap);
            
            if (Trigger.IsUpdate)
                handler.AfterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            
            if (trigger.IsDelete)
                handler.AfterDelete(trigger.old, trigger.oldMap);
        }
    }
}