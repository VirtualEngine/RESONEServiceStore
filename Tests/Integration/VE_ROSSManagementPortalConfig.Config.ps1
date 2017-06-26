configuration VE_ROSSManagementPortalConfig_Config 
{
    param
    (
        ## File path of the RES ONE Service Store Management Portal configuration file.
        [Parameter(Mandatory)]
        [System.String] $Path
    )

    Import-DscResource -ModuleName RESONEServiceStore

    node localhost {

        ROSSManagementPortalConfig Integration_Test {
            Path           = $Path
            DatabaseServer = 'res.lab.local';
            DatabaseName   = 'RESONEIdentityDirector'
        }
    }

}
