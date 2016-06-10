# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        ResourceIncorrectPropertyState  = Resource property '{0}' is NOT in the desired state. Expected '{1}', actual '{2}'.
        ResourceInDesiredState          = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState       = Resource '{0}' is NOT in the desired state.
        DiscoveredSiteId                = Discovered Site Id '{0}'.
'@
}


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## RES ONE Service Store default (NetBIOS) domain name.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## IIS website host header, i.e. http://itstore.lab.local.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $HostHeader,

        ## RES ONE Service Store Catalog Services password (equivalient to CATALOGSERVICESPASSWORD).
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,

        ## RES ONE Service Store Catalog Services host (equivalient to CATALOGSERVICESHOST).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,

        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## IIS website port binding.
        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()] [ValidateNotNull()]
        [System.UInt16] $Port = 80,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $setupPath = ResolveROSSPackagePath -Path $Path -Component 'WebPortal' -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    [System.String] $msiProductName = GetWindowsInstallerPackageProperty -Path $setupPath -Property ProductName;
    $productName = $msiProductName.Trim();

    $targetResource = @{
        Path = $setupPath;
        ProductName = $productName;
        Ensure = if (GetProductEntry -Name $productName) { 'Present' } else { 'Absent' };
    }
    return $targetResource;

} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## RES ONE Service Store default (NetBIOS) domain name.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## IIS website host header, i.e. http://itstore.lab.local.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $HostHeader,

        ## RES ONE Service Store Catalog Services password (equivalient to CATALOGSERVICESPASSWORD).
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,

        ## RES ONE Service Store Catalog Services host (equivalient to CATALOGSERVICESHOST).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,

        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## IIS website port binding.
        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()] [ValidateNotNull()]
        [System.UInt16] $Port = 80,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()] [ValidateSet('Present','Absent')]
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

} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    param (
        ## RES ONE Service Store default (NetBIOS) domain name.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## IIS website host header, i.e. http://itstore.lab.local.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $HostHeader,

        ## RES ONE Service Store Catalog Services password (equivalient to CATALOGSERVICESPASSWORD).
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,

        ## RES ONE Service Store Catalog Services host (equivalient to CATALOGSERVICESHOST).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,

        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## IIS website port binding.
        ## NOTE: Only HTTP binding is supported by the installer; HTTPS binding will need to be managed by another DSC resource/configuration.
        [Parameter()] [ValidateNotNull()]
        [System.UInt16] $Port = 80,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $setupPath = ResolveROSSPackagePath -Path $Path -Component 'WebPortal' -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    if ($Ensure -eq 'Present') {

        $arguments = @(
            ('/i "{0}"' -f $setupPath),
            ('DEFAULTDOMAIN="{0}"' -f $DefaultDomain),
            ('ITSTOREHOSTNAME="{0}"' -f $HostHeader),
            ('ITSTOREPORT="{0}"' -f $Port),
            ('CATALOGSERVICESHOST="{0}"' -f $CatalogServicesHost),
            ('CATALOGSERVICESPASSWORD="{0}"' -f $CatalogServicesCredential.GetNetworkCredential().Password)
        )

    }
    elseif ($Ensure -eq 'Absent') {

        [System.String] $msiProductCode = GetWindowsInstallerPackageProperty -Path $setupPath -Property ProductCode;
        $arguments = @(
            ('/X{0}' -f $msiProductCode)
        )

    }

    ## Start install/uninstall
    $arguments += '/norestart';
    $arguments += '/qn';
    StartWaitProcess -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $arguments -Verbose:$Verbose;

} #end function Set-TargetResource


## Import the ROSS common library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'VE_ROSSCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
