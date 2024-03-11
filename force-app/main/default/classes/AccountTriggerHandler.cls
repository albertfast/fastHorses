public without sharing class AccountTriggerHandler {
   private static final string STAGE_PROSPECT = 'Prospecting';
   private static final string TYPE_NEW_CUSTOMER = 'New Customer';
    public static void insertAccount(List<Account> newAccList) {
        List<Contact> conList = new List<Contact>();
        List<Opportunity> oppList = new  List<Opportunity>();

        for (Account acc : newAccList) {
            Contact con = new Contact();
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            con.AccountId = acc.Id;
            conList.add(con);

            Opportunity opp = new  Opportunity();
            opp.Name = acc.Name;
            opp.StageName = STAGE_PROSPECT;
            opp.Type = TYPE_NEW_CUSTOMER;
            opp.CloseDate = Date.today().addDays(7);
            opp.Amount = acc.AnnualRevenue;
            opp.AccountId = acc.Id;
            oppList.add(opp);
        }

        if (!conList.isEmpty()) {
            try {
                insert conList;
            } catch (Exception ex) {
                
            }
        }
        if (!oppList.isEmpty()) {
            try {
                insert oppList;
            } catch (Exception ex) {
                
            }
        }
    }
}