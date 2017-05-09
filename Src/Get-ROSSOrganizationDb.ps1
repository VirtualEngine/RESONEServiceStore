function Get-ROSSOrganizationDb {
<#
    .SYNOPSIS
        Queries the RES ONE Service Store database for Organizational Contexts.
#>
    [CmdletBinding()]
    [OutputType('VirtualEngine.ROSS.Organization')]
    param (
        # RES ONE Service Store session connection.
        [Parameter()]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # RES ONE Service Store organization context name.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String[]] $Name,

        # Select only root organizational contexts.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Root
    )
    begin {

        Assert-ROSSSession -Session $Session -Database;
    }
    process {

        try {

            $typeName = 'VirtualEngine.ROSS.Organization';
            $query = "SELECT * FROM [OR_Objects] WHERE [Type] = 3";

            if ($Root) {

                $query = "{0} AND [RootGuid] = '00000000-0000-0000-0000-000000000000'" -f $query;
            }

            if ($PSBoundParameters.ContainsKey('Name')) {

                foreach ($organizationName in $Name) {

                    $nameQuery = "{0} AND Name = '{1}'" -f $query, $organizationName;
                    $invokeROSSDatabaseQueryParams = @{
                        Connection = $Session.DbConnection;
                        Query = $nameQuery;
                        TypeName = $typeName;
                    }
                    Write-Output -InputObject (Invoke-ROSSDatabaseQuery @invokeROSSDatabaseQueryParams);
                }
            }
            else {

                $invokeROSSDatabaseQueryParams = @{
                    Connection = $Session.DbConnection;
                    Query = $query;
                    TypeName = $typeName;
                }
                Write-Output -InputObject (Invoke-ROSSDatabaseQuery @invokeROSSDatabaseQueryParams);
            }

        }
        catch {

            throw;
        }

    } #end process
} #end function
