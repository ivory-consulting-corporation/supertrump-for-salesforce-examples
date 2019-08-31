# SuperTRUMP for Salesforce External Quote Add-On

This project is an extension of the SuperTRUMP for Salesforce managed package.
https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3000000B5JerEAF

The project contains the metadata and data files necessary to create a SuperTRUMP
quote object with its assoicated asset, rent, loan, income fee, and expense fee
master-detail objects in a Salesforce org. These custom objects use The SuperTRUMP for Salesforce
managed package and associated mappings to populate them with SuperTRUMP data.
This would allow SuperTRUMP data to be accessible to Users who don't have access
to the managed package, want an additional quote object hierarchy, or want a quote
object that is not associated with an Opportunity.

# Installation

Installing this add-on requires the *SuperTRUMP for Salesforce* managed package version
1.14.1 or greater to already be installed in the org where it will be deployed.

The following commands can be used to setup your org with cash flows:

*Deploy the metadata in this project*
```
sfdx force:source:deploy -u <username> -p force-app
```

*Deploy the custom settings required to setup the link the child objects to the quote*
```
sfdx force:data:tree:import -u <username> -f data/IST__SuperTRUMP_Object_Relationships__c.json
```

*Deploy the mappings that map each individual SuperTRUMP field to the corresponding Salesforce field*
```
sfdx force:data:tree:import -u <username> -f data/IST__SuperTRUMP_Mapping__c.json
```

*Assign the SuperTRUMP_Custom_Quote_Admin permission set to your SuperTRUMP admins*
```
sfdx force:user:permset:assign -u <username> -n SuperTRUMP_Custom_Quote_Admin
```

*Assign the SuperTRUMP_Custom_Quote permission set to your SuperTRUMP users*
```
sfdx force:user:permset:assign -u <username> -n SuperTRUMP_Custom_Quote
```

*Assign the quote page layouts to the appropriate record type*
Log in to the org, go to the setup page, and update the "SuperTRUMP Quote" custom object
by assigning the page layouts to the following record types for all profiles:

Quote Both Layout => Master
Quote Both Layout => Both
Quote Lease Layout => Lease
Quote Loan Layout => Loan

Additionally, to install the custom settings and mappings, the `SuperTRUMPInstaller.cls`
apex class could also be used instead of the `sfdx force:data:tree:import` command. 
The apex class will not insert a record if it already exists. To do so,
run the following from the developer console in Salesforce:

```
SuperTRUMPInstaller.installObjectRelationships();
SuperTRUMPInstaller.installMappings();
```