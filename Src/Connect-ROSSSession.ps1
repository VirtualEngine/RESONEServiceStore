function Connect-ROSSSession {
<#
    .SYNOPSIS
        Authenticates to the RES ONE Service Store API.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## RES ONE Service Store server hostname
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Server,

        ## RES ONE Service Store authentication credential
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## Use https connection
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $UseHttps,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $PassThru
    )
    process {

        $body = @{
            username = $Credential.UserName;
            password = $Credential.GetNetworkCredential().Password;
            logintype = 'windows';
        }

        $uri = Get-ROSSResourceUri -Server $Server -Authentication -UseHttps:$UseHttps;
        $response = Invoke-ROSSRestMethod -Uri $uri -Method Post -Body $body -NoAuthorization;

        $script:_RESONEServiceStoreSession = @{
            Server = $Server;
            AuthorizationToken = $response.AuthorizationToken;
            UseHttps = $UseHttps.ToBool();
        }

        if ($PassThru) {
            return $script:_RESONEServiceStoreSession;
        }

    } #end process
} #end function Connect-ROSSSession