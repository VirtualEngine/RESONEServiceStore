function Close-ROSSDatabaseConnection {
<#
    .SYNOPSIS
        Closes a RES ONE Service Store database connection.
    .NOTES
        Adapted from the VirtualEngine.Database module.
#>
    [CmdletBinding()]
    param (
        # RES ONE Service Store session connection.
        [Parameter()]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession
    )
    process {

        if (($null -ne $Session) -and ($null -ne $Session.DbConnection)) {

            if ($Session.DbConnection.State -ne 'Closed') {
                Write-Debug "Attempting to close connection..";
                $Session.DbConnection.Close();

                ## Clear the exising session
                $Session.DbServer = $null;
                $Session.DbName = $null;
                $Session.DbConnection = $null;
            }
            else {

                Write-Debug "Connection is already closed.";
            }
        }

    } #end process
} #end function Close-ROSSDatabaseConnection
