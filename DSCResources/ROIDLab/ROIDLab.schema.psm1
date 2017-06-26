configuration ROIDLab {
<#
    .SYNOPSIS
        Creates the RES ONE Service Store single node lab deployment using HTTPS.
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

        ## Pfx certificate thumbprint
        [Parameter(Mandatory)]
        [System.String] $CertificateThumbprint,

        ## RES ONE Service Store database name (equivalient to DBNAME).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName = 'RESONEIdentityDirector',

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

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    
    Write-Host ' Starting "ROIDLab".' -ForegroundColor Gray;

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking;

    ## Can't import RESONEServiceStore module due to circular references!
    Import-DscResource -Name ROSSDatabase, ROSSTransactionEngine, ROSSCatalogServices, ROSSWebPortal, ROSSManagementPortal, ROSSMobileGateway, ROSSBuildingBlock;

    if ($Path -match '\.msi$') {

        throw "Specified path '$Path' does not point to a directory.";
    }

    if ($Ensure -eq 'Present') {

        if ($PSBoundParameters.ContainsKey('LicensePath')) {

            Write-Host ' Processing "ROIDLab\ROIDLabDatabase" with "LicensePath".' -ForegroundColor Gray;
            ROSSDatabase 'ROIDLabDatabase' {
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

            Write-Host ' Processing "ROIDLab\ROIDLabDatabase".' -ForegroundColor Gray;
            ROSSDatabase 'ROIDLabDatabase' {
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

        Write-Host ' Processing "ROIDLab\ROIDLabTransactionEngine".' -ForegroundColor Gray;
        ROSSTransactionEngine 'ROIDLabTransactionEngine' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
            DependsOn      = '[ROSSDatabase]ROIDLabDatabase';
        }

        Write-Host ' Processing "ROIDLab\ROIDLabCatalogServices".' -ForegroundColor Gray;
        ROSSCatalogServices 'ROIDLabCatalogServices' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
            DependsOn      = '[ROSSDatabase]ROIDLabDatabase';
        }

        Write-Host ' Processing "ROIDLab\ROIDLabWebPortal".' -ForegroundColor Gray;
        ROSSWebPortal 'ROIDLabWebPortal' {
            Path                  = $Path;
            HostHeader            = $HostHeader;
            CertificateThumbprint = $CertificateThumbprint;
            Version               = $Version;
            IsLiteralPath         = $false;
            Ensure                = $Ensure;
            DependsOn             = '[ROSSDatabase]ROIDLabDatabase';
        }

        Write-Host ' Processing "ROIDLab\ROIDLabManagementPortal".' -ForegroundColor Gray;
        ROSSManagementPortal 'ROIDLabManagementPortal' {
            Path                  = $Path;
            HostHeader            = $HostHeader;
            CertificateThumbprint = $CertificateThumbprint;
            Version               = $Version;
            IsLiteralPath         = $false;
            Ensure                = $Ensure;
            DependsOn             = '[ROSSDatabase]ROIDLabDatabase';
        }

        Write-Host ' Processing "ROIDLab\ROIDLabMobileGateway".' -ForegroundColor Gray;
        ROSSMobileGateway 'ROIDLabMobileGatewayl' {
            Path                  = $Path;
            HostHeader            = $HostHeader;
            CertificateThumbprint = $CertificateThumbprint;
            Version               = $Version;
            IsLiteralPath         = $false;
            Ensure                = $Ensure;
            DependsOn             = '[ROSSDatabase]ROIDLabDatabase';
        }

        if ($PSBoundParameters.ContainsKey('BuildingBlockPath')) {

            Write-Host ' Processing "ROIDLab\ROIDLabBuildingBlock".' -ForegroundColor Gray;
            ROSSBuildingBlock 'ROIDLabBuildingBlock' {
                Path           = $BuildingBlockPath;
                Server         = $HostHeader;
                Credential     = $BuildingBlockCredential;
                DeleteFromDisk = $DeleteBuildingBlock;
                DependsOn      = '[ROSSManagementPortal]ROIDLabManagementPortal';
            }
        }

    }
    elseif ($Ensure -eq 'Absent') {

        Write-Host ' Processing "ROIDLab\ROIDLabMobileGateway".' -ForegroundColor Gray;
        ROSSMobileGateway 'ROIDLabMobileGatewayl' {
            Path                  = $Path;
            HostHeader            = $HostHeader;
            CertificateThumbprint = $CertificateThumbprint;
            Version               = $Version;
            IsLiteralPath         = $false;
            Ensure                = $Ensure;
        }

        Write-Host ' Processing "ROIDLab\ROIDLabManagementPortal".' -ForegroundColor Gray;
        ROSSManagementPortal 'ROIDLabManagementPortal' {
            HostHeader            = $HostHeader;
            Path                  = $Path;
            CertificateThumbprint = $CertificateThumbprint;
            Version               = $Version;
            IsLiteralPath         = $false;
            Ensure                = $Ensure;
        }

        Write-Host ' Processing "ROIDLab\ROIDLabWebPortal".' -ForegroundColor Gray;
        ROSSWebPortal 'ROIDLabWebPortal' {
            Path                  = $Path;
            HostHeader            = $HostHeader;
            CertificateThumbprint = $CertificateThumbprint;
            Version               = $Version;
            IsLiteralPath         = $false;
            Ensure                = $Ensure;
        }

        Write-Host ' Processing "ROIDLab\ROIDLabCatalogServices".' -ForegroundColor Gray;
        ROSSCatalogServices 'ROIDLabCatalogServices' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
        }

        Write-Host ' Processing "ROIDLab\ROIDLabTransactionEngine".' -ForegroundColor Gray;
        ROSSTransactionEngine 'ROIDLabTransactionEngine' {
            DatabaseServer = $DatabaseServer;
            DatabaseName   = $DatabaseName;
            Credential     = $Credential;
            Path           = $Path;
            Version        = $Version;
            IsLiteralPath  = $false;
            Ensure         = $Ensure;
        }

        Write-Host ' Processing "ROIDLab\ROIDLabDatabase".' -ForegroundColor Gray;
        ROSSDatabase 'ROIDLabDatabase' {
            DatabaseServer            = $DatabaseServer;
            DatabaseName              = $DatabaseName;
            Credential                = $Credential;
            SQLCredential             = $SQLCredential;
            CatalogServicesCredential = $CatalogServicesCredential;
            Path                      = $Path;
            Version                   = $Version;
            IsLiteralPath             = $false;
            Ensure                    = $Ensure;
            DependsOn                 = '[ROSSCatalogServices]ROIDLabCatalogServices', '[ROSSTransactionEngine]ROIDLabTransactionEngine';
        }

    }

    Write-Host ' Processing "ROIDLab\ROIDLabCatalogServicesFirewall".' -ForegroundColor Gray;
    xFirewall 'ROIDLabCatalogServicesFirewall' {
        Name        = 'RESONEIdentityDirector-TCP-4733-In';
        Group       = 'RES ONE Identity Director';
        DisplayName = 'RES ONE Identity Director (Catalog Services)';
        Action      = 'Allow';
        Direction   = 'Inbound';
        Enabled     = $true;
        Profile     = 'Any';
        Protocol    = 'TCP';
        LocalPort   = 4733;
        Description = 'RES ONE Identity Director Catalog Services Service';
        Ensure      = $Ensure;
        DependsOn   = '[ROSSCatalogServices]ROIDLabCatalogServices';
    }

    Write-Host ' Processing "ROIDLab\ROIDLabCatalogServicesFirewall8080".' -ForegroundColor Gray;
    xFirewall 'ROIDLabCatalogServicesFirewall8080' {
        Name        = 'RESONEIdentityDirector-TCP-8080-In';
        Group       = 'RES ONE Identity Director';
        DisplayName = 'RES ONE Identity Director (RES ONE Workspace)';
        Action      = 'Allow';
        Direction   = 'Inbound';
        Enabled     = $true;
        Profile     = 'Any';
        Protocol    = 'TCP';
        LocalPort   = 8080;
        Description = 'RES ONE Workspace integration';
        Ensure      = $Ensure;
        DependsOn   = '[ROSSCatalogServices]ROIDLabCatalogServices';
    }

    Write-Host ' Processing "ROIDLab\ROIDLabCatalogServicesFirewall8081".' -ForegroundColor Gray;
    xFirewall 'ROIDLabIdentityDirectorFirewall8081' {
        Name        = 'RESONEIdentityDirector-TCP-8081-In';
        Group       = 'RES ONE Identity Director';
        DisplayName = 'RES ONE Identity Director (RES ONE Automation)';
        Action      = 'Allow';
        Direction   = 'Inbound';
        Enabled     = $true;
        Profile     = 'Any';
        Protocol    = 'TCP';
        LocalPort   = 8081;
        Description = 'RES ONE Automation integration';
        Ensure      = $Ensure;
        DependsOn   = '[ROSSCatalogServices]ROIDLabCatalogServices';
    }

    Write-Host ' Ending "ROIDLab".' -ForegroundColor Gray;

} #end configuration ROIDLab
