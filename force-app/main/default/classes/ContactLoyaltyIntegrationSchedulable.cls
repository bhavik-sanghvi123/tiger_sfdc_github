global class ContactLoyaltyIntegrationSchedulable implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ContactLoyaltyIntegrationMonthlyBatch b = new ContactLoyaltyIntegrationMonthlyBatch ();
       	database.executebatch(b,200);
    }
   
}