configuration ROSSLab {
<#
    .SYNOPSIS
        Creates the RES ONE Service Store single node lab deployment.
#>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param (
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
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
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## Host header for the RES ONE Service Store
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $HostHeader,

        ## RES ONE Service Store default (NetBIOS) domain name.
        [Parameter(Mandatory)]
        [System.String] $DefaultDomain,

        ## RES ONE Service Store database name (equivalient to DBNAME).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName = 'RESONEServiceStore',

        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()]
        [System.UInt16] $Port = 80,

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

        ## Delete the building block from disk after import.
        [Parameter()]
        [System.Boolean] $DeleteBuildingBlock,

        ## Catalog services hostname
        [Parameter()]
        [System.String] $CatalogServicesHost = 'localhost',

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    ## [System.Version] does not support just a major number and therefore, we have to roll our own..
    $versionSplit = $Version.Split('.');
    $productVersion = [PSCustomObject] @{
        Major = $versionSplit[0] -as [System.Int32];
        Minor = if ($versionSplit[1]) { $versionSplit[1] -as [System.Int32] } else { -1 }
        Build = if ($versionSplit[2]) { $versionSplit[2] -as [System.Int32] } else { -1 }
        Revision = if ($versionSplit[3]) { $versionSplit[3] -as [System.Int32] } else { -1 }
    }
    if ($productVersion.Major -gt 9) {
        
        throw ("Unsupported version '{0}'. ROSSLab requires version 9 or earlier." -f $Version);
    }
    
    Write-Host ' Starting "ROSSLab".' -ForegroundColor Gray;

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking;

    ## Can't import RESONEServiceStore module due to circular references!
    Import-DscResource -Name ROSSDatabase, ROSSTransactionEngine, ROSSCatalogServices, ROSSWebPortal, ROSSManagementPortal, ROSSBuildingBlock;

    ## If path -match '\.msi$', throw.
    if ($Path -match '\.msi$') {
        throw "Specified path '$Path' does not point to a directory.";
    }

    if ($Ensure -eq 'Present') {

        if ($PSBoundParameters.ContainsKey('LicensePath')) {

            Write-Host ' Processing "ROSSLab\ROSSLabDatabase" with "LicensePath".' -ForegroundColor Gray;
            ROSSDatabase 'ROSSLabDatabase' {
                DatabaseServer            = $DatabaseServer;
                DatabaseName              = $DatabaseName;
                Credential                = $Credential;
                SQLCredential             = $SQLCredential;
                CatalogServicesCredential = $CatalogServicesCredential;
                Path                      = $Path;
                Version                   = $Version;
                IsLiteralPath             = $false;
                LicensePath               = $LicensePath;
                Ensure                    = $Ensure;
            }
        }
        else {

            Write-Host ' Processing "ROSSLab\ROSSLabDatabase".' -ForegroundColor Gray;
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
        }

        Write-Host ' Processing "ROSSLab\ROSSLabTransactionEngine".' -ForegroundColor Gray;
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

        Write-Host ' Processing "ROSSLab\ROSSLabCatalogServices".' -ForegroundColor Gray;
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

        Write-Host ' Processing "ROSSLab\ROSSLabWebPortal".' -ForegroundColor Gray;
        ROSSWebPortal 'ROSSLabWebPortal' {
            CatalogServicesCredential = $CatalogServicesCredential;
            CatalogServicesHost       = $CatalogServicesHost;
            DefaultDomain             = $DefaultDomain;
            HostHeader                = $HostHeader;
            Port                      = $Port;
            Path                      = $Path;
            Version                   = $Version;
            IsLiteralPath             = $false;
            Ensure                    = $Ensure;
        }

        Write-Host ' Processing "ROSSLab\ROSSLabManagementPortal".' -ForegroundColor Gray;
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

        if ($PSBoundParameters.ContainsKey('BuildingBlockPath')) {

            Write-Host ' Processing "ROSSLab\ROSSLabBuildingBlock".' -ForegroundColor Gray;
            ROSSBuildingBlock 'ROSSLabBuildingBlock' {
                Path           = $BuildingBlockPath;
                Server         = $HostHeader;
                Credential     = $BuildingBlockCredential;
                DeleteFromDisk = $DeleteBuildingBlock;
                DependsOn      = '[ROSSManagementPortal]ROSSLabManagementPortal';
            }
        }

    }
    elseif ($Ensure -eq 'Absent') {

        Write-Host ' Processing "ROSSLab\ROSSLabManagementPortal".' -ForegroundColor Gray;
        ROSSManagementPortal 'ROSSLabManagementPortal' {
            HostHeader    = $HostHeader;
            Port          = $Port;
            Path          = $Path;
            Version       = $Version;
            IsLiteralPath = $false;
            Ensure        = $Ensure;
        }

        Write-Host ' Processing "ROSSLab\ROSSLabWebPortal".' -ForegroundColor Gray;
        ROSSWebPortal 'ROSSLabWebPortal' {
            CatalogServicesCredential = $CatalogServicesCredential;
            CatalogServicesHost = $CatalogServicesHost;
            DefaultDomain       = $DefaultDomain;
            HostHeader          = $HostHeader;
            Port                = $Port;
            Path                = $Path;
            Version             = $Version;
            IsLiteralPath       = $false;
            Ensure              = $Ensure;
        }

        Write-Host ' Processing "ROSSLab\ROSSLabCatalogServices".' -ForegroundColor Gray;
        ROSSCatalogServices 'ROSSLabCatalogServices' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
        }

        Write-Host ' Processing "ROSSLab\ROSSLabTransactionEngine".' -ForegroundColor Gray;
        ROSSTransactionEngine 'ROSSLabTransactionEngine' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
        }

        Write-Host ' Processing "ROSSLab\ROSSLabDatabase".' -ForegroundColor Gray;
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

    Write-Host ' Processing "ROSSLab\ROSSLabCatalogServicesFirewall".' -ForegroundColor Gray;
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

    Write-Host ' Processing "ROSSLab\ROSSLabCatalogServicesFirewall8080".' -ForegroundColor Gray;
    xFirewall 'ROSSLabCatalogServicesFirewall8080' {
        Name        = 'RESONEServiceStore-TCP-8080-In';
        Group       = 'RES ONE Service Store';
        DisplayName = 'RES ONE Service Store (RES ONE Workspace)';
        Action      = 'Allow';
        Direction   = 'Inbound';
        Enabled     = $true;
        Profile     = 'Any';
        Protocol    = 'TCP';
        LocalPort   = 8080;
        Description = 'RES ONE Workspace integration';
        Ensure      = $Ensure;
        DependsOn   = '[ROSSCatalogServices]ROSSLabCatalogServices';
    }

    Write-Host ' Processing "ROSSLab\ROSSLabCatalogServicesFirewall8081".' -ForegroundColor Gray;
    xFirewall 'ROSSLabCatalogServicesFirewall8081' {
        Name        = 'RESONEServiceStore-TCP-8081-In';
        Group       = 'RES ONE Service Store';
        DisplayName = 'RES ONE Service Store (RES ONE Automation)';
        Action      = 'Allow';
        Direction   = 'Inbound';
        Enabled     = $true;
        Profile     = 'Any';
        Protocol    = 'TCP';
        LocalPort   = 8081;
        Description = 'RES ONE Automation integration';
        Ensure      = $Ensure;
        DependsOn   = '[ROSSCatalogServices]ROSSLabCatalogServices';
    }

    Write-Host ' Ending "ROSSLab".' -ForegroundColor Gray;

} #end configuration ROSSLab
