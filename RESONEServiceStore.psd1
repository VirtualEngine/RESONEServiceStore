@{
    RootModule           = 'RESONEServiceStore.psm1';
    ModuleVersion        = '3.2.0';
    GUID                 = '324e5c64-114f-4879-81e6-63238edcddea';
    Author               = 'Iain Brighton';
    CompanyName          = 'Virtual Engine';
    Copyright            = '(c) 2017 Virtual Engine Limited. All rights reserved.';
    Description          = 'RES ONE Identity Director and Service Store deployment and configuration PowerShell cmdlets and DSC resources. These DSC resources are provided AS IS, and are not supported through any means.';
    AliasesToExport      = @('Get-ROSSOrganisation');
    FormatsToProcess     = @('RESONEServiceStore.Format.ps1xml');
    FunctionsToExport    = @('Connect-ROSSSession',
                             'Disable-ROSSPerson',
                             'Disable-ROSSService',
                             'Disable-ROSSServiceWorkflowAction',
                             'Disconnect-ROSSSession',
                             'Enable-ROSSPerson',
                             'Enable-ROSSService',
                             'Enable-ROSSServiceWorkflowAction',
                             'Export-ROSSBuildingBlock',
                             'Get-ROSSDataConnection',
                             'Get-ROSSDataSource',
                             'Get-ROSSOrganization',
                             'Get-ROSSPerson',
                             'Get-ROSSService',
                             'Get-ROSSTransaction',
                             'Import-ROSSBuildingBlock',
                             'New-ROSSPerson',
                             'Set-ROSSPerson',
                             'Set-ROSSService'
                            );

    <# Removed for WMF 4 compatibilty
    DscResourcesToExport = @('ROSSBuildingBlock','ROSSCatalogServices', 'ROSSClient','ROSSConsole','ROSSDatabase',
                                'ROSSManagementPortal','ROSSTransactionEngine','ROSSWebPortal','ROSSBuildingBlock'); #>

    PrivateData = @{
        PSData = @{
            Tags       = @(
                            'VirtualEngine',
                            'RES',
                            'ONE',
                            'ServiceStore',
                            'ITStore',
                            'DSC',
                            'IdentityDirector',
                            'Identity',
                            'Director'
                         );
            LicenseUri = 'https://github.com/VirtualEngine/RESONEServiceStore/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/RESONEServiceStore';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
