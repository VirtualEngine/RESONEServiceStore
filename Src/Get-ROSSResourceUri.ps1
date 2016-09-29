function Get-ROSSResourceUri {
<#
    .SYNOPSIS
        Returns RES ONE Service Store API endpoint URI.
    .NOTES
        This is an internal method and should not be called directly.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        # RES ONE Service Store session connection
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Service')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchService')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchServiceFilter')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchTransaction')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Person')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchPerson')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Organization')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ListOrganization')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UploadBuildingBlock')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ImportBuildingBlock')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ExportBuildingBlock')]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Return the Service API endpoint URI
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Service')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchService')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchServiceFilter')]
        [System.Management.Automation.SwitchParameter] $Service,

        # Specifies the search to use the Transaction API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Person')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchPerson')]
        [System.Management.Automation.SwitchParameter] $Person,

        # Specifies the search critera on the Service API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchService')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchServiceFilter')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchTransaction')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchPerson')]
        [System.Management.Automation.SwitchParameter] $Search,

        # Specifies the search critera on the Service API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchServiceFilter')]
        [System.String] $Filter,

        # Specifies the search to use the Transaction API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchTransaction')]
        [System.Management.Automation.SwitchParameter] $Transaction,

        # Specifies the search to use the Transaction API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Organization')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ListOrganization')]
        [System.Management.Automation.SwitchParameter] $Organization,

        # Specifies the Import action on the Building Block API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ListOrganization')]
        [System.Management.Automation.SwitchParameter] $List,

        # Return the Building Clock API endpoint URI
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UploadBuildingBlock')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ImportBuildingBlock')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ExportBuildingBlock')]
        [System.Management.Automation.SwitchParameter] $BuildingBlock,

        # Specifies the Import action on the Building Block API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ImportBuildingBlock')]
        [System.Management.Automation.SwitchParameter] $Import,

        # Specifies the Upload action on the Building Block API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UploadBuildingBlock')]
        [System.String] $Upload,

        # Specifies the Import action on the Building Block API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ExportBuildingBlock')]
        [System.Management.Automation.SwitchParameter] $Export,

        # Return the Authentication API endpoint URI
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Authentication')]
        [System.Management.Automation.SwitchParameter] $Authentication,

        # Specifies the server hostname hosting the RES ONE Service Store API to perform the authentication action against
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Authentication')]
        [System.String] $Server,

        # Specifies connections to the RES ONE Service Store API should used an encrypted connection
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Authentication')]
        [System.Management.Automation.SwitchParameter] $UseHttps

    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Authentication') {

            $Session = @{
                Server = $Server;
                UseHttps = $UseHttps.ToBool();
            }
        }
        else {

            Assert-ROSSSession -Session $Session;
        }
    }
    process {

        $fqdn = 'http://{0}' -f $Session.Server;
        if ($Session.UseHttps) {
            $fqdn = 'https://{0}' -f $Session.Server;
        }

        switch ($PSCmdlet.ParameterSetName) {

            Authentication {
                return "$fqdn/Management/PublicApi/Authentication/Login";
            }

            Service {
                return "$fqdn/Management/PublicApi/Service";
            }

            SearchService {
                return "$fqdn/Management/PublicApi/Service/Search";
            }

            SearchServiceFilter {
                $escapedFilter = [System.Uri]::EscapeUriString($Filter);
                return "$fqdn/Management/PublicApi/Service/Search?request.freeTextFilter=$escapedFilter";
            }

            ImportBuildingBlock {
                return "$fqdn/Management/PublicApi/BuildingBlock/Import";
            }

            UploadBuildingBlock {
                 $escapedFilename = [System.Uri]::EscapeUriString($Upload);
                 return "$fqdn/Management/PublicApi/BuildingBlock/Upload?fileName=$escapedFilename";
            }

            ExportBuildingBlock {
                return "$fqdn/Management/PublicApi/BuildingBlock/Export";
            }

            SearchTransaction {
                return "$fqdn/Management/PublicApi/Transaction/Search";
            }

            Person {
                return "$fqdn/Management/PublicApi/Person";
            }

            SearchPerson {
                return "$fqdn/Management/PublicApi/Person/Search";
            }

            Organization {
                return "$fqdn/Management/PublicApi/Organization";
            }

            ListOrganization {
                return "$fqdn/Management/PublicApi/Organization/List";
            }

        }

    } #end process
} #end function Get-ROSSResourceUri
