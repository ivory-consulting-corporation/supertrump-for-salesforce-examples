@isTest
private class SuperTRUMPDefaultValuesTests
{
    private static Opportunity createOpportunity()
    {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            Amount = 1000000.00,
            StageName = 'Lead',
            CloseDate = Date.today().addYears(1)
        );
        Database.insert(opp);
        return opp;
    }

    private static IST__SuperTRUMP_Template__c createLeaseTemplate()
    {
        IST__SuperTRUMP_Template__c template = new IST__SuperTRUMP_Template__c();
        template.Name = 'Lease.tem';
        Database.insert(template);
        return template;
    }

    private static IST__SuperTRUMP_Template__c createLoanTemplate()
    {
        IST__SuperTRUMP_Template__c template = new IST__SuperTRUMP_Template__c();
        template.Name = 'Loan.tem';
        Database.insert(template);
        return template;
    }

    private static IST__SuperTRUMP_Pricing_Quote__c createPricingQuote(String opportunityId, String templateId)
    {
        IST__SuperTRUMP_Pricing_Quote__c pq = new IST__SuperTRUMP_Pricing_Quote__c();
        pq.IST__Commencement__c = Date.today().addDays(10);
        pq.IST__Cost__c = Decimal.valueOf('1000000.00');
        pq.IST__Delivery_Date__c = pq.IST__Commencement__c;
        pq.IST__Description__c = 'Pricing Quote';
        pq.IST__Is_Synchronized__c = true;
        pq.IST__Opportunity__c = opportunityId;
        pq.IST__Payment__c = Decimal.valueOf('18000.00');
        pq.IST__stExternalID__c = 'Z10001transaction';
        pq.IST__Template__c = templateId;
        Database.insert(pq);

        return pq;
    }

    static testMethod void testDefaultValueForLease()
    {
        Opportunity opp = createOpportunity();
        IST__SuperTRUMP_Template__c template = createLeaseTemplate();
        IST__SuperTRUMP_Pricing_Quote__c pq = createPricingQuote(opp.Id, template.Id);
        IST.SuperTRUMPInitialState.Context ctx = new IST.SuperTRUMPInitialState.Context(pq);
        SuperTRUMPDefaultValues defvals = new SuperTRUMPDefaultValues();
        List<IST.SuperTRUMPInitialState.CalcFieldUpdate> calcUpdates = defvals.getInitialValues(ctx);
        Integer calcUpdatesSz = calcUpdates.size();
        System.assertequals(1, calcUpdatesSz);
    }

    static testMethod void testDefaultValueForLoan()
    {
        Opportunity opp = createOpportunity();
        IST__SuperTRUMP_Template__c template = createLoanTemplate();
        IST__SuperTRUMP_Pricing_Quote__c pq = createPricingQuote(opp.Id, template.Id);
        IST.SuperTRUMPInitialState.Context ctx = new IST.SuperTRUMPInitialState.Context(pq);
        SuperTRUMPDefaultValues defvals = new SuperTRUMPDefaultValues();
        List<IST.SuperTRUMPInitialState.CalcFieldUpdate> calcUpdates = defvals.getInitialValues(ctx);
        Integer calcUpdatesSz = calcUpdates.size();
        System.assertequals(1, calcUpdatesSz);
    }
}