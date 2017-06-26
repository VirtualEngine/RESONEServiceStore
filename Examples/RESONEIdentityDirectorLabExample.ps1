$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost';
            PSDSCAllowPlainTextPassword = $true;

            ROIDDatabaseServer       = 'controller.lab.local';
            ROIDDatabaseName         = 'RESONEIdentityDirector';
            ROIDBinariesFolder       = 'C:\SharedData\Software\RES\ONE Identity Director 10\RTM';
            ROIDBinariesVersion      = '10.0';
            ROIDHostHeader           = 'res.lab.local';
            ROIDCertificateThumprint = '16C3E093F050B201C2CC4E3FEC095C70741F6604';
        }
    )
}

configuration RESONEIdentityDirectorLabExample {
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

    Import-DscResource -ModuleName RESONEServiceStore #, xWebAdministration;

    node 'localhost' {

        ROIDLab 'ROIDLab' {
            
            Path                      = $node.ROIDBinariesFolder;
            DatabaseServer            = $node.ROIDDatabaseServer;
            DatabaseName              = $node.ROIDDatabaseName;
            Credential                = $Credential;
            SQLCredential             = $SQLCredential;
            CatalogServicesCredential = $Credential;
            Version                   = $node.ROIDBinariesVersion;
            HostHeader                = $node.ROIDHostHeader;
            CertificateThumbprint     = $node.ROIDCertificateThumprint;
        
        }

    }

} #end configuration RESONEServiceStoreLabExample

if (-not $cred) { $cred = Get-Credential -UserName 'RESONEIdentityDirector' -Message 'RES ONE Identity Director SQL account credential'; }
if (-not $sqlCred) { $sqlCred = Get-Credential -UserName 'sa' -Message 'Existing SQL account for database creation'; }
RESONEIdentityDirectorLabExample -OutputPath ~\Documents -ConfigurationData $config -Credential $cred -SQLCredential $sqlCred;
