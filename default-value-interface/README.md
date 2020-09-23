# SuperTRUMP for Salesforce Default Value Interface Add-On

This project is an extension of the SuperTRUMP for Salesforce managed package.
https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3000000B5JerEAF

SuperTRUMP for Salesforce has a Default Value Mapping object that allows package subscribers to set default values in the SuperTRUMP interface. However, it's only possible to set static values, or refer to related fields to set the desired values. It's not possible to conditionally set default values or use other custom logic or dependencies to determine what default values should be used.

SuperTRUMP for Salesforce exposes an interface in apex that package subscribers can use to create default values for the SuperTRUMP interface. Creating default values in apex allows a developer to use SOQL, custom logic, and other features available in apex to customize the default values to the needs of the organization. For example, creating an apex class that implements this interface could set default values based on the template of the quote being created.

# Installation

Installing this add-on requires the *SuperTRUMP for Salesforce* managed package version 1.15.1 or greater to already be installed in the org where it will be deployed.

The following commands can be used to setup your org with the Default Value Interface code:

*Deploy the metadata in this project*
```
sfdx force:source:deploy -u <username> -p force-app
```

*Deploy the custom settings data*
```
sfdx force:data:tree:import -u <username> -f data/IST__SuperTRUMP_Hierarchy_Definition__c.json
```
