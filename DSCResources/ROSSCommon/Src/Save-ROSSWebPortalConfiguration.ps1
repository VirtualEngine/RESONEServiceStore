function Save-ROSSWebPortalConfiguration {
<#
    .SYNOPSIS
        Writes a RES ONE Identity Director Web Portal web configuration file.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'WindowsAuthentication')]
    param (
        ## Path to RES ONE Identity Director Management Portal web configuration file
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        ## RES ONE Identity Director database server/instance name.
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Identity Director database name.
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,
        
        ## RES ONE Identity Director database access credential. Leave blank to use Windows Authentication for database access.
        [Parameter()]
        [System.Management.Automation.PSCredential] $Credential,

        ## RES ONE Identity Broker server Uri.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $IdentityBrokerUrl,

        ## RES ONE Identity Broker application Uri.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $ApplicationUrl,

        ## RES ONE Identity Broker client Id.        
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $ClientId,

        ## RES ONE Identity Broker client shared secret.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.Management.Automation.PSCredential] $ClientSecret
    )

    $webPortalConfigTemplate = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<webPortalConfiguration>
  <managementService port="0" protocol="http">
    <#ManagementServicePlaceholder#>
    <logFile maxLogFileSizeKB="10240" enabled="false" severity="Debug"
      path="" />
  </managementService>
  <#AuthenticationPlaceholder#>
  <security symmetricKey="sskTiNVsBWDHaEATMTISbLSAWS" />
</webPortalConfiguration>
'@

$webPortalManagementServiceSqlAuthenticationTemplate = @'
<database type="<#DatabaseType#>" server="<#DatabaseServer#>" name="<#DatabaseName#>"
      user="<#DatabaseUser#>" password="<#DatabasePassword#>"
      useWindowsAuthentication="false" />
'@

$webPortalManagementServiceWindowsAuthenticationTemplate = @'
<database type="<#DatabaseType#>" server="<#DatabaseServer#>" name="<#DatabaseName#>"
      useWindowsAuthentication="true" />
'@

$webPortalSqlAuthenticationTemplate = @'
<authentication type="IdentityBroker">
    <identityBroker authority="<#ServerUrl#>"
    redirectUri="<#ApplicationUrl#>" clientId="<#ClientId#>"
    clientSecret="<#ClientSecret#>" />
  </authentication>
'@

$webPortalWindowsAuthenticationTemplate = @'
<authentication type="Windows" />
'@
    
    if ($null -ne $Credential) {
    
        $managementService = $webPortalManagementServiceSqlAuthenticationTemplate;
        $managementService = $managementService.Replace('<#DatabaseUser#>', $Credential.Username);
        $managementService = $managementService.Replace('<#DatabasePassword#>', $Credential.GetNetworkCredential().Password);
    }
    else {

        $managementService = $webPortalManagementServiceWindowsAuthenticationTemplate;
    }
    
    $managementService = $managementService.Replace('<#DatabaseType#>', 'MSSQL');
    $managementService = $managementService.Replace('<#DatabaseServer#>', $DatabaseServer);
    $managementService = $managementService.Replace('<#DatabaseName#>', $DatabaseName);
    $webPortalConfig = $webPortalConfigTemplate.Replace('<#ManagementServicePlaceholder#>', $managementService);

    if ($PSCmdlet.ParameterSetName -eq 'IdentityBroker') {

        $identityServer = $webPortalSqlAuthenticationTemplate;
        $identityServer = $identityServer.Replace('<#ServerUrl#>', $IdentityBrokerUrl);
        $identityServer = $identityServer.Replace('<#ApplicationUrl#>', $ApplicationUrl);
        $identityServer = $identityServer.Replace('<#ClientId#>', $ClientId);
        $identityServer = $identityServer.Replace('<#ClientSecret#>', $ClientSecret.GetNetworkCredential().Password);

        $webPortalConfig = $webPortalConfig.Replace('<#AuthenticationPlaceholder#>', $identityServer);
    }
    else {

        $webPortalConfig = $webPortalConfig.Replace('<#AuthenticationPlaceholder#>', $webPortalWindowsAuthenticationTemplate);
    }

    Set-Content -Value $webPortalConfig -Path $Path -Encoding UTF8;

} #end function
