function ConvertTo-PSCustomObjectVersion {
<#
.SYNOPSIS
    Converts a string to a PSCustomObject version object.
.DESCRIPTION
    [System.Version] does not support just a major number and therefore, we have to roll our own..
#>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Version
    )
    process {

        $versionSplit = $Version.Split('.');
        $productVersion = [PSCustomObject] @{
            Major = $versionSplit[0] -as [System.Int32];
            Minor = if ($versionSplit[1]) { $versionSplit[1] -as [System.Int32] } else { -1 }
            Build = if ($versionSplit[2]) { $versionSplit[2] -as [System.Int32] } else { -1 }
            Revision = if ($versionSplit[3]) { $versionSplit[3] -as [System.Int32] } else { -1 }
        }
        return $productVersion;
        
    } #end process
} #end function
