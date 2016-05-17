configuration ROSSClient {
<#
    .SYNOPSIS
        Installs the RES ONE Service Store Windows client component.
#>
    param (
        ## RES ONE Service Store Catalog Services password (equivalient to CATALOGSERVICESPASSWORD).
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,
        
        ## RES ONE Service Store Catalog Services host (equivalient to CATALOGSERVICESHOST).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,
        
        ## File path containing the RES ONE Service Store MSIs or the literal path to the client MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,
        
        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROSSClient';
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
                $setup = 'RES-ITS-Client({0})-{1}.msi' -f $Architecture, $Version.ToString();
                $name = 'RES IT Store Client 2014';
            }
            8 {
                $setup = 'RES-ONE-ServiceStore-2015-Client({0})-{1}.msi' -f $Architecture, $Version.ToString();
                $name = 'RES ONE Service Store 2015 Client';
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
            Arguments = 'CATALOGSERVICESHOST="{0}" CATALOGSERVICESPASSWORD="{1}"' -f $CatalogServicesHost, $CatalogServicesCredential.GetNetworkCredential().Password;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\RES\ITStore\Client';
            InstalledCheckRegValueName = 'CatalogServicesHost';
            InstalledCheckRegValueData = $CatalogServicesHost;
            Ensure = $Ensure;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\RES\ITStore\Client';
            InstalledCheckRegValueName = 'CatalogServicesHost';
            InstalledCheckRegValueData = $CatalogServicesHost;
            Ensure = $Ensure;
        }
    }

} #end console ROSSClient
