function Remove-ROSSDataConnection {
<#
    .SYNOPSIS
        Deletes a RES ONE Service Store Data Connection.
    .NOTES
        This is an unsupported operation and should not be called directly.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'InputObject')]
    [OutputType('VirtualEngine.ROSS.DataConnection')]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'InputObject')]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # RES ONE Service Store data connection reference object.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [PSCustomObject[]] $InputObject,

        # RES ONE Service Store data connection name.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [System.String[]] $Name,

        ## RES ONE Service Store data connection type.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [ValidateSet('CSV','ActiveDirectory','ODBC')]
        [System.String] $Type,

        # Returns an object representing the data connection with which you are working. By default, this cmdlet does not generate any output.
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

        $typeName = 'VirtualEngine.ROSS.DataConnection';

        if ($PSCmdlet.ParameterSetName -eq 'Name') {

            [ref] $null = $PSBoundParameters.Remove('PassThru');
            [ref] $null = $PSBoundParameters.Remove('Force');
            [ref] $null = $PSBoundParameters.Remove('WhatIf');
            $InputObject = Get-ROSSDataConnection @PSBoundParameters;
        }

        foreach ($dataConnection in $InputObject) {

            if ($dataConnection.PSTypeNames -notcontains $typeName) {

                $exceptionMessage = $localizedData.InputObjectTypeMismatchError -f $typeName;
                $exception = New-Object System.ArgumentException $exceptionMessage;
                $category = [System.Management.Automation.ErrorCategory]::InvalidData;
                $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'TypeMismatch', $category, $dataConnection;
                $psCmdlet.WriteError($errorRecord);
                continue;
            }

            if (($Force -and (-not $PSBoundParameters.ContainsKey('WhatIf'))) -or
                ($PSCmdlet.ShouldProcess($dataConnection.Name, $localizedData.ShouldProcessDelete))) {

                try {

                    $query = "DELETE FROM [OR_DataLinks] WHERE [Guid] = '{0}'" -f $dataConnection.Guid;

                    $invokeROSSDatabaseQueryParams = @{
                        Connection = $Session.DbConnection;
                        Query = $query;
                    }
                    [ref] $null = Invoke-ROSSDatabaseQuery @invokeROSSDatabaseQueryParams;

                    if ($PassThru) {

                        Write-Output -InputObject $dataConnection;
                    }
                }
                catch {

                    throw $_;
                }
            }

        } #end foreach datasource

    } #end process
} #end function Remove-ROSSDataConnection
