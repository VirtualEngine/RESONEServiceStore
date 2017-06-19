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
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER)
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Service Store database name (equivalient to DBNAME)
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD)
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the catalog services MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## RES ONE Service Store client version, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $resolveROSSPackagePathParams = @{
        Path = $Path;
        Component = 'CatalogServices';
        Version = $Version;
        IsLiteralPath = $IsLiteralPath;
        Verbose = $Verbose;
    }
    $setupPath = Resolve-ROSSPackagePath @resolveROSSPackagePathParams;

    [System.String] $msiProductName = Get-WindowsInstallerPackageProperty -Path $setupPath -Property ProductName;
    $productName = $msiProductName.Trim();

    $targetResource = @{
        Path = $setupPath;
        ProductName = $productName;
        Ensure = if (Get-InstalledProductEntry -Name $productName) { 'Present' } else { 'Absent' };
    }
    return $targetResource;

} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER)
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Service Store database name (equivalient to DBNAME)
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD)
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the catalog services MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## RES ONE Service Store client version, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IsLiteralPath,

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
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER)
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Service Store database name (equivalient to DBNAME)
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD)
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the catalog services MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## RES ONE Service Store client version, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $resolveROSSPackagePathParams = @{
        Path = $Path;
        Component = 'CatalogServices';
        Version = $Version;
        IsLiteralPath = $IsLiteralPath;
        Verbose = $Verbose;
    }
    $setupPath = Resolve-ROSSPackagePath @resolveROSSPackagePathParams;

    if ($Ensure -eq 'Present') {

        $arguments = @(
            ('/i "{0}"' -f $setupPath),
            ('DBSERVER="{0}"' -f $DatabaseServer),
            ('DBNAME="{0}"' -f $DatabaseName),
            ('DBUSER="{0}"' -f $Credential.Username),
            ('DBPASSWORD="{0}"' -f $Credential.GetNetworkCredential().Password),
            ('DBTYPE="MSSQL"')
        )

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

} #end function Set-TargetResource


## Import the ROSS common library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'ROSSCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
