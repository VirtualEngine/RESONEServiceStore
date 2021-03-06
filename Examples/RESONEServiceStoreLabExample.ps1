﻿$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost';
            PSDSCAllowPlainTextPassword = $true;

            ROSSDatabaseServer  = 'controller.lab.local';
            ROSSDatabaseName    = 'RESONEServiceStore';
            ROSSBinariesFolder  = 'C:\SharedData\Software\RES\ONE Service Store 2015\FR2';
            ROSSBinariesVersion = '8.0';
            ROSSHostHeader      = 'itstore.lab.local';
            ROSSDefaultDomain   = 'LAB';
        }
    )
}

configuration RESONEServiceStoreLabExample {
    param (
        ## RES ONE Service Store SQL database/user credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## Microsoft SQL Server credentials used to create the RES ONE Service Store database/user
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $SQLCredential
    )

    Import-DscResource -ModuleName RESONEServiceStore, xWebAdministration;

    node 'localhost' {

        ROSSLab 'ROSSLab' {
            DatabaseServer = $node.ROSSDatabaseServer;
            DatabaseName = $node.ROSSDatabaseName;
            Credential = $Credential;
            SQLCredential = $SQLCredential;
            CatalogServicesCredential = $Credential;
            Path = $node.ROSSBinariesFolder;
            Version = $node.ROSSBinariesVersion;
            HostHeader = $node.ROSSHostHeader;
            DefaultDomain = $node.ROSSDefaultDomain;
        }

        xWebAppPool 'ITStoreMangementWebAppPool' {
            Name = 'IT Store Management';
            IdentityType = 'LocalSystem';
            DependsOn = '[ROSSLab]ROSSLab';
        }

    }

} #end configuration RESONEServiceStoreLabExample

if (-not $cred) { $cred = Get-Credential -UserName 'RESONEWorkspace' -Message 'RES ONE Service Store SQL account credential'; }
if (-not $sqlCred) { $sqlCred = Get-Credential -UserName 'sa' -Message 'Existing SQL account for database creation'; }
RESONEServiceStoreLabExample -OutputPath ~\Documents -ConfigurationData $config -Credential $cred -SQLCredential $sqlCred;
