function Assert-ROSSSession {
<#
    .SYNOPSIS
        Ensures there is an authenticated RES ONE Service Store session established.
#>
    [CmdletBinding()]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        ## Assert database connection. By default, RES ONE Service Store API session is checked.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter]
        $Database
    )
    process {

        if ($null -eq $Session) {
            throw $localizedData.NoSessionEstablishedError;
        }

        if ($Database) {
            $properties = 'DbServer','DbName','DbConnection';
        }
        else {
            $properties = 'Server','AuthorizationToken','UseHttps';
        }

        ## Check each property and throw if null
        foreach ($property in $properties) {

            if ($null -eq $Session[$property]) {
                throw $localizedData.NoSessionEstablishedError;
            }
        }

    } #end process
} #end function Assert-ROSSSession
