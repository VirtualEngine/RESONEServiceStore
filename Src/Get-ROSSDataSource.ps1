function Get-ROSSDataSource {
<#
    .SYNOPSIS
        Queries the RES ONE Service Store database for Data Sources.
#>
    [CmdletBinding()]
    [OutputType('VirtualEngine.ROSS.DataSource')]
    param (
        # RES ONE Service Store session connection.
        [Parameter()]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # RES ONE Service Store organization context name.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String[]] $Name,

        ## RES ONE Service Store data source type.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('CSV','ActiveDirectory','ODBC')]
        [System.String] $Type
    )
    begin {

        Assert-ROSSSession -Session $Session -Database;
    }
    process {

        try {

            $typeName = 'VirtualEngine.ROSS.DataSource';
            $query = 'SELECT * FROM [OR_Objects] WHERE [Type] = 19';

            if ($PSBoundParameters.ContainsKey('Type')) {

                $dataConnectionType = $customProperties[$typeName].Type.ValueMap.Keys |
                    ForEach-Object {
                        if ($customProperties[$typeName].Type.ValueMap[$_] -eq $Type) { $_ }
                    }
                $query = '{0} AND SPECIFICFLAGS = {1}' -f $query, $dataConnectionType;
            }

            $invokeROSSDatabaseQueryParams = @{
                Connection = $Session.DbConnection;
                TypeName = $typeName;
                PropertyMap = $customProperties[$typeName];
            }

            if ($PSBoundParameters.ContainsKey('Name')) {

                foreach ($dataConnectionName in $Name) {

                    $nameQuery = "{0} AND Name = '{1}'" -f $query, $dataConnectionName;
                    $invokeROSSDatabaseQueryParams['Query'] = $nameQuery;
                    Write-Output -InputObject (Invoke-ROSSDatabaseQuery @invokeROSSDatabaseQueryParams);
                }
            }
            else {

                $invokeROSSDatabaseQueryParams['Query'] = $query;
                Write-Output -InputObject (Invoke-ROSSDatabaseQuery @invokeROSSDatabaseQueryParams);
            }

        }
        catch {

            throw $_;
        }

    } #end process
} #end function Get-ROSSDataSource
