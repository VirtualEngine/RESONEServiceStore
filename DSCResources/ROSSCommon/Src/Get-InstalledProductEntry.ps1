function Get-InstalledProductEntry {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>
    param (
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $IdentifyingNumber,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegHive = 'LocalMachine',

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegKey,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegValueName,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegValueData
    )

    $uninstallKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
    $uninstallKeyWow64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall';

    if ($IdentifyingNumber) {
        $keyLocation = '{0}\{1}' -f $uninstallKey, $identifyingNumber;
        $item = Get-Item $keyLocation -ErrorAction SilentlyContinue;
        if (-not $item) {
            $keyLocation = '{0}\{1}' -f $uninstallKeyWow64, $identifyingNumber;
            $item = Get-Item $keyLocation -ErrorAction SilentlyContinue;
        }
        return $item;
    }

    foreach ($item in (Get-ChildItem -ErrorAction Ignore $uninstallKey, $uninstallKeyWow64)) {
        if ($Name -eq (Get-LocalizableRegistryKeyValue $item 'DisplayName')) {
            return $item;
        }
    }

    if ($InstalledCheckRegKey -and $InstalledCheckRegValueName -and $InstalledCheckRegValueData) {
        $installValue = $null;
        $Get-RegistryValueIgnoreErrorParams = @{
            RegistryHive = $InstalledCheckRegHive;
            Key = $InstalledCheckRegKey;
            Value = $InstalledCheckRegValueName;
        }

        #if 64bit OS, check 64bit registry view first
        if ([System.Environment]::Is64BitOperatingSystem) {
            $installValue = Get-RegistryValueIgnoreError @Get-RegistryValueIgnoreErrorParams -RegistryView [Microsoft.Win32.RegistryView]::Registry64;
        }

        if ($null -eq $installValue) {
            $installValue = Get-RegistryValueIgnoreError @Get-RegistryValueIgnoreErrorParams -RegistryView [Microsoft.Win32.RegistryView]::Registry32;
        }

        if ($installValue) {
            if ($InstalledCheckRegValueData -and $installValue -eq $InstalledCheckRegValueData) {
                return @{ Installed = $true; }
            }
        }
    }

    return $null;
} #end function Get-InstalledProductEntry
