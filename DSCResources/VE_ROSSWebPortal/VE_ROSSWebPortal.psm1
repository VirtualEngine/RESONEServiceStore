data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        ResourceIncorrectPropertyState  = Resource property '{0}' is NOT in the desired state. Expected '{1}', actual '{2}'.
        ResourceInDesiredState          = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState       = Resource '{0}' is NOT in the desired state.
'@
}


function Assert-TargetResourceParameter {
<#
    .SYNOPSIS
        Ensures parameters match product version-specific parameters.
#>
    [CmdletBinding()]
    param (
        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## IIS website host header, i.e. http://itstore.lab.local (v9.1 and ealier) or res.lab.local (v10 and later).
        ## NOTE: equivalent to the ITSTOREHOSTNAME and HOST_SSL parameters.
        [Parameter(Mandatory)]
        [System.String] $HostHeader,
        
        ## RES ONE Service Store default (NetBIOS) domain name (v9.1 and earlier).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## RES ONE Service Store Catalog Services password (v9.1 and earlier).
        ## NOTE: equivalient to CATALOGSERVICESPASSWORD parameter.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,

        ## RES ONE Service Store Catalog Services hostname (v9.1 and earlier).
        ## NOTE: equivalient to the CATALOGSERVICESHOST parameter.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,

        ## Installed certificate thumbprint to bind to the IIS site (v10 and later).
        ## NOTE: equivalient to the SSL_CERTIFICATE_THUMBPRINT parameter.
        [Parameter()]
        [System.String] $CertificateThumbprint,

        ## IIS website port binding.
        ## NOTE: equivalient to the ITSTOREPORT pr PORT_SSL parameter.
        [Parameter()]
        [System.UInt16] $Port,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $productVersion = ConvertTo-PSCustomObjectVersion -Version $Version;
    switch ($productVersion.Major) {

        9 {
            $assertParameterCollectionParams = @{
                ParameterCollection = $PSBoundParameters;
                RequiredParameterName = 'DefaultDomain','CatalogServicesCredential','CatalogServicesHost';
                InvalidParameterName = 'CertificateThumbprint';
                AppendString = '(version 9)';
            }
            Assert-ParameterCollection @assertParameterCollectionParams;
        }

        10 {
            $assertParameterCollectionParams = @{
                ParameterCollection = $PSBoundParameters;
                RequiredParameterName = 'CertificateThumbprint';
                InvalidParameterName = 'DefaultDomain','CatalogServicesCredential','CatalogServicesHost';
                AppendString = '(version 10)';
            }
            Assert-ParameterCollection @assertParameterCollectionParams;
        }
    }

} #end function


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## IIS website host header, i.e. http://itstore.lab.local (v9.1 and ealier) or res.lab.local (v10 and later).
        ## NOTE: equivalent to the ITSTOREHOSTNAME and HOST_SSL parameters.
        [Parameter(Mandatory)]
        [System.String] $HostHeader,
        
        ## RES ONE Service Store default (NetBIOS) domain name (v9.1 and earlier).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## RES ONE Service Store Catalog Services password (v9.1 and earlier).
        ## NOTE: equivalient to CATALOGSERVICESPASSWORD parameter.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,

        ## RES ONE Service Store Catalog Services hostname (v9.1 and earlier).
        ## NOTE: equivalient to the CATALOGSERVICESHOST parameter.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,

        ## Installed certificate thumbprint to bind to the IIS site (v10 and later).
        ## NOTE: equivalient to the SSL_CERTIFICATE_THUMBPRINT parameter.
        [Parameter()]
        [System.String] $CertificateThumbprint,

        ## IIS website port binding.
        ## NOTE: equivalient to the ITSTOREPORT pr PORT_SSL parameter.
        [Parameter()]
        [System.UInt16] $Port,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Assert-TargetResourceParameter @PSBoundParameters;

    $resolveROSSPackagePathParams = @{
        Path = $Path;
        Component = 'WebPortal';
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
        ProductName = $productName;
        Ensure = if (Get-InstalledProductEntry -Name $productName) { 'Present' } else { 'Absent' };
    }
    return $targetResource;

} #end function


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## IIS website host header, i.e. http://itstore.lab.local (v9.1 and ealier) or res.lab.local (v10 and later).
        ## NOTE: equivalent to the ITSTOREHOSTNAME and HOST_SSL parameters.
        [Parameter(Mandatory)]
        [System.String] $HostHeader,
        
        ## RES ONE Service Store default (NetBIOS) domain name (v9.1 and earlier).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## RES ONE Service Store Catalog Services password (v9.1 and earlier).
        ## NOTE: equivalient to CATALOGSERVICESPASSWORD parameter.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,

        ## RES ONE Service Store Catalog Services hostname (v9.1 and earlier).
        ## NOTE: equivalient to the CATALOGSERVICESHOST parameter.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,

        ## Installed certificate thumbprint to bind to the IIS site (v10 and later).
        ## NOTE: equivalient to the SSL_CERTIFICATE_THUMBPRINT parameter.
        [Parameter()]
        [System.String] $CertificateThumbprint,

        ## IIS website port binding.
        ## NOTE: equivalient to the ITSTOREPORT pr PORT_SSL parameter.
        [Parameter()]
        [System.UInt16] $Port,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
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
        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## IIS website host header, i.e. http://itstore.lab.local (v9.1 and ealier) or res.lab.local (v10 and later).
        ## NOTE: equivalent to the ITSTOREHOSTNAME and HOST_SSL parameters.
        [Parameter(Mandatory)]
        [System.String] $HostHeader,
        
        ## RES ONE Service Store default (NetBIOS) domain name (v9.1 and earlier).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultDomain,

        ## RES ONE Service Store Catalog Services password (v9.1 and earlier).
        ## NOTE: equivalient to CATALOGSERVICESPASSWORD parameter.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $CatalogServicesCredential,

        ## RES ONE Service Store Catalog Services hostname (v9.1 and earlier).
        ## NOTE: equivalient to the CATALOGSERVICESHOST parameter.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $CatalogServicesHost,

        ## Installed certificate thumbprint to bind to the IIS site (v10 and later).
        ## NOTE: equivalient to the SSL_CERTIFICATE_THUMBPRINT parameter.
        [Parameter()]
        [System.String] $CertificateThumbprint,

        ## IIS website port binding.
        ## NOTE: equivalient to the ITSTOREPORT pr PORT_SSL parameter.
        [Parameter()]
        [System.UInt16] $Port,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $resolveROSSPackagePathParams = @{
        Path = $Path;
        Component = 'WebPortal';
        Version = $Version;
        IsLiteralPath = $IsLiteralPath;
        Verbose = $Verbose;
    }
    $setupPath = Resolve-ROSSPackagePath @resolveROSSPackagePathParams;

    if ($Ensure -eq 'Present') {

        $productVersion = ConvertTo-PSCustomObjectVersion -Version $Version;
        if ($productVersion.Major -ge 10) {

            $arguments = @(
                ('/i "{0}"' -f $setupPath),
                ('HOST_SSL="{0}"' -f $HostHeader),
                ('SSL_CERTIFICATE_THUMBPRINT="{0}"' -f $CertificateThumbprint)
            )

            if ($PSBoundParameters.ContainsKey('Port')) {

                $arguments += 'PORT_SSL="{0}"' -f $Port;
            }

        }
        else {

            $arguments = @(
                ('/i "{0}"' -f $setupPath),
                ('DEFAULTDOMAIN="{0}"' -f $DefaultDomain),
                ('ITSTOREHOSTNAME="{0}"' -f $HostHeader),
                ('CATALOGSERVICESHOST="{0}"' -f $CatalogServicesHost),
                ('CATALOGSERVICESPASSWORD="{0}"' -f $CatalogServicesCredential.GetNetworkCredential().Password)
            )

            if ($PSBoundParameters.ContainsKey('Port')) {

                $arguments += 'ITSTOREPORT="{0}"' -f $Port;
            }
                
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
