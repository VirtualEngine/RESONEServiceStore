data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        ResourceIncorrectPropertyState  = Resource property '{0}' is NOT in the desired state. Expected '{1}', actual '{2}'.
        ResourceInDesiredState          = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState       = Resource '{0}' is NOT in the desired state.
'@
}


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## IIS website host header/name, i.e. res.lab.local.
        [Parameter(Mandatory)]
        [System.String] $HostHeader,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the management portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Installed certificate thumbprint to bind to the IIS site.
        [Parameter(Mandatory)]
        [System.String] $CertificateThumbprint,

        ## IIS website port binding.
        ## NOTE: equivalient to the PORT_SSL parameter.
        [Parameter()]
        [System.UInt16] $Port,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $resolveROSSPackagePathParams = @{
        Path = $Path;
        Component = 'MobileGateway';
        Version = $Version;
        IsLiteralPath = $IsLiteralPath;
        Verbose = $Verbose;
    }
    $setupPath = Resolve-ROSSPackagePath @resolveROSSPackagePathParams;

    [System.String] $msiProductName = Get-WindowsInstallerPackageProperty -Path $setupPath -Property ProductName;
    $productName = $msiProductName.Trim();

    $targetResource = @{
        HostHeader = $HostHeader;
        Path = $setupPath;
        CertificateThumbprint = $CertificateThumbprint;
        ProductName = $productName;
        Ensure = if (Get-InstalledProductEntry -Name $productName) { 'Present' } else { 'Absent' };
    }
    return $targetResource;

} #end function


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## IIS website host header/name, i.e. res.lab.local.
        [Parameter(Mandatory)]
        [System.String] $HostHeader,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the management portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Installed certificate thumbprint to bind to the IIS site.
        [Parameter(Mandatory)]
        [System.String] $CertificateThumbprint,

        ## IIS website port binding.
        ## NOTE: equivalient to the PORT_SSL parameter.
        [Parameter()]
        [System.UInt16] $Port,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;

    if ($Ensure -ne $targetResource.Ensure) {

        Write-Verbose -Message ($localizedData.ResourceIncorrectPropertyState -f 'Ensure', $Ensure, $targetResource.Ensure);
        Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $targetResource.ProductName);
        return $false;

    }
    else {

        Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $targetResource.ProductName);
        return $true;

    }

} #end function


function Set-TargetResource {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        ## IIS website host header/name, i.e. res.lab.local.
        [Parameter(Mandatory)]
        [System.String] $HostHeader,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the management portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Installed certificate thumbprint to bind to the IIS site.
        [Parameter(Mandatory)]
        [System.String] $CertificateThumbprint,

        ## IIS website port binding.
        ## NOTE: equivalient to the PORT_SSL parameter.
        [Parameter()]
        [System.UInt16] $Port,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $resolveROSSPackagePathParams = @{
        Path = $Path;
        Component = 'MobileGateway';
        Version = $Version;
        IsLiteralPath = $IsLiteralPath;
        Verbose = $Verbose;
    }
    $setupPath = Resolve-ROSSPackagePath @resolveROSSPackagePathParams;

    if ($Ensure -eq 'Present') {

        $arguments = @(
            ('/i "{0}"' -f $setupPath),
            ('HOST_SSL="{0}"' -f $HostHeader),
            ('SSL_CERTIFICATE_THUMBPRINT="{0}"' -f $CertificateThumbprint)
        )

        if ($PSBoundParameters.ContainsKey('Port')) {

            $arguments += 'PORT_SSL="{0}"' -f $Port;
        }

    }
    elseif ($Ensure -eq 'Absent') {

        [System.String] $msiProductCode = Get-WindowsInstallerPackageProperty -Path $setupPath -Property ProductCode;
        $arguments = @(
            ('/X{0}' -f $msiProductCode)
        )

    }

    ## Start install/uninstall
    $arguments += '/norestart';
    $arguments += '/qn';
    Start-WaitProcess -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $arguments -Verbose:$Verbose;

} #end function


## Import the ROSS common library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'ROSSCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
