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
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NewPerson')]
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

        # Return the Person API endpoint URI
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Person')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchPerson')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'NewPerson')]
        [System.Management.Automation.SwitchParameter] $Person,

        # Specifies the New action on the Person API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'NewPerson')]
        [System.Management.Automation.SwitchParameter] $New,

        # Specifies the search critera on the API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchService')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchServiceFilter')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchTransaction')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchPerson')]
        [System.Management.Automation.SwitchParameter] $Search,

        # Specifies the search filter on the Search API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchServiceFilter')]
        [System.String] $Filter,

        # Return the Transaction API endpoint URI
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchTransaction')]
        [System.Management.Automation.SwitchParameter] $Transaction,

        # Return the Organization API endpoint URI
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Organization')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ListOrganization')]
        [System.Management.Automation.SwitchParameter] $Organization,

        # Specifies the List action on the Organization API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ListOrganization')]
        [System.Management.Automation.SwitchParameter] $List,

        # Return the Building Block API endpoint URI
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

        # Connect to the IdentityDirector API endpoint
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Authentication')]
        [System.Management.Automation.SwitchParameter] $IdentityDirector,

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
                IsIdentityDirector = $IdentityDirector.ToBool();
            }
        }
        else {

            Assert-ROSSSession -Session $Session;
        }
    }
    process {

        if ($Session.IsIdentityDirector) {
            
            $apiEndpoint = '{0}/IdentityDirector' -f $Session.Server;
        }
        else {
            
            $apiEndpoint = '{0}/Management' -f $Session.Server;
        }

        if ($Session.UseHttps) {

            $fqdn = 'https://{0}' -f $apiEndpoint;
        }
        else {

            $fqdn = 'http://{0}' -f $apiEndpoint;
        }

        switch ($PSCmdlet.ParameterSetName) {

            Authentication {

                $apiUri = 'PublicApi/Authentication/Login';
            }

            Service {

                $apiUri = 'PublicApi/Service';
            }

            SearchService {

                $apiUri = 'PublicApi/Service/Search';
            }

            SearchServiceFilter {

                $escapedFilter = [System.Uri]::EscapeUriString($Filter);
                $apiUri = 'PublicApi/Service/Search?request.freeTextFilter={0}' -f $escapedFilter;
            }

            ImportBuildingBlock {

                $apiUri = 'PublicApi/BuildingBlock/Import';
            }

            UploadBuildingBlock {

                 $escapedFilename = [System.Uri]::EscapeUriString($Upload);
                 $apiUri = 'PublicApi/BuildingBlock/Upload?fileName={0}' -f $escapedFilename;
            }

            ExportBuildingBlock {

                $apiUri = 'PublicApi/BuildingBlock/Export';
            }

            SearchTransaction {

                $apiUri = 'PublicApi/Transaction/Search';
            }

            Person {

                $apiUri = 'PublicApi/Person';
            }

            SearchPerson {

                $apiUri = 'PublicApi/Person/Search';
            }

            NewPerson {

                $apiUri = 'PublicApi/Person/New';
            }

            Organization {

                $apiUri = 'PublicApi/Organization';
            }

            ListOrganization {

                $apiUri = 'PublicApi/Organization/List';
            }

        }

        return ('{0}/{1}' -f $fqdn, $apiUri);

    } #end process
} #end function Get-ROSSResourceUri
