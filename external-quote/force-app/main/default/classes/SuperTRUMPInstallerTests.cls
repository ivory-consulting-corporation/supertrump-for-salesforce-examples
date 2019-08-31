@IsTest
public with sharing class SuperTRUMPInstallerTests {

    private static void assertInstalledRecords(){
        System.assertEquals(1, [SELECT COUNT() FROM IST__SuperTRUMP_Object_Relationships__c]);
        System.assertEquals(44, [SELECT COUNT() FROM IST__SuperTRUMP_Mapping__c]);
    }

    public static testMethod void testInstall(){
        Test.startTest();
        SuperTRUMPInstaller.installObjectRelationships();
        SuperTRUMPInstaller.installMappings();
        Test.stopTest();

        assertInstalledRecords();
    }

    public static testMethod void testInstallTwice(){

        Test.startTest();
        SuperTRUMPInstaller.installObjectRelationships();
        SuperTRUMPInstaller.installMappings();
        SuperTRUMPInstaller.installObjectRelationships();
        SuperTRUMPInstaller.installMappings();
        Test.stopTest();

        assertInstalledRecords();
    }
}