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
        [Parameter(Mandatory)]
        [System.String] $DefaultDomain,

        ## Pfx certificate thumbprint
        [Parameter(Mandatory)]
        [System.String] $PfxCertificateThumbprint,

        ## RES ONE Service Store database name (equivalient to DBNAME).
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName = 'RESONEServiceStore',

        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()]
        [System.UInt16] $Port = 80,

        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        ## File path to RES ONE Service Store license file.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicensePath,

        ## File path to RES ONE Service Store building blocks to import.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $BuildingBlockPath,

        ## Credential used to import the RES ONE Service Store building blocks.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $BuildingBlockCredential,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Write-Host ' Starting "ROSSLabHttps".' -ForegroundColor Gray;

    Import-DscResource -ModuleName xWebAdministration;

    ## Can't import RESONEServiceStore composite resource due to circular references!
    Import-DscResource -Name ROSSLab;

    if ($PSBoundParameters.ContainsKey('BuildingBlockPath') -and
        $PSBoundParameters.ContainsKey('LicensePath')) {

        Write-Host ' Processing "ROSSLabHttps\ROSSLabHttps" with "BuildingBlockPath" and "LicensePath".' -ForegroundColor Gray;
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
            LicensePath               = $LicensePath;
            BuildingBlockPath         = $BuildingBlockPath;
            BuildingBlockCredential   = $BuildingBlockCredential;
            Ensure                    = $Ensure;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('BuildingBlockPath')) {

        Write-Host ' Processing "ROSSLabHttps\ROSSLabHttps" with "BuildingBlockPath".' -ForegroundColor Gray;
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
            BuildingBlockPath         = $BuildingBlockPath;
            BuildingBlockCredential   = $BuildingBlockCredential;
            Ensure                    = $Ensure;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('LicensePath')) {

        Write-Host ' Processing "ROSSLabHttps\ROSSLabHttps" with "LicensePath".' -ForegroundColor Gray;
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
            LicensePath               = $LicensePath;
            Ensure                    = $Ensure;
        }
    }
    else {

        Write-Host ' Processing "ROSSLabHttps\ROSSLabHttps".' -ForegroundColor Gray;
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
            Ensure                    = $Ensure;
        }
    }

    if ($Architecture -eq 'x64') {
        $physicalPath = 'C:\Program Files (x86)';
    }
    elseif ($Architecture -eq 'x86') {
        $physicalPath = 'C:\Program Files';
    }

    Write-Host ' Processing "ROSSLabHttps\ROSSLabHttpsBinding".' -ForegroundColor Gray;
    xWebSite 'ROSSLabHttpsBinding' {
        Name = 'IT Store';
        PhysicalPath = '{0}\RES Software\IT Store\Web Portal\IT Store' -f $physicalPath;
        BindingInfo = @(
            MSFT_xWebBindingInformation {
                Protocol = 'HTTPS';
                Port = 443;
                HostName = $HostHeader;
                CertificateThumbprint = $PfxCertificateThumbprint;
                CertificateStoreName = 'My';
            }
            MSFT_xWebBindingInformation {
                Protocol = 'HTTP';
                Port = 80;
                HostName = $HostHeader;
            }
        )
        DependsOn = '[ROSSLab]ROSSLabHttps';
    }

    Write-Host ' Ending "ROSSLabHttps".' -ForegroundColor Gray;

} #end configuration ROSSLabHttps
