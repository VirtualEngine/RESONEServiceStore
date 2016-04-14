configuration ROSSCatalogServices {
<#
    .SYNOPSIS
        Installs the RES ONE Service Store Catalog Services component.
#>
    param (
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER)
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,
        
        ## RES ONE Service Store database name (equivalient to DBNAME)
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,
        
        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD)
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## File path containing the RES ONE Service Store MSIs or the literal path to the catalog services MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## RES ONE Service Store client version, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IsLiteralPath,
        
        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROSSCatalogServices';
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
                $setup = 'RES-ITS-Catalog-Services({0})-{1}.msi' -f $Architecture, $Version.ToString();
                $name = 'RES IT Store Catalog Services 2014';
            }
            8 {
                $setup = 'RES-ONE-ServiceStore-2015-Catalog-Services({0})-{1}.msi' -f $Architecture, $Version.ToString();
                $name = 'RES ONE Service Store 2015 Catalog Services';
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
            Arguments = 'DBSERVER="{0}" DBNAME="{1}" DBUSER="{2}" DBPASSWORD="{3}" DBTYPE="MSSQL"' -f $DatabaseServer, $DatabaseName, $Credential.Username, $Credential.GetNetworkCredential().Password;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\RES\ITStore\Catalog Services';
            InstalledCheckRegValueName = 'DBName';
            InstalledCheckRegValueData = $DatabaseName;
            Ensure = $Ensure;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\RES\ITStore\Catalog Services';
            InstalledCheckRegValueName = 'DBName';
            InstalledCheckRegValueData = $DatabaseName;
            Ensure = $Ensure;
        }
    }

} #end configuration ROSSCatalogServices
