function Remove-ROSSOrganization {
<#
    .SYNOPSIS
        Deletes a RES ONE Service Store Organizational Context.
    .NOTES
        THIS IS AN UNSUPPORTED DATABASE OPERATION AND THIS METHOD SHOULD NOT BE CALLED DIRECTLY.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'InputObject')]
    [OutputType('VirtualEngine.ROSS.Organization')]
    [Alias('Remove-ROSSOrganisation')]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'InputObject')]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # RES ONE Service Store organization context reference object.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [PSCustomObject[]] $InputObject,

        # RES ONE Service Store organization context name.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [System.String[]] $Name,

        # RES ONE Service Store organization context name.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [System.String[]] $Path,

        # Perform a regular expression match on name or path parameter.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [System.Management.Automation.SwitchParameter] $Match,

        # Returns an object representing the organization context with which you are working. By default, this cmdlet does not generate any output.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [System.Management.Automation.SwitchParameter] $PassThru,

        # Specifies any comfirmation prompts should be suppressed.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Write-Warning -Message ($localizedData.UnsupportedOperationWarning -f $MyInvocation.MyCommand);
        Assert-ROSSSession -Session $Session -Database;
    }
    process {

        $typeName = 'VirtualEngine.ROSS.Organization';

        if (($PSCmdlet.ParameterSetName -eq 'Name') -or ($PSCmdlet.ParameterSetName -eq 'Path')) {

            [ref] $null = $PSBoundParameters.Remove('PassThru');
            [ref] $null = $PSBoundParameters.Remove('Force');
            [ref] $null = $PSBoundParameters.Remove('WhatIf');
            $InputObject = Get-ROSSOrganization @PSBoundParameters;
        }

        foreach ($organization in $InputObject) {

            if ($organization.PSTypeNames -notcontains $typeName) {

                $exceptionMessage = $localizedData.InputObjectTypeMismatchError -f $typeName;
                $exception = New-Object System.ArgumentException $exceptionMessage;
                $category = [System.Management.Automation.ErrorCategory]::InvalidData;
                $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'TypeMismatch', $category, $organization;
                $psCmdlet.WriteError($errorRecord);
                continue;
            }

            if (($Force -and (-not $PSBoundParameters.ContainsKey('WhatIf'))) -or
                ($PSCmdlet.ShouldProcess($organization.Name, $localizedData.ShouldProcessDelete))) {

                try {

                    ## If we called the API we'll have an OrganizationId property so prefer that
                    $organizationId = $organization.OrganizationId;
                    if ([System.String]::IsNullOrEmpty($organizationId)) {
                        ## If we called Get-ROSSOrganizationDb, we'll have a Guid property so use that instead
                        $organizationId = $organization.Guid;
                    }

                    $query = "DELETE FROM [OR_Objects] WHERE [Type] = 3 AND [Guid] = '{0}'" -f $organizationId;

                    $invokeROSSDatabaseQueryParams = @{
                        Connection = $Session.DbConnection;
                        Query = $query;
                    }
                    [ref] $null = Invoke-ROSSDatabaseQuery @invokeROSSDatabaseQueryParams;

                    if ($PassThru) {

                        Write-Output -InputObject $organization;
                    }
                }
                catch {

                    throw;
                }
            }

        } #end foreach organization

    } #end process
} #end function
