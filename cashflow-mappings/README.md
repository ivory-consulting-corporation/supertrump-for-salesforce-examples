# SuperTRUMP for Salesforce Cash flow Add-On

This project is an extension of the SuperTRUMP for Salesforce managed package.
https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3000000B5JerEAF

The project contains the metadata and data files necessary to map SuperTRUMP rent and loan
cash flow data from SuperTRUMP into a Salesforce org. The SuperTRUMP for Salesforce
managed package comes with mappings for the rent, loan, asset, periodic expense, and
periodic income data so every time a SuperTRUMP quote is saved, this information is
populated into the appropriate Salesforce records. Once in Salesforce this data can
be used for reporting and other integrations.

Metadata for a loan and rent cash flow stream with the associated data and settings is
provided in this project.

# Installation

Installing this add-on requires the *SuperTRUMP for Salesforce* managed package version
1.14.1 or greater to already be installed in the org where it will be deployed.

The following commands can be used to setup your org with cash flows:

*Deploy the metadata in this project*
```
sfdx force:source:deploy -u <username> -p force-app`
```

*Deploy the custom settings required to setup the cash flows to be synced*
```
sfdx force:data:tree:import -u <username> -f data/IST__SuperTRUMP_Object_Relationships__c.json
```

*Deploy the mappings that map each individual SuperTRUMP field to corresponding Salesforce field*
```
sfdx force:data:tree:import -u <username> -f data/IST__SuperTRUMP_Mapping__c.json
```

*Assign the SuperTRUMP_With_Cash_flows permission set to your SuperTRUMP users*
```
sfdx force:user:permset:assign -u <username> -n SuperTRUMP_With_Cash_Flows
```

Additionally, the `SuperTRUMPSetup.cls` apex class could also be instead of the 
`sfdx force:data:tree:import` command, to install the custom settings and mappings. To do so,
run the following from the developer console in Salesforce:

```
SuperTRUMPSetup.installObjectRelationships();
SuperTRUMPSetup.installMappings();
```

The apex class will not insert a record if it already exists.