configuration ROSSLab {
<#
    .SYNOPSIS
        Creates the RES ONE Service Store single node lab deployment.
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

        ## RES ONE Service Store database name (equivalient to DBNAME).
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName = 'RESONEServiceStore',

        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()]
        [System.UInt16] $Port = 80,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking;

    ## Can't import RESONEServiceStore module due to circular references!
    Import-DscResource -Name ROSSDatabase, ROSSTransactionEngine, ROSSCatalogServices, ROSSWebPortal, ROSSManagementPortal;

    ## If path -match '\.msi$', throw.
    if ($Path -match '\.msi$') {
        throw "Specified path '$Path' does not point to a directory.";
    }

    if ($Ensure -eq 'Present') {

        ROSSDatabase 'ROSSLabDatabase' {
            DatabaseServer            = $DatabaseServer;
            DatabaseName              = $DatabaseName;
            Credential                = $Credential;
            SQLCredential             = $SQLCredential;
            CatalogServicesCredential = $CatalogServicesCredential;
            Path                      = $Path;
            Version                   = $Version;
            IsLiteralPath             = $false;
            Ensure                    = $Ensure;
        }

        ROSSTransactionEngine 'ROSSLabTransactionEngine' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
            DependsOn      = '[ROSSDatabase]ROSSLabDatabase';
        }

        ROSSCatalogServices 'ROSSLabCatalogServices' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
            DependsOn      = '[ROSSDatabase]ROSSLabDatabase';
        }

        ROSSWebPortal 'ROSSLabWebPortal' {
            CatalogServicesCredential = $CatalogServicesCredential;
            CatalogServicesHost       = 'localhost';
            DefaultDomain             = $DefaultDomain;
            HostHeader                = $HostHeader;
            Port                      = $Port;
            Path                      = $Path;
            Version                   = $Version;
            IsLiteralPath             = $false;
            Ensure                    = $Ensure;
        }

        ROSSManagementPortal 'ROSSLabManagementPortal' {
            HostHeader    = $HostHeader;
            Port          = $Port;
            DefaultDomain = $DefaultDomain;
            Path          = $Path;
            Version       = $Version;
            IsLiteralPath = $false;
            Ensure        = $Ensure;
            DependsOn     = '[ROSSDatabase]ROSSLabDatabase';
        }

    }
    elseif ($Ensure -eq 'Absent') {

        ROSSManagementPortal 'ROSSLabManagementPortal' {
            HostHeader    = $HostHeader;
            Port          = $Port;
            Path          = $Path;
            Version       = $Version;
            IsLiteralPath = $false;
            Ensure        = $Ensure;
        }

        ROSSWebPortal 'ROSSLabWebPortal' {
            CatalogServicesCredential = $CatalogServicesCredential;
            CatalogServicesHost = 'localhost';
            DefaultDomain       = $DefaultDomain;
            HostHeader          = $HostHeader;
            Port                = $Port;
            Path                = $Path;
            Version             = $Version;
            IsLiteralPath       = $false;
            Ensure              = $Ensure;
        }

        ROSSCatalogServices 'ROSSLabCatalogServices' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
        }

        ROSSTransactionEngine 'ROSSLabTransactionEngine' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
        }

        ROSSDatabase 'ROSSLabDatabase' {
            DatabaseServer            = $DatabaseServer;
            DatabaseName              = $DatabaseName;
            Credential                = $Credential;
            SQLCredential             = $SQLCredential;
            CatalogServicesCredential = $CatalogServicesCredential;
            Path                      = $Path;
            Version                   = $Version;
            IsLiteralPath             = $false;
            Ensure                    = $Ensure;
            DependsOn                 = '[ROSSCatalogServices]ROSSLabCatalogServices', '[ROSSTransactionEngine]ROSSLabTransactionEngine';
        }

    }

    xFirewall 'ROSSLabCatalogServicesFirewall' {
        Name        = 'RESONEServiceStore-TCP-4733-In';
        Group       = 'RES ONE Service Store';
        DisplayName = 'RES ONE Service Store (Catalog Services)';
        Action      = 'Allow';
        Direction   = 'Inbound';
        Enabled     = $true;
        Profile     = 'Any';
        Protocol    = 'TCP';
        LocalPort   = 4733;
        Description = 'RES ONE Service Store Catalog Services Service';
        Ensure      = $Ensure;
        DependsOn   = '[ROSSCatalogServices]ROSSLabCatalogServices';
    }

} #end configuration ROSSLab
