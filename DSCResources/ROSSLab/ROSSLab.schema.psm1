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
        [System.Management.Automation.PSCredential] $Credential,
        
        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $SQLCredential,
        
        ## RES ONE Service Store Catalog Services password (equivalient to CATALOGSERVICESPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $CatalogServicesCredential,
        
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

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;
    
    ## Can't import RESONEServiceStore composite resource due to circular references!
    Import-DscResource -Name ROSSDatabase, ROSSTransactionEngine, ROSSCatalogServices, ROSSWebPortal, ROSSManagementPortal;

    ## If path -match '\.msi$', throw.
    if ($Path -match '\.msi$') {
        throw "Specified path '$Path' does not point to a directory.";
    }

    if ($Ensure -eq 'Present') {
        
        ROSSDatabase 'ROSSLabDatabase' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            SQLCredential = $SQLCredential;
            CatalogServicesCredential = $CatalogServicesCredential;
            Path = $Path;
            Version = $Version;
            Architecture = $Architecture;
            IsLiteralPath = $false;
            Ensure = $Ensure;
        }

        ROSSTransactionEngine 'ROSSLabTransactionEngine' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            Path = $Path;
            Version = $Version;
            Architecture = $Architecture;
            IsLiteralPath = $false;
            Ensure = $Ensure;
            DependsOn = '[ROSSDatabase]ROSSLabDatabase';
        }
    
        ROSSCatalogServices 'ROSSLabCatalogServices' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            Path = $Path;
            Version = $Version;
            Architecture = $Architecture;
            IsLiteralPath = $false;
            Ensure = $Ensure;
            DependsOn = '[ROSSDatabase]ROSSLabDatabase';
        }
    
        ROSSWebPortal 'ROSSLabWebPortal' {
            CatalogServicesCredential = $CatalogServicesCredential;
            CatalogServicesHost = 'localhost';
            DefaultDomain = $DefaultDomain;
            HostHeader = $HostHeader;
            Port = $Port;
            Path = $Path;
            Version = $Version;
            IsLiteralPath = $false;
            Ensure = $Ensure;
        }
    
        ROSSManagementPortal 'ROSSLabManagementPortal' {
            HostHeader = $HostHeader;
            Port = $Port;
            Path = $Path;
            Version = $Version;
            IsLiteralPath = $false;
            Ensure = $Ensure;
            DependsOn = '[ROSSDatabase]ROSSLabDatabase';
        }
        
    }
    elseif ($Ensure -eq 'Absent') {
        
        ROSSManagementPortal 'ROSSLabManagementPortal' {
            HostHeader = $HostHeader;
            Port = $Port;
            Path = $Path;
            Version = $Version;
            IsLiteralPath = $false;
            Ensure = $Ensure;
        }
        
        ROSSWebPortal 'ROSSLabWebPortal' {
            CatalogServicesCredential = $CatalogServicesCredential;
            CatalogServicesHost = 'localhost';
            DefaultDomain = $DefaultDomain;
            HostHeader = $HostHeader;
            Port = $Port;
            Path = $Path;
            Version = $Version;
            IsLiteralPath = $false;
            Ensure = $Ensure;
        }
        
        ROSSCatalogServices 'ROSSLabCatalogServices' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            Path = $Path;
            Version = $Version;
            Architecture = $Architecture;
            IsLiteralPath = $false;
            Ensure = $Ensure;
        }
        
        ROSSTransactionEngine 'ROSSLabTransactionEngine' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            Path = $Path;
            Version = $Version;
            Architecture = $Architecture;
            IsLiteralPath = $false;
            Ensure = $Ensure;
        }
        
         ROSSDatabase 'ROSSLabDatabase' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            SQLCredential = $SQLCredential;
            CatalogServicesCredential = $CatalogServicesCredential;
            Path = $Path;
            Version = $Version;
            Architecture = $Architecture;
            IsLiteralPath = $false;
            Ensure = $Ensure;
            DependsOn = '[ROSSCatalogServices]ROSSLabCatalogServices', '[ROSSTransactionEngine]ROSSLabTransactionEngine';
        }

    }
    
    xFirewall 'ROALabDispatcherFirewall' {
        Name = 'RES ITS Catalog Services';
        Action = 'Allow';
        Direction = 'Inbound';
        DisplayName = 'RES ITS Catalog Services';
        Enabled = $true;
        Profile = 'Any';
        Program = 'C:\Program Files\RES Software\IT Store\Catalog Services\resocs.exe'
        Description = 'RES ONE Automation Dispatcher Service';
        Ensure = $Ensure;
        DependsOn = '[ROSSCatalogServices]CatalogServices';
    }

} #end configuration ROSSLab
