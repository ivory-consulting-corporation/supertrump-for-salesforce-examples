public with sharing class SuperTRUMPInstaller {
    
    public static void installObjectRelationships(){
        List<IST__SuperTRUMP_Object_Relationships__c> toInsert = new List<IST__SuperTRUMP_Object_Relationships__c>();
        List<Map<String, String>> relationships = new List<Map<String, String>>{
            new Map<String, String>{
                'name' => 'SuperTRUMP_Quote__c',
                'childToMasterFieldName' => 'Quote__c',
                'childToMasterRelationshipName' => 'Quote__r'
            }
        };

        for (Map<String, String> entry: relationships){
            String name = entry.get('name');
            String childToMasterFieldName = entry.get('childToMasterFieldName');
            String childToMasterRelationshipName = entry.get('childToMasterRelationshipName');
            IST__SuperTRUMP_Object_Relationships__c objRel = new IST__SuperTRUMP_Object_Relationships__c();
            objRel.Name = name;
            objRel.IST__Child_To_Master_Field_Name__c = childToMasterFieldName; 
            objRel.IST__Child_To_Master_Relationship_Name__c = childToMasterRelationshipName;
            toInsert.add(objRel);
        }

        List<IST__SuperTRUMP_Object_Relationships__c> storedRelationships = [SELECT
                Name,
                IST__Child_To_Master_Field_Name__c,
                IST__Child_To_Master_Relationship_Name__c
            FROM IST__SuperTRUMP_Object_Relationships__c
            LIMIT 10000];
        
        Integer idx = 0;
        while (idx < toInsert.size()){
            IST__SuperTRUMP_Object_Relationships__c relationship = toInsert[idx];
            Boolean isFound = false;
            for (Integer sIdx = 0; sIdx < storedRelationships.size(); ++sIdx){
                IST__SuperTRUMP_Object_Relationships__c m = storedRelationships[sIdx];
                if (m.Name == relationship.Name
                    && m.IST__Child_To_Master_Field_Name__c == relationship.IST__Child_To_Master_Field_Name__c
                    && m.IST__Child_To_Master_Relationship_Name__c == relationship.IST__Child_To_Master_Relationship_Name__c
                ){
                    toInsert.remove(idx);
                    storedRelationships.remove(sIdx);
                    isFound = true;
                    break;
                }
            }
            if (!isFound){
                System.debug('Object Relationship for ' + relationship.Name + '.' + relationship.IST__Child_To_Master_Field_Name__c + '(' + relationship.IST__Child_To_Master_Relationship_Name__c + ') was NOT found.');
                ++idx;
            }
        }

        if (toInsert.size() > 0){
            System.debug(toInsert.size() + ' new object relationships being created.');
            if (!Schema.sObjectType.IST__SuperTRUMP_Object_Relationships__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Object_Relationships__c.fields.Name.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Object_Relationships__c.fields.IST__Child_To_Master_Field_Name__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Object_Relationships__c.fields.IST__Child_To_Master_Relationship_Name__c.isCreateable())
            {
                throw new MappingException('You do not have permission to create an object of type IST__SuperTRUMP_Object_Relationships__c.');
            }
            Database.insert(toInsert, true);
        }
    }
    
    public static void installMappings(){
        List<IST__SuperTRUMP_Mapping__c> toInsert = new List<IST__SuperTRUMP_Mapping__c>();

        toInsert.add(
            new IST__SuperTRUMP_Mapping__c(
                IST__Allow_Salesforce_Changes__c = false,
                IST__External_Binding__c = 'supertrump_pricing_quote__c__quotestatus__c',
                IST__IsSynch__c = false,
                IST__IsSynch_In__c = false,
                IST__SF_Field_Name__c = 'Quote_Status__c',
                IST__SF_Master_Object_Name__c = 'SuperTRUMP_Quote__c',
                IST__SF_Object_Level__c = '1',
                IST__SF_Object_Name__c = 'SuperTRUMP_Quote__c',
                IST__SOR__c = 'SF',
                IST__ST_Field_Name__c = 'Opportunity.Quotes.Quote[].Transaction.QuoteStatus',
                IST__ST_Update_Priority__c = 0
            )
        );

        Map<String, String> quoteSyncMappings = new Map<String, String>{
            'Name' => 'Opportunity.Quotes.Quote[].Transaction.ZephyrData.Quote.CompositeQuoteNumber'
        };

        for (String fieldName : quoteSyncMappings.keySet()){
            String objName = 'SuperTRUMP_Quote__c';
            String calcField = quoteSyncMappings.get(fieldName);
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = false,
                    IST__IsSynch_In__c = true,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Master_Object_Name__c = objName,
                    IST__SF_Object_Level__c = '1',
                    IST__SF_Object_Name__c = objName,
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0
                )
            );
        }
        
        Map<String, String> quoteMappings = new Map<String, String>{
            'Cost__c' => 'Opportunity.Quotes.Quote[].Transaction.AssetCost',
            'Quote_Name__c' => 'Opportunity.Quotes.Quote[].Transaction.TransactionDescription',
            'Commencement__c' => 'Opportunity.Quotes.Quote[].Transaction.CommencementDate',
            'Finance_Type__c' => 'Opportunity.Quotes.Quote[].Transaction.ZephyrData.FinanceType',
            'Term__c' => 'Opportunity.Quotes.Quote[].Transaction.TermInMonths',
            'Payment__c' => 'Opportunity.Quotes.Quote[].Transaction.AveragePayment',
            'Payment_Timing__c' => 'Opportunity.Quotes.Quote[].Transaction.ZephyrData.PaymentTiming',
            'Periodicity__c' => 'Opportunity.Quotes.Quote[].Transaction.Periodicity',
            'Delivery_Date__c' => 'Opportunity.Quotes.Quote[].Transaction.TransactionStartDate',
            'Residual__c' => 'Opportunity.Quotes.Quote[].Transaction.ResidualAmount',
            'Total_Lending__c' => 'Opportunity.Quotes.Quote[].Transaction.TotalLendingLoans',
            'Takedown__c' => 'Opportunity.Quotes.Quote[].Transaction.TransactionStartDate',
            'Lending_Rate__c' => 'Opportunity.Quotes.Quote[].Transaction.LendingRate',
            'Balloon__c' => 'Opportunity.Quotes.Quote[].Transaction.Balloon',
            'Mode__c' => 'Opportunity.Quotes.Quote[].Transaction.Mode',
            'Lessor_FAS__c' => 'Opportunity.Quotes.Quote[].Transaction.Results.LessorAccountingMethod',
            'IRR_NPT__c' => 'Opportunity.Quotes.Quote[].Transaction.Yields.Yield[name=IRR PTCF (per)].NPT',
            'MISF_NAT__c' => 'Opportunity.Quotes.Quote[].Transaction.Yields.Yield[name=MISF (per)].NAT',
            'Rent_IBR__c' => 'Opportunity.Quotes.Quote[].Transaction.PVs.PV[name=Rent].ValuePercent'
        };

        for (String fieldName : quoteMappings.keySet()){
            String objName = 'SuperTRUMP_Quote__c';
            String calcField = quoteMappings.get(fieldName);
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = true,
                    IST__IsSynch_In__c = false,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Master_Object_Name__c = objName,
                    IST__SF_Object_Level__c = '1',
                    IST__SF_Object_Name__c = objName,
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0
                )
            );
        }

        Map<String, String> assetMappings = new Map<String, String>{
            'Description__c' => 'Opportunity.Quotes.Quote[].Transaction.Assets.Asset[].Description',
            'Cost__c' => 'Opportunity.Quotes.Quote[].Transaction.Assets.Asset[].Cost',
            'Delivery__c' => 'Opportunity.Quotes.Quote[].Transaction.Assets.Asset[].DeliveryDate',
            'Residual_Amount__c' => 'Opportunity.Quotes.Quote[].Transaction.Assets.Asset[].Residual',
            'Residual_Percent__c' => 'Opportunity.Quotes.Quote[].Transaction.Assets.Asset[].ResidualAsPercentOfCost'
        };

        for (String fieldName : assetMappings.keySet()){
            String objName = 'SuperTRUMP_Quote_Asset__c';
            String parentObjName = 'SuperTRUMP_Quote__c';
            String calcField = assetMappings.get(fieldName);
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = true,
                    IST__IsSynch_In__c = false,
                    IST__SF_Object_Name__c = objName,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Parent_Name__c = parentObjName,
                    IST__SF_Master_Object_Name__c = parentObjName,
                    IST__SF_Object_Level__c = '2',
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0
                )
            );
        }

        Map<String, String> rentMappings = new Map<String, String>{
            'Description__c' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].Description',
            'Advance_Payment__c' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AdvancePayment',
            'Total_Payments__c' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].SumOfPayments',
            'Number_Of_Payments__c' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].NumberOfPayments'
        };

        for (String fieldName : rentMappings.keySet()){
            String objName = 'SuperTRUMP_Quote_Rent__c';
            String parentObjName = 'SuperTRUMP_Quote__c';
            String calcField = rentMappings.get(fieldName);
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = true,
                    IST__IsSynch_In__c = false,
                    IST__SF_Object_Name__c = objName,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Parent_Name__c = parentObjName,
                    IST__SF_Master_Object_Name__c = parentObjName,
                    IST__SF_Object_Level__c = '2',
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0
                )
            );
        }

        Map<String, String> loanMappings = new Map<String, String>{
            'Description__c' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].Description',
            'Start_Date__c' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].FirstStartAccrual',
            'Advance_Payment__c' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AdvancePayment',
            'Total_Payments__c' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].SumOfPayments',
            'Total_Funding__c' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].SumOfFundings',
            'Number_Of_Payments__c' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].NumberOfPayments'
        };

        for (String fieldName : loanMappings.keySet()){
            String objName = 'SuperTRUMP_Quote_Loan__c';
            String parentObjName = 'SuperTRUMP_Quote__c';
            String calcField = loanMappings.get(fieldName);
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = true,
                    IST__IsSynch_In__c = false,
                    IST__SF_Object_Name__c = objName,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Parent_Name__c = parentObjName,
                    IST__SF_Master_Object_Name__c = parentObjName,
                    IST__SF_Object_Level__c = '2',
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0
                )
            );
        }

        Map<String, String> incomeFeeMappings = new Map<String, String>{
            'Description__c' => 'Opportunity.Quotes.Quote[].Transaction.IncomeFees.IncomeFee[*].IncomeData.Description',
            'Amount__c' => 'Opportunity.Quotes.Quote[].Transaction.IncomeFees.IncomeFee[*].IncomeData.Amount',
            'Percent__c' => 'Opportunity.Quotes.Quote[].Transaction.IncomeFees.IncomeFee[*].IncomeData.PercentOfTotalCost',
            'Paid_Date__c' => 'Opportunity.Quotes.Quote[].Transaction.IncomeFees.IncomeFee[*].IncomeData.FeeDate'
        };

        for (String fieldName : incomeFeeMappings.keySet()){
            String objName = 'SuperTRUMP_Quote_Income_Fee__c';
            String parentObjName = 'SuperTRUMP_Quote__c';
            String calcField = incomeFeeMappings.get(fieldName);
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = true,
                    IST__IsSynch_In__c = false,
                    IST__SF_Object_Name__c = objName,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Parent_Name__c = parentObjName,
                    IST__SF_Master_Object_Name__c = parentObjName,
                    IST__SF_Object_Level__c = '2',
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0
                )
            );
        }

        Map<String, String> expenseFeeMappings = new Map<String, String>{
            'Description__c' => 'Opportunity.Quotes.Quote[].Transaction.ExpenseFees.ExpenseFee[*].ExpenseData.Description',
            'Amount__c' => 'Opportunity.Quotes.Quote[].Transaction.ExpenseFees.ExpenseFee[*].ExpenseData.Amount',
            'Percent__c' => 'Opportunity.Quotes.Quote[].Transaction.ExpenseFees.ExpenseFee[*].ExpenseData.PercentOfTotalCost',
            'Paid_Date__c' => 'Opportunity.Quotes.Quote[].Transaction.ExpenseFees.ExpenseFee[*].ExpenseData.FeeDate'
        };

        for (String fieldName : expenseFeeMappings.keySet()){
            String objName = 'SuperTRUMP_Quote_Expense_Fee__c';
            String parentObjName = 'SuperTRUMP_Quote__c';
            String calcField = expenseFeeMappings.get(fieldName);
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = true,
                    IST__IsSynch_In__c = false,
                    IST__SF_Object_Name__c = objName,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Parent_Name__c = parentObjName,
                    IST__SF_Master_Object_Name__c = parentObjName,
                    IST__SF_Object_Level__c = '2',
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0
                )
            );
        }
        
        List<IST__SuperTRUMP_Mapping__c> storedMappings = [SELECT
                IST__SF_Object_Name__c,
                IST__SF_Field_Name__c,
                IST__ST_Field_Name__c
            FROM IST__SuperTRUMP_Mapping__c
            WHERE IST__SF_Master_Object_Name__c = 'SuperTRUMP_Quote__c'
            LIMIT 10000];
        
        Integer idx = 0;
        while (idx < toInsert.size()){
            IST__SuperTRUMP_Mapping__c mapping = toInsert[idx];
            Boolean isFound = false;
            for (Integer sIdx = 0; sIdx < storedMappings.size(); ++sIdx){
                IST__SuperTRUMP_Mapping__c m = storedMappings[sIdx];
                if (m.IST__SF_Object_Name__c == mapping.IST__SF_Object_Name__c
                    && m.IST__SF_Field_Name__c == mapping.IST__SF_Field_Name__c
                ){
                    toInsert.remove(idx);
                    storedMappings.remove(sIdx);
                    isFound = true;
                    break;
                }
            }
            if (!isFound){
                System.debug('Mapping for ' + mapping.IST__SF_Object_Name__c + '.' + mapping.IST__SF_Field_Name__c + ' was NOT found.');
                ++idx;
            }
        }
        if (toInsert.size() > 0){
            System.debug(toInsert.size() + ' new mappings being created.');
            if (!Schema.sObjectType.IST__SuperTRUMP_Mapping__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__SF_Object_Name__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__SF_Field_Name__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__SF_Parent_Name__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__ST_Field_Name__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__SF_Object_Level__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__IsSynch__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__IsSynch_In__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__SOR__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__SF_Master_Object_Name__c.isCreateable()
                || !Schema.sObjectType.IST__SuperTRUMP_Mapping__c.fields.IST__Allow_Salesforce_Changes__c.isCreateable())
            {
                throw new MappingException('You do not have permission to create an object of type IST__SuperTRUMP_Mapping__c.');
            }
            Database.insert(toInsert, true);
        }
    }
    
    public class MappingException extends Exception {}
}