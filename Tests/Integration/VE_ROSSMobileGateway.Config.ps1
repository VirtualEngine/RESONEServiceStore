configuration VE_ROSSMobileGateway_Config 
{
    param
    (
        ## IIS website host header/name, i.e. res.lab.local.
        [Parameter(Mandatory)]
        [System.String] $HostHeader,

        ## File path containing the RES ONE Service Store MSIs or the literal path to the management portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Installed certificate thumbprint to bind to the IIS site.
        [Parameter(Mandatory)]
        [System.String] $CertificateThumbprint
    )

    Import-DscResource -ModuleName RESONEServiceStore

    node localhost {

        ROSSMobileGateway Integration_Test {
            Path                  = $Path
            HostHeader            = $HostHeader
            CertificateThumbprint = $CertificateThumbprint
        }
    }

}
