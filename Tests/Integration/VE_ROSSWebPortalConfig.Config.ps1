configuration VE_ROSSWebPortalConfig_Config 
{
    param
    (
        ## File path of the RES ONE Service Store Management Portal configuration file.
        [Parameter(Mandatory)]
        [System.String] $Path
    )

    Import-DscResource -ModuleName RESONEServiceStore

    node localhost {

        ROSSWebPortalConfig Integration_Test {
            Path           = $Path
            DatabaseServer = 'res.lab.local';
            DatabaseName   = 'RESONEIdentityDirector'
        }
    }

}
