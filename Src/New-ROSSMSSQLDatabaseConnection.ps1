function New-ROSSMSSQLDatabaseConnection {
<#
    .SYNOPSIS
        Creates a new RES ONE Service Store Microsoft SQL Server connection using either Windows or SQL authentication.
    .NOTES
        Adapted from the VirtualEngine.Database module.
#>
    [CmdletBinding(DefaultParameterSetName = 'WindowsAuthentication')]
    [OutputType([System.Data.Common.DbConnection])]
    param (
        # Database server to connect to
        [Parameter(Mandatory, ParameterSetName = 'SQLAuthentication')]
        [Parameter(Mandatory, ParameterSetName = 'WindowsAuthentication')]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        # Database instance/name
        [Parameter(Mandatory, ParameterSetName = 'SQLAuthentication')]
        [Parameter(Mandatory, ParameterSetName = 'WindowsAuthentication')]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        # SQL authentication username
        [Parameter(Mandatory, ParameterSetName='SQLAuthentication')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        # User the specified connection string
        [Parameter(Mandatory, ParameterSetName = 'ConnectionString')]
        [System.String] $ConnectionString
    )
    begin {

        Write-Debug ("Using parameter set '{0}'." -f $PSCmdlet.ParameterSetName);
    }
    process {

        if ($PSCmdlet.ParameterSetName -ne 'ConnectionString') {

            $ConnectionString = 'Data Source={0};Initial Catalog={1};' -f $DatabaseServer, $DatabaseName;

            if ($PSCmdlet.ParameterSetName -eq 'SQLAuthentication') {

                $ConnectionString += 'User Id={0};Password={1};' -f $Username, $Password;
            }
            else {

                $ConnectionString += 'Integrated Security=SSPI;';
            }
        }

        Write-Debug ("Using connection string '{0}'." -f $ConnectionString);
        New-Object -TypeName System.Data.SqlClient.SqlConnection -Property @{ 'ConnectionString' = $ConnectionString };

    } #end process
} #end function New-ROSSMSSQLDatabaseConnection
