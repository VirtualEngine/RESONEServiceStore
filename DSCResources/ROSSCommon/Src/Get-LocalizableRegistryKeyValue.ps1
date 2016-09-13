function Get-LocalizableRegistryKeyValue {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>

    param (
        [Parameter()]
        [System.Object] $RegKey,

        [Parameter()]
        [System.String] $ValueName
    )

    $res = $RegKey.GetValue("{0}_Localized" -f $ValueName);
    if (-not $res) {
        $res = $RegKey.GetValue($ValueName);
    }
    return $res;
} #end function Get-LocalizableRegistryKeyValue
