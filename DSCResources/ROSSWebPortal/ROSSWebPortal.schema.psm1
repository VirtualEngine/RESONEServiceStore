configuration ROSSWebPortal {
<#
    .SYNOPSIS
        Installs the RES ONE Service Store end-user web portal.
#>
    param (
        ## RES ONE Service Store default (NetBIOS) domain name.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,
        
        ## IIS website host header, i.e. http://itstore.lab.local.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $HostHeader,
        
        ## RES ONE Service Store Catalog Services password (equivalient to CATALOGSERVICESPASSWORD).
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $CatalogServicesCredential,
        
        ## RES ONE Service Store Catalog Services host (equivalient to CATALOGSERVICESHOST).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,
        
        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## IIS website port binding.
        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()] [ValidateNotNull()]
        [System.Int32] $Port = 80,
        
        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROSSWebPortal';
    if (([System.String]::IsNullOrWhitespace($Version)) -and (-not $IsLiteralPath)) {
        throw "$resourceName : Version number is required when not using a literal path.";
    }
    elseif ($IsLiteralPath -and ($Path -notmatch '\.msi$')) {
        throw "$resourceName : Specified path '$Path' does not point to an MSI file.";
    }
    elseif ($Version -notmatch '^\d+\.\d+\.\d+\.\d+$') {
        throw "$resourceName : The specified version '$Version' does not match '1.2.3.4' format.";
    }
    
    if (-not $IsLiteralPath) {
        [System.Version] $Version = $Version;
        switch ($Version.Major) {
            7 {
                $setup = 'RES-ITS-Web-Portal-{0}.msi' -f $Version;
                $name = 'RES IT Store Web Portal 2014';
            }
            8 {
                $setup = 'RES-ONE-ServiceStore-2015-WebPortal-MobileGateway-{0}.msi' -f $Version.ToString();
                $name = 'RES ONE Service Store 2015 Web Portal & Mobile Gateway';
            }
            Default {
                throw "$resourceName : Version '$($Version.Tostring())' is not currently supported :(.";
            }
        }
        $Path = Join-Path -Path $Path -ChildPath $setup;
    }

    if ($Ensure -eq 'Present') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            Arguments = 'DEFAULTDOMAIN="{0}" ITSTOREHOSTNAME="{1}" ITSTOREPORT="{2}" CATALOGSERVICESHOST="{3}" CATALOGSERVICESPASSWORD="{4}"' -f $DefaultDomain, $HostHeader, $Port, $CatalogServicesHost, $CatalogServicesCredential.GetNetworkCredential().Password;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\VirtualEngine\DSC\RES\ServiceStore';
            InstalledCheckRegValueName = 'WebPortal';
            InstalledCheckRegValueData = 'Installed';
            CreateCheckRegValue = $true;
            Ensure = $Ensure;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\VirtualEngine\DSC\RES\ServiceStore';
            InstalledCheckRegValueName = 'WebPortal';
            InstalledCheckRegValueData = 'Installed';
            CreateCheckRegValue = $true;
            Ensure = $Ensure;
        }
    }

} #end configuration ROSSWebPortal
