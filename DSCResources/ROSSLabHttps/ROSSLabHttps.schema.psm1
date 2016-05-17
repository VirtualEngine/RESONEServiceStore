configuration ROSSLabHttps {
<#
    .SYNOPSIS
        Creates the RES ONE Service Store single node lab deployment using HTTPS.
#>
    param (
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,
        
        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,
        
        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $SQLCredential,
        
        ## RES ONE Service Store Catalog Services password (equivalient to CATALOGSERVICESPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,
        
        ## File path containing the RES ONE Service Store MSIs or the literal path to the legacy console/Sync Tool MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## Host header for the RES ONE Service Store 
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $HostHeader,
        
        ## RES ONE Service Store default (NetBIOS) domain name.
        [Parameter(Mandatory)] [System.String] $DefaultDomain,
        
        ## Personal information exchange (Pfx) ertificate file path
        [Parameter(Mandatory)]
        [System.String] $PfxCertificatePath,
        
        ## Pfx certificate thumbprint
        [Parameter(Mandatory)]
        [System.String] $PfxCertificateThumbprint,
        
        ## Pfx certificate password
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $PfxCertificateCredential
        
        ## RES ONE Service Store database name (equivalient to DBNAME).
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName = 'RESONEServiceStore',
        
        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()]
        [System.Int32] $Port = 80,
        
        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xCertificate, xWebAdministration;
    
    ## Can't import RESONEServiceStore composite resource due to circular references!
    Import-DscResource -Name ROSSLab;
    
    ROSSLab 'ROSSLabHttps' {
        DatabaseServer            = $DatabaseServer;
        Credential                = $Credential;
        SQLCredential             = $SQLCredential;
        CatalogServicesCredential = $CatalogServicesCredential;
        Path                      = $Path;
        Version                   = $Version;
        HostHeader                = $HostHeader;
        DefaultDomain             = $DefaultDomain;
        DatabaseName              = $DatabaseName;
        Port                      = $Port;
        Architecture              = $Architecture;
        Ensure                    = $Ensure;
    }
    
    xPfxImport 'ROSSPfxCertificate' {
        Thumbprint = $PfxCertificateThumbprint;
        Location = 'LocalMachine';
        Store = 'My';
        Path = $PfxCertificatePath;
        Credential = $PfxCertificateCredential;
    }
    
    if ($Architecture -eq 'x64') {
        $physicalPath = 'C:\Program Files (x86)';
    }
    elseif ($Architecture -eq 'x86') {
        $physicalPath = 'C:\Program Files';
    }

    xWebSite 'ITStoreWebsite' {
        Name = 'IT Store';
        PhysicalPath = '{0}\RES Software\IT Store\Web Portal\IT Store' -f $physicalPath;
        BindingInfo = @(
            MSFT_xWebBindingInformation  { Protocol = 'HTTPS'; Port = 443; HostName = $HostHeader; CertificateThumbprint = $PfxCertificateThumbprint; CertificateStoreName = 'My'; }
            MSFT_xWebBindingInformation  { Protocol = 'HTTP'; Port = 80; HostName = $HostHeader; }
        )
        DependsOn = '[ROSSLab]ROSSLabHttps','[xPfxImport]PfxCertificate';
    }


} #end configuration ROSSLab
