configuration VE_ROSSManagementPortal_Config 
{
    param
    (
        ## File path containing the RES ONE Service Store Catalog Services MSIs or the literal path to the web portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## IIS website host header, i.e. http://itstore.lab.local (v9.1 and ealier) or res.lab.local (v10 and later).
        ## NOTE: equivalent to the ITSTOREHOSTNAME and HOST_SSL parameters.
        [Parameter(Mandatory)]
        [System.String] $HostHeader
    )

    Import-DscResource -ModuleName RESONEServiceStore

    node localhost {

        ROSSManagementPortal Integration_Test {
            Path       = $Path
            HostHeader = $HostHeader
        }
    }

}
