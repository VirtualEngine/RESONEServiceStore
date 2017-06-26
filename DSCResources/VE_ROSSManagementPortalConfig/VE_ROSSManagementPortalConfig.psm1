data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        ResourceIncorrectPropertyState  = Resource property '{0}' is NOT in the desired state. Expected '{1}', actual '{2}'.
        ResourceInDesiredState          = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState       = Resource '{0}' is NOT in the desired state.

        MissingRequiredParametersError  = Missing required parameter(s) '{0}'.
'@
}


function Assert-TargetResourceParameter {
<#
    .SYNOPSIS
        Ensures that all IdentityBroker parameters are passed.
#>
    [CmdletBinding()]
    param (
        ## RES ONE Identity Director web management portal configuration file path
        [Parameter(Mandatory)]
        [System.String] $Path,
        
        ## RES ONE Identity Director database server/instance name"
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Identity Director database name
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,

        ## RES ONE Identity Director database Microsoft SQL username/password
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## RES ONE Identity Broker Uri
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $IdentityBrokerUrl,

        ## RES ONE Identity Director Management Portal Application/Callback Uri
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ApplicationUrl,

        ## RES ONE Identity Broker Client ID
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ClientId,

        ## RES ONE Identity Broker Client shared secret
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $ClientSecret,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $identityBrokerParameterSet = 'IdentityBrokerUrl','ApplicationUrl','ClientId','ClientSecret';
    $assertParameterCollectionParams = @{
        ParameterCollection = $PSBoundParameters;
        ParameterSet = @{
            IdentityBroker = $identityBrokerParameterSet;
        }
    }
    Assert-ParameterCollection @assertParameterCollectionParams;
    
} #end function


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## RES ONE Identity Director web management portal configuration file path
        [Parameter(Mandatory)]
        [System.String] $Path,
        
        ## RES ONE Identity Director database server/instance name"
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Identity Director database name
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,

        ## RES ONE Identity Director database Microsoft SQL username/password
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## RES ONE Identity Broker Uri
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $IdentityBrokerUrl,

        ## RES ONE Identity Director Management Portal Application/Callback Uri
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ApplicationUrl,

        ## RES ONE Identity Broker Client ID
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ClientId,

        ## RES ONE Identity Broker Client shared secret
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $ClientSecret,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Assert-TargetResourceParameter @PSBoundParameters;
    
    if (Test-Path -Path $Path -PathType Leaf) {

        $webConfig = New-Object -TypeName System.Xml.XmlDocument;
        $webConfig.Load($path);
    }

    $targetResource = @{
        Path = $Path;
        DatabaseServer = $webConfig.webConsoleConfiguration.managementService.database.server;
        DatabaseName = $webConfig.webConsoleConfiguration.managementService.database.name;
        IdentityBrokerUrl = $webConfig.webConsoleConfiguration.authentication.identityServer.authority;
        ApplicationUrl = $webConfig.webConsoleConfiguration.authentication.identityServer.redirectUrl;
        ClientId = $webConfig.webConsoleConfiguration.authentication.identityServer.clientId;
        Ensure = if (Test-Path -Path $Path -PathType Leaf) { 'Present' } else { 'Absent' }
    }
    return $targetResource;

} #end function


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## RES ONE Identity Director web management portal configuration file path
        [Parameter(Mandatory)]
        [System.String] $Path,
        
        ## RES ONE Identity Director database server/instance name"
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Identity Director database name
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,

        ## RES ONE Identity Director database Microsoft SQL username/password
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## RES ONE Identity Broker Uri
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $IdentityBrokerUrl,

        ## RES ONE Identity Director Management Portal Application/Callback Uri
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ApplicationUrl,

        ## RES ONE Identity Broker Client ID
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ClientId,

        ## RES ONE Identity Broker Client shared secret
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $ClientSecret,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    $isInDesiredState = $true;

    if ($Ensure -ne $targetResource.Ensure) {
    
        Write-Verbose -Message ($localizedData.ResourceIncorrectPropertyState -f 'Ensure', $Ensure, $targetResource.Ensure);
        $isInDesiredState = $false;
    }
    elseif ($Ensure -eq 'Present') {
    
        $checkParameterNames = @('DatabaseServer','DatabaseName','IdentityBrokerUrl','ApplicationUrl','ClientId')
        
        foreach ($parameter in $PSBoundParameters.GetEnumerator()) {

            if ($parameter.Key -in $checkParameterNames) {

                if ($parameter.Value -ne $targetResource[$parameter.Key]) {

                    Write-Verbose -Message ($localizedData.ResourceIncorrectPropertyState -f $parameter.Key, $parameter.Value, $targetResource[$parameter.Key]);
                    $isInDesiredState = $false;
                }
            }
        }
    }

    if ($isInDesiredState) {
        
        Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $Path);
        return $true;
    }
    else {
        
        Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $Path);
        return $false;
    }

} #end function


function Set-TargetResource {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        ## RES ONE Identity Director web management portal configuration file path
        [Parameter(Mandatory)]
        [System.String] $Path,
        
        ## RES ONE Identity Director database server/instance name"
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Identity Director database name
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,

        ## RES ONE Identity Director database Microsoft SQL username/password
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## RES ONE Identity Broker Uri
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $IdentityBrokerUrl,

        ## RES ONE Identity Director Management Portal Application/Callback Uri
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ApplicationUrl,

        ## RES ONE Identity Broker Client ID
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ClientId,

        ## RES ONE Identity Broker Client shared secret
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $ClientSecret,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Assert-TargetResourceParameter @PSBoundParameters;
    $null = $PSBoundParameters.Remove('Ensure');

    if ($Ensure -eq 'Present') {

        Save-ROSSManagementPortalConfiguration @PSBoundParameters;
    }
    else {

        $null = Remove-Item -Path $Path -Force;
    }

} #end function


## Import the ROSS common library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'ROSSCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
