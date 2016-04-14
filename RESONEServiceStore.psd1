@{
    ModuleVersion = '1.0.2';
    GUID = '324e5c64-114f-4879-81e6-63238edcddea';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description = 'RES ONE Service Store composite DSC resourecs. These DSC resources are provided AS IS, and are not supported through any means.';
    DscResourcesToExport = @('ROSSCatalogServices', 'ROSSClient', 'ROSSConsole', 'ROSSDatabase', 'ROSSLab', 'ROSSManagementPortal',
                             'ROSSTransactionEngine', 'ROSSWebPortal');
    PrivateData = @{
        PSData = @{
            Tags = @('VirtualEngine','RES','ONE','ServiceStore','ITStore','DSC');
            LicenseUri = 'https://github.com/VirtualEngine/RESONEServiceStore/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/RESONEServiceStore';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
