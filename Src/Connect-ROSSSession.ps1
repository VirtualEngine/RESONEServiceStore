function Connect-ROSSSession {
<#
    .SYNOPSIS
        Authenticate and creates a connection to the RES ONE Service Store API or database.

    .EXAMPLE
        Connect-ROSSSession -Server 'servicestore.lab.local' -Credential 'LAB\Administrator'

        Create a RES ONE Service Store API session to server 'servicestore.lab.local' over HTTP.
    .EXAMPLE
        Connect-ROSSSession -Server 'servicestore.lab.local' -Credential 'LAB\Administrator' -UseHttps

        Create a RES ONE Service Store API session to server 'servicestore.lab.local' over HTTPS.
    .EXAMPLE
        Connect-ROSSSession -DatabaseServer 'controller.lab.local' -DatabaseName RESONEServiceStore

        Create a RES ONE Service Store MSSSQL database session to server 'controller.lab.local' using Windows authentication.
    .EXAMPLE
        Connect-ROSSSession -DatabaseServer 'controller.lab.local' -DatabaseName 'RESONEServiceStore' -Credential 'sa'

        Create a RES ONE Service Store MSSSQL database session to server 'controller.lab.local' using SQL authentication.
#>
    [CmdletBinding(DefaultParameterSetName = 'RestApi')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## RES ONE Service Store server hostname
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'RestApi')]
        [System.String]$Server,

        ## RES ONE Service Store database server hostname
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Database')]
        [System.String] $DatabaseServer,

        ## RES ONE Service Store database name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Database')]
        [System.String] $DatabaseName,

        ## RES ONE Service Store authentication credential
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'RestApi')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Database')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## RES ONE Service Store database name
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Database')]
        [ValidateSet('MSSQL')]
        [System.String] $Provider = 'MSSQL',

        ## Use https connection
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'RestApi')]
        [System.Management.Automation.SwitchParameter] $UseHttps,

        ## Return the session hashtable to the pipeline
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'RestApi')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Database')]
        [System.Management.Automation.SwitchParameter] $PassThru
    )
    process {

        if ($null -eq $script:_RESONEServiceStoreSession) {
            $script:_RESONEServiceStoreSession = @{};
        }

        if ($PSCmdlet.ParameterSetName -eq 'RestApi') {

            $body = @{
                username = $Credential.UserName;
                password = $Credential.GetNetworkCredential().Password;
                logintype = 'windows';
            }

            $uri = Get-ROSSResourceUri -Server $Server -Authentication -UseHttps:$UseHttps;
            $response = Invoke-ROSSRestMethod -Uri $uri -Method Post -Body $body -NoAuthorization;


            $script:_RESONEServiceStoreSession['Server'] = $Server;
            $script:_RESONEServiceStoreSession['AuthorizationToken'] = $response.AuthorizationToken;
            $script:_RESONEServiceStoreSession['UseHttps'] = $UseHttps.ToBool();
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Database') {

            $script:_RESONEServiceStoreSession['DbServer'] = $DatabaseServer;
            $script:_RESONEServiceStoreSession['DbName'] = $DatabaseName;

            [ref] $null = $PSBoundParameters.Remove('PassThru');
            if ($Provider -eq 'MSSQL') {

                $script:_RESONEServiceStoreSession['DbConnection'] = Connect-ROSSMSSQLDatabase @PSBoundParameters;
            }
        }

        if ($PassThru) {
            return $script:_RESONEServiceStoreSession;
        }

    } #end process
} #end function Connect-ROSSSession
