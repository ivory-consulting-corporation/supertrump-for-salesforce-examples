global class SuperTRUMPDefaultValues implements IST.SuperTRUMPInitialState.InitialValueFactory {
 
    global List<IST.SuperTRUMPInitialState.CalcFieldUpdate> getInitialValues(IST.SuperTRUMPInitialState.Context ctx){
        List<IST.SuperTRUMPInitialState.CalcFieldUpdate> calcUpdates
            = new List<IST.SuperTRUMPInitialState.CalcFieldUpdate>();
        IST__SuperTRUMP_Pricing_Quote__c quote = (IST__SuperTRUMP_Pricing_Quote__c) ctx.getQuoteObject();

        String oppName;
        if (quote.IST__Opportunity__c != null){
            Opportunity opp;
            for (Opportunity o : [SELECT Id, Name FROM Opportunity WHERE Id = :quote.IST__Opportunity__c]){
                opp = o;
            }
            if (opp != null){
                oppName = opp.Name;
            }
        }
        if (String.isEmpty(oppName)){
            oppName = 'Default';
        }

        if (quote.IST__Template__c != null){
            IST__SuperTRUMP_Template__c template;
            for (IST__SuperTRUMP_Template__c t : [SELECT Id, Name FROM IST__SuperTRUMP_Template__c
                WHERE Id = :quote.IST__Template__c]
            ) {
                template = t;
            }
            if (template != null){
                if (template.Name == 'Lease.tem'){
                    IST.SuperTRUMPInitialState.CalcFieldUpdate calcUpdate
                        = new IST.SuperTRUMPInitialState.CalcFieldUpdate();
                    // path to the data in the SuperTRUMP calculation engine
                    calcUpdate.setPath('Opportunity.Quotes.Quote[1].Transaction.TransactionDescription');
                    calcUpdate.setValue('Lease - ' + oppName);
                    // Higher numerical values set first in the calc engine.
                    calcUpdate.setPriority(0);
                    calcUpdates.add(calcUpdate);
                }
                if (template.Name == 'Loan.tem'){
                    IST.SuperTRUMPInitialState.CalcFieldUpdate calcUpdate
                        = new IST.SuperTRUMPInitialState.CalcFieldUpdate();
                    // path to the data in the SuperTRUMP calculation engine
                    calcUpdate.setPath('Opportunity.Quotes.Quote[1].Transaction.TransactionDescription');
                    calcUpdate.setValue('Loan - ' + oppName);
                    // Higher numerical values set first in the calc engine.
                    calcUpdate.setPriority(0);
                    calcUpdates.add(calcUpdate);
                }
            }
        }
     
        return calcUpdates;
    }
}
