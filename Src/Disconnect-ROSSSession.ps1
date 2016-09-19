function Disconnect-ROSSSession {
<#
    .SYNOPSIS
        Disconnects connections to the RES ONE Service Store API and/or database..
#>
    [CmdletBinding()]
    param (
        # RES ONE Service Store session connection.
        [Parameter()]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession
    )
    process {

        if ($null -ne $Session) {
            Close-ROSSDatabaseConnection -Session $Session;
            $Session = $null;
        }

    } #end process
} #end function Disconnect-ROSSSession
