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
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        ## RES ONE Service Store database name (equivalient to DBNAME).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the transaction engine MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $setupPath = ResolveROSSPackagePath -Path $Path -Component 'TransactionEngine' -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
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
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        ## RES ONE Service Store database name (equivalient to DBNAME).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the legacy console/Sync Tool MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

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
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        ## RES ONE Service Store database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        ## RES ONE Service Store database name (equivalient to DBNAME).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the legacy console/Sync Tool MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Service Store component version to be installed, i.e. 8.0.3.0
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified $Path is a literal file reference (bypasses the $Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $setupPath = ResolveROSSPackagePath -Path $Path -Component 'TransactionEngine' -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
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
