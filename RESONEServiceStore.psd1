@{
    RootModule           = 'RESONEServiceStore.psm1';
    ModuleVersion        = '2.2.0';
    GUID                 = '324e5c64-114f-4879-81e6-63238edcddea';
    Author               = 'Iain Brighton';
    CompanyName          = 'Virtual Engine';
    Copyright            = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description          = 'RES ONE Service Store deployment and configuration PowerShell cmdlets and DSC resources. These DSC resources are provided AS IS, and are not supported through any means.';
    AliasesToExport      = @('Get-ROSSOrganisation');
    FormatsToProcess     = @('RESONEServiceStore.Format.ps1xml');
    FunctionsToExport    = @('Connect-ROSSSession','Disable-ROSSService','Disable-ROSSServiceWorkflowAction',
                                'Disconnect-ROSSSession','Enable-ROSSService','Enable-ROSSServiceWorkflowAction',
                                'Export-ROSSBuildingBlock','Get-ROSSService','Get-ROSSTransaction',
                                'Import-ROSSBuildingBlock','Set-ROSSService','Get-ROSSOrganization',
                                'Get-ROSSDataConnection','Get-ROSSDataSource');

    <# Removed for WMF 4 compaitibilty
    DscResourcesToExport = @('ROSSBuildingBlock','ROSSCatalogServices', 'ROSSClient','ROSSConsole','ROSSDatabase',
                                'ROSSManagementPortal','ROSSTransactionEngine','ROSSWebPortal','ROSSBuildingBlock'); #>

    PrivateData = @{
        PSData = @{
            Tags       = @('VirtualEngine','RES','ONE','ServiceStore','ITStore','DSC');
            LicenseUri = 'https://github.com/VirtualEngine/RESONEServiceStore/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/RESONEServiceStore';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
