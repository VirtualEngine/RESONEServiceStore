configuration ROSSManagementPortal {
<#
    .SYNOPSIS
        Installs the RES ONE Service Store web management console/portal.
    .NOTES
        This is NOT applicable to RES IT Store 2014 installations.
#>
    param (
        ## IIS website host header, i.e. http://itstore.lab.local.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $HostHeader,
        
        ## File path containing the RES ONE Service Store MSIs or the literal path to the management portal MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## IIS website port binding.
        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()]
        [System.Int32] $Port = 80,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROSSManagementPortal';
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
                Write-Warning ('RES ONE Service Store Management Portal/Console is not available in version ''{0}'' and won''t be installed.' -f $Version);
                return;
            }
            8 {
                $setup = 'RES-ONE-ServiceStore-2015-Management-Portal-{0}.msi' -f $Version.ToString();
            }
            Default {
                throw "$resourceName : Version '$($Version.Tostring())' is not currently supported :(.";
            }
        }
        $Path = Join-Path -Path $Path -ChildPath $setup;
    }

    if ($Ensure -eq 'Present') {
        xPackage $resourceName {
            Name = 'RES ONE Service Store 2015 Management Portal';
            ProductId = '';
            Path = $Path;
            Arguments = 'ITSTOREHOSTNAME="{0}" ITSTOREPORT="{1}"' -f $HostHeader, $Port;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\VirtualEngine\DSC\RES\ServiceStore';
            InstalledCheckRegValueName = 'ManagementPortal';
            InstalledCheckRegValueData = 'Installed';
            CreateCheckRegValue = $true;
            Ensure = $Ensure;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        xPackage $resourceName {
            Name = 'RES ONE Service Store 2015 Management Portal';
            ProductId = '';
            Path = $Path;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\VirtualEngine\DSC\RES\ServiceStore';
            InstalledCheckRegValueName = 'ManagementPortal';
            InstalledCheckRegValueData = 'Installed';
            CreateCheckRegValue = $true;
            Ensure = $Ensure;
        }
    }

} #end configuration ROSSMangementPortal
