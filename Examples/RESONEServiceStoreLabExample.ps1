$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost';
            PSDSCAllowPlainTextPassword = $true;
            
            ROSSDatabaseServer  = 'controller.lab.local';
            ROSSDatabaseName    = 'RESONEServiceStore';
            ROSSBinariesFolder  = 'C:\SharedData\Software\RES\ONE Service Store 2015\FR2';
            ROSSBinariesVersion = '8.2.0.0';
            ROSSHostHeader      = 'itstore.lab.local';
            ROSSDefaultDomain   = 'LAB';
        }
    )
}

configuration RESONEServiceStoreLabExample {
    param (
        ## RES ONE Service Store SQL database/user credential
        [Parameter(Mandatory)]
        [PSCredential] $Credential,

        ## Microsoft SQL Server credentials used to create the RES ONE Service Store database/user
        [Parameter(Mandatory)]
        [PSCredential] $SQLCredential
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

if (-not $Cred) { $Cred = Get-Credential -UserName 'ROSS' -Message 'RES ONE Service Store SQL account credential'; }
if (-not $sqlCred) { $sqlCred = Get-Credential -UserName 'sa' -Message 'Microsoft SQL Server account credential'; }
RESONEServiceStoreLabExample -OutputPath ~\Documents -ConfigurationData $config -Credential $cred -SQLCredential $sqlCred;
