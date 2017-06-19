@{
    RootModule        = 'ROSSCommon.psm1'
    ModuleVersion     = '1.0'
    GUID              = 'de2c03b4-3a84-4bdf-9542-3b7dcaa476c4'
    Author            = 'Iain Brighton'
    CompanyName       = 'Virtual Engine'
    Copyright         = '(c) 2016 Virtual Engine Limited. All rights reserved.'
    Description       = 'RES ONE Service Store common DSC resources library'
    PowerShellVersion = '4.0'
    FunctionsToExport = @(
                            'Assert-ParameterCollection',
                            'ConvertTo-PSCustomObjectVersion',
                            'Get-InstalledProductEntry',
                            'Get-LocalizableRegistryKeyValue',
                            'Get-RegistryValueIgnoreError',
                            'Get-WindowsInstallerPackageProperty',,
                            'Resolve-ROSSPackagePath',
                            'Start-WaitProcess'
                        )
}
