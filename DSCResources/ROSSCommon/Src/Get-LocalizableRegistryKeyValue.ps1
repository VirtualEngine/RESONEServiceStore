function Get-LocalizableRegistryKeyValue {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Object] $RegistryKey,

        [Parameter()]
        [System.String] $ValueName
    )
    process {

        $result = $RegistryKey.GetValue("{0}_Localized" -f $ValueName);
        if (-not $result) {
            $result = $RegistryKey.GetValue($ValueName);
        }
        return $result;

    }
} #end function Get-LocalizableRegistryKeyValue
