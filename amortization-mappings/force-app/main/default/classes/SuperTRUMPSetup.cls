public with sharing class SuperTRUMPSetup {
    
    public static void installObjectRelationships(){
        List<IST__SuperTRUMP_Object_Relationships__c> toInsert = new List<IST__SuperTRUMP_Object_Relationships__c>();
        List<Map<String, String>> relationships = new List<Map<String, String>>{
            new Map<String, String>{
                'name' => 'IST__SuperTRUMP_PQ_Rent__c',
                'childToMasterFieldName' => 'Rent__c',
                'childToMasterRelationshipName' => 'Rent__r'
            },
            new Map<String, String>{
                'name' => 'IST__SuperTRUMP_PQ_Loan__c',
                'childToMasterFieldName' => 'Loan__c',
                'childToMasterRelationshipName' => 'Loan__r'
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

        List<Map<String, String>> mapRentAmortizationToSF = new List<Map<String, String>>{
            new Map<String, String>{
                'fieldName' => 'Order__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Order'
            },
            new Map<String, String>{
                'fieldName' => 'Date__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Date'
            },
            new Map<String, String>{
                'fieldName' => 'Funding__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Funding'
            },
            new Map<String, String>{
                'fieldName' => 'Residual__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Residual'
            },
            new Map<String, String>{
                'fieldName' => 'Payment__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Payment'
            },
            new Map<String, String>{
                'fieldName' => 'Interest__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Interest'
            },
            new Map<String, String>{
                'fieldName' => 'Rate__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Rate'
            },
            new Map<String, String>{
                'fieldName' => 'Principal__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Principal'
            },
            new Map<String, String>{
                'fieldName' => 'Balance__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.Rents.Rent[].AmortSchedule.Cashflow[].Balance'
            }
        };

        for (Map<String, String> entry: mapRentAmortizationToSF){
            String objectName = 'SuperTRUMP_Rent_Amortization_Step__c';
            String fieldName = entry.get('fieldName');
            String calcField = entry.get('calcField');
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = true,
                    IST__IsSynch_In__c = false,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Master_Object_Name__c = 'IST__SuperTRUMP_Pricing_Quote__c',
                    IST__SF_Object_Level__c = '3',
                    IST__SF_Object_Name__c = objectName,
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0,
                    IST__SF_Parent_Name__c = 'IST__SuperTRUMP_PQ_Rent__c'
                )
            );
        }

        List<Map<String, String>> mapLoanAmortizationToSF = new List<Map<String, String>>{
            new Map<String, String>{
                'fieldName' => 'Order__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Order'
            },
            new Map<String, String>{
                'fieldName' => 'Date__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Date'
            },
            new Map<String, String>{
                'fieldName' => 'Funding__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Funding'
            },
            new Map<String, String>{
                'fieldName' => 'Residual__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Residual'
            },
            new Map<String, String>{
                'fieldName' => 'Payment__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Payment'
            },
            new Map<String, String>{
                'fieldName' => 'Interest__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Interest'
            },
            new Map<String, String>{
                'fieldName' => 'Rate__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Rate'
            },
            new Map<String, String>{
                'fieldName' => 'Principal__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Principal'
            },
            new Map<String, String>{
                'fieldName' => 'Balance__c',
                'calcField' => 'Opportunity.Quotes.Quote[].Transaction.LendingLoans.LendingLoan[].AmortSchedule.Cashflow[].Balance'
            }
        };

        for (Map<String, String> entry: mapLoanAmortizationToSF){
            String objectName = 'SuperTRUMP_Loan_Amortization_Step__c';
            String fieldName = entry.get('fieldName');
            String calcField = entry.get('calcField');
            toInsert.add(
                new IST__SuperTRUMP_Mapping__c(
                    IST__Allow_Salesforce_Changes__c = false,
                    IST__External_Binding__c = null,
                    IST__IsSynch__c = true,
                    IST__IsSynch_In__c = false,
                    IST__SF_Field_Name__c = fieldName,
                    IST__SF_Master_Object_Name__c = 'IST__SuperTRUMP_Pricing_Quote__c',
                    IST__SF_Object_Level__c = '3',
                    IST__SF_Object_Name__c = objectName,
                    IST__SOR__c = 'ST',
                    IST__ST_Field_Name__c = calcField,
                    IST__ST_Update_Priority__c = 0,
                    IST__SF_Parent_Name__c = 'IST__SuperTRUMP_PQ_Loan__c'
                )
            );
        }

        List<IST__SuperTRUMP_Mapping__c> storedMappings = [SELECT
                IST__SF_Object_Name__c,
                IST__SF_Field_Name__c,
                IST__ST_Field_Name__c
            FROM IST__SuperTRUMP_Mapping__c
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
    public class PermissionException extends Exception {}
}