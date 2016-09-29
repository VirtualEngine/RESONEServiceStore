function Get-RegistryValueIgnoreError {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>

    param (
        [Parameter(Mandatory)]
        [Microsoft.Win32.RegistryHive] $RegistryHive,

        [Parameter(Mandatory)]
        [System.String] $Key,

        [Parameter(Mandatory)]
        [System.String] $Value,

        [Parameter(Mandatory)]
        [Microsoft.Win32.RegistryView] $RegistryView
    )
    process {

        try {

            $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($RegistryHive, $RegistryView);
            $subKey =  $baseKey.OpenSubKey($Key);
            if ($null -ne $subKey) {

                return $subKey.GetValue($Value);
            }
        }
        catch {

            $exceptionText = ($_ | Out-String).Trim();
            Write-Verbose "Exception occured in Get-RegistryValueIgnoreError: $exceptionText";
        }
        return $null;

    } #end process
} #end function Get-RegistryValueIgnoreError
