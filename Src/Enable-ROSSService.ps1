function Enable-ROSSService {
<#
    .SYNOPSIS
        Enables RES ONE Service Store service transactions.
    .NOTES
        The RES ONE Service Store API performs a wildcard search on the service name when specified.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Name')]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Id')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [System.Collections.Hashtable] $Session = $Script:_RESONEServiceStoreSession,

        # Specifies RES ONE Service Store service(s) to enable by Id.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Id')]
        [System.String[]] $Id,

        # Specifies RES ONE Service Store service(s) to enable by name.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [System.String[]] $Name,

        # Specifies RES ONE Service Store service(s) to enable by reference.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [PSCustomObject[]] $InputObject,

        # Returns the updated RES ONE Service Store service object to the pipeline.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Id')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [System.Management.Automation.SwitchParameter] $PassThru,

        # Specifies any comfirmation prompts should be suppressed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Assert-ROSSSession -Session $Session;
    }
    process {

        if ($PSCmdlet.ParameterSetName -eq 'Id') {

            $InputObject = Get-ROSSService -Session $Session -Id $Id;
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Name') {

            $InputObject = Get-ROSSService -Session $Session -Name $Name;
        }

        foreach ($service in $InputObject) {

            if ($Force -or ($PSCmdlet.ShouldProcess($service.Name, $localizedData.ShouldProcessEnable))) {

                $service.EnableTransactions = $true;
                $setROSSServiceParams = @{
                    Session = $Session;
                    InputObject = $service;
                    Force = $Force;
                    Confirm = $false;
                }
                Set-ROSSService @setROSSServiceParams;

                if ($PassThru) {
                    ## Set-ROSSSession only returns the Service.Id so we'll have to fetch it
                    Get-ROSSService -Session $Session -Id $service.Id;
                }
            }
        }

    } #end process
} #end function Enable-ROSSService
