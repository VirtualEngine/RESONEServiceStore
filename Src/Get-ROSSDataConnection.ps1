function Get-ROSSDataConnection {
<#
    .SYNOPSIS
        Queries the RES ONE Service Store database for Data Connections.
#>
    [CmdletBinding()]
    [OutputType('VirtualEngine.ROSS.DataConnection')]
    param (
        # RES ONE Service Store session connection.
        [Parameter()]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # RES ONE Service Store organization context name.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String[]] $Name,

        ## RES ONE Service Store data connection type
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Attribute','Classification','Organization','People')]
        [System.String] $Type
    )
    begin {

        Assert-ROSSSession -Session $Session -Database;
    }
    process {

        try {

            $typeName = 'VirtualEngine.ROSS.DataConnection';
            $query = 'SELECT * FROM [OR_DataLinks]';

            if ($PSBoundParameters.ContainsKey('Type')) {

                $dataConnectionType = $customProperties[$typeName].Type.ValueMap.Keys |
                    ForEach-Object {
                        if ($customProperties[$typeName].Type.ValueMap[$_] -eq $Type) { $_ }
                    }
                $query = '{0} WHERE TYPE = {1}' -f $query, $dataConnectionType;
            }

            $invokeROSSDatabaseQueryParams = @{
                Connection = $Session.DbConnection;
                TypeName = $typeName;
                PropertyMap = $customProperties[$typeName];
            }

            if (($PSBoundParameters.ContainsKey('Name')) -and
                ($PSBoundParameters.ContainsKey('Type'))) {

                foreach ($dataConnectionName in $Name) {

                    $nameQuery = "{0} AND Name = '{1}'" -f $query, $dataConnectionName;
                    $invokeROSSDatabaseQueryParams['Query'] = $nameQuery;
                    Write-Output -InputObject (Invoke-ROSSDatabaseQuery @invokeROSSDatabaseQueryParams);
                }
            }
            elseif ($PSBoundParameters.ContainsKey('Name')) {

                foreach ($dataConnectionName in $Name) {

                    $nameQuery = "{0} WHERE Name = '{1}'" -f $query, $dataConnectionName;
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
} #end function Get-ROSSDataConnection
