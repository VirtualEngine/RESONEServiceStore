function Remove-ROSSDataSource {
<#
    .SYNOPSIS
        Deletes a RES ONE Service Store Data Source.
    .NOTES
        THIS IS AN UNSUPPORTED DATABASE OPERATION AND THIS METHOD SHOULD NOT BE CALLED DIRECTLY.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'InputObject')]
    [OutputType('VirtualEngine.ROSS.DataSource')]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'InputObject')]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # RES ONE Service Store data source reference object.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [PSCustomObject[]] $InputObject,

        # RES ONE Service Store data source name.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [System.String[]] $Name,

        ## RES ONE Service Store data source type.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [ValidateSet('CSV','ActiveDirectory','ODBC')]
        [System.String] $Type,

        # Returns an object representing the data source with which you are working. By default, this cmdlet does not generate any output.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [System.Management.Automation.SwitchParameter] $PassThru,

        # Specifies any comfirmation prompts should be suppressed.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Write-Warning -Message ($localizedData.UnsupportedOperationWarning -f $MyInvocation.MyCommand);
        Assert-ROSSSession -Session $Session -Database;
    }
    process {

        $typeName = 'VirtualEngine.ROSS.DataSource';

        if ($PSCmdlet.ParameterSetName -eq 'Name') {

            [ref] $null = $PSBoundParameters.Remove('PassThru');
            [ref] $null = $PSBoundParameters.Remove('Force');
            [ref] $null = $PSBoundParameters.Remove('WhatIf');
            $InputObject = Get-ROSSDataSource @PSBoundParameters;
        }

        foreach ($dataSource in $InputObject) {

            if ($dataSource.PSTypeNames -notcontains $typeName) {

                $exceptionMessage = $localizedData.InputObjectTypeMismatchError -f $typeName;
                $exception = New-Object System.ArgumentException $exceptionMessage;
                $category = [System.Management.Automation.ErrorCategory]::InvalidData;
                $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'TypeMismatch', $category, $dataSource;
                $psCmdlet.WriteError($errorRecord);
                continue;
            }

            if (($Force -and (-not $PSBoundParameters.ContainsKey('WhatIf'))) -or
                ($PSCmdlet.ShouldProcess($dataSource.Name, $localizedData.ShouldProcessDelete))) {

                try {

                    $query = "DELETE FROM [OR_Objects] WHERE [Type] = 19 AND [Guid] = '{0}'" -f $dataSource.Guid;

                    $invokeROSSDatabaseQueryParams = @{
                        Connection = $Session.DbConnection;
                        Query = $query;
                    }
                    [ref] $null = Invoke-ROSSDatabaseQuery @invokeROSSDatabaseQueryParams;

                    if ($PassThru) {

                        Write-Output -InputObject $dataSource;
                    }
                }
                catch {

                    throw $_;
                }
            }

        } #end foreach datasource

    } #end process
} #end function Remove-ROSSDataSource
