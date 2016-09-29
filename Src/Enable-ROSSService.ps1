function Enable-ROSSService {
<#
    .SYNOPSIS
        Enables RES ONE Service Store service transactions.
    .EXAMPLE
        Enable-ROSSService -ServiceName 'Sales'

        Enables all services with a name matching 'Sales'.
    .EXAMPLE
        Enable-ROSSService -ServiceId 'a13003e7-3c51-4c22-9c9e-0a8210813ed1'

        Enables the service with the 'a13003e7-3c51-4c22-9c9e-0a8210813ed1' identifier.
    .NOTES
        The RES ONE Service Store API performs a wildcard search on the service name when specified.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Name')]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceId')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [System.Collections.Hashtable] $Session = $Script:_RESONEServiceStoreSession,

        # Specifies RES ONE Service Store service(s) to enable by name.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceName')]
        [System.String[]] $ServiceName,

        # Specifies RES ONE Service Store service(s) to enable by ServiceId.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceId')]
        [System.String[]] $ServiceId,

        # Specifies RES ONE Service Store service(s) to enable by reference.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [PSCustomObject[]] $InputObject,

        # Returns the updated RES ONE Service Store service object to the pipeline.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceId')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceName')]
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

        if ($PSCmdlet.ParameterSetName -eq 'ServiceId') {

            $InputObject = Get-ROSSService -Session $Session -ServiceId $ServiceId;
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ServiceName') {

            $InputObject = Get-ROSSService -Session $Session -ServiceName $ServiceName;
        }

        try {

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
                        ## Set-ROSSSession only returns the Service.ServiceId so we'll have to fetch it
                        Write-Output -InputObject (Get-ROSSService -Session $Session -ServiceId $service.Id);
                    }
                }
            }
        }
        catch {

            throw $_;
        }

    } #end process
} #end function Enable-ROSSService
