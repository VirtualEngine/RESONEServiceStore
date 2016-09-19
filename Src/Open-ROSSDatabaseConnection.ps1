function Open-ROSSDatabaseConnection {
<#
    .SYNOPSIS
        Opens a RES ONE Service Store database connection.
    .NOTES
        Adapted from the VirtualEngine.Database module.
#>
    [CmdletBinding()]
    param (
        # Microsoft SQL server connection
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Data.Common.DbConnection] $Connection
    )
    process {

        if ($Connection.State -eq 'Closed') {

            Write-Debug "Connection is closed. Attempting to open..";
            $Connection.Open();

        }
        else {

            Write-Debug "Connection is already open.";
        } #end if

    } #end process
} #end function Open-ROSSDatabaseConnection
