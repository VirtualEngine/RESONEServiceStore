function Assert-ROSSSession {
<#
    .SYNOPSIS
        Ensures there is an authenticated RES ONE Service Store session established.
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession
    )
    process {

        if ($null -eq $Session) {
            throw 'Must be connected/authorised by the RES ONE Service Store first!';
        }

    } #end process
} #end function Assert-ROSSSession
