function Invoke-ROSSDatabaseQuery {
<#
    .SYNOPSIS
        Executes a SQL server query against a RES ONE Service Store database.
    .NOTES
        Adapted from the VirtualEngine.Database module.
#>
    [CmdletBinding()]
    [OutputType([System.Data.DataRow[]])]
    param (
        # Database connection object.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.Data.Common.DbConnection] $Connection,

        # Transact-SQL query to run
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Query,

        # PSCustomObject type name to apply to the object.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $TypeName = 'VirtualEngine.ROSS.Object',

        # Custom property map to return calculated properties.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $PropertyMap
    )
    process {

        Write-Verbose -Message ($localizedData.InvokingSQLQuery -f $Query);
        $sqlCommand = $Connection.CreateCommand();
        $sqlCommand.CommandText = $Query;

        switch ($Connection.GetType().Name) {

            MySqlConnection {

                [void] [System.Reflection.Assembly]::LoadWithPartialName('MySql.Data');
                $sqlDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($sqlCommand);
            }

            SqlConnection {

                $sqlDataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($sqlCommand);
            }

            Default {

                throw ($localizedData.UnsupportedDbConnectionType -f $Connection.GetType().Name);
            }
        }

        $dataSet = New-Object System.Data.DataSet;
        [ref]$null = $sqlDataAdapter.Fill($dataSet);

        $dataSet.Tables[0] | ForEach-Object {

            $datarow = $_;
            if ($datarow) {

                $datarowPropertyNames = Get-Member -InputObject $datarow -MemberType Property |
                                            Select-Object -ExpandProperty Name;

                $datarowObjectProperties = @{ }
                foreach ($datarowPropertyName in $datarowPropertyNames) {

                    $datarowObjectProperties[$datarowPropertyName] = $datarow.Item($datarowPropertyName);
                }

                ## Add the calculated properties
                if ($PSBoundParameters.ContainsKey('PropertyMap')) {

                    foreach ($propertyName in $PropertyMap.Keys) {

                        $customProperty = $PropertyMap[$propertyName];
                        $propertyValue = $datarow.Item($customProperty['DataSourceColumn']);
                        $datarowObjectProperties[$propertyName] = $propertyValue;
                        if ($null -ne $customProperty.ValueMap) {
                            $datarowObjectProperties[$propertyName] = $customProperty.ValueMap[$propertyValue];
                        }
                    }
                }

                ## Add the custom type name
                $datarowObject = [PSCustomObject] $datarowObjectProperties;
                $datarowObject.PSObject.TypeNames.Insert(0, $TypeName);
                Write-Output -InputObject $datarowObject;

            } #end if datarow
        };

    } #end process
} #end function Invoke-ROSSDatabaseQuery