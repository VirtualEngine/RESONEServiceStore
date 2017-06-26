function Save-ROSSMobileGatewayConfiguration {
<#
    .SYNOPSIS
        Writes a RES ONE Identity Director Mobile Gateway web configuration file.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'WindowsAuthentication')]
    param (
        ## Path to RES ONE Identity Director Mobile Gateway web configuration file
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
        [System.Management.Automation.PSCredential] $Credential
    )

    $mobileGatewayConfigTemplate = @'
<serviceConfiguration>
  <clientService port="80">
    <#DatabaseServicePlaceholder#>  
    <session renewal="30" renewaltimeunits="Minutes" expiration="7" expirationtimeunits="Days" />
    <panels cacheenabled="true" cacheexpiration="5" cacheexpirationtimeunits="Minutes" />
    <notifications enabled="true" detailed="true" checkinterval="5" checkintervaltimeunits="Seconds" cleanupinterval="1" cleanupintervaltimeunits="Hours" sessionexpiration="7" sessionexpirationtimeunits="Days">
      <discovery type="Lookup" connectionstring="cs.push.ross.res.com" hubname="hn.push.ross.res.com" />
    </notifications>
  </clientService>
</serviceConfiguration>
'@

$mobileGatewayDatabaseServiceSqlAuthenticationTemplate = @'
<database type="<#DatabaseType#>" server="<#DatabaseServer#>" name="<#DatabaseName#>" user="<#DatabaseUser#>" password="<#DatabasePassword#>" useWindowsAuthentication="false" />
'@

$mobileGatewayDatabaseServiceWindowsAuthenticationTemplate = @'
<database type="<#DatabaseType#>" server="<#DatabaseServer#>" name="<#DatabaseName#>" user="" password="" useWindowsAuthentication="true" />
'@

    if ($null -ne $Credential) {
    
        $databaseService = $mobileGatewayDatabaseServiceSqlAuthenticationTemplate;
        $databaseService = $databaseService.Replace('<#DatabaseUser#>', $Credential.Username);
        $databaseService = $databaseService.Replace('<#DatabasePassword#>', $Credential.GetNetworkCredential().Password);
    }
    else {

        $databaseService = $mobileGatewayDatabaseServiceWindowsAuthenticationTemplate;
    }
    
    $databaseService = $databaseService.Replace('<#DatabaseType#>', 'MSSQL');
    $databaseService = $databaseService.Replace('<#DatabaseServer#>', $DatabaseServer);
    $databaseService = $databaseService.Replace('<#DatabaseName#>', $DatabaseName);
    $mobileGatewayConfig = $mobileGatewayConfigTemplate.Replace('<#DatabaseServicePlaceholder#>', $databaseService);


    Set-Content -Value $mobileGatewayConfig -Path $Path -Encoding UTF8;

} #end function
